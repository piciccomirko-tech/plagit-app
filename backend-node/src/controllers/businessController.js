const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const AppError = require('../utils/AppError');
const { bus } = require('../services/realtime/eventBus');
const { buildReplyEnvelope } = require('../services/messageReplyEnvelope');
const { isAlbumColumnPresent, isVideoColumnsPresent, isVideoAlbumColumnsPresent, isForwardedColumnsPresent, isCallLogColumnPresent, isGroupChatColumnsPresent, isGroupPhotoColumnPresent, isCandidateAvailabilityColumnsPresent, isUrgentRequestsTablePresent } = require('../services/schemaFeatureFlags');
const { buildEntityShareEnvelope, isSupportedShareType, batchEntityShareEnvelopes } = require('../services/entityShareEnvelope');
const { scoreCandidateAgainstBusinessJobs } = require('../services/matchScoring');
const storage = require('../storage');

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
    // Step 4A — capture the inserted row's stable id so the SSE
    // payload can carry it. Flutter consumers (notifications providers
    // + push handler) use this id as the canonical dedup key across
    // SSE / polling / future FCM. `.returning('id')` is a no-op on
    // older drivers that ignore it, so behaviour stays identical when
    // postgres returns null.
    const inserted = await db('notifications').insert(row).returning('id');
    const notificationId = (inserted && inserted[0] && inserted[0].id) || null;
    bus.publish('notification.new', {
      id: notificationId,
      recipient_user_id: recipientId,
      title,
      body: body || null,
      notification_type: type || 'in_app',
      linked_entity: linkedEntity || null,
      destination_route: route || null,
    }, ['role:admin', `user:${recipientId}`]);
  } catch (e) { /* ignore if table missing */ }
}

// ─── Group-aware permission gate (Stage A.1, mig 049) ────────────
// Symmetric to candidateController._resolveCandidateMessageAccess.
// Returns `{ target, biz, isGroup }`:
//   • `target` null when message missing OR caller has no access.
//   • `biz` is the businesses row for 1:1 paths, null for groups.
//   • `isGroup` lets callers branch side-effects (e.g. reactions
//     skip the synthetic "X reacted" row in groups).
async function _resolveBusinessMessageAccess(messageId, userId) {
  const target = await db('messages')
    .leftJoin('conversations', 'messages.conversation_id', 'conversations.id')
    .where('messages.id', messageId)
    .select(
      'messages.id as msg_id',
      'messages.sender_id as msg_sender_id',
      'messages.created_at as msg_created_at',
      'messages.attachment_type as msg_attachment_type',
      'messages.body as msg_body',
      'messages.deleted_for_everyone_at as msg_deleted_for_everyone_at',
      'conversations.id as conv_id',
      'conversations.type as conv_type',
      'conversations.name as conv_name',
      'conversations.candidate_id as conv_candidate_id',
      'conversations.business_id as conv_business_id',
    )
    .first();
  if (!target) return { target: null, biz: null, isGroup: false };

  const groupReady = await isGroupChatColumnsPresent();
  const isGroup = groupReady && target.conv_type === 'group';

  if (isGroup) {
    const member = await db('conversation_members')
      .where({ conversation_id: target.conv_id, user_id: userId })
      .whereNull('left_at')
      .first();
    if (!member) return { target: null, biz: null, isGroup };
    return { target, biz: null, isGroup };
  }

  const biz = await db('businesses').where({ user_id: userId }).first();
  if (!biz || target.conv_business_id !== biz.id) {
    return { target: null, biz: null, isGroup };
  }
  return { target, biz, isGroup };
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
        // Step 4A — propagate the stable id to the SSE payload so
        // Flutter can dedup against future FCM tap deliveries.
        bus.publish('notification.new', {
          id: ins.id || null,
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
      // Step C.2/A.2 — expose the candidate's users.id so the Flutter
      // contact picker can pass a valid `member_user_ids` entry to
      // POST /v1/groups + POST /v1/groups/:id/members (both endpoints
      // validate against users.id via the existing
      // `_resolveMyContactUserIds` contact gate). Same join we already
      // use for `candidate_photo_url`, just an extra select.
      'users.id as candidate_user_id',
      'users.photo_url as candidate_photo_url',
      'jobs.title as job_title',
      // Step 3B.1 — symmetric with candidateController.listConversations.
      // Surface the latest message's discriminator + sender so Flutter
      // can override the shared `last_message` text on the callee side
      // (missed call → "Missed voice/video call").
      db.raw(
        "(SELECT attachment_type FROM messages WHERE conversation_id = conversations.id ORDER BY created_at DESC LIMIT 1) AS last_message_attachment_type"
      ),
      db.raw(
        "(SELECT sender_id FROM messages WHERE conversation_id = conversations.id ORDER BY created_at DESC LIMIT 1) AS last_message_sender_id"
      ),
    ).orderBy('conversations.updated_at', 'desc').limit(+limit).offset((+page - 1) * +limit);
    for (const row of rows) {
      const unread = await db('messages').where({ conversation_id: row.id, is_read: false }).whereNot('sender_id', req.user.id).count('* as c').first();
      row.unread_count = +(unread?.c || 0);
      row.type = '1v1';
    }

    // mig 049 — append group conversations the business user is a
    // member of. Mirror of candidateController.listConversations.
    if (await isGroupChatColumnsPresent()) {
      const userId = req.user.id;
      // Stage C.2A.2 — mirror of the candidate-side gate. Append
      // group_photo_url only when mig 050 has applied so the SELECT
      // never names an absent column.
      const groupPhotoReady = await isGroupPhotoColumnPresent();
      const groupSelectColumns = [
        'conversations.id',
        'conversations.last_message',
        'conversations.status',
        'conversations.is_interview_related',
        'conversations.updated_at',
        'conversations.type',
        'conversations.name',
        'conversations.avatar_hue',
        'conversations.created_by_user_id',
        'conversation_members.last_read_at',
        db.raw(
          "(SELECT attachment_type FROM messages WHERE conversation_id = conversations.id AND attachment_type <> 'reaction' ORDER BY created_at DESC LIMIT 1) AS last_message_attachment_type"
        ),
        db.raw(
          "(SELECT sender_id FROM messages WHERE conversation_id = conversations.id AND attachment_type <> 'reaction' ORDER BY created_at DESC LIMIT 1) AS last_message_sender_id"
        ),
      ];
      if (groupPhotoReady) {
        groupSelectColumns.push('conversations.group_photo_url');
      }

      const groupRows = await db('conversations')
        .innerJoin('conversation_members', function () {
          this.on('conversation_members.conversation_id', '=', 'conversations.id')
            .andOn('conversation_members.user_id', '=', db.raw('?', [userId]));
        })
        .whereNull('conversation_members.left_at')
        .where('conversations.type', 'group')
        .whereNot('conversations.status', 'archived')
        .select(...groupSelectColumns)
        .orderBy('conversations.updated_at', 'desc');

      for (const g of groupRows) {
        const sinceTs = g.last_read_at || new Date(0).toISOString();
        const unread = await db('messages')
          .where('conversation_id', g.id)
          .where('created_at', '>', sinceTs)
          .whereNot('sender_id', userId)
          .whereNot('attachment_type', 'reaction')
          .count('* as c').first();
        g.unread_count = +(unread?.c || 0);
        delete g.last_read_at;
      }

      rows.push(...groupRows);
      rows.sort((a, b) =>
        new Date(b.updated_at).getTime() - new Date(a.updated_at).getTime()
      );
    }

    paginated(res, rows, { page: +page, limit: +limit, total: rows.length });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /business/conversations/:id/messages — Messages in conversation
// ---------------------------------------------------------------------------
async function listMessages(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    // mig 049 — accept group conversations the caller is a member of.
    // 1:1 path stays gated on business_id ownership.
    const conv = await db('conversations').where({ id: req.params.id }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');
    const groupReady = await isGroupChatColumnsPresent();
    const isGroup = groupReady && conv.type === 'group';
    if (isGroup) {
      const myMembership = await db('conversation_members')
        .where({ conversation_id: conv.id, user_id: req.user.id })
        .whereNull('left_at')
        .first();
      if (!myMembership) throw AppError.notFound('Conversation not found.');
    } else if (conv.business_id !== bizId) {
      throw AppError.notFound('Conversation not found.');
    }
    const { page = 1, limit = 200 } = req.query;
    // Sprint 4C — count must mirror the same `message_hides` filter
    // applied to the SELECT below; otherwise pagination thinks there
    // are more rows than the caller will ever see.
    const total = await db('messages')
      .where({ conversation_id: conv.id })
      // Sprint 4F — synthetic 'reaction' rows drive unread/last_message
      // bookkeeping but never render as bubbles. Filter from total so
      // pagination matches the SELECT below.
      .whereNot('attachment_type', 'reaction')
      .whereNotExists(function () {
        this.select(db.raw('1'))
          .from('message_hides')
          .whereRaw('message_hides.message_id = messages.id')
          .where('message_hides.user_id', req.user.id);
      })
      .count('* as c').first().then(r => +r.c);
    // See candidateController.listMessages — guard the album SELECT
    // so a redeploy that races ahead of `migrate:latest` doesn't 500
    // the inbox.
    const albumReady = await isAlbumColumnPresent();
    const videoReady = await isVideoColumnsPresent();
    // Video-album columns (migration 048 — multi-video bubble). Same
    // zero-downtime gate as the photo album / single-video readiness.
    const videoAlbumReady = await isVideoAlbumColumnsPresent();
    // Forward columns (migration 041, not yet applied). Same pattern.
    const forwardReady = await isForwardedColumnsPresent();
    // Call-log metadata column (migration 046, Step 3A). Same gate.
    const callLogReady = await isCallLogColumnPresent();

    // Pull the LATEST `limit` messages (desc + offset), then reverse to
    // chronological order for the client. Previous ASC+offset query
    // silently truncated long threads to the oldest page once total > limit,
    // making the chat appear "stuck" while admin (limit=200) saw newer rows.
    // Phase 3D — same LEFT JOIN trick as candidate side to surface a
    // compact reply preview (id / sender_type / attachment_type /
    // body / audio_duration_ms) for every message that points at a
    // parent.
    const selectCols = [
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
      'messages.deleted_for_everyone_at',
      'messages.reply_to_message_id',
      'messages.shared_entity_type',
      'messages.shared_entity_id',
      'users.name as sender_name', 'users.user_type as sender_type',
      'replied.body as reply_body',
      'replied.attachment_type as reply_attachment_type',
      'replied.audio_duration_ms as reply_audio_duration_ms',
      'replied.shared_entity_type as reply_shared_entity_type',
      'replied.deleted_for_everyone_at as reply_deleted_for_everyone_at',
      'replied_user.user_type as reply_sender_type',
      'replied_user.name as reply_sender_name',
    ];
    if (albumReady) {
      selectCols.push('messages.album_image_urls');
      selectCols.push('replied.album_image_urls as reply_album_image_urls');
    }
    if (videoReady) {
      selectCols.push('messages.video_url');
      selectCols.push('messages.video_size_bytes');
      selectCols.push('messages.video_mime_type');
      selectCols.push('messages.video_duration_ms');
      selectCols.push('messages.video_width');
      selectCols.push('messages.video_height');
    }
    if (videoAlbumReady) {
      selectCols.push('messages.album_video_urls');
      selectCols.push('messages.album_video_metadata');
      selectCols.push('replied.album_video_urls as reply_album_video_urls');
    }
    if (forwardReady) {
      selectCols.push('messages.forwarded_from_message_id');
      selectCols.push('messages.is_forwarded');
    }
    if (callLogReady) {
      selectCols.push('messages.call_log_metadata');
    }
    const msgs = (await db('messages').leftJoin('users', 'messages.sender_id', 'users.id')
      .leftJoin('messages as replied', 'messages.reply_to_message_id', 'replied.id')
      .leftJoin('users as replied_user', 'replied.sender_id', 'replied_user.id')
      .where('messages.conversation_id', conv.id)
      // Sprint 4F — synthetic 'reaction' rows are bookkeeping only,
      // never rendered as chat bubbles.
      .whereNot('messages.attachment_type', 'reaction')
      // Sprint 4C — exclude rows the caller has hidden via delete-for-me.
      .whereNotExists(function () {
        this.select(db.raw('1'))
          .from('message_hides')
          .whereRaw('message_hides.message_id = messages.id')
          .where('message_hides.user_id', req.user.id);
      })
      .select(...selectCols)
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
    // Sprint 4A — caller's own stars in a single batch (private).
    const starredIds = ids.length === 0
      ? new Set()
      : new Set(
          (await db('message_stars')
            .whereIn('message_id', ids)
            .where('user_id', req.user.id)
            .pluck('message_id')),
        );
    // Phase 4 — batch-fetch entity-share envelopes for the page.
    // Mirror of the candidate-side enrichment, with viewerRole='business'.
    const shareItems = msgs
      .filter((m) => m.attachment_type === 'entity_share' && m.shared_entity_id)
      .map((m) => ({ type: m.shared_entity_type, id: m.shared_entity_id }));
    const shareEnvelopes = await batchEntityShareEnvelopes(shareItems, 'business');

    const enriched = msgs.map((m) => {
      const {
        reply_body,
        reply_attachment_type,
        reply_audio_duration_ms,
        reply_shared_entity_type,
        reply_album_image_urls,
        reply_album_video_urls,
        reply_deleted_for_everyone_at,
        reply_sender_type,
        reply_sender_name,
        ...rest
      } = m;
      let replyTo = null;
      if (m.reply_to_message_id && reply_attachment_type !== null) {
        // Sprint 4C — tombstone parent reads "This message was deleted".
        const parentDeleted = reply_deleted_for_everyone_at != null;
        replyTo = {
          id: m.reply_to_message_id,
          sender_type: reply_sender_type || null,
          sender_name: reply_sender_name || null,
          attachment_type: parentDeleted ? 'deleted' : reply_attachment_type,
          body_preview: parentDeleted
            ? 'This message was deleted'
            : _replyBodyPreview(reply_attachment_type, reply_body, reply_shared_entity_type, reply_album_image_urls, reply_album_video_urls),
          audio_duration_ms: parentDeleted ? null : (reply_audio_duration_ms || null),
        };
      }
      // Sprint 4C — tombstone payload: strip body + media URLs so the
      // bubble can't accidentally render the original content.
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
            video_url: null,
            video_size_bytes: null,
            video_mime_type: null,
            video_duration_ms: null,
            video_width: null,
            video_height: null,
            location_lat: null,
            location_lng: null,
            location_address: null,
            shared_entity_type: null,
            shared_entity_id: null,
            album_image_urls: null,
            album_video_urls: null,
            album_video_metadata: null,
            // See candidateController.listMessages — tombstoned rows
            // lose the "Forwarded" label.
            forwarded_from_message_id: null,
            is_forwarded: false,
            call_log_metadata: null,
          }
        : {
            // Pre-migration: column wasn't selected; ship null so
            // every payload always carries the field for the client.
            album_image_urls: albumReady ? _normalizeAlbumUrls(m.album_image_urls) : null,
            album_video_urls: videoAlbumReady ? _normalizeAlbumUrls(m.album_video_urls) : null,
            album_video_metadata: videoAlbumReady ? _normalizeAlbumMetadata(m.album_video_metadata) : null,
            video_url: videoReady ? (m.video_url || null) : null,
            video_size_bytes: videoReady ? (m.video_size_bytes || null) : null,
            video_mime_type: videoReady ? (m.video_mime_type || null) : null,
            video_duration_ms: videoReady ? (m.video_duration_ms || null) : null,
            video_width: videoReady ? (m.video_width || null) : null,
            video_height: videoReady ? (m.video_height || null) : null,
            // Pre-migration: forward fields default to null/false so
            // the Flutter side reads the legacy shape consistently.
            forwarded_from_message_id: forwardReady ? (m.forwarded_from_message_id || null) : null,
            is_forwarded: forwardReady ? !!m.is_forwarded : false,
            // Call-log metadata (mig 046, Step 3A). Same pre-migration
            // gate — ships null until the column is live, then the
            // JSONB blob flows through to `CallLogBubble`.
            call_log_metadata: callLogReady ? (m.call_log_metadata || null) : null,
          };
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
// POST /business/conversations/:id/messages/ack-delivered — Mark peer messages delivered
// ---------------------------------------------------------------------------
// Called by the client as soon as a message is received (e.g. on SSE message.new
// or on chat mount). Stamps delivered_at for each message from the counterpart
// that has not yet been delivered, and emits message.delivered to the sender.
async function ackMessagesDelivered(req, res, next) {
  try {
    const bizId = await getBizId(req.user.id);
    // mig 049 — group ack is a soft no-op for the MVP (per-user
    // delivery receipts deferred to Stage D). Members get a clean
    // 200 + empty array.
    const conv = await db('conversations').where({ id: req.params.id }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');
    const groupReady = await isGroupChatColumnsPresent();
    const isGroup = groupReady && conv.type === 'group';
    if (isGroup) {
      const member = await db('conversation_members')
        .where({ conversation_id: conv.id, user_id: req.user.id })
        .whereNull('left_at')
        .first();
      if (!member) throw AppError.notFound('Conversation not found.');
      ok(res, { message_ids: [], delivered_at: new Date().toISOString() });
      return;
    }
    if (conv.business_id !== bizId) {
      throw AppError.notFound('Conversation not found.');
    }

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
    // mig 049 — accept group conversations the caller is a member of.
    // 1:1 path stays gated on business_id ownership.
    const conv = await db('conversations').where({ id: req.params.id }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');
    const groupReady = await isGroupChatColumnsPresent();
    const isGroup = groupReady && conv.type === 'group';
    if (isGroup) {
      const myMembership = await db('conversation_members')
        .where({ conversation_id: conv.id, user_id: req.user.id })
        .whereNull('left_at')
        .first();
      if (!myMembership) throw AppError.notFound('Conversation not found.');
    } else if (conv.business_id !== bizId) {
      throw AppError.notFound('Conversation not found.');
    }
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
      video_url,
      video_size_bytes,
      video_mime_type,
      video_duration_ms,
      video_width,
      video_height,
      location_lat,
      location_lng,
      location_address,
      reply_to_message_id,
      shared_entity_type,
      shared_entity_id,
      album_image_urls,
      album_video_urls,
      album_video_metadata,
      forwarded_from_message_id,
      is_forwarded,
    } = req.body;

    const isAudio = attachment_type === 'audio';
    const isImage = attachment_type === 'image';
    const isDocument = attachment_type === 'document';
    const isVideo = attachment_type === 'video';
    const isLocation = attachment_type === 'location';
    const isEntityShare = attachment_type === 'entity_share';
    const isAlbum = attachment_type === 'album';
    const isVideoAlbum = attachment_type === 'video_album';
    // Album guard: see candidateController.sendMessage for design.
    let cleanAlbumUrls = null;
    if (isAlbum) {
      // Pre-migration safety — see candidateController.sendMessage.
      if (!(await isAlbumColumnPresent())) {
        throw AppError.unavailable(
          'Album messages are temporarily unavailable. Please try again in a moment.',
          'ALBUM_NOT_READY',
        );
      }
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
    if (isImage) {
      // See candidateController.sendMessage for design rationale.
      if (!image_url || typeof image_url !== 'string' || !storage.isOwnedUrl(image_url)) {
        throw AppError.badRequest('image_url is required and must come from /v1/uploads/image.');
      }
    }
    if (isDocument) {
      if (!document_url || typeof document_url !== 'string' || !storage.isOwnedUrl(document_url)) {
        throw AppError.badRequest('document_url is required and must come from /v1/uploads/document.');
      }
    }
    if (isVideo) {
      if (!(await isVideoColumnsPresent())) {
        throw AppError.unavailable(
          'Video messages are temporarily unavailable. Please try again in a moment.',
          'VIDEO_NOT_READY',
        );
      }
      if (!video_url || typeof video_url !== 'string' || !storage.isOwnedUrl(video_url) || !_looksLikeVideoStorageUrl(video_url)) {
        throw AppError.badRequest('video_url is required and must come from /v1/uploads/video.');
      }
      if (!_isAllowedVideoMime(video_mime_type)) {
        throw AppError.badRequest('Unsupported video type. Use MP4/MOV/M4V.', 'INVALID_MEDIA_TYPE');
      }
    }
    // Video-album guard. Mirror of the photo-album branch: validate
    // count + storage origin + (optional) metadata array shape. Each
    // URL must come from /v1/uploads/video — same allowlist as the
    // single-video path. Metadata is best-effort: missing or null is
    // fine, but if present it must be an array of the same length so
    // each tile pairs with its own (optional) duration/dims.
    let cleanVideoAlbumUrls = null;
    let cleanVideoAlbumMetadata = null;
    if (isVideoAlbum) {
      if (!(await isVideoAlbumColumnsPresent())) {
        throw AppError.unavailable(
          'Video album messages are temporarily unavailable. Please try again in a moment.',
          'VIDEO_ALBUM_NOT_READY',
        );
      }
      if (!Array.isArray(album_video_urls)) {
        throw AppError.badRequest('album_video_urls is required and must be an array.');
      }
      if (album_video_urls.length < 2) {
        throw AppError.badRequest('album_video_urls must contain at least 2 videos.');
      }
      if (album_video_urls.length > 6) {
        throw AppError.badRequest('album_video_urls cannot contain more than 6 videos.');
      }
      for (const u of album_video_urls) {
        if (!u || typeof u !== 'string' || !storage.isOwnedUrl(u) || !_looksLikeVideoStorageUrl(u)) {
          throw AppError.badRequest('Every album_video_urls entry must come from /v1/uploads/video.');
        }
      }
      cleanVideoAlbumUrls = album_video_urls;
      if (album_video_metadata !== undefined && album_video_metadata !== null) {
        if (!Array.isArray(album_video_metadata)) {
          throw AppError.badRequest('album_video_metadata must be an array when provided.');
        }
        if (album_video_metadata.length !== album_video_urls.length) {
          throw AppError.badRequest('album_video_metadata length must match album_video_urls length.');
        }
        // Each entry: sanitize to a shallow object of known keys so a
        // rogue client can't smuggle arbitrary JSON into the column.
        cleanVideoAlbumMetadata = album_video_metadata.map((entry) => {
          if (entry == null || typeof entry !== 'object') return {};
          const out = {};
          if (Number.isFinite(+entry.duration_ms)) out.duration_ms = +entry.duration_ms;
          if (Number.isFinite(+entry.width)) out.width = +entry.width;
          if (Number.isFinite(+entry.height)) out.height = +entry.height;
          if (Number.isFinite(+entry.size_bytes)) out.size_bytes = +entry.size_bytes;
          if (typeof entry.mime_type === 'string' && entry.mime_type.length <= 64) {
            out.mime_type = entry.mime_type;
          }
          return out;
        });
      }
    }
    // Location guard — same WGS-84 range check as candidateController.
    let locLat = null;
    let locLng = null;
    if (isLocation) {
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
    if (!isAudio && !isImage && !isDocument && !isVideo && !isLocation && !isEntityShare && !isAlbum && !isVideoAlbum && (!body || !body.trim())) {
      throw AppError.badRequest('Message body is required.');
    }

    // Phase 4 — entity-share guard. Mirror of
    // candidateController.sendMessage.
    let entityEnvelope = null;
    if (isEntityShare) {
      if (!isSupportedShareType(shared_entity_type)) {
        throw AppError.badRequest('Invalid shared_entity_type.');
      }
      if (typeof shared_entity_id !== 'string' || shared_entity_id.length === 0) {
        throw AppError.badRequest('Invalid shared_entity_id.');
      }
      entityEnvelope = await buildEntityShareEnvelope({
        type: shared_entity_type,
        id: shared_entity_id,
        viewerRole: 'business',
      });
      if (!entityEnvelope) {
        throw AppError.badRequest('Shared entity not found.');
      }
    }

    // Phase 3D — same-conversation reply guard. Mirror of
    // candidateController.sendMessage.
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

    // Forward support. Mirror of candidateController — see there for
    // full rationale. The business is allowed to forward FROM any
    // conversation they own (i.e. any business_id matching `bizId`).
    let forwardSourceId = null;
    let forwardFlag = false;
    if (forwarded_from_message_id !== undefined && forwarded_from_message_id !== null) {
      if (typeof forwarded_from_message_id !== 'string' || forwarded_from_message_id.length === 0) {
        throw AppError.badRequest('Invalid forwarded_from_message_id.');
      }
      if (is_forwarded !== true) {
        throw AppError.badRequest('forwarded_from_message_id requires is_forwarded=true.');
      }
      if (!(await isForwardedColumnsPresent())) {
        throw AppError.unavailable(
          'Message forwarding is temporarily unavailable. Please try again in a moment.',
          'FORWARD_NOT_READY',
        );
      }
      const source = await db('messages')
        .leftJoin('conversations', 'conversations.id', 'messages.conversation_id')
        .where('messages.id', forwarded_from_message_id)
        .select(
          'messages.id',
          'messages.deleted_for_everyone_at',
          'conversations.business_id',
        )
        .first();
      if (!source) {
        throw AppError.notFound('Forward source message not found.');
      }
      if (source.business_id !== bizId) {
        throw AppError.forbidden('You cannot forward messages from a conversation you are not part of.');
      }
      if (source.deleted_for_everyone_at != null) {
        throw AppError.badRequest('Cannot forward a deleted message.');
      }
      forwardSourceId = source.id;
      forwardFlag = true;
    } else if (is_forwarded === true) {
      throw AppError.badRequest('is_forwarded=true requires forwarded_from_message_id.');
    }

    const cleanBody = (body && body.trim()) || '';
    const dbAttachmentType = isAudio
      ? 'audio'
      : isImage
        ? 'image'
        : isDocument
          ? 'document'
          : isVideo
            ? 'video'
            : isLocation
              ? 'location'
              : isEntityShare
                ? 'entity_share'
                : isAlbum
                  ? 'album'
                  : isVideoAlbum
                    ? 'video_album'
                    : 'text';
    const insertData = {
      conversation_id: conv.id,
      sender_id: req.user.id,
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
      // businesses.id) even when the client passed users.id.
      shared_entity_id: isEntityShare ? entityEnvelope.id : null,
    };
    // Album: jsonb array. See candidateController.sendMessage.
    if (await isAlbumColumnPresent()) {
      insertData.album_image_urls = isAlbum ? JSON.stringify(cleanAlbumUrls) : null;
    }
    if (await isVideoColumnsPresent()) {
      insertData.video_url = isVideo ? video_url : null;
      insertData.video_size_bytes = isVideo && Number.isFinite(+video_size_bytes) ? +video_size_bytes : null;
      insertData.video_mime_type = isVideo ? video_mime_type : null;
      insertData.video_duration_ms = isVideo && Number.isFinite(+video_duration_ms) ? +video_duration_ms : null;
      insertData.video_width = isVideo && Number.isFinite(+video_width) ? +video_width : null;
      insertData.video_height = isVideo && Number.isFinite(+video_height) ? +video_height : null;
    }
    // Video album: jsonb arrays. Mirror of the photo-album insert.
    if (await isVideoAlbumColumnsPresent()) {
      insertData.album_video_urls = isVideoAlbum ? JSON.stringify(cleanVideoAlbumUrls) : null;
      insertData.album_video_metadata = isVideoAlbum && cleanVideoAlbumMetadata != null
        ? JSON.stringify(cleanVideoAlbumMetadata)
        : null;
    }
    // Forward fields. Mirror of candidateController. The auth +
    // FORWARD_NOT_READY guard above already gates `forwardFlag` to
    // false when the columns are missing, so by the time we reach
    // the INSERT either we have both fields ready or the row is a
    // plain legacy send.
    if (await isForwardedColumnsPresent()) {
      insertData.forwarded_from_message_id = forwardSourceId;
      insertData.is_forwarded = forwardFlag;
    }
    const [msg] = await db('messages').insert(insertData).returning('*');

    const preview = isAudio
      ? '🎤 Voice message'
      : isImage
        ? '🖼 Photo'
        : isDocument
          ? '📄 Document'
          : isVideo
            ? '🎥 Video'
            : isLocation
              ? '📍 Location'
              : isEntityShare
                ? _entitySharePreview(shared_entity_type)
                : isVideoAlbum
                  ? `🎥 Album · ${cleanVideoAlbumUrls.length} videos`
                  : isAlbum
                    ? `📷 Album · ${cleanAlbumUrls.length} photo${cleanAlbumUrls.length === 1 ? '' : 's'}`
                  : cleanBody.slice(0, 200);
    await db('conversations').where({ id: conv.id }).update({
      last_message: preview,
      updated_at: db.fn.now(),
    });
    console.log(`[BACKEND CREATE] business→candidate msgId=${msg.id} convId=${conv.id} businessUserId=${req.user.id} candidateId=${conv.candidate_id || 'null'} type=${msg.attachment_type} body="${msg.body}"`);
    // Notify the recipient(s). 1:1: single candidate. Group: fan
    // out via conversation_members minus the sender.
    let candidateUserId = null;
    let candNameForAdmin = null;
    let bizNameForAdmin = null;
    const groupMemberIds = [];
    if (isGroup) {
      const bizUser = await db('users').where({ id: req.user.id }).first();
      bizNameForAdmin = bizUser?.name || null;
      const memberRows = await db('conversation_members')
        .where({ conversation_id: conv.id })
        .whereNull('left_at')
        .pluck('user_id');
      for (const uid of memberRows) {
        if (uid !== req.user.id) {
          groupMemberIds.push(uid);
          hiringNotify(
            uid,
            `New message in ${conv.name || 'group'}`,
            'in_app',
            conv.id,
            'message',
          );
        }
      }
    } else if (conv.candidate_id) {
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
      const adminPreview = isGroup
        ? `Group message: ${bizNameForAdmin || 'business'} → ${conv.name || 'group'}`
        : `Message: ${bizNameForAdmin || 'business'} → ${candNameForAdmin || 'candidate'}`;
      await notifyAllAdmins(
        adminPreview,
        'in_app', conv.id, 'message', preview.slice(0, 80),
      );
    } catch (e) { /* best-effort */ }
    // Phase 3D — see candidateController.sendMessage for the full
    // rationale. Build the compact reply envelope once and reuse it
    // across both the POST response and the SSE message.new payload.
    const replyEnvelope = await buildReplyEnvelope(msg.reply_to_message_id);
    // Realtime broadcast — 1:1 path unchanged; group path fans out.
    const audience = ['role:admin', `user:${req.user.id}`];
    if (isGroup) {
      for (const uid of groupMemberIds) audience.push(`user:${uid}`);
    } else if (candidateUserId) {
      audience.push(`user:${candidateUserId}`);
    }
    console.log(`[SSE EMIT] type=message.new convId=${conv.id} senderUserId=${req.user.id} ${isGroup ? `groupMembers=${groupMemberIds.length}` : `recipientUserId=${candidateUserId || 'null'}`} audience=${JSON.stringify(audience)}`);
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
        video_url: msg.video_url || null,
        video_size_bytes: msg.video_size_bytes || null,
        video_mime_type: msg.video_mime_type || null,
        video_duration_ms: msg.video_duration_ms || null,
        video_width: msg.video_width || null,
        video_height: msg.video_height || null,
        location_lat: msg.location_lat == null ? null : msg.location_lat,
        location_lng: msg.location_lng == null ? null : msg.location_lng,
        location_address: msg.location_address || null,
        album_image_urls: _normalizeAlbumUrls(msg.album_image_urls),
        album_video_urls: _normalizeAlbumUrls(msg.album_video_urls),
        album_video_metadata: _normalizeAlbumMetadata(msg.album_video_metadata),
        // Forward metadata — see candidateController.sendMessage.
        forwarded_from_message_id: msg.forwarded_from_message_id || null,
        is_forwarded: !!msg.is_forwarded,
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
      sender_user_id: req.user.id,
      // 1:1 carries the explicit peer id; groups stay null
      // (audience field tells subscribers they're recipients).
      recipient_user_id: isGroup ? null : candidateUserId,
      sender_role: 'business',
      conversation_type: isGroup ? 'group' : '1v1',
    }, audience);
    ok(res, { ...msg, reply_to: replyEnvelope, shared_entity: entityEnvelope });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /business/messages/:messageId/reactions — Add or update reaction
// ---------------------------------------------------------------------------
// Mirror of the candidate-side endpoint. One reaction per user per
// message, UPSERT-based. Access gated by conversation membership —
// the business can only react to messages inside its own threads.
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

    // Group-aware permission gate (mig 049).
    const { target, biz, isGroup } =
      await _resolveBusinessMessageAccess(messageId, userId);
    if (!target) throw AppError.notFound('Message not found.');

    const existing = await db('message_reactions')
      .where({ message_id: messageId, user_id: userId })
      .select('emoji')
      .first();

    await db('message_reactions')
      .insert({ message_id: messageId, user_id: userId, emoji })
      .onConflict(['message_id', 'user_id'])
      .merge({ emoji, updated_at: db.fn.now() });

    // mig 049 — in groups, skip the synthetic "X reacted" row +
    // last_message bump. Mirror of the candidate-side branch.
    if (isGroup) {
      ok(res, { message_id: messageId, user_id: userId, emoji });
      return;
    }

    // Sprint 4F — surface the reaction on the peer's inbox / home.
    // Same pattern as candidateController: synthetic
    // attachment_type='reaction' message bumps unread + last_message
    // and emits message.new SSE; the bell is intentionally untouched
    // (no notification.new). Self-react and emoji re-tap are silent.
    const emojiChanged = !existing || existing.emoji !== emoji;
    const isSelfReact = String(target.msg_sender_id) === String(userId);
    let peerUserId = null;
    if (target.conv_candidate_id) {
      const cand = await db('candidates')
        .where({ id: target.conv_candidate_id })
        .select('user_id')
        .first();
      peerUserId = cand?.user_id || null;
    }

    if (emojiChanged && !isSelfReact && peerUserId) {
      const preview = `${biz.name} reacted to your message`;
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
        sender_role: 'business',
        kind: 'reaction',
      }, audience);
    }

    ok(res, { message_id: messageId, user_id: userId, emoji });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /business/messages/:messageId/reactions — Remove own reaction
// ---------------------------------------------------------------------------
async function removeMessageReaction(req, res, next) {
  try {
    const messageId = req.params.messageId;

    // Group-aware permission gate (mig 049).
    const { target } = await _resolveBusinessMessageAccess(messageId, req.user.id);
    if (!target) throw AppError.notFound('Message not found.');

    await db('message_reactions')
      .where({ message_id: messageId, user_id: req.user.id })
      .delete();

    ok(res, { message_id: messageId, user_id: req.user.id, removed: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// POST /business/messages/:messageId/star — Star a message (per-user)
// ---------------------------------------------------------------------------
// Mirror of candidateController.starMessage. Stars are private —
// only the caller sees them. No realtime broadcast.
async function starMessage(req, res, next) {
  try {
    const messageId = req.params.messageId;

    // Group-aware permission gate (mig 049).
    const { target } = await _resolveBusinessMessageAccess(messageId, req.user.id);
    if (!target) throw AppError.notFound('Message not found.');

    await db('message_stars')
      .insert({ message_id: messageId, user_id: req.user.id })
      .onConflict(['message_id', 'user_id'])
      .ignore();

    ok(res, { message_id: messageId, user_id: req.user.id, starred: true });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// DELETE /business/messages/:messageId/star — Unstar own star
// ---------------------------------------------------------------------------
async function unstarMessage(req, res, next) {
  try {
    const messageId = req.params.messageId;

    // Group-aware permission gate (mig 049).
    const { target } = await _resolveBusinessMessageAccess(messageId, req.user.id);
    if (!target) throw AppError.notFound('Message not found.');

    await db('message_stars')
      .where({ message_id: messageId, user_id: req.user.id })
      .delete();

    ok(res, { message_id: messageId, user_id: req.user.id, starred: false });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// Sprint 4C — Delete actions, mirror of candidateController. See the
// candidate-side comment for the design rationale.
// ---------------------------------------------------------------------------

const DELETE_FOR_EVERYONE_WINDOW_MS = 15 * 60 * 1000;

async function hideMessageForMe(req, res, next) {
  try {
    const messageId = req.params.messageId;

    // Group-aware permission gate (mig 049).
    const { target } = await _resolveBusinessMessageAccess(messageId, req.user.id);
    if (!target) throw AppError.notFound('Message not found.');

    await db('message_hides')
      .insert({ message_id: messageId, user_id: req.user.id })
      .onConflict(['message_id', 'user_id'])
      .ignore();

    ok(res, { message_id: messageId, user_id: req.user.id, hidden: true });
  } catch (err) { next(err); }
}

async function deleteMessageForEveryone(req, res, next) {
  try {
    const messageId = req.params.messageId;

    // Group-aware permission gate (mig 049). Returns target with
    // sender_id, created_at, deleted_for_everyone_at, conv fields.
    const { target, isGroup } =
      await _resolveBusinessMessageAccess(messageId, req.user.id);
    if (!target) throw AppError.notFound('Message not found.');

    if (target.msg_sender_id !== req.user.id) {
      throw AppError.forbidden(
        'You can only delete your own messages for everyone.',
        'NOT_SENDER',
      );
    }
    if (target.msg_deleted_for_everyone_at) {
      ok(res, { message_id: messageId, deleted_for_everyone: true });
      return;
    }
    const ageMs = Date.now() - new Date(target.msg_created_at).getTime();
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
      await trx('message_reactions').where({ message_id: messageId }).delete();
    });

    // Realtime fan-out. 1:1: sender + candidate peer. Group: every
    // active member so each client can flip the bubble to a
    // tombstone immediately.
    const audience = ['role:admin', `user:${req.user.id}`];
    if (isGroup) {
      const memberRows = await db('conversation_members')
        .where({ conversation_id: target.conv_id })
        .whereNull('left_at')
        .pluck('user_id');
      for (const u of memberRows) {
        if (u !== req.user.id) audience.push(`user:${u}`);
      }
    } else if (target.conv_candidate_id) {
      const cand = await db('candidates').where({ id: target.conv_candidate_id }).select('user_id').first();
      if (cand?.user_id) audience.push(`user:${cand.user_id}`);
    }
    bus.publish('message.deleted_for_everyone', {
      message_id: messageId,
      conversation_id: target.conv_id,
      deleted_for_everyone_at: deletedAt,
      sender_user_id: req.user.id,
    }, audience);

    ok(res, { message_id: messageId, deleted_for_everyone: true, deleted_for_everyone_at: deletedAt });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// Sprint 4E4 — Report a message. Mirror of candidateController.
// See that file for the full design rationale (reuse the platform
// `reports` table with type='message', no migration, allowlist for
// categories, notes mandatory only for 'other', tombstone reportable,
// notifyAllAdmins best-effort).
// ---------------------------------------------------------------------------

const ALLOWED_REPORT_CATEGORIES_BIZ = new Set([
  'spam',
  'harassment',
  'scam',
  'inappropriate',
  'other',
]);
const REPORT_NOTES_MAX_LEN_BIZ = 1000;

async function reportMessage(req, res, next) {
  try {
    const userId = req.user.id;
    const messageId = req.params.messageId;
    const { category, notes } = req.body || {};

    if (typeof category !== 'string' || !ALLOWED_REPORT_CATEGORIES_BIZ.has(category)) {
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
      if (cleanNotes != null && cleanNotes.length > REPORT_NOTES_MAX_LEN_BIZ) {
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

    // Group-aware permission gate (mig 049).
    const { target } = await _resolveBusinessMessageAccess(messageId, userId);
    if (!target) throw AppError.notFound('Message not found.');

    const [report] = await db('reports')
      .insert({
        title: 'Message report',
        type: 'message',
        reported_entity: messageId,
        reporter: userId,
        reason: category,
        summary: cleanNotes,
      })
      .returning(['id', 'status', 'created_at']);

    try {
      const preview = (target.msg_body || '').slice(0, 80);
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

// Phase 4A — messages-surface notification routes ('message' for 1:1
// chat, 'group' for group lifecycle) must never appear in the bell
// list per the product rule "Bell for non-chat events only". Mirror
// of `candidateController._BELL_EXCLUDED_ROUTES`. Rows with NULL
// destination_route are KEPT (legacy generic notifications).
const _BELL_EXCLUDED_ROUTES = ['message', 'group'];

function _excludeChatRoutes(qb) {
  return qb.where(function () {
    this.whereNull('destination_route')
      .orWhereNotIn('destination_route', _BELL_EXCLUDED_ROUTES);
  });
}

async function listNotifications(req, res, next) {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 50, is_read } = req.query;
    let base = _excludeChatRoutes(
      db('notifications').where({ recipient_id: userId }),
    );
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

// ---------------------------------------------------------------------------
// GET /business/candidates/available — Stage AL.4A
//
// Discovery endpoint for candidates whose AL.1 availability_state is
// non-null AND non-expired. Two operating modes:
//
//   • haversine — business has lat/lng AND candidate has lat/lng:
//     filters by radius, returns distance_km sorted ascending.
//   • fallback  — business is missing lat/lng: returns ALL available
//     candidates (geo data on the candidate side is ignored), sorted
//     by state priority (now > today > tomorrow > weekend > recurring)
//     then last_active_at desc. distance_km is null.
//
// In haversine mode, candidates without lat/lng are EXCLUDED so the
// "nearby" promise isn't silently violated. They only surface when
// the business itself has no geo (fallback mode).
//
// Raw lat/lng is NEVER returned — only the computed distance_km. The
// endpoint is gated by `isCandidateAvailabilityColumnsPresent` so a
// pre-mig-051 deploy returns 503, not 500.
// ---------------------------------------------------------------------------
const _AVAILABILITY_STATE_PRIORITY_SQL = `
  CASE candidates.availability_state
    WHEN 'now'          THEN 1
    WHEN 'today'        THEN 2
    WHEN 'tomorrow'     THEN 3
    WHEN 'this_weekend' THEN 4
    WHEN 'evening_only' THEN 5
    WHEN 'full_time'    THEN 6
    WHEN 'part_time'    THEN 7
    ELSE                     99
  END AS state_priority`;

async function availableCandidates(req, res, next) {
  try {
    if (!(await isCandidateAvailabilityColumnsPresent())) {
      throw AppError.unavailable(
        'Availability discovery is temporarily unavailable. Please try again in a moment.',
        'CANDIDATE_AVAILABILITY_NOT_READY',
      );
    }
    if (req.user.role !== 'business') {
      throw AppError.forbidden('Only businesses can list available candidates.');
    }

    const { radius = 10, limit = 30, role } = req.query;
    const radiusKm = Math.max(1, Math.min(parseFloat(radius) || 10, 200));
    const cap = Math.max(1, Math.min(parseInt(limit, 10) || 30, 100));

    const biz = await db('businesses').where({ user_id: req.user.id }).first();
    if (!biz) throw AppError.notFound('Business profile not found.');
    const hasBizGeo = biz.latitude != null && biz.longitude != null;

    // Common filter: candidate active + availability set + not expired.
    const applyAvailabilityFilter = (qb) => qb
      .where('users.user_type', 'candidate')
      .where('users.status', 'active')
      .whereNotNull('candidates.availability_state')
      .where(function () {
        this.whereNull('candidates.availability_until')
          .orWhere('candidates.availability_until', '>', db.fn.now());
      });

    let rows;
    let geoMode;

    if (hasBizGeo) {
      let base = db('candidates')
        .leftJoin('users', 'candidates.user_id', 'users.id')
        .whereNotNull('users.latitude')
        .whereNotNull('users.longitude')
        .select(
          'candidates.id', 'candidates.name', 'candidates.initials',
          'candidates.role', 'candidates.location',
          'candidates.availability_state', 'candidates.availability_until',
          'candidates.verification_status', 'candidates.avatar_hue',
          'users.photo_url',
          db.raw(CANDIDATE_HAVERSINE, [biz.latitude, biz.longitude, biz.latitude]),
        );
      base = applyAvailabilityFilter(base);
      if (role) base = base.whereILike('candidates.role', `%${role}%`);

      const sub = base.as('avail');
      rows = await db.select('*').from(sub)
        .where('distance_km', '<=', radiusKm)
        .orderBy('distance_km', 'asc')
        .limit(cap);
      geoMode = 'haversine';
    } else {
      let base = db('candidates')
        .leftJoin('users', 'candidates.user_id', 'users.id')
        .select(
          'candidates.id', 'candidates.name', 'candidates.initials',
          'candidates.role', 'candidates.location',
          'candidates.availability_state', 'candidates.availability_until',
          'candidates.verification_status', 'candidates.avatar_hue',
          'candidates.last_active_at', 'candidates.created_at',
          'users.photo_url',
          db.raw(_AVAILABILITY_STATE_PRIORITY_SQL),
        );
      base = applyAvailabilityFilter(base);
      if (role) base = base.whereILike('candidates.role', `%${role}%`);

      rows = await base
        .orderByRaw('state_priority asc')
        .orderByRaw('candidates.last_active_at desc nulls last')
        .orderBy('candidates.created_at', 'desc')
        .limit(cap);
      geoMode = 'fallback';
    }

    // Privacy: never leak raw lat/lng. Only the computed distance_km
    // (rounded to 100m precision) crosses the boundary.
    const data = rows.map((r) => ({
      id: r.id,
      name: r.name || '',
      initials: r.initials || '',
      role: r.role || '',
      location: r.location || '',
      photo_url: r.photo_url || null,
      verified: r.verification_status === 'verified',
      avatar_hue: r.avatar_hue ?? 0.5,
      availability_state: r.availability_state,
      availability_until: r.availability_until || null,
      distance_km: geoMode === 'haversine' && r.distance_km != null
        ? Math.round(r.distance_km * 10) / 10
        : null,
    }));

    ok(res, data, { total: data.length, geo_mode: geoMode, radius_km: hasBizGeo ? radiusKm : null });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// Stage AL.5.2 — Urgent staff requests (CRUD-ish, business-side only)
//
// Three endpoints backing the "Need staff today" Business UX:
//
//   POST  /business/urgent-requests        — create an open request
//   GET   /business/urgent-requests        — list own (filterable by status)
//   PATCH /business/urgent-requests/:id    — cancel or mark filled
//
// All three are role-gated to business JWTs (403 candidate/admin) and
// schema-flag-gated on `urgent_requests` table presence (503 pre-mig).
//
// `expires_at` is server-computed at INSERT as `(ends_at OR starts_at)
// + 4h grace`. The 4h covers shift overrun + tardy candidate replies
// without keeping stale posts live overnight. PATCH `ends_at`
// extensions recompute expires_at automatically.
//
// Status transitions are one-way:
//   open → cancelled  ✅   open → filled  ✅
//   (anything else)   ❌   Terminal states are immutable.
//
// `filled_by_candidate_id` is never written by AL.5.2 — manual fill
// marks the row "filled" without a candidate id. AL.6 will populate
// the column via the chat-handoff flow without an additional schema
// change.
//
// `expired` is detected lazily on read (filter `expires_at > NOW()`
// when `include_expired=false`). No cron, no auto status flip. Stale
// open rows stay in the table with `status='open'` until a future
// cleanup sprint.
// ---------------------------------------------------------------------------

const _URGENT_REQUEST_NOT_READY = 'URGENT_REQUESTS_NOT_READY';
const _URGENT_MAX_NOTES_LENGTH = 500;
const _URGENT_MAX_LOCATION_LENGTH = 200;
const _URGENT_MAX_ROLE_LENGTH = 100;
const _URGENT_MAX_SHIFT_DURATION_MS = 24 * 60 * 60 * 1000;     // single-shift cap
const _URGENT_MAX_FUTURE_START_MS = 30 * 24 * 60 * 60 * 1000;  // 30 days
const _URGENT_CLOCK_SKEW_MS = 5 * 60 * 1000;                   // 5 min tolerance
const _URGENT_EXPIRY_GRACE_MS = 4 * 60 * 60 * 1000;            // 4 h post-end
const _URGENT_VALID_STATUS_FILTERS = new Set(['open', 'filled', 'expired', 'cancelled']);
const _URGENT_ALLOWED_PATCH_STATUSES = new Set(['cancelled', 'filled']);

function _parseUrgentIsoTimestamp(raw, field) {
  if (typeof raw !== 'string' || !raw.trim()) {
    throw AppError.badRequest(`${field} is required.`);
  }
  const d = new Date(raw);
  if (Number.isNaN(d.getTime())) {
    throw AppError.badRequest(`${field} must be a valid ISO timestamp.`);
  }
  return d;
}

function _computeUrgentExpiresAt(startsAt, endsAt) {
  const base = endsAt instanceof Date ? endsAt : startsAt;
  return new Date(base.getTime() + _URGENT_EXPIRY_GRACE_MS);
}

async function createUrgentRequest(req, res, next) {
  try {
    if (!(await isUrgentRequestsTablePresent())) {
      throw AppError.unavailable(
        'Urgent requests are temporarily unavailable. Please try again in a moment.',
        _URGENT_REQUEST_NOT_READY,
      );
    }
    if (req.user.role !== 'business') {
      throw AppError.forbidden('Only businesses can create urgent requests.');
    }

    const body = req.body || {};
    const roleRaw = typeof body.role === 'string' ? body.role.trim() : '';
    if (!roleRaw) throw AppError.badRequest('role is required.');
    if (roleRaw.length > _URGENT_MAX_ROLE_LENGTH) {
      throw AppError.badRequest(`role must be 1-${_URGENT_MAX_ROLE_LENGTH} characters.`);
    }

    const startsAt = _parseUrgentIsoTimestamp(body.starts_at, 'starts_at');
    const now = Date.now();
    if (startsAt.getTime() < now - _URGENT_CLOCK_SKEW_MS) {
      throw AppError.badRequest('starts_at cannot be in the past.');
    }
    if (startsAt.getTime() > now + _URGENT_MAX_FUTURE_START_MS) {
      throw AppError.badRequest('starts_at cannot be more than 30 days from now.');
    }

    let endsAt = null;
    if (body.ends_at !== undefined && body.ends_at !== null && body.ends_at !== '') {
      endsAt = _parseUrgentIsoTimestamp(body.ends_at, 'ends_at');
      if (endsAt.getTime() <= startsAt.getTime()) {
        throw AppError.badRequest('ends_at must be after starts_at.');
      }
      if (endsAt.getTime() - startsAt.getTime() > _URGENT_MAX_SHIFT_DURATION_MS) {
        throw AppError.badRequest('ends_at cannot be more than 24 hours after starts_at.');
      }
    }

    let location = null;
    if (body.location !== undefined && body.location !== null) {
      if (typeof body.location !== 'string') {
        throw AppError.badRequest('location must be a string or null.');
      }
      const trimmed = body.location.trim();
      if (trimmed.length > _URGENT_MAX_LOCATION_LENGTH) {
        throw AppError.badRequest(`location must be at most ${_URGENT_MAX_LOCATION_LENGTH} characters.`);
      }
      location = trimmed || null;
    }

    let latitude = null;
    if (body.latitude !== undefined && body.latitude !== null) {
      const n = Number(body.latitude);
      if (!Number.isFinite(n) || n < -90 || n > 90) {
        throw AppError.badRequest('latitude must be a number between -90 and 90.');
      }
      latitude = n;
    }
    let longitude = null;
    if (body.longitude !== undefined && body.longitude !== null) {
      const n = Number(body.longitude);
      if (!Number.isFinite(n) || n < -180 || n > 180) {
        throw AppError.badRequest('longitude must be a number between -180 and 180.');
      }
      longitude = n;
    }

    let notes = null;
    if (body.notes !== undefined && body.notes !== null) {
      if (typeof body.notes !== 'string') {
        throw AppError.badRequest('notes must be a string or null.');
      }
      const trimmed = body.notes.trim();
      if (trimmed.length > _URGENT_MAX_NOTES_LENGTH) {
        throw AppError.badRequest(`notes must be at most ${_URGENT_MAX_NOTES_LENGTH} characters.`);
      }
      notes = trimmed || null;
    }

    // Resolve business defaults — copy location/lat/lng from the
    // business row when the caller didn't supply them. Keeps urgent
    // posts useful even when the business UI doesn't prompt for
    // explicit location entry.
    const biz = await db('businesses').where({ user_id: req.user.id }).first();
    if (!biz) throw AppError.badRequest('Business profile not found.');
    if (location === null) location = biz.location || null;
    if (latitude === null) latitude = biz.latitude ?? null;
    if (longitude === null) longitude = biz.longitude ?? null;

    const expiresAt = _computeUrgentExpiresAt(startsAt, endsAt);

    const [row] = await db('urgent_requests').insert({
      business_id: biz.id,
      role: roleRaw,
      location,
      latitude,
      longitude,
      starts_at: startsAt.toISOString(),
      ends_at: endsAt ? endsAt.toISOString() : null,
      notes,
      status: 'open',
      expires_at: expiresAt.toISOString(),
    }).returning('*');

    return res.status(201).json({ success: true, data: row });
  } catch (err) { next(err); }
}

async function listUrgentRequests(req, res, next) {
  try {
    if (!(await isUrgentRequestsTablePresent())) {
      throw AppError.unavailable(
        'Urgent requests are temporarily unavailable. Please try again in a moment.',
        _URGENT_REQUEST_NOT_READY,
      );
    }
    if (req.user.role !== 'business') {
      throw AppError.forbidden('Only businesses can list urgent requests.');
    }

    const bizId = await getBizId(req.user.id);
    const statusRaw = typeof req.query.status === 'string'
      ? req.query.status.trim() : 'open';
    const status = _URGENT_VALID_STATUS_FILTERS.has(statusRaw) ? statusRaw : 'open';
    const includeExpired = req.query.include_expired === 'true'
      || req.query.include_expired === '1';
    const cap = Math.max(1, Math.min(parseInt(req.query.limit, 10) || 20, 100));

    let q = db('urgent_requests')
      .where({ business_id: bizId, status });

    // Lazy expired filter: open + not yet past grace window.
    if (status === 'open' && !includeExpired) {
      q = q.where('expires_at', '>', db.fn.now());
    }

    const orderField = status === 'open' ? 'starts_at' : 'updated_at';
    const orderDir = status === 'open' ? 'asc' : 'desc';
    const rows = await q.orderBy(orderField, orderDir).limit(cap);

    ok(res, rows, {
      total: rows.length,
      status,
      include_expired: includeExpired,
    });
  } catch (err) { next(err); }
}

async function updateUrgentRequest(req, res, next) {
  try {
    if (!(await isUrgentRequestsTablePresent())) {
      throw AppError.unavailable(
        'Urgent requests are temporarily unavailable. Please try again in a moment.',
        _URGENT_REQUEST_NOT_READY,
      );
    }
    if (req.user.role !== 'business') {
      throw AppError.forbidden('Only businesses can update urgent requests.');
    }

    const bizId = await getBizId(req.user.id);
    const body = req.body || {};
    if (
      body.status === undefined
      && body.ends_at === undefined
      && body.notes === undefined
    ) {
      throw AppError.badRequest('No fields to update.');
    }

    const existing = await db('urgent_requests')
      .where({ id: req.params.id, business_id: bizId })
      .first();
    if (!existing) throw AppError.notFound('Urgent request not found.');

    // Terminal-state guard — `cancelled`/`filled`/`expired` are
    // immutable in AL.5.2 (audit-trail clarity).
    if (existing.status !== 'open') {
      throw AppError.badRequest('Urgent request is no longer open and cannot be updated.');
    }

    const updates = { updated_at: db.fn.now() };

    if (body.status !== undefined) {
      if (!_URGENT_ALLOWED_PATCH_STATUSES.has(body.status)) {
        throw AppError.badRequest(
          `Invalid status transition. Allowed: ${[..._URGENT_ALLOWED_PATCH_STATUSES].join(', ')}.`,
        );
      }
      updates.status = body.status;
    }

    let newEndsAt = null;
    if (body.ends_at !== undefined) {
      if (body.ends_at === null || body.ends_at === '') {
        updates.ends_at = null;
      } else {
        newEndsAt = _parseUrgentIsoTimestamp(body.ends_at, 'ends_at');
        const startsAt = new Date(existing.starts_at);
        if (newEndsAt.getTime() <= startsAt.getTime()) {
          throw AppError.badRequest('ends_at must be after starts_at.');
        }
        if (newEndsAt.getTime() - startsAt.getTime() > _URGENT_MAX_SHIFT_DURATION_MS) {
          throw AppError.badRequest('ends_at cannot be more than 24 hours after starts_at.');
        }
        updates.ends_at = newEndsAt.toISOString();
        // Extension recomputes expires_at off the new ends_at.
        updates.expires_at = _computeUrgentExpiresAt(startsAt, newEndsAt).toISOString();
      }
    }

    if (body.notes !== undefined) {
      if (body.notes === null) {
        updates.notes = null;
      } else if (typeof body.notes !== 'string') {
        throw AppError.badRequest('notes must be a string or null.');
      } else {
        const trimmed = body.notes.trim();
        if (trimmed.length > _URGENT_MAX_NOTES_LENGTH) {
          throw AppError.badRequest(`notes must be at most ${_URGENT_MAX_NOTES_LENGTH} characters.`);
        }
        updates.notes = trimmed || null;
      }
    }

    // Optimistic-lock semantics: re-check status='open' inside the
    // UPDATE WHERE so a concurrent cancel/fill races safely (returns
    // 0 rows, we surface a 400). Same pattern as the existing
    // updateJob endpoint.
    const [row] = await db('urgent_requests')
      .where({ id: existing.id, business_id: bizId, status: 'open' })
      .update(updates)
      .returning('*');
    if (!row) {
      throw AppError.badRequest('Urgent request was modified by another request. Please refresh.');
    }

    ok(res, row);
  } catch (err) { next(err); }
}

// Mirror of candidateController._AVATAR_MIME_TO_EXT — kept inline.
const _AVATAR_MIME_TO_EXT = {
  'image/jpeg': 'jpg',
  'image/jpg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
  'image/heic': 'heic',
  'image/heif': 'heic',
};
const _AVATAR_MAX_BYTES = 4 * 1024 * 1024;

async function uploadPhoto(req, res, next) {
  try {
    const { photo } = req.body;

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
      // See candidateController.uploadPhoto for the full design rationale.
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

/** See candidateController._replyBodyPreview — keep in sync. */
function _replyBodyPreview(attachmentType, body, sharedEntityType, albumImageUrls, albumVideoUrls) {
  if (attachmentType === 'deleted') return 'This message was deleted';
  if (attachmentType === 'audio') return '🎤 Voice message';
  if (attachmentType === 'image') return '🖼 Photo';
  if (attachmentType === 'document') return '📄 Document';
  if (attachmentType === 'video') return '🎥 Video';
  if (attachmentType === 'location') return '📍 Location';
  if (attachmentType === 'entity_share') {
    return _entitySharePreview(sharedEntityType);
  }
  if (attachmentType === 'album') {
    const urls = _normalizeAlbumUrls(albumImageUrls);
    const len = Array.isArray(urls) ? urls.length : 0;
    return `📷 Album · ${len} photo${len === 1 ? '' : 's'}`;
  }
  if (attachmentType === 'video_album') {
    const urls = _normalizeAlbumUrls(albumVideoUrls);
    const len = Array.isArray(urls) ? urls.length : 0;
    return `🎥 Album · ${len} video${len === 1 ? '' : 's'}`;
  }
  return (body || '').slice(0, 200);
}

const _VIDEO_MESSAGE_MIME = new Set([
  'video/mp4',
  'video/quicktime',
  'video/x-m4v',
]);

function _isAllowedVideoMime(mime) {
  return typeof mime === 'string' && _VIDEO_MESSAGE_MIME.has(mime);
}

function _looksLikeVideoStorageUrl(url) {
  if (typeof url !== 'string') return false;
  try {
    return new URL(url).pathname.includes('/video/');
  } catch (_) {
    return url.includes('/video/');
  }
}

/** See candidateController._normalizeAlbumUrls — keep in sync. */
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

/** Normalize the `album_video_metadata` jsonb column into an array
 *  of {duration_ms?, width?, height?, size_bytes?, mime_type?}
 *  objects. Mirror of [_normalizeAlbumUrls] — same defensive parse so
 *  the column survives a manual psql insert that stored the JSON as a
 *  plain string instead of a real jsonb. Keep in sync with
 *  candidateController. */
function _normalizeAlbumMetadata(value) {
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

/** See candidateController._entitySharePreview — keep in sync. */
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

module.exports = {
  profile, home, updateProfile, uploadPhoto,
  listJobs, createJob, getJob, updateJob, duplicateJob,
  listApplicants, updateApplicantStatus,
  listInterviews, scheduleInterview, updateInterviewStatus,
  listConversations, listMessages, sendMessage, sendTyping, ackMessagesDelivered, startConversation, archiveConversation,
  addMessageReaction, removeMessageReaction,
  starMessage, unstarMessage,
  hideMessageForMe, deleteMessageForEveryone,
  reportMessage,
  getCandidateProfile,
  listNotifications, markNotificationRead, markAllNotificationsRead,
  deleteNotification, deleteAllNotifications,
  recentApplicants, nearbyCandidates, availableCandidates, listJobMatches, submitMatchFeedback, updateMatchStatus,
  createUrgentRequest, listUrgentRequests, updateUrgentRequest,
  quickplugDeck, quickplugSwipe,
  subscription,
  tryCreateMutualMatch,
  // Phase 5A — expose the existing admin fan-out helper so
  // authController (and any future signup / lifecycle controller)
  // can hook admin visibility events without duplicating the
  // hiringNotify-per-admin loop.
  notifyAllAdmins,
  // Stage AL.5.8 — expose the granular per-recipient notify helper
  // so candidateController.acceptUrgentRequest can fire-and-forget
  // a single business-side notification without duplicating the
  // dedupe + bus.publish plumbing.
  hiringNotify,
};
