const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const AppError = require('../utils/AppError');
const { bus } = require('../services/realtime/eventBus');
const { buildReplyEnvelope } = require('../services/messageReplyEnvelope');
const { buildEntityShareEnvelope, isSupportedShareType, batchEntityShareEnvelopes } = require('../services/entityShareEnvelope');
const { scoreCandidateForJob } = require('../services/matchScoring');
const { rankJobs } = require('../services/jobRanking');
const storage = require('../storage');

// ---------------------------------------------------------------------------
// Candidate Quick Jobs daily swipe cap
// ---------------------------------------------------------------------------
// Server-side enforced cap on how many cards a candidate can swipe in a
// single UTC day. Plan-aware: cap is derived from the candidate's
// users.subscription_plan. Unknown / null plans fall back to 'free'.
//
// Both interested=true and interested=false swipes count: we want the
// cap to throttle deck consumption regardless of direction so no one can
// burn the deck by mass-passing.
const PLAN_QUOTA_MAP = {
  free: 5,
  basic: 5,
  pro: 20,
  premium: 999,
};

function resolvePlanLimit(plan) {
  const key = (plan || 'free').toLowerCase();
  return PLAN_QUOTA_MAP[key] ?? PLAN_QUOTA_MAP.free;
}

// UTC midnight for "today" — matches the index on
// candidate_quickjob_swipes(candidate_id, swiped_at) without leaking
// per-tenant timezone state into the cap definition.
function utcDayStart(d = new Date()) {
  return new Date(Date.UTC(
    d.getUTCFullYear(),
    d.getUTCMonth(),
    d.getUTCDate(),
    0, 0, 0, 0,
  ));
}

// Resolves the daily Quick Jobs swipe cap for a candidate. Joins
// candidates → users to read subscription_plan, maps it via
// PLAN_QUOTA_MAP, and returns the count of swipes consumed today plus
// the derived remaining / reached fields the deck and swipe endpoints
// surface to Flutter. Falls back to 'free' if the plan is missing.
async function resolveQuickjobSwipeQuota(candidateId) {
  const planRow = await db('candidates')
    .join('users', 'users.id', 'candidates.user_id')
    .where('candidates.id', candidateId)
    .select('users.subscription_plan as plan')
    .first();
  const plan = planRow?.plan || 'free';
  const dailyLimit = resolvePlanLimit(plan);
  const since = utcDayStart();
  const row = await db('candidate_quickjob_swipes')
    .where({ candidate_id: candidateId })
    .andWhere('swiped_at', '>=', since)
    .count({ n: '*' })
    .first();
  const swipesUsed = parseInt(row?.n, 10) || 0;
  const swipesRemaining = Math.max(dailyLimit - swipesUsed, 0);
  const hasReachedLimit = swipesUsed >= dailyLimit;
  return { dailyLimit, swipesUsed, swipesRemaining, hasReachedLimit, plan };
}

// Helper: create a hiring notification + emit SSE so every subscribed
// notifications provider (candidate, business, admin) refreshes its
// badge + list in real time without a pull-to-refresh.
async function hiringNotify(recipientId, title, type, linkedEntity, route, body) {
  try {
    await db('notifications').insert({
      recipient_id: recipientId,
      notification_type: type || 'in_app',
      title,
      body: body || null,
      linked_entity: linkedEntity || null,
      destination_route: route || null,
      delivery_state: 'delivered',
      is_read: false,
    });
    bus.publish('notification.new', {
      recipient_user_id: recipientId,
      title,
      body: body || null,
      notification_type: type || 'in_app',
      linked_entity: linkedEntity || null,
      destination_route: route || null,
    }, ['role:admin', `user:${recipientId}`]);
  } catch (e) { /* ignore */ }
}

// Persist a notification row for every admin user so the audit feed
// reflects platform-wide events (apply, hire decisions, interviews,
// messages). SSE audience `role:admin` keeps live admin clients fresh.
async function notifyAllAdmins(title, type, linkedEntity, route, body) {
  try {
    const admins = await db('users').where({ user_type: 'admin' }).select('id');
    for (const a of admins) {
      await hiringNotify(a.id, title, type, linkedEntity, route, body);
    }
  } catch (e) { console.error('[notifyAllAdmins]', e.message); }
}

// Mutual-interest match creation. Mirrors the helper in
// businessController.js — kept inline here so the candidate apply
// flow does not need to require the business controller. Idempotent
// on the (business_id, candidate_id, job_id) unique index, so it is
// safe to call from either side of the interest pair.
async function tryCreateMutualMatch({
  businessId,
  candidateId,
  jobId,
  sourceBusiness,
  sourceCandidate,
}) {
  if (!businessId || !candidateId || !jobId) return false;
  try {
    const existing = await db('mutual_matches')
      .where({
        business_id: businessId,
        candidate_id: candidateId,
        job_id: jobId,
      })
      .first();
    if (existing) return false;

    const [row] = await db('mutual_matches')
      .insert({
        business_id: businessId,
        candidate_id: candidateId,
        job_id: jobId,
        source_business: sourceBusiness || 'quickplug',
        source_candidate: sourceCandidate || 'application',
        status: 'active',
      })
      .returning(['id', 'created_at']);

    const [biz, cand, job] = await Promise.all([
      db('businesses').where({ id: businessId }).first(),
      db('candidates').where({ id: candidateId }).first(),
      db('jobs').where({ id: jobId }).first(),
    ]);

    const bizName = biz?.name || 'A business';
    const candName = cand?.name || 'a candidate';
    const jobTitle = job?.title || 'a role';

    if (cand?.user_id) {
      await hiringNotify(
        cand.user_id,
        `You matched with ${bizName}`,
        'in_app',
        row.id,
        'match',
        `Mutual interest on ${jobTitle}.`,
      );
    }
    if (biz?.user_id) {
      await hiringNotify(
        biz.user_id,
        `You matched with ${candName}`,
        'in_app',
        row.id,
        'match',
        `Mutual interest on ${jobTitle}.`,
      );
    }
    await notifyAllAdmins(
      `New match: ${bizName} ↔ ${candName} on ${jobTitle}`,
      'in_app',
      row.id,
      'match',
      null,
    );

    bus.publish(
      'match.created',
      {
        match_id: row.id,
        business_id: businessId,
        business_name: bizName,
        candidate_id: candidateId,
        candidate_user_id: cand?.user_id || null,
        candidate_name: candName,
        job_id: jobId,
        job_title: jobTitle,
        source_business: sourceBusiness || 'quickplug',
        source_candidate: sourceCandidate || 'application',
        created_at: row.created_at,
      },
      [
        'role:admin',
        ...(cand?.user_id ? [`user:${cand.user_id}`] : []),
        ...(biz?.user_id ? [`user:${biz.user_id}`] : []),
      ],
    );

    return true;
  } catch (e) {
    console.error('[tryCreateMutualMatch]', e.message);
    return false;
  }
}

// ---------------------------------------------------------------------------
// GET /candidate/profile — Return the authenticated candidate's profile
// ---------------------------------------------------------------------------
async function profile(req, res, next) {
  try {
    const user = await db('users').where({ id: req.user.id }).first();
    if (!user) throw AppError.notFound('User not found.');

    // Try to load the extended candidate row (may not exist yet)
    const candidate = await db('candidates').where({ user_id: user.id }).first();

    ok(res, {
      id: user.id,
      name: user.name,
      initials: user.initials || user.name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2),
      email: user.email,
      phone: user.phone,
      location: user.location,
      role: user.role,
      status: user.status,
      is_verified: user.is_verified,
      profile_strength: user.profile_strength || 0,
      avatar_hue: user.avatar_hue || 0.5,
      photo_url: user.photo_url || null,
      // Extended candidate fields (nullable until profile is completed)
      experience: candidate?.experience || null,
      languages: candidate?.languages || null,
      job_type: candidate?.job_type || null,
      bio: candidate?.bio || null,
      start_date: candidate?.start_date || null,
      available_to_relocate: candidate?.available_to_relocate || false,
      verification_status: candidate?.verification_status || 'new',
      created_at: user.created_at,
      // Subscription
      subscription_plan: user.subscription_plan || 'free',
      subscription_status: user.subscription_status || 'inactive',
      subscription_expires: user.subscription_expires || null,
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/home — Aggregated dashboard data in a single call
// ---------------------------------------------------------------------------
async function home(req, res, next) {
  try {
    const userId = req.user.id;

    // Find the candidate row linked to this user
    const candidate = await db('candidates').where({ user_id: userId }).first();
    const candidateId = candidate?.id || null;

    // ---- Applications summary ----
    let applicationsSummary = { total: 0, under_review: 0, interview: 0, offer: 0 };
    if (candidateId) {
      const rows = await db('applications')
        .where({ candidate_id: candidateId })
        .select('status')
        .then(rows => rows);
      applicationsSummary.total = rows.length;
      applicationsSummary.under_review = rows.filter(r => r.status === 'under_review' || r.status === 'shortlisted').length;
      applicationsSummary.interview = rows.filter(r => r.status === 'interview').length;
      applicationsSummary.offer = rows.filter(r => r.status === 'offer').length;
    }

    // ---- Next interview ----
    let nextInterview = null;
    if (candidateId) {
      nextInterview = await db('interviews')
        .where({ candidate_id: candidateId })
        .whereIn('status', ['pending', 'confirmed'])
        .where('scheduled_at', '>', db.fn.now())
        .orderBy('scheduled_at', 'asc')
        .first();

      if (nextInterview) {
        // Attach job title
        const job = await db('jobs').where({ id: nextInterview.job_id }).select('title', 'location').first();
        nextInterview.job_title = job?.title || 'Unknown';
        nextInterview.job_location = job?.location || '';
      }
    }

    // ---- Unread messages count ----
    let unreadMessages = 0;
    if (candidateId) {
      const convs = await db('conversations')
        .where({ candidate_id: candidateId })
        .whereNot('status', 'archived')
        .select('id');
      // For now, count conversations — full unread tracking needs a messages table
      unreadMessages = convs.length;
    }

    // ---- Unread notifications count ----
    const unreadNotifications = await db('notifications')
      .where({ recipient_id: userId, is_read: false })
      .count('* as c').first().then(r => +r.c);

    // ---- User profile snippet ----
    const user = await db('users').where({ id: userId }).first();

    ok(res, {
      user: (() => {
        // Compute profile strength from real data
        const checks = {
          has_photo: !!user.photo_url,
          has_location: !!user.location,
          has_role: !!(candidate?.role),
          has_experience: !!(candidate?.experience),
          has_languages: !!(candidate?.languages),
          has_phone: !!user.phone,
          has_job_type: !!(candidate?.job_type),
          is_verified: !!user.is_verified,
        };
        const done = Object.values(checks).filter(Boolean).length;
        const strength = Math.round((done / Object.keys(checks).length) * 100);
        return {
          name: user.name,
          initials: user.initials || user.name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2),
          location: user.location,
          avatar_hue: user.avatar_hue || 0.5,
          profile_strength: strength,
          ...checks,
          is_verified: user.is_verified,
          photo_url: user.photo_url || null,
          profile_lat: user.latitude || null,
          profile_lng: user.longitude || null,
          app_language_code: user.app_language_code || 'en',
          spoken_languages: user.spoken_languages || null,
          nationality: candidate?.nationality || null,
          nationality_code: candidate?.nationality_code || null,
          country_code: candidate?.country_code || null,
          job_type: candidate?.job_type || null,
          subscription_plan: user.subscription_plan || 'free',
          subscription_status: user.subscription_status || 'inactive',
        };
      })(),
      applications_summary: applicationsSummary,
      next_interview: nextInterview,
      unread_messages: unreadMessages,
      unread_notifications: unreadNotifications,
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/jobs/featured — Active + featured jobs for the candidate
// ---------------------------------------------------------------------------
async function featuredJobs(req, res, next) {
  try {
    const { page = 1, limit = 20, search } = req.query;

    let base = db('jobs')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .leftJoin('users as biz_users', 'businesses.user_id', 'biz_users.id')
      .where('jobs.status', 'active');

    if (search) {
      const q = `%${search}%`;
      base = base.where(b => b
        .whereILike('jobs.title', q)
        .orWhereILike('jobs.location', q)
        .orWhereILike('jobs.category', q)
        .orWhereILike('businesses.name', q));
    }

    const total = await base.clone().count('* as c').first().then(r => +r.c);

    const rows = await base.clone()
      .select(
        'jobs.id', 'jobs.title', 'jobs.location', 'jobs.employment_type',
        'jobs.salary', 'jobs.category', 'jobs.is_featured', 'jobs.avatar_hue',
        'jobs.created_at', 'jobs.open_to_international',
        'jobs.is_urgent', 'jobs.shift_hours',
        'businesses.id as business_id', 'businesses.name as business_name',
        'businesses.initials as business_initials',
        'businesses.is_verified as business_verified',
        'businesses.avatar_hue as business_avatar_hue',
        'biz_users.photo_url as business_photo_url'
      )
      .orderByRaw('jobs.is_featured DESC, jobs.created_at DESC')
      .limit(limit)
      .offset((+page - 1) * +limit);

    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/jobs — Paginated active jobs for candidates
// ---------------------------------------------------------------------------
async function listJobs(req, res, next) {
  try {
    const { page = 1, limit = 20, search, employment_type, category, open_to_international,
            is_urgent, shift_hours, salary_min, salary_max, verified_only } = req.query;

    let base = db('jobs')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .leftJoin('users as biz_users', 'businesses.user_id', 'biz_users.id')
      .where('jobs.status', 'active');

    if (search) {
      const q = `%${search}%`;
      base = base.where(b => b
        .whereILike('jobs.title', q)
        .orWhereILike('jobs.location', q)
        .orWhereILike('jobs.category', q)
        .orWhereILike('businesses.name', q));
    }
    if (employment_type) base = base.where('jobs.employment_type', employment_type);
    if (category) base = base.whereILike('jobs.category', `%${category}%`);
    if (open_to_international === 'true') base = base.where('jobs.open_to_international', true);
    if (is_urgent === 'true') base = base.where('jobs.is_urgent', true);
    if (shift_hours) base = base.whereILike('jobs.shift_hours', `%${shift_hours}%`);
    if (verified_only === 'true') base = base.where('businesses.is_verified', true);

    const total = await base.clone().count('* as c').first().then(r => +r.c);

    const rows = await base.clone()
      .select(
        'jobs.id', 'jobs.title', 'jobs.location', 'jobs.employment_type',
        'jobs.salary', 'jobs.category', 'jobs.is_featured', 'jobs.avatar_hue',
        'jobs.created_at', 'jobs.open_to_international',
        'jobs.is_urgent', 'jobs.shift_hours',
        'jobs.boost_status', 'jobs.boost_type', 'jobs.visibility_score',
        'businesses.id as business_id', 'businesses.name as business_name',
        'businesses.initials as business_initials',
        'businesses.is_verified as business_verified',
        'businesses.avatar_hue as business_avatar_hue',
        'biz_users.photo_url as business_photo_url'
      )
      // Pre-TestFlight order: visibility_score DESC, then newest active
      // job. visibility_score is recomputed by the boost cron (see
      // services/visibilityScoreRecalc.js) and bakes in boost priority,
      // freshness and stale/expiry penalties; jobs without a meaningful
      // score (cron not run yet, or all zeros) collapse to created_at.
      // The list endpoint is candidate-AGNOSTIC so we cannot apply the
      // per-match rankJobs() here without page-level re-sort artefacts.
      .orderByRaw('jobs.visibility_score DESC NULLS LAST, jobs.created_at DESC')
      .limit(+limit)
      .offset((+page - 1) * +limit);

    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/jobs/:id — Single job detail
// ---------------------------------------------------------------------------
async function getJob(req, res, next) {
  try {
    // Phase 4 — drop the hardcoded `status='active'` filter that was
    // 404-ing chat-shared paused/closed jobs. The detail endpoint is
    // read-only; rendering a non-active job is fine and the UI can
    // disable the Apply CTA based on the returned `status` field.
    // The list endpoints (`listJobs`, `featuredJobs`,
    // `listBusinessJobsForConversation`) keep their own
    // status='active' filters so the discovery surfaces stay clean.
    const job = await db('jobs')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .leftJoin('users as biz_users', 'businesses.user_id', 'biz_users.id')
      .where('jobs.id', req.params.id)
      .select(
        'jobs.*',
        'businesses.name as business_name', 'businesses.initials as business_initials',
        'businesses.is_verified as business_verified', 'businesses.avatar_hue as business_avatar_hue',
        'businesses.venue_type as business_venue_type', 'businesses.location as business_location',
        'biz_users.photo_url as business_photo_url'
      )
      .first();
    if (!job) throw AppError.notFound('Job not found.');

    // Increment view count
    await db('jobs').where({ id: job.id }).increment('views', 1);

    // Check if this candidate has already applied
    const candidate = await db('candidates').where({ user_id: req.user.id }).first();
    let hasApplied = false;
    let applicationStatus = null;
    if (candidate) {
      const app = await db('applications')
        .where({ candidate_id: candidate.id, job_id: job.id })
        .whereNot('status', 'withdrawn')
        .first();
      if (app) { hasApplied = true; applicationStatus = app.status; }
    }
    job.has_applied = hasApplied;
    job.application_status = applicationStatus;

    ok(res, job);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// applyToJobCore — shared apply pipeline used by both POST /jobs/:id/apply
// and POST /quickjobs/swipe (interested=true).
//
// Returns { application, applicationCreated, matchCreated, job, candidate }.
//
// Behavior on duplicate application:
//  - returnExisting=false (default, classic apply handler): throws 400.
//  - returnExisting=true (swipe path): resolves with applicationCreated=false
//    and the existing row, then still runs the mutual-match check so a
//    swipe-right after an out-of-band shortlist can still close the loop.
// ---------------------------------------------------------------------------
async function applyToJobCore({ userId, jobId, sourceCandidate = 'application', returnExisting = false }) {
  const candidate = await db('candidates').where({ user_id: userId }).first();
  if (!candidate) throw AppError.badRequest('Please complete your candidate profile before applying.');

  const job = await db('jobs').where({ id: jobId, status: 'active' }).first();
  if (!job) throw AppError.notFound('Job not found or no longer active.');

  const existing = await db('applications')
    .where({ candidate_id: candidate.id, job_id: jobId })
    .whereNot('status', 'withdrawn')
    .first();

  let application = existing;
  let applicationCreated = false;

  if (existing && !returnExisting) {
    throw AppError.badRequest('You have already applied to this job.');
  }

  if (!existing) {
    [application] = await db('applications').insert({
      candidate_id: candidate.id,
      job_id: jobId,
      status: 'applied',
    }).returning('*');
    applicationCreated = true;

    try {
      const bizForBroadcast = await db('businesses').where({ id: job.business_id }).select('user_id').first();
      bus.publish('application.new', {
        application_id: application.id,
        job_id: jobId,
        job_title: job.title,
        candidate_id: candidate.id,
        candidate_name: candidate.name,
        business_id: job.business_id,
      }, [
        'role:admin',
        bizForBroadcast ? `user:${bizForBroadcast.user_id}` : null,
      ].filter(Boolean));
    } catch (e) { /* ignore */ }

    const biz = await db('businesses').where({ id: job.business_id }).select('user_id').first();
    if (biz) {
      try {
        await hiringNotify(
          biz.user_id,
          `New application from ${candidate.name}`,
          'in_app',
          application.id,
          'applicant',
          `For ${job.title}`,
        );
      } catch (e) { /* best-effort */ }
    }
    try {
      const bizName = await db('businesses').where({ id: job.business_id }).select('name').first();
      await notifyAllAdmins(
        `New application: ${candidate.name} → ${bizName?.name || 'a business'}`,
        'in_app',
        application.id,
        'application',
        `For ${job.title}`,
      );
    } catch (e) { /* best-effort */ }
  }

  // Mutual match check — runs whether the application is brand new or
  // was already on file. tryCreateMutualMatch is idempotent on
  // (business_id, candidate_id, job_id), so it returns false when a
  // match was created from the other direction.
  let matchCreated = false;
  try {
    const shortlist = await db('quickplug_shortlists')
      .where({
        business_id: job.business_id,
        candidate_id: candidate.id,
      })
      .first();
    if (shortlist) {
      matchCreated = await tryCreateMutualMatch({
        businessId: job.business_id,
        candidateId: candidate.id,
        jobId: jobId,
        sourceBusiness: shortlist.source || 'quickplug',
        sourceCandidate,
      });
    }
  } catch (e) {
    console.error('[applyToJobCore match check]', e.message);
  }

  return { application, applicationCreated, matchCreated, job, candidate };
}

// ---------------------------------------------------------------------------
// POST /candidate/jobs/:id/apply — Apply to a job
// ---------------------------------------------------------------------------
async function applyToJob(req, res, next) {
  try {
    const { application } = await applyToJobCore({
      userId: req.user.id,
      jobId: req.params.id,
      sourceCandidate: 'application',
      returnExisting: false,
    });
    ok(res, {
      id: application.id,
      job_id: application.job_id,
      status: application.status,
      created_at: application.created_at,
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /candidate/quickjobs/swipe — Record a Candidate Quick Jobs swipe
// ---------------------------------------------------------------------------
// Body: { jobId: string, interested: boolean }
//
// interested=true:
//  - Reuses applyToJobCore so the apply pipeline (application row,
//    business notification, admin audit, SSE broadcast, mutual-match
//    check) stays the canonical path. Duplicate applications resolve
//    silently (applicationCreated=false) instead of throwing 400.
//  - source_candidate is tagged 'quickjobs' so the resulting match
//    attributes the candidate side to the swipe surface.
//
// interested=false:
//  - Pass. Silent. No application, no match, no notification. The job
//    is looked up only to echo businessId in the response so the
//    Flutter card animation has consistent context for analytics.
async function quickjobsSwipe(req, res, next) {
  try {
    const { jobId, interested } = req.body || {};
    if (!jobId) throw AppError.badRequest('jobId is required.');
    if (typeof interested !== 'boolean') {
      throw AppError.badRequest('interested must be a boolean.');
    }

    const cand = await db('candidates').where({ user_id: req.user.id }).first();
    if (!cand) throw AppError.badRequest('Please complete your candidate profile first.');

    // Enforce the daily cap before doing any work — no apply pipeline,
    // no log row, no notification when the candidate is over budget.
    // Flutter renders the lock state from the returned quota fields.
    const quotaBefore = await resolveQuickjobSwipeQuota(cand.id);
    if (quotaBefore.hasReachedLimit) {
      ok(res, {
        success: false,
        interested,
        applicationCreated: false,
        matchCreated: false,
        jobId,
        businessId: null,
        hasReachedLimit: true,
        dailyLimit: quotaBefore.dailyLimit,
        swipesUsed: quotaBefore.swipesUsed,
        swipesRemaining: 0,
      });
      return;
    }

    // Log the swipe against the daily cap. Both directions count so the
    // candidate cannot bypass the limit by mass-passing. Failure here
    // must NOT block the swipe pipeline: best-effort insert.
    try {
      await db('candidate_quickjob_swipes').insert({
        candidate_id: cand.id,
        job_id: jobId,
        interested,
      });
    } catch (e) { /* best-effort */ }

    if (!interested) {
      const job = await db('jobs')
        .where({ id: jobId })
        .select('id', 'business_id')
        .first();
      const quotaAfter = await resolveQuickjobSwipeQuota(cand.id);
      ok(res, {
        success: true,
        interested: false,
        applicationCreated: false,
        matchCreated: false,
        jobId,
        businessId: job?.business_id || null,
        hasReachedLimit: quotaAfter.hasReachedLimit,
        dailyLimit: quotaAfter.dailyLimit,
        swipesUsed: quotaAfter.swipesUsed,
        swipesRemaining: quotaAfter.swipesRemaining,
      });
      return;
    }

    const result = await applyToJobCore({
      userId: req.user.id,
      jobId,
      sourceCandidate: 'quickjobs',
      returnExisting: true,
    });

    const quotaAfter = await resolveQuickjobSwipeQuota(cand.id);
    ok(res, {
      success: true,
      interested: true,
      applicationCreated: result.applicationCreated,
      matchCreated: result.matchCreated,
      jobId,
      businessId: result.job.business_id,
      hasReachedLimit: quotaAfter.hasReachedLimit,
      dailyLimit: quotaAfter.dailyLimit,
      swipesUsed: quotaAfter.swipesUsed,
      swipesRemaining: quotaAfter.swipesRemaining,
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/applications — Candidate's own applications
// ---------------------------------------------------------------------------
async function listApplications(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) { ok(res, []); return; }

    const { page = 1, limit = 50, status, search } = req.query;

    let base = db('applications')
      .leftJoin('jobs', 'applications.job_id', 'jobs.id')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .where('applications.candidate_id', candidate.id);

    if (status) base = base.where('applications.status', status);
    if (search) {
      const q = `%${search}%`;
      base = base.where(b => b
        .whereILike('jobs.title', q)
        .orWhereILike('businesses.name', q)
        .orWhereILike('jobs.location', q));
    }

    const total = await base.clone().count('* as c').first().then(r => +r.c);

    const rows = await base.clone()
      .select(
        'applications.id', 'applications.status', 'applications.created_at as applied_at',
        'applications.has_interview', 'applications.has_offer',
        'jobs.id as job_id', 'jobs.title as job_title', 'jobs.location as job_location',
        'jobs.salary', 'jobs.employment_type', 'jobs.avatar_hue as job_avatar_hue',
        'businesses.name as business_name', 'businesses.initials as business_initials',
        'businesses.is_verified as business_verified',
        'businesses.avatar_hue as business_avatar_hue'
      )
      .orderBy('applications.created_at', 'desc')
      .limit(+limit)
      .offset((+page - 1) * +limit);

    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/applications/:id — Single application detail
// ---------------------------------------------------------------------------
async function getApplication(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Application not found.');

    const app = await db('applications')
      .leftJoin('jobs', 'applications.job_id', 'jobs.id')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .where('applications.id', req.params.id)
      .where('applications.candidate_id', candidate.id)
      .select(
        'applications.*',
        'jobs.title as job_title', 'jobs.location as job_location',
        'jobs.salary', 'jobs.employment_type', 'jobs.avatar_hue as job_avatar_hue',
        'businesses.name as business_name', 'businesses.initials as business_initials',
        'businesses.is_verified as business_verified',
        'businesses.avatar_hue as business_avatar_hue'
      )
      .first();
    if (!app) throw AppError.notFound('Application not found.');

    ok(res, app);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /candidate/applications/:id/withdraw — Withdraw an application
// ---------------------------------------------------------------------------
async function withdrawApplication(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Application not found.');

    const app = await db('applications')
      .where({ id: req.params.id, candidate_id: candidate.id })
      .first();
    if (!app) throw AppError.notFound('Application not found.');
    if (app.status === 'withdrawn') throw AppError.badRequest('Application already withdrawn.');

    await db('applications')
      .where({ id: app.id })
      .update({ status: 'withdrawn', updated_at: db.fn.now() });

    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/interviews — Candidate's upcoming and past interviews
// ---------------------------------------------------------------------------
async function listInterviews(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) { paginated(res, [], { page: 1, limit: 50, total: 0 }); return; }

    const { page = 1, limit = 50, status } = req.query;

    let base = db('interviews')
      .leftJoin('jobs', 'interviews.job_id', 'jobs.id')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .where('interviews.candidate_id', candidate.id);

    if (status) base = base.where('interviews.status', status);

    const total = await base.clone().count('* as c').first().then(r => +r.c);

    const rows = await base.clone()
      .select(
        'interviews.id', 'interviews.scheduled_at', 'interviews.timezone',
        'interviews.interview_type', 'interviews.status', 'interviews.location',
        'interviews.meeting_link', 'interviews.created_at',
        'jobs.id as job_id', 'jobs.title as job_title', 'jobs.location as job_location',
        'businesses.name as business_name', 'businesses.initials as business_initials',
        'businesses.is_verified as business_verified',
        'businesses.avatar_hue as business_avatar_hue'
      )
      .orderBy('interviews.scheduled_at', 'asc')
      .limit(+limit)
      .offset((+page - 1) * +limit);

    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/interviews/:id — Single interview detail
// ---------------------------------------------------------------------------
async function getInterview(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Interview not found.');

    const iv = await db('interviews')
      .leftJoin('jobs', 'interviews.job_id', 'jobs.id')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .where('interviews.id', req.params.id)
      .where('interviews.candidate_id', candidate.id)
      .select(
        'interviews.*',
        'jobs.title as job_title', 'jobs.location as job_location',
        'businesses.name as business_name', 'businesses.initials as business_initials',
        'businesses.is_verified as business_verified',
        'businesses.avatar_hue as business_avatar_hue'
      )
      .first();
    if (!iv) throw AppError.notFound('Interview not found.');

    ok(res, iv);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/conversations — Candidate's conversations
// ---------------------------------------------------------------------------
async function listConversations(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) { paginated(res, [], { page: 1, limit: 50, total: 0 }); return; }

    const { page = 1, limit = 50 } = req.query;

    let base = db('conversations')
      .leftJoin('businesses', 'conversations.business_id', 'businesses.id')
      // Owner user of the business — its `photo_url` is the brand
      // logo Elena should see in the chat list / header on her side.
      // Mirror of the business-side query, which already joins
      // `users` on `candidates.user_id` to expose
      // `candidate_photo_url`.
      .leftJoin('users as biz_users', 'businesses.user_id', 'biz_users.id')
      .leftJoin('jobs', 'conversations.job_id', 'jobs.id')
      .where('conversations.candidate_id', candidate.id)
      .whereNot('conversations.status', 'archived');

    const total = await base.clone().count('* as c').first().then(r => +r.c);

    const rows = await base.clone()
      .select(
        'conversations.id', 'conversations.last_message', 'conversations.status',
        'conversations.is_interview_related', 'conversations.updated_at',
        'businesses.name as business_name', 'businesses.initials as business_initials',
        'businesses.is_verified as business_verified', 'businesses.avatar_hue as business_avatar_hue',
        'businesses.country_code as business_country_code',
        'biz_users.photo_url as business_photo_url',
        'jobs.title as job_title'
      )
      .orderBy('conversations.updated_at', 'desc')
      .limit(+limit).offset((+page - 1) * +limit);

    // Attach unread count per conversation
    for (const row of rows) {
      const unread = await db('messages')
        .where({ conversation_id: row.id, is_read: false })
        .whereNot('sender_id', userId)
        .count('* as c').first();
      row.unread_count = +(unread?.c || 0);
    }

    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/conversations/:id/messages — Messages in a conversation
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// GET /candidate/conversations/:id/business-jobs
// ---------------------------------------------------------------------------
// Surfaces jobs posted by the business on the OTHER side of a chat
// conversation. Used by the chat Job picker (Phase 4) so a candidate
// can only share jobs that are relevant to the current thread —
// avoids "candidate shares a random job from another business".
// Auth: candidate must own the conversation. Returns active jobs
// only (status='active'), most recent first.
async function listBusinessJobsForConversation(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Candidate profile required.');
    const conv = await db('conversations')
      .where({ id: req.params.id, candidate_id: candidate.id })
      .first();
    if (!conv) throw AppError.notFound('Conversation not found.');
    if (!conv.business_id) { ok(res, []); return; }

    const rows = await db('jobs')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .where('jobs.business_id', conv.business_id)
      .where('jobs.status', 'active')
      .select(
        'jobs.id',
        'jobs.title',
        'jobs.location',
        'jobs.employment_type',
        'jobs.salary',
        'jobs.is_urgent',
        'jobs.is_featured',
        'jobs.created_at',
        'businesses.name as business_name',
      )
      .orderBy('jobs.created_at', 'desc');
    ok(res, rows);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/conversations/:id/business-interviews
// ---------------------------------------------------------------------------
// Mirror of listBusinessJobsForConversation but for interviews.
// Used by the chat Interview picker (Phase 4) so a candidate can
// only share interviews tied to the business at the other side of
// THIS thread (interviews where interviews.candidate_id = me AND
// jobs.business_id = conv.business_id). Most recent first.
async function listInterviewsForConversation(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Candidate profile required.');
    const conv = await db('conversations')
      .where({ id: req.params.id, candidate_id: candidate.id })
      .first();
    if (!conv) throw AppError.notFound('Conversation not found.');
    if (!conv.business_id) { ok(res, []); return; }

    const rows = await db('interviews')
      .leftJoin('jobs', 'interviews.job_id', 'jobs.id')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .where('interviews.candidate_id', candidate.id)
      .where('jobs.business_id', conv.business_id)
      .select(
        'interviews.id',
        'interviews.scheduled_at',
        'interviews.interview_type',
        'interviews.status',
        'interviews.location',
        'jobs.title as job_title',
        'businesses.name as business_name',
      )
      .orderBy('interviews.scheduled_at', 'desc');
    ok(res, rows);
  } catch (err) { next(err); }
}

async function listMessages(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Conversation not found.');

    // Verify candidate owns this conversation
    const conv = await db('conversations')
      .where({ id: req.params.id, candidate_id: candidate.id }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');

    const { page = 1, limit = 200 } = req.query;
    // Sprint 4C — count must mirror the same `message_hides` filter
    // applied to the SELECT below; otherwise pagination thinks there
    // are more rows than the caller will ever see and infinite-scroll
    // misbehaves on threads with hidden messages.
    const total = await db('messages')
      .where({ conversation_id: conv.id })
      // Sprint 4F — synthetic 'reaction' rows drive unread/last_message
      // bookkeeping but never render as bubbles. Filter them from the
      // total so pagination matches the SELECT below.
      .whereNot('attachment_type', 'reaction')
      .whereNotExists(function () {
        this.select(db.raw('1'))
          .from('message_hides')
          .whereRaw('message_hides.message_id = messages.id')
          .where('message_hides.user_id', userId);
      })
      .count('* as c').first().then(r => +r.c);

    // Pull the LATEST `limit` messages (desc + offset), then reverse to
    // chronological order for the client. Previous behaviour was ASC + offset
    // which silently truncated long threads to the oldest page and made the
    // chat appear "stuck" once the conversation crossed the page size.
    //
    // Phase 3D — also LEFT JOIN the replied-to message + its sender so
    // each row carries a snapshot quote preview (id / sender_type /
    // attachment_type / body / audio_duration_ms). NULL-safe: rows with
    // no reply leave every `reply_*` column NULL.
    const msgs = (await db('messages')
      .leftJoin('users', 'messages.sender_id', 'users.id')
      .leftJoin('messages as replied', 'messages.reply_to_message_id', 'replied.id')
      .leftJoin('users as replied_user', 'replied.sender_id', 'replied_user.id')
      .where('messages.conversation_id', conv.id)
      // Sprint 4F — synthetic 'reaction' rows are bookkeeping only,
      // never rendered as chat bubbles.
      .whereNot('messages.attachment_type', 'reaction')
      // Sprint 4C — exclude rows the caller has hidden via
      // delete-for-me. Other participants and admin are unaffected.
      .whereNotExists(function () {
        this.select(db.raw('1'))
          .from('message_hides')
          .whereRaw('message_hides.message_id = messages.id')
          .where('message_hides.user_id', userId);
      })
      .select(
        'messages.id', 'messages.body', 'messages.is_read', 'messages.delivered_at',
        'messages.sender_id', 'messages.created_at',
        'messages.attachment_type', 'messages.audio_url',
        'messages.audio_duration_ms', 'messages.audio_size_bytes',
        'messages.audio_mime_type',
        'messages.image_url', 'messages.image_size_bytes',
        'messages.image_mime_type', 'messages.image_width',
        'messages.image_height',
        'messages.document_url', 'messages.document_size_bytes',
        'messages.document_mime_type', 'messages.document_filename',
        'messages.location_lat', 'messages.location_lng',
        'messages.location_address',
        'messages.album_image_urls',
        'messages.deleted_for_everyone_at',
        'messages.reply_to_message_id',
        'messages.shared_entity_type',
        'messages.shared_entity_id',
        'users.name as sender_name', 'users.user_type as sender_type',
        'replied.body as reply_body',
        'replied.attachment_type as reply_attachment_type',
        'replied.audio_duration_ms as reply_audio_duration_ms',
        'replied.shared_entity_type as reply_shared_entity_type',
        'replied.album_image_urls as reply_album_image_urls',
        'replied.deleted_for_everyone_at as reply_deleted_for_everyone_at',
        'replied_user.user_type as reply_sender_type',
        'replied_user.name as reply_sender_name',
      )
      .orderBy('messages.created_at', 'desc')
      .limit(+limit).offset((+page - 1) * +limit)).reverse();

    // Flip unread peer messages to read and broadcast to the sender.
    const toMark = await db('messages')
      .where({ conversation_id: conv.id, is_read: false })
      .whereNot('sender_id', userId)
      .pluck('id');
    if (toMark.length > 0) {
      const readAt = new Date().toISOString();
      await db('messages').whereIn('id', toMark).update({ is_read: true });
      let businessUserId = null;
      if (conv.business_id) {
        const biz = await db('businesses').where({ id: conv.business_id }).select('user_id').first();
        if (biz) businessUserId = biz.user_id;
      }
      if (businessUserId) {
        bus.publish('message.read', {
          conversation_id: conv.id,
          message_ids: toMark,
          reader_user_id: userId,
          read_at: readAt,
        }, [`user:${businessUserId}`]);
      }
    }

    // Hydrate reactions for the returned message slice. One round
    // trip keyed by message ids so we don't issue N+1 queries.
    const ids = msgs.map((m) => m.id);
    const reactionRows = ids.length === 0
      ? []
      : await db('message_reactions')
          .whereIn('message_id', ids)
          .select('message_id', 'user_id', 'emoji', 'created_at');
    const reactionsByMsg = new Map();
    for (const r of reactionRows) {
      if (!reactionsByMsg.has(r.message_id)) reactionsByMsg.set(r.message_id, []);
      reactionsByMsg.get(r.message_id).push({
        user_id: r.user_id,
        emoji: r.emoji,
        created_at: r.created_at,
      });
    }
    // Sprint 4A — hydrate the caller's own stars in a single batch.
    // Stars are private: each user only sees their own, so we
    // filter by user_id here at fetch time and surface a flat
    // `is_starred_by_me` boolean per row.
    const starredIds = ids.length === 0
      ? new Set()
      : new Set(
          (await db('message_stars')
            .whereIn('message_id', ids)
            .where('user_id', userId)
            .pluck('message_id')),
        );
    // Phase 4 — batch-fetch entity-share envelopes for the page.
    // One grouped query per type at most (4 max), avoiding N+1.
    const shareItems = msgs
      .filter((m) => m.attachment_type === 'entity_share' && m.shared_entity_id)
      .map((m) => ({ type: m.shared_entity_type, id: m.shared_entity_id }));
    const shareEnvelopes = await batchEntityShareEnvelopes(shareItems, 'candidate');

    const enriched = msgs.map((m) => {
      const {
        reply_body,
        reply_attachment_type,
        reply_audio_duration_ms,
        reply_shared_entity_type,
        reply_album_image_urls,
        reply_deleted_for_everyone_at,
        reply_sender_type,
        reply_sender_name,
        ...rest
      } = m;
      // Build the compact reply preview only when the parent
      // exists (FK ON DELETE SET NULL drops the link if the
      // original was removed; we surface the lost-link case as
      // reply_to_message_id present + reply_to absent).
      let replyTo = null;
      if (m.reply_to_message_id && reply_attachment_type !== null) {
        // Sprint 4C — when the parent has been tombstoned the reply
        // preview must read "This message was deleted" instead of
        // the original body. The attachment_type is forced to
        // 'deleted' so the bubble can branch its rendering without
        // peeking at extra fields.
        const parentDeleted = reply_deleted_for_everyone_at != null;
        replyTo = {
          id: m.reply_to_message_id,
          sender_type: reply_sender_type || null,
          sender_name: reply_sender_name || null,
          attachment_type: parentDeleted ? 'deleted' : reply_attachment_type,
          body_preview: parentDeleted
            ? 'This message was deleted'
            : _replyBodyPreview(reply_attachment_type, reply_body, reply_shared_entity_type, reply_album_image_urls),
          audio_duration_ms: parentDeleted ? null : (reply_audio_duration_ms || null),
        };
      }
      // Sprint 4C — tombstone payload. Once a message has been
      // deleted-for-everyone we still ship the row (so the bubble
      // index stays stable + the reply quote can still resolve to
      // it), but we strip the body and any media URLs so the bubble
      // renders "This message was deleted" without leaking the
      // original content. The `deleted_for_everyone_at` flag tells
      // the client to switch render branches.
      const isTombstoned = m.deleted_for_everyone_at != null;
      const tombstoneOverrides = isTombstoned
        ? {
            body: '',
            audio_url: null,
            audio_duration_ms: null,
            audio_size_bytes: null,
            audio_mime_type: null,
            image_url: null,
            image_size_bytes: null,
            image_mime_type: null,
            image_width: null,
            image_height: null,
            document_url: null,
            document_size_bytes: null,
            document_mime_type: null,
            document_filename: null,
            location_lat: null,
            location_lng: null,
            location_address: null,
            shared_entity_type: null,
            shared_entity_id: null,
            album_image_urls: null,
          }
        : { album_image_urls: _normalizeAlbumUrls(m.album_image_urls) };
      // Attach the entity-share envelope when this row is itself an
      // entity share. Missing entity (deleted after send) → null →
      // client renders a "no longer available" fallback.
      const sharedEntity = !isTombstoned && m.attachment_type === 'entity_share' && m.shared_entity_id
        ? (shareEnvelopes.get(`${m.shared_entity_type}:${m.shared_entity_id}`) || null)
        : null;
      return {
        ...rest,
        ...tombstoneOverrides,
        reply_to: replyTo,
        shared_entity: sharedEntity,
        reactions: isTombstoned ? [] : (reactionsByMsg.get(m.id) || []),
        is_starred_by_me: !isTombstoned && starredIds.has(m.id),
      };
    });

    paginated(res, enriched, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /candidate/conversations/:id/messages/ack-delivered — Mark peer messages delivered
// ---------------------------------------------------------------------------
async function ackMessagesDelivered(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.badRequest('Candidate profile required.');

    const conv = await db('conversations')
      .where({ id: req.params.id, candidate_id: candidate.id }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');

    const ids = Array.isArray(req.body?.message_ids) ? req.body.message_ids.filter(Boolean) : [];
    const deliveredAt = new Date().toISOString();

    let query = db('messages')
      .where({ conversation_id: conv.id })
      .whereNot('sender_id', userId)
      .whereNull('delivered_at');
    if (ids.length > 0) query = query.whereIn('id', ids);
    const flipped = await query.clone().pluck('id');
    if (flipped.length > 0) {
      await query.update({ delivered_at: deliveredAt });

      let businessUserId = null;
      if (conv.business_id) {
        const biz = await db('businesses').where({ id: conv.business_id }).select('user_id').first();
        if (biz) businessUserId = biz.user_id;
      }
      if (businessUserId) {
        bus.publish('message.delivered', {
          conversation_id: conv.id,
          message_ids: flipped,
          delivered_at: deliveredAt,
        }, [`user:${businessUserId}`]);
      }
    }
    ok(res, { message_ids: flipped, delivered_at: deliveredAt });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /candidate/conversations/:id/messages — Send a message
// ---------------------------------------------------------------------------
async function sendMessage(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.badRequest('Candidate profile required.');

    const conv = await db('conversations')
      .where({ id: req.params.id, candidate_id: candidate.id }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');

    const {
      body,
      attachment_type,
      audio_url,
      audio_duration_ms,
      audio_size_bytes,
      audio_mime_type,
      image_url,
      image_size_bytes,
      image_mime_type,
      image_width,
      image_height,
      document_url,
      document_size_bytes,
      document_mime_type,
      document_filename,
      location_lat,
      location_lng,
      location_address,
      reply_to_message_id,
      shared_entity_type,
      shared_entity_id,
      album_image_urls,
    } = req.body;

    const isAudio = attachment_type === 'audio';
    const isImage = attachment_type === 'image';
    const isDocument = attachment_type === 'document';
    const isLocation = attachment_type === 'location';
    const isEntityShare = attachment_type === 'entity_share';
    const isAlbum = attachment_type === 'album';
    // Album guard: ordered jsonb array of HTTPS R2/S3 URLs, all
    // produced by /v1/uploads/image. Cap of 6 mirrors the picker UX
    // and keeps a single bubble manageable. Same defense-in-depth as
    // the single-image path — `storage.isOwnedUrl()` rejects any
    // third-party origin, `data:` URI, file:// scheme, etc.
    let cleanAlbumUrls = null;
    if (isAlbum) {
      if (!Array.isArray(album_image_urls)) {
        throw AppError.badRequest('album_image_urls is required and must be an array.');
      }
      if (album_image_urls.length === 0) {
        throw AppError.badRequest('album_image_urls cannot be empty.');
      }
      if (album_image_urls.length > 6) {
        throw AppError.badRequest('album_image_urls cannot contain more than 6 photos.');
      }
      for (const u of album_image_urls) {
        if (!u || typeof u !== 'string' || !storage.isOwnedUrl(u)) {
          throw AppError.badRequest('Every album_image_urls entry must come from /v1/uploads/image.');
        }
      }
      cleanAlbumUrls = album_image_urls;
    }
    if (isAudio && (!audio_url || typeof audio_url !== 'string')) {
      throw AppError.badRequest('audio_url is required for audio messages.');
    }
    // Image guard: URL must be a string and must point to our own
    // storage namespace. Anything else (arbitrary http://…, file://,
    // data:) is rejected so a malicious client can't inject a bubble
    // that renders content from a third-party origin.
    if (isImage) {
      // image_url MUST be one this storage adapter issued — works for
      // both LocalDiskAdapter (`/uploads/image/...`) in dev and
      // S3Adapter (R2/AWS https URL) in production. Previous guard
      // only matched the local-disk shape and silently rejected
      // every prod upload — see fix(messaging): accept S3/R2 URLs
      // in image+document message guards.
      if (!image_url || typeof image_url !== 'string' || !storage.isOwnedUrl(image_url)) {
        throw AppError.badRequest('image_url is required and must come from /v1/uploads/image.');
      }
    }
    // Document guard: same origin check as image — URL must come from
    // /uploads/document/ so we can't be tricked into rendering a
    // bubble pointing at an attacker-controlled host.
    if (isDocument) {
      if (!document_url || typeof document_url !== 'string' || !storage.isOwnedUrl(document_url)) {
        throw AppError.badRequest('document_url is required and must come from /v1/uploads/document.');
      }
    }
    // Location guard: require both lat/lng to be finite numbers in
    // the WGS-84 valid range. Sending NaN, Infinity, strings or out-
    // of-range values short-circuits before the insert so we don't
    // store dangling coords. `location_address` is optional — Sprint 3
    // ships without client-side reverse-geocoding.
    let locLat = null;
    let locLng = null;
    if (isLocation) {
      // Reject null/undefined explicitly first — `Number(null) === 0`
      // would otherwise pass the in-range check and silently store
      // the equator/Greenwich coordinate.
      if (location_lat === null || location_lat === undefined) {
        throw AppError.badRequest('location_lat is required.');
      }
      if (location_lng === null || location_lng === undefined) {
        throw AppError.badRequest('location_lng is required.');
      }
      const parsedLat = typeof location_lat === 'number' ? location_lat : Number(location_lat);
      const parsedLng = typeof location_lng === 'number' ? location_lng : Number(location_lng);
      if (!Number.isFinite(parsedLat) || parsedLat < -90 || parsedLat > 90) {
        throw AppError.badRequest('location_lat must be a finite number in [-90, 90].');
      }
      if (!Number.isFinite(parsedLng) || parsedLng < -180 || parsedLng > 180) {
        throw AppError.badRequest('location_lng must be a finite number in [-180, 180].');
      }
      locLat = parsedLat;
      locLng = parsedLng;
    }
    // Text messages still require a body. Audio / image / document /
    // location / entity-share rows can carry an optional caption
    // (kept) or no body at all.
    if (!isAudio && !isImage && !isDocument && !isLocation && !isEntityShare && !isAlbum && (!body || !body.trim())) {
      throw AppError.badRequest('Message body is required.');
    }

    // Phase 4 — entity-share guard. The (type, id) pair must reference
    // an entity that exists in this DB; otherwise the bubble would
    // render an empty card on the receiver and we'd have a dangling
    // polymorphic pointer in `messages`.
    let entityEnvelope = null;
    if (isEntityShare) {
      if (!isSupportedShareType(shared_entity_type)) {
        throw AppError.badRequest('Invalid shared_entity_type.');
      }
      if (typeof shared_entity_id !== 'string' || shared_entity_id.length === 0) {
        throw AppError.badRequest('Invalid shared_entity_id.');
      }
      // viewerRole 'candidate' here just for the existence lookup —
      // the real per-recipient envelope is rebuilt at listMessages
      // time. Since the lookup itself is read-only, the route field
      // resolved here is harmless.
      entityEnvelope = await buildEntityShareEnvelope({
        type: shared_entity_type,
        id: shared_entity_id,
        viewerRole: 'candidate',
      });
      if (!entityEnvelope) {
        throw AppError.badRequest('Shared entity not found.');
      }
    }

    // Phase 3D — reply support. If the client provides
    // reply_to_message_id, validate that the target message exists in
    // the SAME conversation. Cross-conversation replies are rejected
    // up front so the FK never has a chance to point at unrelated
    // threads, even though the FK itself would technically allow it.
    let replyToId = null;
    if (reply_to_message_id !== undefined && reply_to_message_id !== null) {
      if (typeof reply_to_message_id !== 'string' || reply_to_message_id.length === 0) {
        throw AppError.badRequest('Invalid reply_to_message_id.');
      }
      const target = await db('messages')
        .where({ id: reply_to_message_id, conversation_id: conv.id })
        .first();
      if (!target) {
        throw AppError.badRequest('Reply target message not found in this conversation.');
      }
      replyToId = target.id;
    }

    const cleanBody = (body && body.trim()) || '';
    const dbAttachmentType = isAudio
      ? 'audio'
      : isImage
        ? 'image'
        : isDocument
          ? 'document'
          : isLocation
            ? 'location'
            : isEntityShare
              ? 'entity_share'
              : isAlbum
                ? 'album'
                : 'text';
    const [msg] = await db('messages').insert({
      conversation_id: conv.id,
      sender_id: userId,
      body: cleanBody,
      attachment_type: dbAttachmentType,
      audio_url: isAudio ? audio_url : null,
      audio_duration_ms: isAudio && Number.isFinite(+audio_duration_ms) ? +audio_duration_ms : null,
      audio_size_bytes: isAudio && Number.isFinite(+audio_size_bytes) ? +audio_size_bytes : null,
      audio_mime_type: isAudio ? (audio_mime_type || null) : null,
      image_url: isImage ? image_url : null,
      image_size_bytes: isImage && Number.isFinite(+image_size_bytes) ? +image_size_bytes : null,
      image_mime_type: isImage ? (image_mime_type || null) : null,
      image_width: isImage && Number.isFinite(+image_width) ? +image_width : null,
      image_height: isImage && Number.isFinite(+image_height) ? +image_height : null,
      document_url: isDocument ? document_url : null,
      document_size_bytes: isDocument && Number.isFinite(+document_size_bytes) ? +document_size_bytes : null,
      document_mime_type: isDocument ? (document_mime_type || null) : null,
      document_filename: isDocument ? (document_filename || null) : null,
      location_lat: isLocation ? locLat : null,
      location_lng: isLocation ? locLng : null,
      location_address: isLocation && typeof location_address === 'string' && location_address.trim().length > 0
        ? location_address.trim().slice(0, 500)
        : null,
      reply_to_message_id: replyToId,
      shared_entity_type: isEntityShare ? shared_entity_type : null,
      // Persist the canonical id resolved by the envelope (e.g.
      // candidates.id) even when the client passed users.id. This
      // keeps the DB row consistent with what listMessages will
      // look up later.
      shared_entity_id: isEntityShare ? entityEnvelope.id : null,
      // Album: ordered jsonb array, knex pg auto-casts JS arrays via
      // JSON.stringify on jsonb columns, so the column round-trips as
      // a real array on SELECT.
      album_image_urls: isAlbum ? JSON.stringify(cleanAlbumUrls) : null,
    }).returning('*');

    // Conversation last_message — non-text rows show a glyph since
    // the body preview would otherwise be empty.
    const preview = isAudio
      ? '🎤 Voice message'
      : isImage
        ? '🖼 Photo'
        : isDocument
          ? '📄 Document'
          : isLocation
            ? '📍 Location'
            : isEntityShare
              ? _entitySharePreview(shared_entity_type)
              : isAlbum
                ? `📷 Album · ${cleanAlbumUrls.length} photo${cleanAlbumUrls.length === 1 ? '' : 's'}`
                : cleanBody.slice(0, 200);
    await db('conversations').where({ id: conv.id }).update({
      last_message: preview,
      updated_at: db.fn.now(),
    });

    console.log(`[BACKEND CREATE] candidate→business msgId=${msg.id} convId=${conv.id} candidateUserId=${userId} businessId=${conv.business_id || 'null'} type=${msg.attachment_type} body="${msg.body}"`);

    // Notify the business — use hiringNotify so `notification.new` is
    // published on the SSE bus; otherwise BusinessNotificationsProvider
    // can't refresh in real time (it only listens to notification.new).
    let businessUserId = null;
    let bizNameForAdmin = null;
    if (conv.business_id) {
      const biz = await db('businesses').where({ id: conv.business_id }).select('user_id', 'name').first();
      if (biz) {
        businessUserId = biz.user_id;
        bizNameForAdmin = biz.name;
        hiringNotify(biz.user_id, `New message from ${candidate.name}`, 'in_app', conv.id, 'message');
      }
    }
    try {
      await notifyAllAdmins(
        `Message: ${candidate.name} → ${bizNameForAdmin || 'business'}`,
        'in_app', conv.id, 'message', preview.slice(0, 80),
      );
    } catch (e) { /* best-effort */ }

    // Phase 3D — build the same compact reply envelope that listMessages
    // produces, so the POST response and SSE message.new event carry it
    // immediately. Without this, the sender's just-sent bubble and the
    // peer's incoming bubble both render with an empty quote until the
    // next thread refetch (where the LEFT JOIN finally fills it in).
    const replyEnvelope = await buildReplyEnvelope(msg.reply_to_message_id);

    // Realtime broadcast
    const audience = ['role:admin', `user:${userId}`];
    if (businessUserId) audience.push(`user:${businessUserId}`);
    console.log(`[SSE EMIT] type=message.new convId=${conv.id} senderUserId=${userId} recipientUserId=${businessUserId || 'null'} audience=${JSON.stringify(audience)}`);
    bus.publish('message.new', {
      message: {
        id: msg.id,
        conversation_id: conv.id,
        body: msg.body,
        attachment_type: msg.attachment_type,
        audio_url: msg.audio_url,
        audio_duration_ms: msg.audio_duration_ms,
        audio_size_bytes: msg.audio_size_bytes,
        audio_mime_type: msg.audio_mime_type,
        image_url: msg.image_url || null,
        image_size_bytes: msg.image_size_bytes || null,
        image_mime_type: msg.image_mime_type || null,
        image_width: msg.image_width || null,
        image_height: msg.image_height || null,
        document_url: msg.document_url || null,
        document_size_bytes: msg.document_size_bytes || null,
        document_mime_type: msg.document_mime_type || null,
        document_filename: msg.document_filename || null,
        location_lat: msg.location_lat == null ? null : msg.location_lat,
        location_lng: msg.location_lng == null ? null : msg.location_lng,
        location_address: msg.location_address || null,
        album_image_urls: _normalizeAlbumUrls(msg.album_image_urls),
        sender_id: msg.sender_id,
        created_at: msg.created_at,
        delivered_at: msg.delivered_at || null,
        is_read: !!msg.is_read,
        reply_to_message_id: msg.reply_to_message_id || null,
        reply_to: replyEnvelope,
        shared_entity_type: msg.shared_entity_type || null,
        shared_entity_id: msg.shared_entity_id || null,
        shared_entity: entityEnvelope,
      },
      conversation_id: conv.id,
      sender_user_id: userId,
      recipient_user_id: businessUserId,
      sender_role: 'candidate',
    }, audience);

    ok(res, { ...msg, reply_to: replyEnvelope, shared_entity: entityEnvelope });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /candidate/messages/:messageId/reactions — Add or update reaction
// ---------------------------------------------------------------------------
// One reaction per user per message. UPSERT replaces the emoji if the
// user already reacted; the schema-level UNIQUE (message_id, user_id)
// makes this race-safe. Access is gated by conversation membership —
// a candidate can only react to messages inside their own threads.
async function addMessageReaction(req, res, next) {
  try {
    const userId = req.user.id;
    const messageId = req.params.messageId;
    const emoji = req.body && typeof req.body.emoji === 'string'
      ? req.body.emoji
      : null;
    if (!emoji || emoji.length === 0 || emoji.length > 32) {
      throw AppError.badRequest('Invalid emoji.');
    }

    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Message not found.');

    // Membership check + locate the original message's sender + the
    // owning conversation in a single round-trip. We need the sender
    // to detect self-react and the conversation to look up the peer
    // user for the SSE audience + last_message bump.
    const target = await db('messages')
      .leftJoin('conversations', 'messages.conversation_id', 'conversations.id')
      .where('messages.id', messageId)
      .where('conversations.candidate_id', candidate.id)
      .select(
        'messages.id as msg_id',
        'messages.sender_id as msg_sender_id',
        'conversations.id as conv_id',
        'conversations.business_id as conv_business_id',
      )
      .first();
    if (!target) throw AppError.notFound('Message not found.');

    // Read the previous emoji (if any) BEFORE the upsert so we can
    // tell whether this is a real change or a no-op re-tap. We only
    // notify on a real change.
    const existing = await db('message_reactions')
      .where({ message_id: messageId, user_id: userId })
      .select('emoji')
      .first();

    await db('message_reactions')
      .insert({ message_id: messageId, user_id: userId, emoji })
      .onConflict(['message_id', 'user_id'])
      .merge({ emoji, updated_at: db.fn.now() });

    // Sprint 4F — surface the reaction on the peer's inbox / home.
    //
    // The /conversations + /home unread counters key off
    // `messages.is_read=false AND sender_id != caller`. To make the
    // reaction count as activity without inserting a real chat
    // bubble we drop a synthetic row with attachment_type='reaction'
    // — listMessages filters those out so the chat thread itself
    // stays clean. The same row drives `conversations.last_message`
    // and the `message.new` SSE event the inbox provider already
    // listens to (no `notification.new`, so the bell stays silent
    // per product decision).
    //
    // Guards:
    //   • self-react (reactor === message owner) — silent.
    //   • emoji unchanged (re-tap) — silent.
    //   • peer userId not resolvable — silent.
    const emojiChanged = !existing || existing.emoji !== emoji;
    const isSelfReact = String(target.msg_sender_id) === String(userId);
    let peerUserId = null;
    if (target.conv_business_id) {
      const biz = await db('businesses')
        .where({ id: target.conv_business_id })
        .select('user_id')
        .first();
      peerUserId = biz?.user_id || null;
    }

    if (emojiChanged && !isSelfReact && peerUserId) {
      const preview = `${candidate.name} reacted to your message`;
      const [synth] = await db('messages').insert({
        conversation_id: target.conv_id,
        sender_id: userId,
        body: preview,
        attachment_type: 'reaction',
        is_read: false,
        reply_to_message_id: messageId,
      }).returning('*');

      await db('conversations').where({ id: target.conv_id }).update({
        last_message: preview,
        updated_at: db.fn.now(),
      });

      const audience = ['role:admin', `user:${userId}`, `user:${peerUserId}`];
      console.log(`[SSE EMIT] type=message.new(reaction) convId=${target.conv_id} reactorUserId=${userId} peerUserId=${peerUserId} emoji=${emoji}`);
      bus.publish('message.new', {
        message: {
          id: synth.id,
          conversation_id: target.conv_id,
          body: preview,
          attachment_type: 'reaction',
          sender_id: userId,
          created_at: synth.created_at,
          is_read: false,
          reply_to_message_id: messageId,
        },
        conversation_id: target.conv_id,
        sender_user_id: userId,
        recipient_user_id: peerUserId,
        sender_role: 'candidate',
        kind: 'reaction',
      }, audience);
    }

    ok(res, { message_id: messageId, user_id: userId, emoji });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /candidate/messages/:messageId/reactions — Remove own reaction
// ---------------------------------------------------------------------------
// Removes only the actor's own row. Other users' reactions on the same
// message are untouched.
async function removeMessageReaction(req, res, next) {
  try {
    const userId = req.user.id;
    const messageId = req.params.messageId;

    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Message not found.');

    const allowed = await db('messages')
      .leftJoin('conversations', 'messages.conversation_id', 'conversations.id')
      .where('messages.id', messageId)
      .where('conversations.candidate_id', candidate.id)
      .select('messages.id')
      .first();
    if (!allowed) throw AppError.notFound('Message not found.');

    await db('message_reactions')
      .where({ message_id: messageId, user_id: userId })
      .delete();

    ok(res, { message_id: messageId, user_id: userId, removed: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /candidate/messages/:messageId/star — Star a message (per-user)
// ---------------------------------------------------------------------------
// Idempotent: re-tapping Star while already starred is a no-op (UNIQUE
// constraint + ON CONFLICT DO NOTHING). Stars are private — only the
// caller sees them. No realtime broadcast.
//
// Membership gate: same pattern as reactions — the message must live
// inside a conversation the candidate is part of.
async function starMessage(req, res, next) {
  try {
    const userId = req.user.id;
    const messageId = req.params.messageId;

    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Message not found.');

    const allowed = await db('messages')
      .leftJoin('conversations', 'messages.conversation_id', 'conversations.id')
      .where('messages.id', messageId)
      .where('conversations.candidate_id', candidate.id)
      .select('messages.id')
      .first();
    if (!allowed) throw AppError.notFound('Message not found.');

    await db('message_stars')
      .insert({ message_id: messageId, user_id: userId })
      .onConflict(['message_id', 'user_id'])
      .ignore();

    ok(res, { message_id: messageId, user_id: userId, starred: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /candidate/messages/:messageId/star — Unstar own star
// ---------------------------------------------------------------------------
// Removes only the actor's own star row. Idempotent — DELETE on a
// missing row returns 0 affected rows but resolves with success
// (the desired end state — "I don't have a star here" — is already
// true).
async function unstarMessage(req, res, next) {
  try {
    const userId = req.user.id;
    const messageId = req.params.messageId;

    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Message not found.');

    const allowed = await db('messages')
      .leftJoin('conversations', 'messages.conversation_id', 'conversations.id')
      .where('messages.id', messageId)
      .where('conversations.candidate_id', candidate.id)
      .select('messages.id')
      .first();
    if (!allowed) throw AppError.notFound('Message not found.');

    await db('message_stars')
      .where({ message_id: messageId, user_id: userId })
      .delete();

    ok(res, { message_id: messageId, user_id: userId, starred: false });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// Sprint 4C — Delete actions for chat messages.
//
// Two distinct flavours:
//   1. POST   /candidate/messages/:id/hide   — soft-hide for this user.
//   2. DELETE /candidate/messages/:id        — tombstone for everyone,
//      sender-only, gated to a 15-minute window after `created_at`.
//
// The 15-minute window is a hard product rule (no per-account override
// in Sprint 4). Constant lives next to the handlers so the value is
// visible at the call site instead of buried in shared config.
// ---------------------------------------------------------------------------

const DELETE_FOR_EVERYONE_WINDOW_MS = 15 * 60 * 1000;

// ---------------------------------------------------------------------------
// POST /candidate/messages/:messageId/hide — Hide a message for me only
// ---------------------------------------------------------------------------
// Idempotent: re-hiding an already-hidden message is a no-op (UNIQUE
// constraint + ON CONFLICT DO NOTHING). Other participants and admin
// keep seeing the message normally.
async function hideMessageForMe(req, res, next) {
  try {
    const userId = req.user.id;
    const messageId = req.params.messageId;

    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Message not found.');

    const allowed = await db('messages')
      .leftJoin('conversations', 'messages.conversation_id', 'conversations.id')
      .where('messages.id', messageId)
      .where('conversations.candidate_id', candidate.id)
      .select('messages.id')
      .first();
    if (!allowed) throw AppError.notFound('Message not found.');

    await db('message_hides')
      .insert({ message_id: messageId, user_id: userId })
      .onConflict(['message_id', 'user_id'])
      .ignore();

    ok(res, { message_id: messageId, user_id: userId, hidden: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /candidate/messages/:messageId — Delete for everyone
// ---------------------------------------------------------------------------
// Two gates, both 4xx:
//   • NOT_SENDER (403)         — only the original sender can tombstone
//   • DELETE_WINDOW_EXPIRED    — outside 15 min from created_at
//
// On success we set deleted_for_everyone_at, drop reactions on this
// row (mirror of WhatsApp UX — the message no longer exists, the
// reactions don't either), and emit message.deleted_for_everyone on
// the SSE bus so peer clients can flip their bubble to a tombstone
// without waiting for the next poll.
async function deleteMessageForEveryone(req, res, next) {
  try {
    const userId = req.user.id;
    const messageId = req.params.messageId;

    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Message not found.');

    const msg = await db('messages')
      .leftJoin('conversations', 'messages.conversation_id', 'conversations.id')
      .where('messages.id', messageId)
      .where('conversations.candidate_id', candidate.id)
      .select(
        'messages.id',
        'messages.sender_id',
        'messages.created_at',
        'messages.deleted_for_everyone_at',
        'messages.conversation_id',
        'conversations.business_id',
      )
      .first();
    if (!msg) throw AppError.notFound('Message not found.');

    if (msg.sender_id !== userId) {
      throw AppError.forbidden(
        'You can only delete your own messages for everyone.',
        'NOT_SENDER',
      );
    }
    // Idempotent: already tombstoned → no-op success.
    if (msg.deleted_for_everyone_at) {
      ok(res, { message_id: messageId, deleted_for_everyone: true });
      return;
    }
    const ageMs = Date.now() - new Date(msg.created_at).getTime();
    if (ageMs > DELETE_FOR_EVERYONE_WINDOW_MS) {
      throw AppError.badRequest(
        'You can only delete a message for everyone within 15 minutes of sending.',
        'DELETE_WINDOW_EXPIRED',
      );
    }

    const deletedAt = new Date().toISOString();
    await db.transaction(async (trx) => {
      await trx('messages')
        .where({ id: messageId })
        .update({ deleted_for_everyone_at: deletedAt, updated_at: deletedAt });
      // Mirror WhatsApp UX: reactions on a tombstone are confusing,
      // remove them. The message_reactions schema-level cascade does
      // NOT fire (we keep the messages row alive) — explicit DELETE.
      await trx('message_reactions').where({ message_id: messageId }).delete();
    });

    // Realtime: peer can flip bubble to tombstone immediately. Even
    // when SSE is disabled client-side (current state), we still emit
    // so the bus → fan-out pipeline stays exercised.
    let peerUserId = null;
    if (msg.business_id) {
      const biz = await db('businesses').where({ id: msg.business_id }).select('user_id').first();
      if (biz) peerUserId = biz.user_id;
    }
    const audience = ['role:admin', `user:${userId}`];
    if (peerUserId) audience.push(`user:${peerUserId}`);
    bus.publish('message.deleted_for_everyone', {
      message_id: messageId,
      conversation_id: msg.conversation_id,
      deleted_for_everyone_at: deletedAt,
      sender_user_id: userId,
    }, audience);

    ok(res, { message_id: messageId, deleted_for_everyone: true, deleted_for_everyone_at: deletedAt });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// Sprint 4E4 — Report a message.
// ---------------------------------------------------------------------------
// Reuses the platform-level `reports` table (type='message'). No new
// migration: the schema already accepts `type='message'` in its CHECK
// constraint, and the generic columns map cleanly:
//
//   reports.reported_entity ← message.id
//   reports.reporter        ← caller's user id (uuid as string)
//   reports.reason          ← category (spam | harassment | scam |
//                              inappropriate | other)
//   reports.summary         ← optional notes (mandatory for 'other')
//
// Tombstoned messages are reportable on purpose — the audit trail for
// safety reviews shouldn't disappear just because the sender deleted
// the message client-side.
//
// `notifyAllAdmins` is best-effort; a notify failure is logged but
// never blocks the report from persisting.
// ---------------------------------------------------------------------------

const ALLOWED_REPORT_CATEGORIES = new Set([
  'spam',
  'harassment',
  'scam',
  'inappropriate',
  'other',
]);
const REPORT_NOTES_MAX_LEN = 1000;

async function reportMessage(req, res, next) {
  try {
    const userId = req.user.id;
    const messageId = req.params.messageId;
    const { category, notes } = req.body || {};

    if (typeof category !== 'string' || !ALLOWED_REPORT_CATEGORIES.has(category)) {
      throw AppError.badRequest(
        'Invalid report category. Use spam / harassment / scam / inappropriate / other.',
        'INVALID_REPORT_CATEGORY',
      );
    }
    let cleanNotes = null;
    if (notes != null) {
      if (typeof notes !== 'string') {
        throw AppError.badRequest('Notes must be a string.');
      }
      cleanNotes = notes.trim();
      if (cleanNotes.length === 0) cleanNotes = null;
      if (cleanNotes != null && cleanNotes.length > REPORT_NOTES_MAX_LEN) {
        throw AppError.badRequest(
          'Notes too long (max 1000 characters).',
          'REPORT_NOTES_TOO_LONG',
        );
      }
    }
    if (category === 'other' && cleanNotes == null) {
      throw AppError.badRequest(
        'Notes are required when reporting as "other".',
        'REPORT_OTHER_NOTES_REQUIRED',
      );
    }

    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Message not found.');

    // Membership gate — same pattern as star/delete: caller must be
    // a participant in the conversation that owns this message.
    const msg = await db('messages')
      .leftJoin('conversations', 'messages.conversation_id', 'conversations.id')
      .where('messages.id', messageId)
      .where('conversations.candidate_id', candidate.id)
      .select('messages.id', 'messages.body', 'messages.attachment_type')
      .first();
    if (!msg) throw AppError.notFound('Message not found.');

    const [report] = await db('reports')
      .insert({
        title: 'Message report',
        type: 'message',
        reported_entity: messageId,
        reporter: userId,
        reason: category,
        summary: cleanNotes,
        // Severity stays at table default ('medium'); admin can bump
        // it during triage. Status defaults to 'open'.
      })
      .returning(['id', 'status', 'created_at']);

    // Best-effort admin fan-out. Never let a notify failure roll the
    // report back — it already persisted.
    try {
      const preview = (msg.body || '').slice(0, 80);
      await notifyAllAdmins(
        `Message reported (${category})`,
        'in_app',
        report.id,
        'report',
        preview,
      );
    } catch (e) {
      console.warn('[reportMessage] notifyAllAdmins failed:', e.message);
    }

    ok(res, {
      report_id: report.id,
      status: report.status || 'open',
      message_id: messageId,
      category,
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /candidate/conversations/:id/typing — Emit typing indicator
// ---------------------------------------------------------------------------
// Ephemeral — does NOT persist. Relays an SSE event to the business
// counterpart so their chat view can render / hide the "…" typing bubble.
// Admin is intentionally EXCLUDED (typing is UX noise, not auditable);
// sender is excluded too.
async function sendTyping(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.badRequest('Candidate profile required.');

    const conv = await db('conversations')
      .where({ id: req.params.id, candidate_id: candidate.id }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');

    let businessUserId = null;
    if (conv.business_id) {
      const biz = await db('businesses').where({ id: conv.business_id }).select('user_id').first();
      if (biz) businessUserId = biz.user_id;
    }

    if (businessUserId) {
      bus.publish('chat.typing', {
        conversation_id: conv.id,
        sender_user_id: userId,
        is_typing: !!req.body.is_typing,
        actor: 'candidate',
      }, [`user:${businessUserId}`]);
    }
    ok(res, { ok: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PUT /candidate/profile — Update candidate profile
// ---------------------------------------------------------------------------
async function updateProfile(req, res, next) {
  try {
    const userId = req.user.id;
    const { name, phone, location, role, experience, languages, latitude, longitude, job_type, bio, start_date, available_to_relocate } = req.body;

    // Update users table
    const userUpdates = {};
    if (name !== undefined) userUpdates.name = name;
    if (phone !== undefined) userUpdates.phone = phone;
    if (location !== undefined) userUpdates.location = location;
    if (latitude !== undefined) userUpdates.latitude = latitude;
    if (longitude !== undefined) userUpdates.longitude = longitude;
    if (role !== undefined) userUpdates.role = role;
    if (Object.keys(userUpdates).length > 0) {
      userUpdates.updated_at = db.fn.now();
      if (name) userUpdates.initials = name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2);
      await db('users').where({ id: userId }).update(userUpdates);
    }

    // Update candidates table
    let candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) {
      const user = await db('users').where({ id: userId }).first();
      [candidate] = await db('candidates').insert({
        user_id: userId,
        name: name || user.name,
        initials: (name || user.name).split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2),
        role: role || user.role,
        location: location || user.location,
      }).returning('*');
    }

    const candUpdates = {};
    if (name !== undefined) { candUpdates.name = name; candUpdates.initials = name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2); }
    if (role !== undefined) candUpdates.role = role;
    if (location !== undefined) candUpdates.location = location;
    if (experience !== undefined) candUpdates.experience = experience;
    if (languages !== undefined) candUpdates.languages = languages;
    if (job_type !== undefined) candUpdates.job_type = job_type;
    if (bio !== undefined) candUpdates.bio = bio;
    if (start_date !== undefined) candUpdates.start_date = start_date;
    if (available_to_relocate !== undefined) candUpdates.available_to_relocate = available_to_relocate;
    if (Object.keys(candUpdates).length > 0) {
      candUpdates.updated_at = db.fn.now();
      await db('candidates').where({ id: candidate.id }).update(candUpdates);
    }

    // Calculate profile strength
    const user = await db('users').where({ id: userId }).first();
    const cand = await db('candidates').where({ user_id: userId }).first();
    let strength = 20; // base for having account
    if (user.name) strength += 15;
    if (user.location) strength += 15;
    if (user.role) strength += 10;
    if (cand?.experience) strength += 15;
    if (cand?.languages) strength += 15;
    if (user.phone) strength += 10;
    strength = Math.min(strength, 100);
    await db('users').where({ id: userId }).update({ profile_strength: strength });

    // Send match notifications to matching businesses when role + job_type are set
    const freshCand = await db('candidates').where({ user_id: userId }).first();
    if ((role !== undefined || job_type !== undefined) && freshCand?.role && freshCand?.job_type) {
      (async () => {
        try {
          const candRole = freshCand.role.toLowerCase().trim();
          const candJT = freshCand.job_type.toLowerCase().trim();
          const matchedJobs = await db('jobs')
            .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
            .where('jobs.status', 'active')
            .whereRaw('LOWER(TRIM(jobs.category)) = ?', [candRole])
            .whereRaw('LOWER(TRIM(jobs.employment_type)) = ?', [candJT])
            .select('businesses.user_id', 'jobs.title', 'jobs.employment_type', 'jobs.id as job_id')
            .limit(50);
          for (const mj of matchedJobs) {
            // Create match record
            try {
              await db('matches').insert({
                candidate_id: freshCand.id, job_id: mj.job_id,
                status: 'pending',
              });
            } catch (_) { /* ignore duplicate */ }
            await hiringNotify(
              mj.user_id,
              `New match: ${freshCand.name} – ${freshCand.role} (${freshCand.job_type})`,
              'in_app', freshCand.id, 'match'
            );
          }
        } catch (e) { console.error('[Match notify]', e.message); }
      })();
    }

    // Return updated profile
    const updated = await db('users').where({ id: userId }).first();
    const updatedCand = await db('candidates').where({ user_id: userId }).first();
    ok(res, {
      id: updated.id, name: updated.name,
      initials: updated.initials || updated.name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2),
      email: updated.email, phone: updated.phone, location: updated.location,
      role: updated.role, status: updated.status, is_verified: updated.is_verified,
      profile_strength: updated.profile_strength, avatar_hue: updated.avatar_hue,
      experience: updatedCand?.experience, languages: updatedCand?.languages,
      job_type: updatedCand?.job_type || null, bio: updatedCand?.bio || null,
      start_date: updatedCand?.start_date || null,
      available_to_relocate: updatedCand?.available_to_relocate || false,
      verification_status: updatedCand?.verification_status || 'new',
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/community — Published community posts
// ---------------------------------------------------------------------------
async function listCommunityPosts(req, res, next) {
  try {
    const { page = 1, limit = 20, category } = req.query;

    let base = db('community_posts').where('status', 'published');
    if (category) base = base.where('category', category);

    const total = await base.clone().count('* as c').first().then(r => +r.c);

    const rows = await base.clone()
      .select('*')
      .orderByRaw('is_pinned DESC, is_featured_on_home DESC, published_date DESC NULLS LAST, created_at DESC')
      .limit(+limit)
      .offset((+page - 1) * +limit);

    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// Haversine distance formula (returns km)
// ---------------------------------------------------------------------------
const HAVERSINE_SELECT = `
  (6371 * acos(
    LEAST(1.0, cos(radians(?)) * cos(radians(jobs.latitude)) *
    cos(radians(jobs.longitude) - radians(?)) +
    sin(radians(?)) * sin(radians(jobs.latitude)))
  )) AS distance_km`;

// ---------------------------------------------------------------------------
// GET /candidate/jobs/nearby — Jobs near a coordinate with radius filter
// ---------------------------------------------------------------------------
async function nearbyJobs(req, res, next) {
  try {
    const { lat, lng, radius = 10, page = 1, limit = 30, category } = req.query;
    if (!lat || !lng) throw AppError.badRequest('lat and lng are required.');

    const userLat = parseFloat(lat);
    const userLng = parseFloat(lng);
    const radiusKm = parseFloat(radius);

    let base = db('jobs')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .leftJoin('users as biz_users', 'businesses.user_id', 'biz_users.id')
      .where('jobs.status', 'active')
      .whereNotNull('jobs.latitude')
      .whereNotNull('jobs.longitude')
      .select(
        'jobs.id', 'jobs.title', 'jobs.location', 'jobs.employment_type',
        'jobs.salary', 'jobs.category', 'jobs.is_featured', 'jobs.avatar_hue',
        'jobs.latitude', 'jobs.longitude', 'jobs.created_at',
        'businesses.name as business_name', 'businesses.initials as business_initials',
        'businesses.is_verified as business_verified', 'businesses.avatar_hue as business_avatar_hue',
        'biz_users.photo_url as business_photo_url',
        'businesses.country_code as business_country_code',
        db.raw(HAVERSINE_SELECT, [userLat, userLng, userLat])
      );

    if (category) base = base.whereILike('jobs.category', `%${category}%`);

    // We need to filter by distance — use a subquery wrapper
    const subquery = base.as('nearby');
    const rows = await db.select('*').from(subquery)
      .where('distance_km', '<=', radiusKm)
      .orderBy('distance_km', 'asc')
      .limit(+limit)
      .offset((+page - 1) * +limit);

    const countResult = await db.select(db.raw('count(*) as c')).from(
      db('jobs')
        .where('jobs.status', 'active')
        .whereNotNull('jobs.latitude')
        .whereNotNull('jobs.longitude')
        .select('jobs.id', db.raw(HAVERSINE_SELECT, [userLat, userLng, userLat]))
        .as('cnt')
    ).where('distance_km', '<=', radiusKm).first();

    paginated(res, rows, { page: +page, limit: +limit, total: +(countResult?.c || 0) });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/quickjobs/deck — Tinder-style swipe deck of jobs
// ---------------------------------------------------------------------------
// Returns up to `limit` active jobs the candidate hasn't applied to yet,
// shaped for the Candidate Quick Jobs UI (mirror of Business Quick Plug).
//
// Query params (all optional):
//  - lat, lng: coordinates. When both are provided we compute a Haversine
//    distance and hard-filter by `radius` (default 50km, max 500).
//  - verified_only=true: hard-filter to verified businesses only.
//  - limit (default 20, max 50).
//
// Soft signals — never empty the deck, just reorder:
//  - role_match: true when the candidate's primary_role/role overlaps
//    with the job's category or main_role_needed (case-insensitive).
//  - role_match=true rows surface first, then is_featured, then distance
//    (when computed), then recency.
//
// Always excludes jobs the candidate has already applied to (any
// non-withdrawn application). Withdrawn ones are eligible again so the
// candidate can re-discover them.
async function quickjobsDeck(req, res, next) {
  try {
    const { lat, lng, radius, verified_only, limit } = req.query;
    const cap = Math.min(Math.max(parseInt(limit, 10) || 20, 1), 50);

    const cand = await db('candidates').where({ user_id: req.user.id }).first();
    if (!cand) throw AppError.badRequest('Please complete your candidate profile first.');

    const hasCoords = lat !== undefined && lng !== undefined && lat !== '' && lng !== '';
    const userLat = hasCoords ? parseFloat(lat) : null;
    const userLng = hasCoords ? parseFloat(lng) : null;
    const radiusKm = hasCoords
      ? Math.min(Math.max(parseFloat(radius) || 50, 1), 500)
      : null;

    let base = db('jobs')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .leftJoin('users as biz_users', 'businesses.user_id', 'biz_users.id')
      .where('jobs.status', 'active')
      .whereNotExists(function () {
        this.select('*')
          .from('applications')
          .whereRaw('applications.job_id = jobs.id')
          .where('applications.candidate_id', cand.id)
          .whereNot('applications.status', 'withdrawn');
      });

    if (verified_only === 'true' || verified_only === true) {
      base = base.where('businesses.is_verified', true);
    }

    const baseSelect = [
      'jobs.id', 'jobs.title', 'jobs.location', 'jobs.employment_type',
      'jobs.salary', 'jobs.category', 'jobs.is_featured', 'jobs.is_urgent',
      'jobs.shift_hours', 'jobs.description', 'jobs.requirements',
      'jobs.avatar_hue', 'jobs.created_at', 'jobs.main_role_needed',
      'jobs.additional_roles_needed',
      'jobs.expiry_date',
      'jobs.boost_status', 'jobs.boost_type', 'jobs.boost_priority',
      'jobs.boost_starts_at',
      'businesses.id as business_id',
      'businesses.name as business_name',
      'businesses.initials as business_initials',
      'businesses.is_verified as business_verified',
      'businesses.avatar_hue as business_avatar_hue',
      'businesses.venue_type as business_venue_type',
      'biz_users.photo_url as business_photo_url',
    ];

    let rows;
    if (hasCoords) {
      base = base
        .whereNotNull('jobs.latitude')
        .whereNotNull('jobs.longitude')
        .select(...baseSelect, db.raw(HAVERSINE_SELECT, [userLat, userLng, userLat]));
      const sub = base.as('deck');
      rows = await db.select('*').from(sub)
        .where('distance_km', '<=', radiusKm)
        .orderByRaw('is_featured DESC, distance_km ASC, created_at DESC')
        .limit(cap);
    } else {
      rows = await base.clone()
        .select(...baseSelect)
        .orderByRaw('jobs.is_featured DESC, jobs.created_at DESC')
        .limit(cap);
    }

    // Phase 1 — score each row and attach the per-candidate match
    // signals straight onto the SQL row object. We keep the original
    // row shape so rankJobs() can read boost_*, created_at, expiry_date
    // directly without us having to re-marshal.
    const enriched = rows.map((r) => {
      const jobShape = {
        id: r.id,
        title: r.title,
        main_role_needed: r.main_role_needed,
        additional_roles_needed: r.additional_roles_needed,
        location: r.location,
        employment_type: r.employment_type,
        salary: r.salary,
        requirements: r.requirements,
      };
      const match = scoreCandidateForJob(cand, jobShape);
      return {
        ...r,
        match_score: match.score,
        match_level: match.level,
        match_reasons: match.reasons,
        top_match_reason: match.topReason,
        role_match: match.breakdown.role >= 25,
      };
    });

    // Phase 2 — boost-aware re-rank. When BOOST_RANKING_ENABLED is OFF
    // (production default) rankJobs() is a pure pass-through and the
    // legacy match-score order below kicks in instead. When ON, the
    // rankJobs sort already accounts for matchScore, urgent/top/featured
    // boosts, freshness, expiry, stale-boost penalties, the floor-for-30
    // demote and the featured-cap rule.
    const ranked = rankJobs(enriched);
    const isFlagOn = ranked.length > 0 && ranked[0].__ranking !== undefined;

    if (!isFlagOn) {
      // Legacy fallback sort — same behaviour as before Step 2 so the
      // off-flag path is bit-for-bit equivalent.
      ranked.sort((a, b) => {
        if (b.match_score !== a.match_score) return b.match_score - a.match_score;
        if (b.is_featured !== a.is_featured) return (b.is_featured ? 1 : 0) - (a.is_featured ? 1 : 0);
        return 0;
      });
    }

    // Phase 3 — map the ranked rows to the API DTO. The __ranking field
    // is dropped from the response unless ?explain=1 is set.
    const explain = req.query.explain === '1' || req.query.explain === 'true';
    const data = ranked.map((r) => ({
      id: r.id,
      title: r.title || '',
      location: r.location || '',
      employment_type: r.employment_type || '',
      salary: r.salary || '',
      category: r.category || '',
      shift_hours: r.shift_hours || '',
      description: r.description || '',
      requirements: r.requirements || '',
      is_featured: !!r.is_featured,
      is_urgent: !!r.is_urgent,
      avatar_hue: r.avatar_hue,
      distance_km: r.distance_km != null ? +Number(r.distance_km).toFixed(1) : null,
      // Legacy soft signal — kept for back-compat with older Flutter
      // builds that still read role_match. New builds should use
      // match_score / match_level instead.
      role_match: r.role_match,
      match_score: r.match_score,
      match_level: r.match_level,
      match_reasons: r.match_reasons,
      top_match_reason: r.top_match_reason,
      business: {
        id: r.business_id,
        name: r.business_name || '',
        initials: r.business_initials || '',
        verified: !!r.business_verified,
        venue_type: r.business_venue_type || '',
        logo_url: r.business_photo_url || null,
        avatar_hue: r.business_avatar_hue,
      },
      ...(explain && r.__ranking ? { __ranking: r.__ranking } : {}),
    }));

    // Daily-swipe quota — server is source of truth. Flutter mirrors
    // these fields into CandidateQuickJobsProvider and shows the lock
    // state when hasReachedLimit is true.
    const quota = await resolveQuickjobSwipeQuota(cand.id);

    ok(res, data, quota);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /candidate/photo — Upload profile photo (base64)
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// POST /candidate/cv — Upload CV (base64, store URL)
// ---------------------------------------------------------------------------
async function uploadCV(req, res, next) {
  try {
    const { cv, file_name } = req.body;
    if (!cv || !cv.trim()) throw AppError.badRequest('CV data is required.');
    if (cv.length > 8 * 1024 * 1024) throw AppError.badRequest('CV too large. Max 5 MB file.');

    // Store CV data on candidate record
    const cand = await db('candidates').where({ user_id: req.user.id }).first();
    if (cand) {
      await db('candidates').where({ id: cand.id }).update({ cv_url: cv, cv_file_name: file_name || 'cv.pdf', updated_at: db.fn.now() });
    }

    ok(res, { cv_url: cv ? 'uploaded' : null, file_name: file_name || 'cv.pdf' });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /candidate/cv/parse — Upload CV and extract profile data via Claude
// ---------------------------------------------------------------------------
async function parseCV(req, res, next) {
  try {
    const { cv, file_name } = req.body;
    if (!cv || !cv.trim()) throw AppError.badRequest('CV data is required.');

    // Extract text from base64 CV
    let cvText = '';
    try {
      // Remove data URI prefix if present
      let base64Data = cv;
      if (base64Data.includes(';base64,')) {
        base64Data = base64Data.split(';base64,')[1];
      }
      const buffer = Buffer.from(base64Data, 'base64');

      // Try PDF parse
      const lowerName = (file_name || '').toLowerCase();
      if (lowerName.endsWith('.pdf') || cv.startsWith('data:application/pdf')) {
        const pdfParse = require('pdf-parse');
        const pdfData = await pdfParse(buffer);
        cvText = pdfData.text || '';
      } else {
        // DOC/DOCX — extract as plain text (best effort)
        cvText = buffer.toString('utf-8').replace(/[^\x20-\x7E\n\r\t]/g, ' ').replace(/\s+/g, ' ').trim();
      }
    } catch (parseErr) {
      console.error('[CV Parse] Text extraction failed:', parseErr.message);
      // Return empty extraction rather than failing
      ok(res, { extracted: {}, raw_text: '', parse_error: 'Could not extract text from file. Please fill in your details manually.' });
      return;
    }

    if (!cvText || cvText.trim().length < 20) {
      ok(res, { extracted: {}, raw_text: cvText, parse_error: 'CV text too short to extract data. Please fill in your details manually.' });
      return;
    }

    // Use Claude API to extract structured data
    let extracted = {};
    try {
      const Anthropic = require('@anthropic-ai/sdk');
      const apiKey = process.env.ANTHROPIC_API_KEY;
      if (!apiKey) {
        console.warn('[CV Parse] No ANTHROPIC_API_KEY set, skipping AI extraction');
        ok(res, { extracted: {}, raw_text: cvText.slice(0, 2000), parse_error: 'AI extraction not configured. Please fill in your details manually.' });
        return;
      }

      const client = new Anthropic({ apiKey });
      const message = await client.messages.create({
        model: 'claude-sonnet-4-20250514',
        max_tokens: 1024,
        messages: [{
          role: 'user',
          content: `Extract structured profile data from this CV/resume text. This is for a hospitality recruitment app.

Return ONLY a valid JSON object with these fields (use null for any field you cannot find):

{
  "first_name": "string or null",
  "last_name": "string or null",
  "email": "string or null",
  "phone": "string or null",
  "location": "city and country string or null",
  "role": "most recent job title or null",
  "role_category": "one of: chef, waiter, bartender, manager, reception, kitchen_porter, sommelier, or null",
  "experience": "years of experience as a string like '5 years' or null",
  "languages": "comma-separated list of spoken languages or null",
  "skills": "comma-separated list of key skills or null",
  "certifications": "comma-separated list of certifications or null",
  "bio": "a 1-2 sentence professional summary or null"
}

CV Text:
${cvText.slice(0, 6000)}

Return ONLY the JSON, no markdown, no explanation.`
        }]
      });

      const responseText = message.content[0]?.text || '{}';
      // Parse JSON from response (handle potential markdown wrapping)
      let jsonStr = responseText.trim();
      if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.replace(/^```(?:json)?\n?/, '').replace(/\n?```$/, '');
      }
      extracted = JSON.parse(jsonStr);
    } catch (aiErr) {
      console.error('[CV Parse] AI extraction failed:', aiErr.message);
      // Return partial data rather than failing
      ok(res, { extracted: {}, raw_text: cvText.slice(0, 2000), parse_error: 'AI extraction failed. Please fill in your details manually.' });
      return;
    }

    // Also store the CV
    const cand = await db('candidates').where({ user_id: req.user.id }).first();
    if (cand) {
      await db('candidates').where({ id: cand.id }).update({ cv_url: cv, cv_file_name: file_name || 'cv.pdf', updated_at: db.fn.now() });
    }

    ok(res, { extracted, raw_text: cvText.slice(0, 2000) });
  } catch (err) { next(err); }
}

// Mirror of uploadController.IMAGE_MIME_TO_EXT — kept inline so the
// uploadPhoto helper doesn't need to import the chat upload module.
const _AVATAR_MIME_TO_EXT = {
  'image/jpeg': 'jpg',
  'image/jpg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'image/heic': 'heic',
  'image/heif': 'heic',
};
const _AVATAR_MAX_BYTES = 4 * 1024 * 1024; // 4MB raw decoded

async function uploadPhoto(req, res, next) {
  try {
    const { photo } = req.body;

    // Empty / null = remove photo (existing behaviour kept).
    if (!photo || typeof photo !== 'string' || !photo.trim()) {
      await db('users').where({ id: req.user.id }).update({
        photo_url: null,
        updated_at: db.fn.now(),
      });
      return ok(res, { photo_url: null });
    }

    const trimmed = photo.trim();
    let photoUrl;

    if (trimmed.startsWith('data:image')) {
      // Legacy client path — Flutter posts a base64 data URI inline.
      // Decode + upload to R2 + persist HTTPS URL so `users.photo_url`
      // is never a 600+KB inline blob (root cause of ProfilePhoto
      // flicker on iPhone real devices).
      const m = trimmed.match(/^data:([a-zA-Z0-9.+/-]+);base64,(.*)$/);
      if (!m) throw AppError.badRequest('Invalid photo data URI.');
      const mime = m[1].toLowerCase();
      let buffer;
      try {
        buffer = Buffer.from(m[2], 'base64');
      } catch (_) {
        throw AppError.badRequest('Invalid photo base64 payload.');
      }
      if (buffer.length === 0) {
        throw AppError.badRequest('Empty photo payload.');
      }
      if (buffer.length > _AVATAR_MAX_BYTES) {
        throw AppError.badRequest('Photo too large. Please choose a smaller image.');
      }
      const ext = _AVATAR_MIME_TO_EXT[mime] || 'jpg';
      photoUrl = await storage.save(buffer, { ext, mimeType: mime, kind: 'avatar' });
    } else if (trimmed.startsWith('https://') && storage.isOwnedUrl(trimmed)) {
      // Forward-compat: future Flutter / admin clients may upload via
      // a separate multipart endpoint and pass the resulting URL here.
      // Only OWNED URLs (issued by our storage adapter) are accepted —
      // an arbitrary http(s):// is silently rejected so a malicious
      // caller can't pin a third-party image into a user record.
      photoUrl = trimmed;
    } else {
      throw AppError.badRequest('Invalid photo. Provide a data:image URI or an owned HTTPS URL.');
    }

    await db('users').where({ id: req.user.id }).update({
      photo_url: photoUrl,
      updated_at: db.fn.now(),
    });
    ok(res, { photo_url: photoUrl });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /candidate/interviews/:id/respond — Accept/Decline interview
// ---------------------------------------------------------------------------
async function respondToInterview(req, res, next) {
  try {
    const cand = await db('candidates').where({ user_id: req.user.id }).first();
    if (!cand) throw AppError.notFound('Candidate not found.');
    const candId = cand.id;
    const { status } = req.body; // confirmed, declined
    if (!['confirmed', 'declined'].includes(status)) throw AppError.badRequest('Status must be confirmed or declined.');
    const iv = await db('interviews').where({ id: req.params.id, candidate_id: candId }).first();
    if (!iv) throw AppError.notFound('Interview not found.');
    await db('interviews').where({ id: iv.id }).update({ status, updated_at: db.fn.now() });
    const job = await db('jobs').where({ id: iv.job_id }).select('business_id').first();
    const bizUser = job ? await db('businesses').where({ id: job.business_id }).select('user_id').first() : null;
    const audience = ['role:admin', `user:${req.user.id}`];
    if (bizUser) audience.push(`user:${bizUser.user_id}`);
    bus.publish('interview.status_changed', {
      interview_id: iv.id,
      application_id: iv.application_id,
      candidate_id: iv.candidate_id,
      job_id: iv.job_id,
      status,
      actor: 'candidate',
      candidate_user_id: req.user.id,
      business_user_id: bizUser?.user_id || null,
    }, audience);
    try {
      const jobRow = await db('jobs').where({ id: iv.job_id }).select('title').first();
      await notifyAllAdmins(
        `Interview ${status} by ${cand.name}: ${jobRow?.title || 'job'}`,
        'in_app', iv.id, 'interview', null,
      );
    } catch (e) { /* best-effort */ }
    ok(res, { success: true, status });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/notifications — Candidate notifications
// ---------------------------------------------------------------------------
async function listCandidateNotifications(req, res, next) {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 30 } = req.query;
    const total = await db('notifications').where({ recipient_id: userId }).count('* as c').first().then(r => +r.c);
    const rows = await db('notifications')
      .where({ recipient_id: userId })
      .select('*')
      .orderBy('created_at', 'desc')
      .limit(+limit).offset((+page - 1) * +limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/notifications/count — Unread count
// ---------------------------------------------------------------------------
async function candidateUnreadCount(req, res, next) {
  try {
    const c = await db('notifications').where({ recipient_id: req.user.id, is_read: false }).count('* as c').first();
    ok(res, { count: +(c?.c || 0) });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /candidate/notifications/:id/read
// ---------------------------------------------------------------------------
async function markCandidateNotifRead(req, res, next) {
  try {
    await db('notifications').where({ id: req.params.id, recipient_id: req.user.id }).update({ is_read: true, updated_at: db.fn.now() });
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /candidate/notifications/read-all
// ---------------------------------------------------------------------------
async function markAllCandidateNotifsRead(req, res, next) {
  try {
    await db('notifications').where({ recipient_id: req.user.id, is_read: false }).update({ is_read: true, updated_at: db.fn.now() });
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /candidate/notifications/:id — Delete a single notification
// ---------------------------------------------------------------------------
async function deleteCandidateNotif(req, res, next) {
  try {
    await db('notifications').where({ id: req.params.id, recipient_id: req.user.id }).del();
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /candidate/notifications — Delete every notification of the user
// ---------------------------------------------------------------------------
async function deleteAllCandidateNotifs(req, res, next) {
  try {
    await db('notifications').where({ recipient_id: req.user.id }).del();
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /candidate/conversations/:id — Archive conversation
// ---------------------------------------------------------------------------
async function archiveConversation(req, res, next) {
  try {
    const candidate = await db('candidates').where({ user_id: req.user.id }).first();
    if (!candidate) throw AppError.badRequest('Candidate not found.');
    const conv = await db('conversations').where({ id: req.params.id, candidate_id: candidate.id }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');
    await db('conversations').where({ id: conv.id }).update({ status: 'archived', updated_at: db.fn.now() });
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /candidate/matches — Jobs matching candidate's role + job_type
// ---------------------------------------------------------------------------
async function listMatches(req, res, next) {
  try {
    const userId = req.user.id;
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.notFound('Candidate not found.');

    const { page = 1, limit = 20 } = req.query;
    const candRole = (candidate.role || '').toLowerCase().trim();
    const candJobType = (candidate.job_type || '').toLowerCase().trim();

    if (!candRole || !candJobType) {
      return paginated(res, [], { page: +page, limit: +limit, total: 0 });
    }

    // STRICT: exact match only on role + job_type
    // Read from matches table (status-aware) with fallback to computed matches
    let base = db('matches')
      .leftJoin('jobs', 'matches.job_id', 'jobs.id')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .leftJoin('users as biz_users', 'businesses.user_id', 'biz_users.id')
      .where('matches.candidate_id', candidate.id)
      .where('jobs.status', 'active')
      .whereNot('matches.status', 'denied');

    const total = await base.clone().count('* as c').first().then(r => +r.c);

    const rows = await base.clone()
      .select(
        'matches.id as match_id', 'matches.status as match_status',
        'jobs.id', 'jobs.title', 'jobs.location', 'jobs.employment_type',
        'jobs.salary', 'jobs.category', 'jobs.is_featured', 'jobs.avatar_hue',
        'jobs.is_urgent', 'jobs.created_at', 'jobs.description',
        'businesses.id as business_id', 'businesses.name as business_name',
        'businesses.initials as business_initials', 'businesses.avatar_hue as business_avatar_hue',
        'biz_users.is_verified as business_verified', 'biz_users.photo_url as business_photo_url'
      )
      .orderBy('matches.created_at', 'desc')
      .limit(+limit).offset((+page - 1) * +limit);

    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /candidate/feedback — Submit match feedback
// ---------------------------------------------------------------------------
async function submitMatchFeedback(req, res, next) {
  try {
    const { match_id, was_relevant, role_accurate, job_type_accurate } = req.body;
    if (!match_id) throw AppError.badRequest('match_id is required.');
    await db('match_feedback').insert({
      user_id: req.user.id,
      match_id,
      user_type: 'candidate',
      was_relevant: was_relevant ?? null,
      role_accurate: role_accurate ?? null,
      job_type_accurate: job_type_accurate ?? null,
    });
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /candidate/matches/:id/status — Accept or deny a match
// ---------------------------------------------------------------------------
async function updateMatchStatus(req, res, next) {
  try {
    const candidate = await db('candidates').where({ user_id: req.user.id }).first();
    if (!candidate) throw AppError.notFound('Candidate not found.');
    const { status } = req.body;
    if (!['accepted', 'denied'].includes(status)) throw AppError.badRequest('Status must be accepted or denied.');
    const match = await db('matches').where({ id: req.params.id, candidate_id: candidate.id }).first();
    if (!match) throw AppError.notFound('Match not found.');
    await db('matches').where({ id: match.id }).update({ status, updated_at: db.fn.now() });
    ok(res, { success: true, status });
  } catch (err) { next(err); }
}

/** Compact one-liner for an inline reply quote — same logic as
 *  `messageReplyEnvelope._bodyPreviewFor` but operates on the flat
 *  columns that the listMessages LEFT JOIN exposes (no extra round
 *  trip). Keep the two implementations in sync if you change either. */
function _replyBodyPreview(attachmentType, body, sharedEntityType, albumImageUrls) {
  if (attachmentType === 'deleted') return 'This message was deleted';
  if (attachmentType === 'audio') return '🎤 Voice message';
  if (attachmentType === 'image') return '🖼 Photo';
  if (attachmentType === 'document') return '📄 Document';
  if (attachmentType === 'location') return '📍 Location';
  if (attachmentType === 'entity_share') {
    return _entitySharePreview(sharedEntityType);
  }
  if (attachmentType === 'album') {
    const urls = _normalizeAlbumUrls(albumImageUrls);
    const len = Array.isArray(urls) ? urls.length : 0;
    return `📷 Album · ${len} photo${len === 1 ? '' : 's'}`;
  }
  return (body || '').slice(0, 200);
}

/** pg's jsonb adapter sometimes hands us back the array pre-parsed,
 *  sometimes a JSON string (depends on driver path / .returning('*')
 *  vs .select). Normalize once so downstream consumers (SSE payload,
 *  reply preview, listMessages enrichment) all see a real Array. */
function _normalizeAlbumUrls(value) {
  if (value == null) return null;
  if (Array.isArray(value)) return value;
  if (typeof value === 'string') {
    try {
      const parsed = JSON.parse(value);
      return Array.isArray(parsed) ? parsed : null;
    } catch (_) {
      return null;
    }
  }
  return null;
}

/** Glyph + label used as `conversations.last_message` when the
 *  outgoing message is an entity share. Mirrors the icons used by
 *  the Flutter EntityShareBubble so the inbox preview matches what
 *  the user sees in the thread. */
function _entitySharePreview(type) {
  switch (type) {
    case 'profile_candidate':
    case 'profile_business':
      return '📋 Profile';
    case 'job':
      return '💼 Job';
    case 'interview':
      return '📅 Interview';
    default:
      return '📎 Shared item';
  }
}

// ---------------------------------------------------------------------------
// GET /candidate/businesses/:id — Public-ish business profile
// ---------------------------------------------------------------------------
// Surfaced primarily to support EntityShareBubble navigation when a
// candidate taps a shared business profile card. Returns a curated
// subset of `businesses` + the owner-user's photo. Lookup tolerates
// both `businesses.id` and `businesses.user_id` so the route works
// regardless of which identifier the share envelope persisted.
async function getBusinessProfile(req, res, next) {
  try {
    const id = req.params.id;
    if (!id) throw AppError.badRequest('Business id required.');
    const row = await db('businesses')
      .leftJoin('users', 'businesses.user_id', 'users.id')
      .where(function () {
        this.where('businesses.id', id).orWhere('businesses.user_id', id);
      })
      .select(
        'businesses.id',
        'businesses.user_id',
        'businesses.name',
        'businesses.venue_type',
        'businesses.location',
        'businesses.languages',
        'businesses.website',
        'businesses.is_verified',
        'businesses.avatar_hue',
        'businesses.latitude',
        'businesses.longitude',
        'users.photo_url',
        'users.email',
        'users.phone',
      )
      .first();
    if (!row) throw AppError.notFound('Business not found.');
    ok(res, {
      id: row.id,
      user_id: row.user_id,
      name: row.name,
      venue_type: row.venue_type,
      location: row.location,
      languages: row.languages,
      website: row.website || null,
      is_verified: !!row.is_verified,
      avatar_hue: row.avatar_hue,
      latitude: row.latitude,
      longitude: row.longitude,
      photo_url: row.photo_url || null,
      email: row.email || null,
      phone: row.phone || null,
    });
  } catch (err) { next(err); }
}

module.exports = {
  getBusinessProfile,
  listBusinessJobsForConversation,
  listInterviewsForConversation,
  profile, home, featuredJobs,
  listJobs, getJob, applyToJob,
  listApplications, getApplication, withdrawApplication,
  listInterviews, getInterview, respondToInterview,
  listConversations, listMessages, sendMessage, sendTyping, ackMessagesDelivered, archiveConversation,
  addMessageReaction, removeMessageReaction,
  starMessage, unstarMessage,
  hideMessageForMe, deleteMessageForEveryone,
  reportMessage,
  updateProfile, uploadPhoto, uploadCV, parseCV,
  listCommunityPosts,
  nearbyJobs, quickjobsDeck, quickjobsSwipe,
  listMatches, submitMatchFeedback, updateMatchStatus,
  listCandidateNotifications, candidateUnreadCount, markCandidateNotifRead, markAllCandidateNotifsRead,
  deleteCandidateNotif, deleteAllCandidateNotifs,
};
