const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const AppError = require('../utils/AppError');
const { bus } = require('../services/realtime/eventBus');

// ---------------------------------------------------------------------------
// Candidate Quick Jobs daily swipe cap
// ---------------------------------------------------------------------------
// Server-side enforced cap on how many cards a candidate can swipe in a
// single UTC day. Free candidates only — premium / unlimited tiers will
// override this via subscription resolution once that feature lands.
//
// Both interested=true and interested=false swipes count: we want the
// cap to throttle deck consumption regardless of direction so no one can
// burn the deck by mass-passing.
const FREE_DAILY_QUICKJOB_SWIPE_LIMIT = 5;

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

// Resolves the daily Quick Jobs swipe cap for a candidate. Returns the
// raw count of swipes consumed today plus the derived remaining /
// reached fields the deck and swipe endpoints surface to Flutter.
//
// Hook point for premium: when candidate subscriptions ship, branch on
// the cached subscription tier here and return Infinity (or a large
// premium cap) instead of FREE_DAILY_QUICKJOB_SWIPE_LIMIT.
async function resolveQuickjobSwipeQuota(candidateId) {
  const dailyLimit = FREE_DAILY_QUICKJOB_SWIPE_LIMIT;
  const since = utcDayStart();
  const row = await db('candidate_quickjob_swipes')
    .where({ candidate_id: candidateId })
    .andWhere('swiped_at', '>=', since)
    .count({ n: '*' })
    .first();
  const swipesUsed = parseInt(row?.n, 10) || 0;
  const swipesRemaining = Math.max(dailyLimit - swipesUsed, 0);
  const hasReachedLimit = swipesUsed >= dailyLimit;
  return { dailyLimit, swipesUsed, swipesRemaining, hasReachedLimit };
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
        'businesses.id as business_id', 'businesses.name as business_name',
        'businesses.initials as business_initials',
        'businesses.is_verified as business_verified',
        'businesses.avatar_hue as business_avatar_hue',
        'biz_users.photo_url as business_photo_url'
      )
      .orderByRaw('jobs.is_featured DESC, jobs.created_at DESC')
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
    const job = await db('jobs')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .leftJoin('users as biz_users', 'businesses.user_id', 'biz_users.id')
      .where('jobs.id', req.params.id)
      .where('jobs.status', 'active')
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
    const total = await db('messages').where({ conversation_id: conv.id }).count('* as c').first().then(r => +r.c);

    // Pull the LATEST `limit` messages (desc + offset), then reverse to
    // chronological order for the client. Previous behaviour was ASC + offset
    // which silently truncated long threads to the oldest page and made the
    // chat appear "stuck" once the conversation crossed the page size.
    const msgs = (await db('messages')
      .leftJoin('users', 'messages.sender_id', 'users.id')
      .where('messages.conversation_id', conv.id)
      .select(
        'messages.id', 'messages.body', 'messages.is_read', 'messages.delivered_at',
        'messages.sender_id', 'messages.created_at',
        'users.name as sender_name', 'users.user_type as sender_type'
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

    paginated(res, msgs, { page: +page, limit: +limit, total });
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

    const { body } = req.body;
    if (!body || !body.trim()) throw AppError.badRequest('Message body is required.');

    const [msg] = await db('messages').insert({
      conversation_id: conv.id,
      sender_id: userId,
      body: body.trim(),
    }).returning('*');

    // Update conversation last_message
    await db('conversations').where({ id: conv.id }).update({
      last_message: body.trim().slice(0, 200),
      updated_at: db.fn.now(),
    });

    console.log(`[BACKEND CREATE] candidate→business msgId=${msg.id} convId=${conv.id} candidateUserId=${userId} businessId=${conv.business_id || 'null'} body="${msg.body}"`);

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
        'in_app', conv.id, 'message', body.trim().slice(0, 80),
      );
    } catch (e) { /* best-effort */ }

    // Realtime broadcast
    const audience = ['role:admin', `user:${userId}`];
    if (businessUserId) audience.push(`user:${businessUserId}`);
    console.log(`[SSE EMIT] type=message.new convId=${conv.id} senderUserId=${userId} recipientUserId=${businessUserId || 'null'} audience=${JSON.stringify(audience)}`);
    bus.publish('message.new', {
      message: {
        id: msg.id,
        conversation_id: conv.id,
        body: msg.body,
        sender_id: msg.sender_id,
        created_at: msg.created_at,
        delivered_at: msg.delivered_at || null,
        is_read: !!msg.is_read,
      },
      conversation_id: conv.id,
      sender_user_id: userId,
      recipient_user_id: businessUserId,
      sender_role: 'candidate',
    }, audience);

    ok(res, msg);
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

    const candRole = (cand.primary_role || cand.role || '').trim();

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

    const candRoleLc = candRole.toLowerCase();
    const data = rows.map((r) => {
      const title = (r.title || '').toLowerCase();
      const cat = (r.category || '').toLowerCase();
      const mainRole = (r.main_role_needed || '').toLowerCase();
      const overlaps = (a, b) =>
        a.length > 0 && b.length > 0 && (a.includes(b) || b.includes(a));
      const roleMatch = candRoleLc.length > 0 && (
        overlaps(title, candRoleLc) ||
        overlaps(cat, candRoleLc) ||
        overlaps(mainRole, candRoleLc)
      );
      return {
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
        role_match: roleMatch,
        business: {
          id: r.business_id,
          name: r.business_name || '',
          initials: r.business_initials || '',
          verified: !!r.business_verified,
          venue_type: r.business_venue_type || '',
          logo_url: r.business_photo_url || null,
          avatar_hue: r.business_avatar_hue,
        },
      };
    });

    // Stable secondary sort: role_match=true first while preserving the
    // SQL-imposed order within each group.
    data.sort((a, b) => {
      if (a.role_match === b.role_match) return 0;
      return a.role_match ? -1 : 1;
    });

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

async function uploadPhoto(req, res, next) {
  try {
    const { photo } = req.body;
    // Empty string = remove photo
    const photoUrl = (photo && photo.trim()) ? photo : null;
    if (photoUrl && photoUrl.length > 4 * 1024 * 1024) throw AppError.badRequest('Photo too large. Please choose a smaller image.');

    await db('users').where({ id: req.user.id }).update({ photo_url: photoUrl, updated_at: db.fn.now() });
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

module.exports = {
  profile, home, featuredJobs,
  listJobs, getJob, applyToJob,
  listApplications, getApplication, withdrawApplication,
  listInterviews, getInterview, respondToInterview,
  listConversations, listMessages, sendMessage, sendTyping, ackMessagesDelivered, archiveConversation,
  updateProfile, uploadPhoto, uploadCV, parseCV,
  listCommunityPosts,
  nearbyJobs, quickjobsDeck, quickjobsSwipe,
  listMatches, submitMatchFeedback, updateMatchStatus,
  listCandidateNotifications, candidateUnreadCount, markCandidateNotifRead, markAllCandidateNotifsRead,
  deleteCandidateNotif, deleteAllCandidateNotifs,
};
