const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const AppError = require('../utils/AppError');

// Helper: create a hiring notification
async function hiringNotify(recipientId, title, type, linkedEntity, route) {
  try {
    await db('notifications').insert({
      recipient_id: recipientId,
      notification_type: type || 'in_app',
      title,
      linked_entity: linkedEntity || null,
      destination_route: route || null,
      delivery_state: 'delivered',
      is_read: false,
    });
  } catch (e) { /* ignore */ }
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
        'businesses.avatar_hue as business_avatar_hue'
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
        'businesses.avatar_hue as business_avatar_hue'
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
// POST /candidate/jobs/:id/apply — Apply to a job
// ---------------------------------------------------------------------------
async function applyToJob(req, res, next) {
  try {
    const jobId = req.params.id;
    const userId = req.user.id;

    // Find candidate record
    const candidate = await db('candidates').where({ user_id: userId }).first();
    if (!candidate) throw AppError.badRequest('Please complete your candidate profile before applying.');

    // Check job exists and is active
    const job = await db('jobs').where({ id: jobId, status: 'active' }).first();
    if (!job) throw AppError.notFound('Job not found or no longer active.');

    // Check for duplicate application
    const existing = await db('applications')
      .where({ candidate_id: candidate.id, job_id: jobId })
      .whereNot('status', 'withdrawn')
      .first();
    if (existing) throw AppError.badRequest('You have already applied to this job.');

    // Create application
    const [application] = await db('applications').insert({
      candidate_id: candidate.id,
      job_id: jobId,
      status: 'applied',
    }).returning('*');

    // Notify business of new applicant
    const biz = await db('businesses').where({ id: job.business_id }).select('user_id').first();
    if (biz) {
      try {
        await db('notifications').insert({
          recipient_id: biz.user_id, notification_type: 'in_app',
          title: `New applicant for ${job.title}: ${candidate.name}`,
          linked_entity: application.id, destination_route: 'applicant',
          delivery_state: 'delivered', is_read: false,
        });
      } catch (e) { /* ignore */ }
    }

    ok(res, {
      id: application.id,
      job_id: application.job_id,
      status: application.status,
      created_at: application.created_at,
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

    const { page = 1, limit = 50 } = req.query;
    const total = await db('messages').where({ conversation_id: conv.id }).count('* as c').first().then(r => +r.c);

    const msgs = await db('messages')
      .leftJoin('users', 'messages.sender_id', 'users.id')
      .where('messages.conversation_id', conv.id)
      .select(
        'messages.id', 'messages.body', 'messages.is_read',
        'messages.sender_id', 'messages.created_at',
        'users.name as sender_name', 'users.user_type as sender_type'
      )
      .orderBy('messages.created_at', 'asc')
      .limit(+limit).offset((+page - 1) * +limit);

    // Mark unread messages from others as read
    await db('messages')
      .where({ conversation_id: conv.id, is_read: false })
      .whereNot('sender_id', userId)
      .update({ is_read: true });

    paginated(res, msgs, { page: +page, limit: +limit, total });
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

    // Notify the business
    if (conv.business_id) {
      const biz = await db('businesses').where({ id: conv.business_id }).select('user_id').first();
      if (biz) {
        try {
          await db('notifications').insert({
            recipient_id: biz.user_id, notification_type: 'in_app',
            title: `New message from ${candidate.name}`,
            linked_entity: conv.id, destination_route: 'message',
            delivery_state: 'delivered', is_read: false,
          });
        } catch (e) { /* ignore */ }
      }
    }

    ok(res, msg);
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
  listConversations, listMessages, sendMessage, archiveConversation,
  updateProfile, uploadPhoto, uploadCV, parseCV,
  listCommunityPosts,
  nearbyJobs,
  listMatches, submitMatchFeedback, updateMatchStatus,
  listCandidateNotifications, candidateUnreadCount, markCandidateNotifRead, markAllCandidateNotifsRead,
};
