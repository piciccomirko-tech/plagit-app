const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const AppError = require('../utils/AppError');
const { bus } = require('../services/realtime/eventBus');
const { scoreCandidateAgainstBusinessJobs } = require('../services/matchScoring');

// ---------------------------------------------------------------------------
// Business Quick Plug daily swipe cap
// ---------------------------------------------------------------------------
// Server-side enforced cap on how many candidate cards a business can
// swipe in a single UTC day. Plan-aware: cap is derived from the
// business owner's users.subscription_plan. Unknown / null plans fall
// back to 'free'. Mirrors the candidate-side Quick Jobs quota so the
// two flows share the same source-of-truth pattern.
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

// Maps the full product-string form stored in users.subscription_plan
// (e.g. 'business_pro_monthly', 'business_premium_annual') to the simple
// tier name Flutter's BusinessSubscriptionPlan enum understands. Direct
// simple tier strings pass through; anything unknown falls back to free.
// Keep aligned with the IAP product IDs in subscriptionController.js.
function normalizeBusinessPlan(rawPlan) {
  const s = (rawPlan || 'free').toString().toLowerCase().trim();
  if (!s || s === 'free' || s === 'none' || s === 'inactive') return 'free';
  if (s.includes('premium')) return 'premium';
  if (s.includes('pro')) return 'pro';
  if (s.includes('basic')) return 'basic';
  return 'free';
}

// Active job posting cap, mirrors PLAN_QUOTA_MAP. Enforced in createJob
// (Step D) by counting jobs.status='active' for the business and rejecting
// the insert before it touches the table when the cap is reached.
const PLAN_JOB_LIMIT_MAP = {
  free: 1,
  basic: 1,
  pro: 10,
  premium: 999,
};

// Resolves the active-job cap for the current user's plan. Mirrors the
// shape of resolveQuickplugSwipeQuota so call sites read the same way.
async function resolveBusinessJobLimit(userId) {
  const user = await db('users')
    .where({ id: userId })
    .select('subscription_plan')
    .first();
  const plan = normalizeBusinessPlan(user?.subscription_plan);
  const activeJobLimit = PLAN_JOB_LIMIT_MAP[plan] ?? PLAN_JOB_LIMIT_MAP.free;
  return { plan, activeJobLimit };
}

// UTC midnight for "today" — matches the index on
// business_quickplug_swipes(business_id, swiped_at) without leaking
// per-tenant timezone state into the cap definition.
function utcDayStart(d = new Date()) {
  return new Date(Date.UTC(
    d.getUTCFullYear(),
    d.getUTCMonth(),
    d.getUTCDate(),
    0, 0, 0, 0,
  ));
}

// Resolves the daily Quick Plug swipe cap for a business. Joins
// businesses → users to read subscription_plan, maps it via
// PLAN_QUOTA_MAP, and returns the count of swipes consumed today plus
// the derived remaining / reached fields the deck and swipe endpoints
// surface to Flutter. Falls back to 'free' if the plan is missing.
async function resolveQuickplugSwipeQuota(businessId) {
  const planRow = await db('businesses')
    .join('users', 'users.id', 'businesses.user_id')
    .where('businesses.id', businessId)
    .select('users.subscription_plan as plan')
    .first();
  const plan = planRow?.plan || 'free';
  const dailyLimit = resolvePlanLimit(plan);
  const since = utcDayStart();
  const row = await db('business_quickplug_swipes')
    .where({ business_id: businessId })
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
//
// `body` is optional and only persisted when the migration that adds
// the `notifications.body` column has run — wrapped in try/catch so
// older deployments don't crash on insert.
async function hiringNotify(recipientId, title, type, linkedEntity, route, body) {
  try {
    // Idempotency guard — when both linkedEntity and route are
    // provided, skip if a notification with the same
    // (recipient, entity, route) triple already exists. Prevents
    // duplicate "job posted" rows on retries / hot-reloads / repeat
    // createJob fan-outs for the same job.
    if (linkedEntity && route) {
      const existing = await db('notifications')
        .where({ recipient_id: recipientId, linked_entity: linkedEntity, destination_route: route })
        .first();
      if (existing) return;
    }
    const row = {
      recipient_id: recipientId,
      notification_type: type || 'in_app',
      title,
      linked_entity: linkedEntity || null,
      destination_route: route || null,
      delivery_state: 'delivered',
      is_read: false,
    };
    if (body) row.body = body;
    await db('notifications').insert(row);
    bus.publish('notification.new', {
      recipient_user_id: recipientId,
      title,
      body: body || null,
      notification_type: type || 'in_app',
      linked_entity: linkedEntity || null,
      destination_route: route || null,
    }, ['role:admin', `user:${recipientId}`]);
  } catch (e) { /* ignore if table missing */ }
}

// Fan-out a single platform event (e.g. "new job posted") to every
// admin user as their own notification row, so the admin list
// renders correctly even though the controller does not filter by
// recipient. The shared SSE audience `role:admin` still ensures live
// refresh on all admin clients regardless of recipient.
async function notifyAllAdmins(title, type, linkedEntity, route, body) {
  try {
    const admins = await db('users').where({ user_type: 'admin' }).select('id');
    for (const a of admins) {
      await hiringNotify(a.id, title, type, linkedEntity, route, body);
    }
  } catch (e) { console.error('[notifyAllAdmins]', e.message); }
}

// ---------------------------------------------------------------------------
// Mutual-interest matching
// ---------------------------------------------------------------------------
// A mutual match exists when BOTH sides have shown explicit interest:
//   - business shortlisted the candidate (Quick Plug shortlist row)
//   - candidate applied to one of that business's jobs
//
// `tryCreateMutualMatch` is the single insertion point. It is
// idempotent on the (business_id, candidate_id, job_id) unique index,
// so callers can fire it from either direction (shortlist-then-apply
// or apply-then-shortlist) without worrying about duplicates.
//
// On *new* match creation it:
//   - looks up candidate.user_id + display name and business.name
//   - notifies both sides + every admin
//   - publishes a `match.created` SSE event so all three audiences
//     refresh in real time
//
// Returns true when a new match row was inserted, false when the
// match already existed (no notifications fired in that case).
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
// GET /business/profile — Business profile
// ---------------------------------------------------------------------------
async function profile(req, res, next) {
  try {
    const user = await db('users').where({ id: req.user.id }).first();
    if (!user) throw AppError.notFound('User not found.');

    const biz = await db('businesses').where({ user_id: user.id }).first();

    ok(res, {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      location: user.location,
      status: user.status,
      is_verified: user.is_verified,
      avatar_hue: user.avatar_hue || 0.5,
      photo_url: user.photo_url || null,
      profile_strength: user.profile_strength || 0,
      // Business-specific
      company_name: biz?.name || user.name,
      company_initials: biz?.initials || user.name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2),
      venue_type: biz?.venue_type || null,
      business_location: biz?.location || null,
      is_featured: biz?.is_featured || false,
      plan: biz?.plan || null,
      plan_status: biz?.plan_status || null,
      response_rate: biz?.response_rate || 0,
      languages: biz?.languages || null,
      country: biz?.country || null,
      country_code: biz?.country_code || null,
      created_at: user.created_at,
      // Subscription
      subscription_plan: user.subscription_plan || 'free',
      subscription_status: user.subscription_status || 'inactive',
      subscription_expires: user.subscription_expires || null,
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/home — Aggregated dashboard data
// ---------------------------------------------------------------------------
async function home(req, res, next) {
  try {
    const userId = req.user.id;
    const biz = await db('businesses').where({ user_id: userId }).first();
    const bizId = biz?.id || null;

    // Active jobs count
    let activeJobs = 0;
    let totalApplicants = 0;
    let newApplicants = 0;
    let interviewCount = 0;

    let activeJobsList = [];
    let recentApplicantsList = [];

    if (bizId) {
      const jobs = await db('jobs').where({ business_id: bizId }).select('*').orderBy('created_at', 'desc');
      const activeOnly = jobs.filter(j => j.status === 'active');
      activeJobs = activeOnly.length;
      activeJobsList = activeOnly.slice(0, 10);

      // Attach applicant counts for the active jobs we'll return
      for (const j of activeJobsList) {
        const c = await db('applications').where({ job_id: j.id }).count('* as c').first();
        j.applicant_count = +(c?.c || 0);
      }

      const activeJobIds = activeOnly.map(j => j.id);
      if (activeJobIds.length > 0) {
        const apps = await db('applications').whereIn('job_id', activeJobIds).select('status', 'created_at');
        totalApplicants = apps.length;
        const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
        newApplicants = apps.filter(a => new Date(a.created_at) > weekAgo).length;
        interviewCount = apps.filter(a => a.status === 'interview').length;

        // Recent applicants (top 5 across all active jobs, joined with candidate + job)
        const recentRows = await db('applications')
          .whereIn('applications.job_id', activeJobIds)
          .leftJoin('candidates', 'applications.candidate_id', 'candidates.id')
          .leftJoin('jobs', 'applications.job_id', 'jobs.id')
          .select(
            'applications.id as id',
            'applications.status as status',
            'applications.created_at as created_at',
            'applications.candidate_id as candidate_id',
            'applications.job_id as job_id',
            'candidates.name as candidate_name',
            'candidates.role as candidate_role',
            'candidates.initials as candidate_initials',
            'candidates.avatar_hue as avatar_hue',
            'jobs.title as job_title',
          )
          .orderBy('applications.created_at', 'desc')
          .limit(5);
        recentApplicantsList = recentRows;
      }
    }

    // Upcoming interviews
    let nextInterview = null;
    if (bizId) {
      const jobIds = await db('jobs').where({ business_id: bizId }).select('id').then(r => r.map(j => j.id));
      if (jobIds.length > 0) {
        nextInterview = await db('interviews')
          .whereIn('job_id', jobIds)
          .whereIn('status', ['pending', 'confirmed'])
          .where('scheduled_at', '>', db.fn.now())
          .orderBy('scheduled_at', 'asc')
          .first();
        if (nextInterview) {
          const job = await db('jobs').where({ id: nextInterview.job_id }).select('title').first();
          const cand = await db('candidates').where({ id: nextInterview.candidate_id }).select('name', 'initials').first();
          nextInterview.job_title = job?.title || 'Unknown';
          nextInterview.candidate_name = cand?.name || 'Unknown';
          nextInterview.candidate_initials = cand?.initials || '?';
        }
      }
    }

    // Unread messages
    let unreadMessages = 0;
    if (bizId) {
      unreadMessages = await db('messages')
        .leftJoin('conversations', 'messages.conversation_id', 'conversations.id')
        .where('conversations.business_id', bizId)
        .where('messages.is_read', false)
        .whereNot('messages.sender_id', userId)
        .count('* as c').first().then(r => +r.c);
    }

    const user = await db('users').where({ id: userId }).first();

    ok(res, {
      business: {
        company_name: biz?.name || user.name,
        company_initials: biz?.initials || '?',
        venue_type: biz?.venue_type || null,
        location: biz?.location || user.location,
        avatar_hue: biz?.avatar_hue || user.avatar_hue || 0.5,
        is_verified: biz?.is_verified || false,
        photo_url: user.photo_url || null,
        profile_lat: user.latitude || null,
        profile_lng: user.longitude || null,
        app_language_code: user.app_language_code || 'en',
        spoken_languages: user.spoken_languages || null,
        country: biz?.country || null,
        country_code: biz?.country_code || null,
        subscription_plan: user.subscription_plan || 'free',
        subscription_status: user.subscription_status || 'inactive',
      },
      stats: {
        active_jobs: activeJobs,
        total_applicants: totalApplicants,
        new_applicants: newApplicants,
        interviews: interviewCount,
      },
      activeJobs: activeJobsList,
      recentApplicants: recentApplicantsList,
      next_interview: nextInterview,
      unread_messages: unreadMessages,
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/subscription — Plan + derived limits for the auth'd business
// ---------------------------------------------------------------------------
// Reads users.subscription_plan / status / expires for the current user and
// returns a Flutter-shaped payload (camelCase, simple tier strings, derived
// limits). Read-only and idempotent; safe to hit on every login. Falls back
// to 'free' when the row or columns are missing so the Flutter UI never
// hits a 404 path post Step C.
async function subscription(req, res, next) {
  try {
    const user = await db('users')
      .where({ id: req.user.id })
      .select(
        'subscription_plan',
        'subscription_status',
        'subscription_expires',
        'subscription_product_id',
        'created_at',
      )
      .first();

    let rawPlan = user?.subscription_plan || 'free';
    let status = user?.subscription_status || 'inactive';
    const expires = user?.subscription_expires || null;

    // Mirror the grace-period logic from /v1/subscription/status without
    // writing back to the DB: that endpoint is the writer, this one is
    // read-only and called frequently from Flutter.
    if (expires && new Date(expires) < new Date()) {
      const graceEnd = new Date(new Date(expires).getTime() + 7 * 24 * 60 * 60 * 1000);
      const now = new Date();
      if (now < graceEnd && status === 'active') {
        status = 'grace';
      } else {
        status = 'expired';
        rawPlan = 'free';
      }
    }

    const plan = normalizeBusinessPlan(rawPlan);
    const dailyQuickPlugLimit = PLAN_QUOTA_MAP[plan] ?? PLAN_QUOTA_MAP.free;
    const activeJobLimit = PLAN_JOB_LIMIT_MAP[plan] ?? PLAN_JOB_LIMIT_MAP.free;

    ok(res, {
      plan,
      status,
      dailyQuickPlugLimit,
      activeJobLimit,
      isPro: plan === 'pro',
      isPremium: plan === 'premium',
      startDate: user?.created_at ? new Date(user.created_at).toISOString() : null,
      renewalDate: expires ? new Date(expires).toISOString() : null,
      productId: user?.subscription_product_id || null,
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// Helper: get business ID for current user
// ---------------------------------------------------------------------------
async function getBizId(userId) {
  const biz = await db('businesses').where({ user_id: userId }).first();
  if (!biz) throw AppError.badRequest('Business profile not found.');
  return biz.id;
}

// ---------------------------------------------------------------------------
// GET /business/jobs — Business's own jobs
// ---------------------------------------------------------------------------
async function listJobs(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const { page = 1, limit = 50, status } = req.query;
    let base = db('jobs').where({ business_id: bizId });
    if (status) base = base.where('status', status);
    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone().select('*').orderBy('created_at', 'desc').limit(+limit).offset((+page - 1) * +limit);

    // Attach applicant counts
    for (const job of rows) {
      const c = await db('applications').where({ job_id: job.id }).count('* as c').first();
      job.applicant_count = +(c?.c || 0);
    }
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /business/jobs — Create a new job
// ---------------------------------------------------------------------------
async function createJob(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const { title, location, employment_type, salary, category, latitude, longitude,
            description, requirements, is_urgent, num_hires, start_date, end_date, shift_hours,
            open_to_international } = req.body;
    if (!title) throw AppError.badRequest('Job title is required.');

    // Plan-aware active job cap (Step D). Counts only jobs.status='active'
    // — paused / closed jobs don't count toward the cap, and existing
    // active jobs above-cap are grandfathered in (the cap blocks new
    // inserts, never the existing rows). Returns a structured 403 with
    // code=JOB_LIMIT_REACHED so Flutter can render a tailored upgrade CTA
    // instead of a generic error toast.
    const { plan, activeJobLimit } = await resolveBusinessJobLimit(req.user.id);
    const activeRow = await db('jobs')
      .where({ business_id: bizId, status: 'active' })
      .count({ n: '*' })
      .first();
    const activeJobCount = parseInt(activeRow?.n, 10) || 0;
    if (activeJobCount >= activeJobLimit) {
      return res.status(403).json({
        error: 'Upgrade your plan to post more active jobs.',
        code: 'JOB_LIMIT_REACHED',
        message: 'Upgrade your plan to post more active jobs.',
        activeJobLimit,
        activeJobCount,
        plan,
      });
    }

    const avatarHue = Math.random() * 0.8 + 0.1;
    const [job] = await db('jobs').insert({
      business_id: bizId, title, location: location || null,
      employment_type: employment_type || null, salary: salary || null,
      category: category || null, status: 'active', avatar_hue: avatarHue,
      latitude: latitude || null, longitude: longitude || null,
      description: description || null, requirements: requirements || null,
      is_urgent: is_urgent || false, num_hires: num_hires || 1,
      start_date: start_date || null, end_date: end_date || null,
      shift_hours: shift_hours || null,
      open_to_international: open_to_international || false,
    }).returning('*');

    // Admin notification: fan-out to every admin user so the platform
    // operator team sees a "New job posted by X" entry with a tap target
    // that deep-links to /admin/jobs/:id. Title is the headline, body
    // packs role · location · salary so the row carries enough context
    // to triage without opening the detail.
    (async () => {
      try {
        const biz = await db('businesses').where({ id: bizId }).first();
        const businessName = biz?.name || 'a business';
        const subtitleParts = [
          category || null,
          location || null,
          salary || null,
        ].filter((p) => p && String(p).trim().length > 0);
        await notifyAllAdmins(
          `${businessName} posted a new job`,
          'in_app',
          job.id,
          'job',
          subtitleParts.join(' • '),
        );
      } catch (e) { console.error('[Admin job notify]', e.message); }
    })();

    // Send match notifications to matching candidates (async, non-blocking).
    // Match a candidate when their role matches the job title or category
    // (case-insensitive substring). Optional employment_type filter only when
    // the candidate has job_type set — otherwise we don't exclude them.
    (async () => {
      try {
        const biz = await db('businesses').where({ id: bizId }).first();
        const businessName = biz?.name || 'a business';
        const subtitleParts = [title, location || null, salary || null].filter(Boolean);
        const notifTitle = `${businessName} posted a new job`;
        const notifBody  = subtitleParts.join(' • ');

        const titleNeedle = `%${(title || '').toLowerCase().trim()}%`;
        const catNeedle   = category ? `%${category.toLowerCase().trim()}%` : null;
        const empType     = employment_type ? employment_type.toLowerCase().trim() : null;

        // Already-applied dedup — never notify a candidate about a job
        // they have already applied to. The job is brand-new so the set
        // is typically empty, but the filter is defensive against
        // re-create / replay scenarios.
        const appliedRows = await db('applications')
          .where({ job_id: job.id })
          .select('candidate_id');
        const appliedIds = appliedRows.map((r) => r.candidate_id);

        const baseQ = db('candidates')
          .leftJoin('users', 'candidates.user_id', 'users.id')
          .where('users.user_type', 'candidate')
          .where('users.status', 'active');

        const matchedCandidates = await baseQ.clone()
          .modify((q) => {
            if (appliedIds.length) q.whereNotIn('candidates.id', appliedIds);
          })
          .andWhere(b => {
            b.whereRaw('LOWER(TRIM(candidates.role)) LIKE ?', [titleNeedle]);
            if (catNeedle) b.orWhereRaw('LOWER(TRIM(candidates.role)) LIKE ?', [catNeedle]);
          })
          .andWhere(b => {
            b.whereNull('candidates.job_type')
             .orWhereRaw("TRIM(COALESCE(candidates.job_type,'')) = ''");
            if (empType) b.orWhereRaw('LOWER(TRIM(candidates.job_type)) = ?', [empType]);
          })
          .select('users.id as user_id', 'candidates.id as cand_id')
          .limit(50);

        const notified = new Set();
        for (const mc of matchedCandidates) {
          try { await db('matches').insert({ candidate_id: mc.cand_id, job_id: job.id, status: 'pending' }); } catch (_) {}
          await hiringNotify(mc.user_id, notifTitle, 'in_app', job.id, 'job', notifBody);
          notified.add(mc.cand_id);
        }

        if (open_to_international) {
          const intlCandidates = await baseQ.clone()
            .where('candidates.available_to_relocate', true)
            .modify((q) => {
              if (appliedIds.length) q.whereNotIn('candidates.id', appliedIds);
            })
            .andWhere(b => {
              b.whereRaw('LOWER(TRIM(candidates.role)) LIKE ?', [titleNeedle]);
              if (catNeedle) b.orWhereRaw('LOWER(TRIM(candidates.role)) LIKE ?', [catNeedle]);
            })
            .select('users.id as user_id', 'candidates.id as cand_id')
            .limit(50);
          for (const ic of intlCandidates) {
            if (notified.has(ic.cand_id)) continue;
            try { await db('matches').insert({ candidate_id: ic.cand_id, job_id: job.id, status: 'pending' }); } catch (_) {}
            await hiringNotify(ic.user_id, notifTitle, 'in_app', job.id, 'job', notifBody);
          }
        }
      } catch (e) { console.error('[Match notify]', e.message); }
    })();

    ok(res, job);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/jobs/:id — Single job detail with applicant count
// ---------------------------------------------------------------------------
async function getJob(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const job = await db('jobs').where({ id: req.params.id, business_id: bizId }).first();
    if (!job) throw AppError.notFound('Job not found.');
    const c = await db('applications').where({ job_id: job.id }).count('* as c').first();
    job.applicant_count = +(c?.c || 0);
    ok(res, job);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /business/jobs/:id/duplicate — Clone a job as a new Draft
// ---------------------------------------------------------------------------
// Loads the source job (scoped by business owner), strips immutable fields
// (id, timestamps, counters), forces status = 'draft', and inserts a fresh
// row. The duplicate is invisible to candidates until the business
// edits + activates it.
async function duplicateJob(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const src = await db('jobs').where({ id: req.params.id, business_id: bizId }).first();
    if (!src) throw AppError.notFound('Job not found.');
    const {
      id, created_at, updated_at, views, ...clone
    } = src;
    void id; void created_at; void updated_at; void views;
    clone.status = 'draft';
    clone.title = `${src.title} (Copy)`;
    const [created] = await db('jobs').insert(clone).returning('*');
    ok(res, created);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /business/jobs/:id — Update job fields
// ---------------------------------------------------------------------------
async function updateJob(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const { title, location, employment_type, salary, category, status,
            description, requirements, is_urgent, num_hires, start_date, end_date, shift_hours,
            open_to_international } = req.body;
    const updates = {};
    if (title !== undefined) updates.title = title;
    if (location !== undefined) updates.location = location;
    if (open_to_international !== undefined) updates.open_to_international = open_to_international;
    if (employment_type !== undefined) updates.employment_type = employment_type;
    if (salary !== undefined) updates.salary = salary;
    if (category !== undefined) updates.category = category;
    if (status !== undefined) updates.status = status;
    if (description !== undefined) updates.description = description;
    if (requirements !== undefined) updates.requirements = requirements;
    if (is_urgent !== undefined) updates.is_urgent = is_urgent;
    if (num_hires !== undefined) updates.num_hires = num_hires;
    if (start_date !== undefined) updates.start_date = start_date;
    if (end_date !== undefined) updates.end_date = end_date;
    if (shift_hours !== undefined) updates.shift_hours = shift_hours;
    if (Object.keys(updates).length === 0) throw AppError.badRequest('No fields to update.');
    updates.updated_at = db.fn.now();
    const [updated] = await db('jobs').where({ id: req.params.id, business_id: bizId }).update(updates).returning('*');
    if (!updated) throw AppError.notFound('Job not found.');
    ok(res, updated);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/jobs/:id/applicants — Applicants for a specific job
// ---------------------------------------------------------------------------
async function listApplicants(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const job = await db('jobs').where({ id: req.params.id, business_id: bizId }).first();
    if (!job) throw AppError.notFound('Job not found.');
    const { page = 1, limit = 50, status } = req.query;
    let base = db('applications')
      .leftJoin('candidates', 'applications.candidate_id', 'candidates.id')
      .leftJoin('users', 'candidates.user_id', 'users.id')
      .where('applications.job_id', job.id);
    if (status) base = base.where('applications.status', status);
    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone().select(
      'applications.id', 'applications.status', 'applications.created_at as applied_at',
      'applications.has_interview', 'applications.has_offer',
      'candidates.id as candidate_id', 'candidates.name as candidate_name',
      'candidates.initials as candidate_initials', 'candidates.role as candidate_role',
      'candidates.location as candidate_location', 'candidates.experience as candidate_experience',
      'candidates.avatar_hue as candidate_avatar_hue', 'candidates.nationality_code as candidate_nationality_code',
      'users.is_verified as candidate_verified',
      'users.photo_url as candidate_photo_url'
    ).orderBy('applications.created_at', 'desc').limit(+limit).offset((+page - 1) * +limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /business/applicants/:id/status — Update applicant status
// ---------------------------------------------------------------------------
async function updateApplicantStatus(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const { status } = req.body;
    console.log(`[STATUS-DBG] PATCH /business/applicants/${req.params.id}/status status=${status} bizUserId=${req.user.id}`);
    if (!status) throw AppError.badRequest('Status is required.');
    // Verify this application belongs to a job owned by this business
    const app = await db('applications').leftJoin('jobs', 'applications.job_id', 'jobs.id')
      .where('applications.id', req.params.id).where('jobs.business_id', bizId)
      .select('applications.id').first();
    if (!app) {
      console.log(`[STATUS-DBG] application=${req.params.id} not found for bizId=${bizId}`);
      throw AppError.notFound('Application not found.');
    }
    await db('applications').where({ id: app.id }).update({ status, updated_at: db.fn.now() });
    // Notify candidate of status change
    const fullApp = await db('applications').leftJoin('candidates', 'applications.candidate_id', 'candidates.id')
      .where('applications.id', app.id).select('candidates.user_id', 'applications.job_id').first();
    console.log(`[STATUS-DBG] candidate user_id recipient=${fullApp?.user_id} job_id=${fullApp?.job_id}`);
    let jobTitle = null;
    if (fullApp?.user_id) {
      const job = await db('jobs').where({ id: fullApp.job_id }).select('title').first();
      jobTitle = job?.title || null;
      // Resolve business display name (companies.name preferred, fallback to owner user.name)
      const biz = await db('businesses').where({ id: bizId }).select('name', 'user_id').first();
      let businessName = biz?.name || null;
      if (!businessName && biz?.user_id) {
        const ownerUser = await db('users').where({ id: biz.user_id }).select('name').first();
        businessName = ownerUser?.name || 'a business';
      }
      businessName = businessName || 'a business';
      const job_label = jobTitle || 'a job';
      let title;
      let body;
      if (status === 'shortlisted') {
        title = `You have been shortlisted by ${businessName}`;
        body = `For ${job_label}`;
      } else if (status === 'rejected') {
        title = 'Your application was not selected';
        body = `For ${job_label} at ${businessName}`;
      } else if (status === 'under_review') {
        title = `Application under review for ${job_label}`;
        body = `${businessName} is reviewing your application`;
      } else if (status === 'offer') {
        title = `You received an offer from ${businessName}`;
        body = `For ${job_label}`;
      } else {
        title = `Status update for ${job_label}`;
        body = `${businessName} updated your application`;
      }
      try {
        const row = {
          recipient_id: fullApp.user_id,
          notification_type: 'in_app',
          title,
          body,
          linked_entity: app.id,
          destination_route: 'application',
          delivery_state: 'delivered',
          is_read: false,
        };
        const inserted = await db('notifications').insert(row).returning(['id', 'title', 'body']);
        const ins = inserted[0] || {};
        console.log(`[STATUS-DBG] notification inserted id=${ins.id} title="${ins.title}" body="${ins.body}"`);
        bus.publish('notification.new', {
          recipient_user_id: fullApp.user_id,
          title,
          body,
          notification_type: 'in_app',
          linked_entity: app.id,
          destination_route: 'application',
        }, ['role:admin', `user:${fullApp.user_id}`]);
      } catch (e) {
        console.error('[STATUS-DBG] notification insert failed:', e.message);
      }
      // Admin audit feed — persist a row per admin user.
      try {
        const candName = await db('candidates').where({ id: app.candidate_id }).select('name').first();
        await notifyAllAdmins(
          `Application ${status}: ${candName?.name || 'candidate'} · ${job_label}`,
          'in_app',
          app.id,
          'application',
          businessName,
        );
      } catch (e) { /* best-effort */ }
    }
    // Realtime broadcast to candidate + business + admins
    const audience = ['role:admin', `user:${req.user.id}`];
    if (fullApp?.user_id) audience.push(`user:${fullApp.user_id}`);
    bus.publish('application.status_changed', {
      application_id: app.id,
      status,
      job_id: fullApp?.job_id || null,
      job_title: jobTitle,
      candidate_user_id: fullApp?.user_id || null,
      business_user_id: req.user.id,
    }, audience);
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/interviews — Business's interviews
// ---------------------------------------------------------------------------
async function listInterviews(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const jobIds = await db('jobs').where({ business_id: bizId }).select('id').then(r => r.map(j => j.id));
    if (jobIds.length === 0) { paginated(res, [], { page: 1, limit: 50, total: 0 }); return; }
    const { page = 1, limit = 50, status } = req.query;
    let base = db('interviews')
      .leftJoin('candidates', 'interviews.candidate_id', 'candidates.id')
      .leftJoin('users', 'candidates.user_id', 'users.id')
      .leftJoin('jobs', 'interviews.job_id', 'jobs.id')
      .whereIn('interviews.job_id', jobIds);
    if (status) base = base.where('interviews.status', status);
    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone().select(
      'interviews.id', 'interviews.scheduled_at', 'interviews.timezone',
      'interviews.interview_type', 'interviews.status', 'interviews.location',
      'interviews.meeting_link', 'interviews.created_at',
      'candidates.name as candidate_name', 'candidates.initials as candidate_initials',
      'candidates.role as candidate_role', 'candidates.avatar_hue as candidate_avatar_hue', 'candidates.nationality_code as candidate_nationality_code',
      'users.photo_url as candidate_photo_url',
      'jobs.title as job_title'
    );
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /business/interviews — Schedule an interview
// ---------------------------------------------------------------------------
async function scheduleInterview(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const { application_id, candidate_id, scheduled_at, timezone, interview_type, location, meeting_link } = req.body;
    if (!scheduled_at) throw AppError.badRequest('scheduled_at is required.');

    let app;
    if (application_id) {
      app = await db('applications').leftJoin('jobs', 'applications.job_id', 'jobs.id')
        .where('applications.id', application_id).where('jobs.business_id', bizId)
        .select('applications.id', 'applications.candidate_id', 'applications.job_id').first();
    } else if (candidate_id) {
      // Find most recent application from this candidate to any of this business's jobs
      const jobIds = await db('jobs').where({ business_id: bizId }).select('id').then(r => r.map(j => j.id));
      if (jobIds.length > 0) {
        app = await db('applications')
          .where('applications.candidate_id', candidate_id)
          .whereIn('applications.job_id', jobIds)
          .orderBy('applications.created_at', 'desc')
          .select('applications.id', 'applications.candidate_id', 'applications.job_id').first();
      }
      // If no application exists, create a direct interview with first job
      if (!app && jobIds.length > 0) {
        app = { id: null, candidate_id, job_id: jobIds[0] };
      }
    }
    if (!app) throw AppError.badRequest('No application or candidate found for this business.');
    const [iv] = await db('interviews').insert({
      application_id: app.id || null, candidate_id: app.candidate_id, job_id: app.job_id,
      scheduled_at, timezone: timezone || 'UTC', interview_type: interview_type || 'video_call',
      location: location || null, meeting_link: meeting_link || null, status: 'pending',
    }).returning('*');
    if (app.id) {
      await db('applications').where({ id: app.id }).update({ status: 'interview', has_interview: true, updated_at: db.fn.now() });
    }
    // Notify candidate
    const candUser = await db('candidates').where({ id: app.candidate_id }).select('user_id').first();
    const bizUser = await db('users').where({ id: req.user.id }).first();
    if (candUser) {
      hiringNotify(candUser.user_id, `${bizUser?.name || 'A business'} invited you to interview`, 'in_app', iv.id, 'interview');
    }
    // Admin audit feed
    try {
      const candName = await db('candidates').where({ id: app.candidate_id }).select('name').first();
      const jobRow = await db('jobs').where({ id: app.job_id }).select('title').first();
      await notifyAllAdmins(
        `Interview scheduled: ${candName?.name || 'candidate'} · ${jobRow?.title || 'job'}`,
        'in_app',
        iv.id,
        'interview',
        bizUser?.name || null,
      );
    } catch (e) { /* best-effort */ }
    const audience = ['role:admin', `user:${req.user.id}`];
    if (candUser) audience.push(`user:${candUser.user_id}`);
    bus.publish('interview.scheduled', {
      interview: {
        id: iv.id,
        application_id: iv.application_id,
        candidate_id: iv.candidate_id,
        job_id: iv.job_id,
        scheduled_at: iv.scheduled_at,
        status: iv.status,
        interview_type: iv.interview_type,
      },
      business_user_id: req.user.id,
      candidate_user_id: candUser?.user_id || null,
    }, audience);
    ok(res, iv);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /business/interviews/:id/status — Update interview status
// ---------------------------------------------------------------------------
async function updateInterviewStatus(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const { status } = req.body;
    // Verify interview belongs to a job owned by this business
    const iv = await db('interviews').leftJoin('jobs', 'interviews.job_id', 'jobs.id')
      .where('interviews.id', req.params.id).where('jobs.business_id', bizId)
      .select('interviews.id', 'interviews.candidate_id', 'interviews.application_id', 'interviews.job_id')
      .first();
    if (!iv) throw AppError.notFound('Interview not found.');
    await db('interviews').where({ id: iv.id }).update({ status, updated_at: db.fn.now() });
    const candUser = await db('candidates').where({ id: iv.candidate_id }).select('user_id').first();
    const audience = ['role:admin', `user:${req.user.id}`];
    if (candUser) audience.push(`user:${candUser.user_id}`);
    bus.publish('interview.status_changed', {
      interview_id: iv.id,
      application_id: iv.application_id,
      candidate_id: iv.candidate_id,
      job_id: iv.job_id,
      status,
      actor: 'business',
      business_user_id: req.user.id,
      candidate_user_id: candUser?.user_id || null,
    }, audience);
    try {
      const candName = await db('candidates').where({ id: iv.candidate_id }).select('name').first();
      const jobRow = await db('jobs').where({ id: iv.job_id }).select('title').first();
      await notifyAllAdmins(
        `Interview ${status}: ${candName?.name || 'candidate'} · ${jobRow?.title || 'job'}`,
        'in_app', iv.id, 'interview', null,
      );
    } catch (e) { /* best-effort */ }
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PUT /business/profile — Update business profile
// ---------------------------------------------------------------------------
async function updateProfile(req, res, next) {
  try {
    const userId = req.user.id;
    const { company_name, venue_type, location, phone, contact, latitude, longitude, languages, country, country_code } = req.body;
    const userUpdates = {};
    if (phone !== undefined) userUpdates.phone = phone;
    if (location !== undefined) userUpdates.location = location;
    if (latitude !== undefined) userUpdates.latitude = latitude;
    if (longitude !== undefined) userUpdates.longitude = longitude;
    if (Object.keys(userUpdates).length) { userUpdates.updated_at = db.fn.now(); await db('users').where({ id: userId }).update(userUpdates); }
    const biz = await db('businesses').where({ user_id: userId }).first();
    if (biz) {
      const bizUp = {};
      if (company_name !== undefined) { bizUp.name = company_name; bizUp.initials = company_name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2); }
      if (venue_type !== undefined) bizUp.venue_type = venue_type;
      if (location !== undefined) bizUp.location = location;
      if (contact !== undefined) bizUp.contact = contact;
      if (languages !== undefined) bizUp.languages = languages;
      if (country !== undefined) bizUp.country = country;
      if (country_code !== undefined) bizUp.country_code = country_code;
      if (Object.keys(bizUp).length) { bizUp.updated_at = db.fn.now(); await db('businesses').where({ id: biz.id }).update(bizUp); }
    }
    // Return fresh profile
    const user = await db('users').where({ id: userId }).first();
    const freshBiz = await db('businesses').where({ user_id: userId }).first();
    ok(res, {
      id: user.id, name: user.name, email: user.email, phone: user.phone, location: user.location,
      status: user.status, is_verified: user.is_verified, avatar_hue: user.avatar_hue || 0.5,
      photo_url: user.photo_url || null,
      profile_strength: user.profile_strength || 0,
      company_name: freshBiz?.name || user.name,
      company_initials: freshBiz?.initials || '?',
      venue_type: freshBiz?.venue_type, business_location: freshBiz?.location,
      is_featured: freshBiz?.is_featured || false,
      plan: freshBiz?.plan || null, plan_status: freshBiz?.plan_status || null,
      response_rate: freshBiz?.response_rate || 0,
      languages: freshBiz?.languages || null,
      country: freshBiz?.country || null,
      country_code: freshBiz?.country_code || null,
      created_at: user.created_at,
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/conversations — Business conversations
// ---------------------------------------------------------------------------
async function listConversations(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const { page = 1, limit = 50 } = req.query;
    let base = db('conversations')
      .leftJoin('candidates', 'conversations.candidate_id', 'candidates.id')
      .leftJoin('users', 'candidates.user_id', 'users.id')
      .leftJoin('jobs', 'conversations.job_id', 'jobs.id')
      .where('conversations.business_id', bizId)
      .whereNot('conversations.status', 'archived');
    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone().select(
      'conversations.id', 'conversations.last_message', 'conversations.status',
      'conversations.is_interview_related', 'conversations.updated_at',
      'candidates.name as candidate_name', 'candidates.initials as candidate_initials',
      'candidates.avatar_hue as candidate_avatar_hue', 'candidates.nationality_code as candidate_nationality_code',
      'users.photo_url as candidate_photo_url',
      'jobs.title as job_title'
    ).orderBy('conversations.updated_at', 'desc').limit(+limit).offset((+page - 1) * +limit);
    for (const row of rows) {
      const unread = await db('messages').where({ conversation_id: row.id, is_read: false }).whereNot('sender_id', req.user.id).count('* as c').first();
      row.unread_count = +(unread?.c || 0);
    }
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/conversations/:id/messages — Messages in conversation
// ---------------------------------------------------------------------------
async function listMessages(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const conv = await db('conversations').where({ id: req.params.id, business_id: bizId }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');
    const { page = 1, limit = 200 } = req.query;
    const total = await db('messages').where({ conversation_id: conv.id }).count('* as c').first().then(r => +r.c);
    // Pull the LATEST `limit` messages (desc + offset), then reverse to
    // chronological order for the client. Previous ASC+offset query
    // silently truncated long threads to the oldest page once total > limit,
    // making the chat appear "stuck" while admin (limit=200) saw newer rows.
    const msgs = (await db('messages').leftJoin('users', 'messages.sender_id', 'users.id')
      .where('messages.conversation_id', conv.id)
      .select('messages.id', 'messages.body', 'messages.is_read', 'messages.delivered_at', 'messages.sender_id', 'messages.created_at', 'users.name as sender_name', 'users.user_type as sender_type')
      .orderBy('messages.created_at', 'desc').limit(+limit).offset((+page - 1) * +limit)).reverse();

    // Flip unread peer messages to read and broadcast to the sender.
    const toMark = await db('messages')
      .where({ conversation_id: conv.id, is_read: false })
      .whereNot('sender_id', req.user.id)
      .pluck('id');
    if (toMark.length > 0) {
      const readAt = new Date().toISOString();
      await db('messages').whereIn('id', toMark).update({ is_read: true });
      // Peer user id (candidate side) is the only audience — admin ignores seen state.
      let candidateUserId = null;
      if (conv.candidate_id) {
        const cand = await db('candidates').where({ id: conv.candidate_id }).select('user_id').first();
        if (cand) candidateUserId = cand.user_id;
      }
      if (candidateUserId) {
        bus.publish('message.read', {
          conversation_id: conv.id,
          message_ids: toMark,
          reader_user_id: req.user.id,
          read_at: readAt,
        }, [`user:${candidateUserId}`]);
      }
    }
    paginated(res, msgs, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /business/conversations/:id/messages/ack-delivered — Mark peer messages delivered
// ---------------------------------------------------------------------------
// Called by the client as soon as a message is received (e.g. on SSE message.new
// or on chat mount). Stamps delivered_at for each message from the counterpart
// that has not yet been delivered, and emits message.delivered to the sender.
async function ackMessagesDelivered(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const conv = await db('conversations').where({ id: req.params.id, business_id: bizId }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');

    const ids = Array.isArray(req.body?.message_ids) ? req.body.message_ids.filter(Boolean) : [];
    const deliveredAt = new Date().toISOString();

    // Update only rows that are from the peer AND not already delivered.
    let query = db('messages')
      .where({ conversation_id: conv.id })
      .whereNot('sender_id', req.user.id)
      .whereNull('delivered_at');
    if (ids.length > 0) query = query.whereIn('id', ids);
    const flipped = await query.clone().pluck('id');
    if (flipped.length > 0) {
      await query.update({ delivered_at: deliveredAt });

      let candidateUserId = null;
      if (conv.candidate_id) {
        const cand = await db('candidates').where({ id: conv.candidate_id }).select('user_id').first();
        if (cand) candidateUserId = cand.user_id;
      }
      if (candidateUserId) {
        bus.publish('message.delivered', {
          conversation_id: conv.id,
          message_ids: flipped,
          delivered_at: deliveredAt,
        }, [`user:${candidateUserId}`]);
      }
    }
    ok(res, { message_ids: flipped, delivered_at: deliveredAt });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /business/conversations/:id/messages — Send message
// ---------------------------------------------------------------------------
async function sendMessage(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const conv = await db('conversations').where({ id: req.params.id, business_id: bizId }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');
    const { body } = req.body;
    if (!body || !body.trim()) throw AppError.badRequest('Message body is required.');
    const [msg] = await db('messages').insert({ conversation_id: conv.id, sender_id: req.user.id, body: body.trim() }).returning('*');
    await db('conversations').where({ id: conv.id }).update({ last_message: body.trim().slice(0, 200), updated_at: db.fn.now() });
    console.log(`[BACKEND CREATE] business→candidate msgId=${msg.id} convId=${conv.id} businessUserId=${req.user.id} candidateId=${conv.candidate_id || 'null'} body="${msg.body}"`);
    // Notify the candidate
    let candidateUserId = null;
    let candNameForAdmin = null;
    let bizNameForAdmin = null;
    if (conv.candidate_id) {
      const cand = await db('candidates').where({ id: conv.candidate_id }).select('user_id', 'name').first();
      const bizUser = await db('users').where({ id: req.user.id }).first();
      if (cand) {
        candidateUserId = cand.user_id;
        candNameForAdmin = cand.name;
        bizNameForAdmin = bizUser?.name || null;
        hiringNotify(cand.user_id, `New message from ${bizUser?.name || 'a business'}`, 'in_app', conv.id, 'message');
      }
    }
    try {
      await notifyAllAdmins(
        `Message: ${bizNameForAdmin || 'business'} → ${candNameForAdmin || 'candidate'}`,
        'in_app', conv.id, 'message', body.trim().slice(0, 80),
      );
    } catch (e) { /* best-effort */ }
    // Realtime broadcast
    const audience = ['role:admin', `user:${req.user.id}`];
    if (candidateUserId) audience.push(`user:${candidateUserId}`);
    console.log(`[SSE EMIT] type=message.new convId=${conv.id} senderUserId=${req.user.id} recipientUserId=${candidateUserId || 'null'} audience=${JSON.stringify(audience)}`);
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
      sender_user_id: req.user.id,
      recipient_user_id: candidateUserId,
      sender_role: 'business',
    }, audience);
    ok(res, msg);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /business/conversations/:id/typing — Emit typing indicator
// ---------------------------------------------------------------------------
// Ephemeral — does NOT persist. Just relays an SSE event to the candidate
// counterpart so their chat view can render / hide the "…" typing bubble.
// Admin is intentionally EXCLUDED from the audience: typing is UX noise, not
// an auditable event. Sender is excluded too (they don't need to echo).
async function sendTyping(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const conv = await db('conversations').where({ id: req.params.id, business_id: bizId }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');

    let candidateUserId = null;
    if (conv.candidate_id) {
      const cand = await db('candidates').where({ id: conv.candidate_id }).select('user_id').first();
      if (cand) candidateUserId = cand.user_id;
    }

    if (candidateUserId) {
      bus.publish('chat.typing', {
        conversation_id: conv.id,
        sender_user_id: req.user.id,
        is_typing: !!req.body.is_typing,
        actor: 'business',
      }, [`user:${candidateUserId}`]);
    }
    ok(res, { ok: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/candidates/:id — View a candidate's profile
// ---------------------------------------------------------------------------
async function getCandidateProfile(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const candidateId = req.params.id;

    // Verify this business has a hiring relationship with the candidate:
    // the candidate must have applied to at least one of this business's jobs.
    const relationship = await db('applications')
      .leftJoin('jobs', 'applications.job_id', 'jobs.id')
      .where('applications.candidate_id', candidateId)
      .where('jobs.business_id', bizId)
      .first();

    if (!relationship) throw AppError.forbidden('You do not have access to this candidate profile.');

    const cand = await db('candidates').where({ id: candidateId }).first();
    if (!cand) throw AppError.notFound('Candidate not found.');
    const user = await db('users').where({ id: cand.user_id }).first();
    ok(res, {
      id: cand.id, user_id: cand.user_id, name: cand.name, initials: cand.initials,
      role: cand.role, location: cand.location, experience: cand.experience,
      languages: cand.languages, job_type: cand.job_type || null,
      bio: cand.bio || null, verification_status: cand.verification_status,
      avatar_hue: cand.avatar_hue, is_verified: user?.is_verified || false,
      nationality: cand.nationality || null, nationality_code: cand.nationality_code || null,
      country_code: cand.country_code || null,
      photo_url: user?.photo_url || null,
      email: user?.email, phone: user?.phone,
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/notifications — Business notifications
// ---------------------------------------------------------------------------
async function listNotifications(req, res, next) {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 50, is_read } = req.query;
    let base = db('notifications').where({ recipient_id: userId });
    if (is_read !== undefined) base = base.where('is_read', is_read === 'true');
    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone().select('*').orderBy('created_at', 'desc').limit(+limit).offset((+page - 1) * +limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /business/notifications/:id/read — Mark notification as read
// ---------------------------------------------------------------------------
async function markNotificationRead(req, res, next) {
  try {
    await db('notifications').where({ id: req.params.id, recipient_id: req.user.id }).update({ is_read: true, updated_at: db.fn.now() });
    ok(res, { success: true });
  } catch (err) { next(err); }
}

async function markAllNotificationsRead(req, res, next) {
  try {
    await db('notifications').where({ recipient_id: req.user.id, is_read: false }).update({ is_read: true, updated_at: db.fn.now() });
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /business/notifications/:id — Delete a single notification
// ---------------------------------------------------------------------------
async function deleteNotification(req, res, next) {
  try {
    await db('notifications').where({ id: req.params.id, recipient_id: req.user.id }).del();
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /business/notifications — Delete every notification of the user
// ---------------------------------------------------------------------------
async function deleteAllNotifications(req, res, next) {
  try {
    await db('notifications').where({ recipient_id: req.user.id }).del();
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/recent-applicants — Recent applicants across all jobs (for home dashboard)
// ---------------------------------------------------------------------------
async function recentApplicants(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const { limit = 10 } = req.query;
    const rows = await db('applications')
      .leftJoin('candidates', 'applications.candidate_id', 'candidates.id')
      .leftJoin('users', 'candidates.user_id', 'users.id')
      .leftJoin('jobs', 'applications.job_id', 'jobs.id')
      .where('jobs.business_id', bizId)
      .select(
        'applications.id', 'applications.status', 'applications.created_at as applied_at',
        'candidates.id as candidate_id', 'candidates.name as candidate_name',
        'candidates.initials as candidate_initials', 'candidates.role as candidate_role',
        'candidates.location as candidate_location', 'candidates.experience as candidate_experience',
        'candidates.avatar_hue as candidate_avatar_hue', 'candidates.nationality_code as candidate_nationality_code',
        'users.is_verified as candidate_verified',
        'users.photo_url as candidate_photo_url',
        'jobs.title as job_title', 'jobs.id as job_id'
      )
      .orderBy('applications.created_at', 'desc')
      .limit(+limit);
    ok(res, rows);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/candidates/nearby — Candidates near a coordinate
// ---------------------------------------------------------------------------
const CANDIDATE_HAVERSINE = `
  (6371 * acos(
    LEAST(1.0, cos(radians(?)) * cos(radians(users.latitude)) *
    cos(radians(users.longitude) - radians(?)) +
    sin(radians(?)) * sin(radians(users.latitude)))
  )) AS distance_km`;

async function nearbyCandidates(req, res, next) {
  try {
    const { lat, lng, radius = 10, limit = 30, role } = req.query;
    if (!lat || !lng) throw AppError.badRequest('lat and lng are required.');

    const userLat = parseFloat(lat);
    const userLng = parseFloat(lng);
    const radiusKm = parseFloat(radius);

    let base = db('candidates')
      .leftJoin('users', 'candidates.user_id', 'users.id')
      .where('users.user_type', 'candidate')
      .where('users.status', 'active')
      .whereNotNull('users.latitude')
      .whereNotNull('users.longitude')
      .select(
        'candidates.id', 'candidates.name', 'candidates.initials',
        'candidates.role', 'candidates.location', 'candidates.experience',
        'candidates.languages', 'candidates.job_type', 'candidates.available_to_relocate',
        'candidates.verification_status',
        'candidates.avatar_hue', 'candidates.nationality_code',
        'users.is_verified', 'users.photo_url', 'users.latitude', 'users.longitude',
        db.raw(CANDIDATE_HAVERSINE, [userLat, userLng, userLat])
      );

    if (role) base = base.whereILike('candidates.role', `%${role}%`);

    const subquery = base.as('nearby');
    const rows = await db.select('*').from(subquery)
      .where('distance_km', '<=', radiusKm)
      .orderBy('distance_km', 'asc')
      .limit(+limit);

    const countResult = await db.select(db.raw('count(*) as c')).from(
      db('candidates').leftJoin('users', 'candidates.user_id', 'users.id')
        .where('users.user_type', 'candidate').where('users.status', 'active')
        .whereNotNull('users.latitude').whereNotNull('users.longitude')
        .select('candidates.id', db.raw(CANDIDATE_HAVERSINE, [userLat, userLng, userLat]))
        .as('cnt')
    ).where('distance_km', '<=', radiusKm).first();

    paginated(res, rows, { page: 1, limit: +limit, total: +(countResult?.c || 0) });
  } catch (err) { next(err); }
}

async function uploadPhoto(req, res, next) {
  try {
    const { photo } = req.body;
    const photoUrl = (photo && photo.trim()) ? photo : null;
    if (photoUrl && photoUrl.length > 4 * 1024 * 1024) throw AppError.badRequest('Photo too large.');
    await db('users').where({ id: req.user.id }).update({ photo_url: photoUrl, updated_at: db.fn.now() });
    ok(res, { photo_url: photoUrl });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /business/conversations/start — Get or create conversation with a candidate
// ---------------------------------------------------------------------------
async function startConversation(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const { candidate_id } = req.body;
    if (!candidate_id) throw AppError.badRequest('candidate_id is required.');

    // Check if conversation already exists
    const existing = await db('conversations')
      .where({ business_id: bizId, candidate_id })
      .whereNot('status', 'archived')
      .first();

    if (existing) {
      ok(res, { conversation_id: existing.id, created: false });
      return;
    }

    // Create new conversation. Schema default for `status` is 'normal'
    // (enum: ['normal','flagged','under_review','archived','restricted']);
    // do NOT pass 'active' here — it's not a valid value and the CHECK
    // constraint rejects the insert with HTTP 500, breaking every first
    // Message tap from Quick Plug / Nearby / candidate profile.
    const [conv] = await db('conversations').insert({
      business_id: bizId, candidate_id,
    }).returning('*');

    ok(res, { conversation_id: conv.id, created: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /business/conversations/:id — Archive conversation
// ---------------------------------------------------------------------------
async function archiveConversation(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const conv = await db('conversations').where({ id: req.params.id, business_id: bizId }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');
    await db('conversations').where({ id: conv.id }).update({ status: 'archived', updated_at: db.fn.now() });
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/matches/:jobId — Candidates matching a specific job's role + employment_type
// ---------------------------------------------------------------------------
async function listJobMatches(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const job = await db('jobs').where({ id: req.params.jobId, business_id: bizId }).first();
    if (!job) throw AppError.notFound('Job not found.');

    const { page = 1, limit = 20 } = req.query;
    const jobCategory = (job.category || '').toLowerCase().trim();
    const jobType = (job.employment_type || '').toLowerCase().trim();

    if (!jobCategory || !jobType) {
      return paginated(res, [], { page: +page, limit: +limit, total: 0 });
    }

    // Read from matches table (status-aware), exclude denied
    let base = db('matches')
      .leftJoin('candidates', 'matches.candidate_id', 'candidates.id')
      .leftJoin('users', 'candidates.user_id', 'users.id')
      .where('matches.job_id', job.id)
      .where('users.status', 'active')
      .whereNot('matches.status', 'denied');

    const total = await base.clone().count('* as c').first().then(r => +r.c);

    const rows = await base.clone()
      .select(
        'candidates.id', 'candidates.name', 'candidates.initials',
        'candidates.role', 'candidates.location', 'candidates.experience',
        'candidates.languages', 'candidates.job_type', 'candidates.bio',
        'candidates.verification_status', 'candidates.avatar_hue',
        'candidates.nationality_code',
        'users.is_verified', 'users.photo_url',
        'matches.id as match_id', 'matches.status as match_status'
      )
      .orderBy('matches.created_at', 'desc')
      .limit(+limit).offset((+page - 1) * +limit);

    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /business/feedback — Submit match feedback
// ---------------------------------------------------------------------------
async function submitMatchFeedback(req, res, next) {
  try {
    const { match_id, was_relevant, role_accurate, job_type_accurate } = req.body;
    if (!match_id) throw AppError.badRequest('match_id is required.');
    await db('match_feedback').insert({
      user_id: req.user.id,
      match_id,
      user_type: 'business',
      was_relevant: was_relevant ?? null,
      role_accurate: role_accurate ?? null,
      job_type_accurate: job_type_accurate ?? null,
    });
    ok(res, { success: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH /business/matches/:id/status — Accept or deny a match (business side)
// ---------------------------------------------------------------------------
async function updateMatchStatus(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    const { status } = req.body;
    if (!['accepted', 'denied'].includes(status)) throw AppError.badRequest('Status must be accepted or denied.');
    // Verify this match belongs to one of this business's jobs
    const match = await db('matches')
      .leftJoin('jobs', 'matches.job_id', 'jobs.id')
      .where('matches.id', req.params.id)
      .where('jobs.business_id', bizId)
      .select('matches.id')
      .first();
    if (!match) throw AppError.notFound('Match not found.');
    await db('matches').where({ id: match.id }).update({ status, updated_at: db.fn.now() });
    ok(res, { success: true, status });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/quickplug/deck — Tinder-style swipe deck of active candidates
// ---------------------------------------------------------------------------
// Returns up to 20 active candidates, newest first. Filters out candidates
// the current business has already swiped on (when business_id is tracked).
// Shape matches Flutter `QuickPlugCandidate.fromJson`.

// Demo 3-photo album per seeded candidate name. Until candidates upload
// their own photos, the deck ships a curated triplet so the swipe deck
// can render Tinder-style stories progress bars + tap-to-cycle. URLs use
// Unsplash CDN at 1200px wide for retina sharpness.
const QUICKPLUG_DEMO_PHOTOS = {
  'Elena Rossi': [
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=1200&q=80&auto=format&fit=crop',
  ],
  'James Park': [
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1492447166138-50c3889fccb1?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=1200&q=80&auto=format&fit=crop',
  ],
  'Sofia Blanc': [
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=1200&q=80&auto=format&fit=crop',
  ],
  'Marco Bianchi': [
    'https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1463453091185-61582044d556?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=1200&q=80&auto=format&fit=crop',
  ],
  'Anna Weber': [
    'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1592621385612-4d7129426394?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1496440737103-cd596325d314?w=1200&q=80&auto=format&fit=crop',
  ],
  'Tom Chen': [
    'https://images.unsplash.com/photo-1564564321837-a57b7070ac4f?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1556157382-97eda2d62296?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1542178243-bc20204b769f?w=1200&q=80&auto=format&fit=crop',
  ],
  'Priya Sharma': [
    'https://images.unsplash.com/photo-1607746882042-944635dfe10e?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1485875437342-9b39470b3d95?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1605405748313-a416a1b84491?w=1200&q=80&auto=format&fit=crop',
  ],
  'David Okafor': [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=1200&q=80&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1507081323647-4d250478b919?w=1200&q=80&auto=format&fit=crop',
  ],
};

async function quickplugDeck(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);

    // Pull all of this business's active jobs once. Each candidate is
    // ranked against the *best fit* job in this set so a Quick Plug
    // swipe surfaces the relevant candidate→job pairing without making
    // the business pick a job per swipe.
    const businessJobs = await db('jobs')
      .where({ business_id: bizId, status: 'active' })
      .select(
        'id', 'title', 'main_role_needed', 'additional_roles_needed',
        'location', 'employment_type', 'salary', 'requirements',
      );

    const rows = await db('candidates')
      .leftJoin('users', 'candidates.user_id', 'users.id')
      .where('users.user_type', 'candidate')
      .where('users.status', 'active')
      .select(
        'candidates.id',
        'candidates.name',
        'candidates.initials',
        'candidates.role',
        'candidates.primary_role',
        'candidates.additional_roles',
        'candidates.location',
        'candidates.country_code',
        'candidates.experience',
        'candidates.job_type',
        'candidates.start_date',
        'candidates.available_to_relocate',
        'candidates.languages',
        'candidates.verification_status',
        'candidates.cv_url',
        'candidates.cv_visible_to_businesses',
      )
      .orderBy('candidates.created_at', 'desc')
      .limit(20);

    const data = rows.map((r) => {
      const langs = (r.languages || '')
        .split(',')
        .map((s) => s.trim())
        .filter(Boolean);
      const photos = QUICKPLUG_DEMO_PHOTOS[r.name] || [];
      // Privacy gate: only expose cv_url when the candidate explicitly
      // opted in. Treat missing flag as opted-in for back-compat with
      // pre-019 rows.
      const cvVisible = r.cv_visible_to_businesses !== false;
      const cvUrl = cvVisible && r.cv_url ? r.cv_url : null;

      const match = scoreCandidateAgainstBusinessJobs(r, businessJobs);

      return {
        id: r.id,
        name: r.name || '',
        initials: r.initials || '',
        role: r.role || '',
        location: r.location || '',
        experience: r.experience || '',
        verified: r.verification_status === 'verified',
        tags: langs.slice(0, 3),
        summary: r.role && r.experience
          ? `${r.role} with ${r.experience} of experience.`
          : (r.role || ''),
        photos,
        cvUrl,
        match_score: match.score,
        match_level: match.level,
        match_reasons: match.reasons,
        top_match_reason: match.topReason,
        best_job_id: match.bestJobId,
        best_job_title: match.bestJobTitle,
      };
    });

    // Re-rank by match score so the strongest candidate→job fit is
    // shown first. SQL's recency ordering remains the tiebreaker
    // implicitly via stable sort.
    data.sort((a, b) => b.match_score - a.match_score);

    // Daily-swipe quota — server is source of truth. Flutter mirrors
    // these fields into BusinessQuickPlugProvider and shows the lock
    // state when hasReachedLimit is true.
    const quota = await resolveQuickplugSwipeQuota(bizId);

    ok(res, data, quota);
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /business/quickplug/swipe — Record a Quick Plug swipe
// ---------------------------------------------------------------------------
// Body: { candidateId: string, interested: boolean }
//
// Shortlist (`interested = true`):
//  - Persist a `notifications` row addressed to the candidate's user
//    so the candidate sees "<Business> shortlisted your profile" in
//    their inbox + bell badge.
//  - Fan out an admin notification row per admin user via
//    `notifyAllAdmins`, so the admin notifications feed surfaces the
//    Quick Plug interaction without us spinning up a separate audit
//    log table.
//  - SSE: hiringNotify already publishes `notification.new` with
//    `role:admin` + `user:<candidateUserId>` audiences, so connected
//    clients refresh in real time.
//
// Pass (`interested = false`):
//  - No persistence, no notifications. Acknowledged silently so the
//    Flutter card animation can complete and move to the next
//    candidate. Analytics can be layered on later without a contract
//    change.
//
// Failures inside the notification fan-out are swallowed so a missing
// table or a transient DB hiccup never blocks the swipe response: the
// UI must always be able to advance to the next card.
async function quickplugSwipe(req, res, next) {
  try {
    const { candidateId, interested } = req.body || {};
    if (!candidateId) throw AppError.badRequest('candidateId is required.');
    if (typeof interested !== 'boolean') {
      throw AppError.badRequest('interested must be a boolean.');
    }

    const bizId = await getBizId(req.user.id);

    // Quota gate — backend is source of truth. When the cap is reached
    // we do not insert the swipe row, do not create a shortlist, do not
    // emit any notifications or SSE events. Flutter renders the lock
    // state from the returned quota.
    const preQuota = await resolveQuickplugSwipeQuota(bizId);
    if (preQuota.hasReachedLimit) {
      return ok(res, {
        success: false,
        candidateId,
        interested,
        source: 'quickplug',
        shortlisted: false,
        ...preQuota,
      });
    }

    // Log this swipe before running the shortlist/match pipeline so the
    // counter stays consistent even if a downstream step throws.
    try {
      await db('business_quickplug_swipes').insert({
        business_id: bizId,
        candidate_id: candidateId,
        interested,
      });
    } catch (e) {
      console.error('[quickplugSwipe log]', e.message);
    }

    let shortlisted = false;
    if (interested) {
      try {
        const biz = await db('businesses').where({ id: bizId }).first();
        const cand = await db('candidates')
          .where({ id: candidateId })
          .first();
        if (cand && cand.user_id) {
          const bizName = biz?.name || 'A business';
          const candName = cand.name || 'a candidate';
          shortlisted = true;

          // Persist the business intent so the apply-side flow can
          // detect it later. Idempotent on (business_id, candidate_id).
          // returning() lets us distinguish a brand-new shortlist from an
          // already-existing one so the notification fan-out below only
          // fires once per (business, candidate) pair.
          let wasNewlyShortlisted = false;
          try {
            const inserted = await db('quickplug_shortlists')
              .insert({
                business_id: bizId,
                candidate_id: candidateId,
                source: 'quickplug',
              })
              .onConflict(['business_id', 'candidate_id'])
              .ignore()
              .returning(['id']);
            wasNewlyShortlisted = Array.isArray(inserted) && inserted.length > 0;
          } catch (e) {
            console.error('[quickplugSwipe shortlist persist]', e.message);
          }

          if (wasNewlyShortlisted) {
            await hiringNotify(
              cand.user_id,
              `${bizName} shortlisted your profile`,
              'in_app',
              candidateId,
              'shortlist',
              'Spotted you on Quick Plug — they may reach out soon.',
            );
            await notifyAllAdmins(
              `${bizName} shortlisted ${candName} via Quick Plug`,
              'in_app',
              candidateId,
              'shortlist',
              null,
            );
            bus.publish(
              'quickplug.shortlisted',
              {
                source: 'quickplug',
                business_id: bizId,
                business_name: bizName,
                candidate_id: candidateId,
                candidate_user_id: cand.user_id,
                candidate_name: candName,
              },
              ['role:admin', `user:${cand.user_id}`],
            );
          }

          // Mutual match check — if the candidate has already applied
          // to one or more of this business's jobs, create a match per
          // job. tryCreateMutualMatch is idempotent so retries are
          // safe and existing matches will not duplicate.
          try {
            const apps = await db('applications')
              .leftJoin('jobs', 'applications.job_id', 'jobs.id')
              .where('applications.candidate_id', candidateId)
              .where('jobs.business_id', bizId)
              .select('applications.job_id as job_id');
            for (const a of apps) {
              await tryCreateMutualMatch({
                businessId: bizId,
                candidateId,
                jobId: a.job_id,
                sourceBusiness: 'quickplug',
                sourceCandidate: 'application',
              });
            }
          } catch (e) {
            console.error('[quickplugSwipe match check]', e.message);
          }
        }
      } catch (e) {
        console.error('[quickplugSwipe shortlist]', e.message);
      }
    }

    // Re-resolve quota AFTER the insert so Flutter gets the post-swipe
    // counters in a single round-trip — keeps provider state in lockstep
    // with the server without a follow-up deck call.
    const postQuota = await resolveQuickplugSwipeQuota(bizId);

    ok(res, {
      success: true,
      candidateId,
      interested,
      source: 'quickplug',
      shortlisted,
      ...postQuota,
    });
  } catch (err) { next(err); }
}

module.exports = {
  profile, home, updateProfile, uploadPhoto,
  listJobs, createJob, getJob, updateJob, duplicateJob,
  listApplicants, updateApplicantStatus,
  listInterviews, scheduleInterview, updateInterviewStatus,
  listConversations, listMessages, sendMessage, sendTyping, ackMessagesDelivered, startConversation, archiveConversation,
  getCandidateProfile,
  listNotifications, markNotificationRead, markAllNotificationsRead,
  deleteNotification, deleteAllNotifications,
  recentApplicants, nearbyCandidates, listJobMatches, submitMatchFeedback, updateMatchStatus,
  quickplugDeck, quickplugSwipe,
  subscription,
  tryCreateMutualMatch,
};
