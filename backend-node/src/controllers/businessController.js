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
  } catch (e) { /* ignore if table missing */ }
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

    if (bizId) {
      const jobs = await db('jobs').where({ business_id: bizId }).select('id', 'status');
      activeJobs = jobs.filter(j => j.status === 'active').length;

      const activeJobIds = jobs.filter(j => j.status === 'active').map(j => j.id);
      if (activeJobIds.length > 0) {
        const apps = await db('applications').whereIn('job_id', activeJobIds).select('status', 'created_at');
        totalApplicants = apps.length;
        const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
        newApplicants = apps.filter(a => new Date(a.created_at) > weekAgo).length;
        interviewCount = apps.filter(a => a.status === 'interview').length;
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
      next_interview: nextInterview,
      unread_messages: unreadMessages,
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

    // Send match notifications to matching candidates (async, non-blocking)
    if (category && employment_type) {
      (async () => {
        try {
          const jobCat = category.toLowerCase().trim();
          const jobEmpType = employment_type.toLowerCase().trim();
          const biz = await db('businesses').where({ id: bizId }).first();
          const notifTitle = `New match: ${title} – ${employment_type} at ${biz?.name || 'a business'}`;

          // Local matches: exact role + job_type
          const matchedCandidates = await db('candidates')
            .leftJoin('users', 'candidates.user_id', 'users.id')
            .where('users.user_type', 'candidate')
            .where('users.status', 'active')
            .whereRaw('LOWER(TRIM(candidates.role)) = ?', [jobCat])
            .whereRaw('LOWER(TRIM(candidates.job_type)) = ?', [jobEmpType])
            .select('users.id as user_id', 'candidates.id as cand_id')
            .limit(50);

          const notified = new Set();
          for (const mc of matchedCandidates) {
            try { await db('matches').insert({ candidate_id: mc.cand_id, job_id: job.id, status: 'pending' }); } catch (_) {}
            await hiringNotify(mc.user_id, notifTitle, 'in_app', job.id, 'match');
            notified.add(mc.cand_id);
          }

          // International matches: if open_to_international, also match relocatable candidates
          if (open_to_international) {
            const intlCandidates = await db('candidates')
              .leftJoin('users', 'candidates.user_id', 'users.id')
              .where('users.user_type', 'candidate')
              .where('users.status', 'active')
              .where('candidates.available_to_relocate', true)
              .whereRaw('LOWER(TRIM(candidates.role)) = ?', [jobCat])
              .whereRaw('LOWER(TRIM(candidates.job_type)) = ?', [jobEmpType])
              .select('users.id as user_id', 'candidates.id as cand_id')
              .limit(50);
            for (const ic of intlCandidates) {
              if (notified.has(ic.cand_id)) continue; // already notified locally
              try { await db('matches').insert({ candidate_id: ic.cand_id, job_id: job.id, status: 'pending' }); } catch (_) {}
              await hiringNotify(ic.user_id, `International opportunity: ${title} – ${employment_type} at ${biz?.name || 'a business'}`, 'in_app', job.id, 'match');
            }
          }
        } catch (e) { console.error('[Match notify]', e.message); }
      })();
    }

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
    if (!status) throw AppError.badRequest('Status is required.');
    // Verify this application belongs to a job owned by this business
    const app = await db('applications').leftJoin('jobs', 'applications.job_id', 'jobs.id')
      .where('applications.id', req.params.id).where('jobs.business_id', bizId)
      .select('applications.id').first();
    if (!app) throw AppError.notFound('Application not found.');
    await db('applications').where({ id: app.id }).update({ status, updated_at: db.fn.now() });
    // Notify candidate of status change
    const fullApp = await db('applications').leftJoin('candidates', 'applications.candidate_id', 'candidates.id')
      .where('applications.id', app.id).select('candidates.user_id', 'applications.job_id').first();
    if (fullApp?.user_id) {
      const job = await db('jobs').where({ id: fullApp.job_id }).select('title').first();
      const labels = { shortlisted: 'You were shortlisted', rejected: 'Application update', under_review: 'Application under review', offer: 'You received an offer' };
      hiringNotify(fullApp.user_id, `${labels[status] || 'Status update'} for ${job?.title || 'a job'}`, 'in_app', app.id, 'application');
    }
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
      .select('interviews.id').first();
    if (!iv) throw AppError.notFound('Interview not found.');
    await db('interviews').where({ id: iv.id }).update({ status, updated_at: db.fn.now() });
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
    const { page = 1, limit = 50 } = req.query;
    const total = await db('messages').where({ conversation_id: conv.id }).count('* as c').first().then(r => +r.c);
    const msgs = await db('messages').leftJoin('users', 'messages.sender_id', 'users.id')
      .where('messages.conversation_id', conv.id)
      .select('messages.id', 'messages.body', 'messages.is_read', 'messages.sender_id', 'messages.created_at', 'users.name as sender_name', 'users.user_type as sender_type')
      .orderBy('messages.created_at', 'asc').limit(+limit).offset((+page - 1) * +limit);
    await db('messages').where({ conversation_id: conv.id, is_read: false }).whereNot('sender_id', req.user.id).update({ is_read: true });
    paginated(res, msgs, { page: +page, limit: +limit, total });
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
    // Notify the candidate
    if (conv.candidate_id) {
      const cand = await db('candidates').where({ id: conv.candidate_id }).select('user_id', 'name').first();
      const bizUser = await db('users').where({ id: req.user.id }).first();
      if (cand) {
        hiringNotify(cand.user_id, `New message from ${bizUser?.name || 'a business'}`, 'in_app', conv.id, 'message');
      }
    }
    ok(res, msg);
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

    // Create new conversation
    const [conv] = await db('conversations').insert({
      business_id: bizId, candidate_id, status: 'active',
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

module.exports = {
  profile, home, updateProfile, uploadPhoto,
  listJobs, createJob, getJob, updateJob,
  listApplicants, updateApplicantStatus,
  listInterviews, scheduleInterview, updateInterviewStatus,
  listConversations, listMessages, sendMessage, startConversation, archiveConversation,
  getCandidateProfile,
  listNotifications, markNotificationRead, markAllNotificationsRead,
  recentApplicants, nearbyCandidates, listJobMatches, submitMatchFeedback, updateMatchStatus,
};
