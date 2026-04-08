const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const AppError = require('../utils/AppError');

// ---------------------------------------------------------------------------
// GET /admin/matches — List all match records with full details
// ---------------------------------------------------------------------------
async function listMatches(req, res, next) {
  try {
    const { page = 1, limit = 50, role, job_type, status, search } = req.query;

    let base = db('matches')
      .leftJoin('candidates', 'matches.candidate_id', 'candidates.id')
      .leftJoin('users as cand_user', 'candidates.user_id', 'cand_user.id')
      .leftJoin('jobs', 'matches.job_id', 'jobs.id')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
      .leftJoin('users as biz_user', 'businesses.user_id', 'biz_user.id');

    if (role) base = base.whereILike('candidates.role', `%${role}%`);
    if (job_type) base = base.whereRaw('LOWER(TRIM(candidates.job_type)) = ?', [job_type.toLowerCase().trim()]);
    if (status) base = base.where('matches.status', status);
    if (search) {
      base = base.where(function () {
        this.whereILike('candidates.name', `%${search}%`)
          .orWhereILike('jobs.title', `%${search}%`)
          .orWhereILike('businesses.name', `%${search}%`);
      });
    }

    const total = await base.clone().count('* as c').first().then(r => +r.c);

    const rows = await base.clone()
      .select(
        'matches.id as match_id',
        'matches.status as match_status',
        'matches.created_at as match_created_at',
        'candidates.id as candidate_id',
        'candidates.name as candidate_name',
        'candidates.initials as candidate_initials',
        'candidates.role as candidate_role',
        'candidates.job_type as candidate_job_type',
        'candidates.location as candidate_location',
        'candidates.avatar_hue as candidate_avatar_hue',
        'cand_user.is_verified as candidate_verified',
        'cand_user.photo_url as candidate_photo_url',
        'cand_user.latitude as candidate_lat',
        'cand_user.longitude as candidate_lng',
        'jobs.id as job_id',
        'jobs.title as job_title',
        'jobs.category as job_role',
        'jobs.employment_type as job_type',
        'jobs.location as job_location',
        'jobs.salary as job_salary',
        'jobs.latitude as job_lat',
        'jobs.longitude as job_lng',
        'businesses.id as business_id',
        'businesses.name as business_name',
        'businesses.initials as business_initials',
        'biz_user.is_verified as business_verified'
      )
      .orderBy('matches.created_at', 'desc')
      .limit(+limit)
      .offset((+page - 1) * +limit);

    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /admin/matches/notifications — Match notification history
// ---------------------------------------------------------------------------
async function matchNotifications(req, res, next) {
  try {
    const { page = 1, limit = 50 } = req.query;
    const total = await db('notifications').where('destination_route', 'match').count('* as c').first().then(r => +r.c);
    const rows = await db('notifications')
      .leftJoin('users', 'notifications.recipient_id', 'users.id')
      .where('notifications.destination_route', 'match')
      .select(
        'notifications.id', 'notifications.title',
        'notifications.delivery_state', 'notifications.is_read',
        'notifications.sent_at', 'notifications.created_at',
        'notifications.linked_entity',
        'users.name as recipient_name', 'users.user_type as recipient_type'
      )
      .orderBy('notifications.created_at', 'desc')
      .limit(+limit).offset((+page - 1) * +limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /admin/feedback — List all collected match feedback
// ---------------------------------------------------------------------------
async function listFeedback(req, res, next) {
  try {
    const { page = 1, limit = 50, user_type } = req.query;

    let base = db('match_feedback')
      .leftJoin('users', 'match_feedback.user_id', 'users.id');

    if (user_type) base = base.where('match_feedback.user_type', user_type);

    const total = await base.clone().count('* as c').first().then(r => +r.c);

    const rows = await base.clone()
      .select(
        'match_feedback.*',
        'users.name as user_name',
        'users.email as user_email',
        'users.user_type as account_type'
      )
      .orderBy('match_feedback.created_at', 'desc')
      .limit(+limit)
      .offset((+page - 1) * +limit);

    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET /admin/matches/stats — Match system overview stats
// ---------------------------------------------------------------------------
async function matchStats(req, res, next) {
  try {
    const counts = await db('matches').select(db.raw(`
      count(*) as total,
      count(*) filter (where status = 'pending') as pending,
      count(*) filter (where status = 'accepted') as accepted,
      count(*) filter (where status = 'denied') as denied
    `)).first();

    const matchNotifs = await db('notifications')
      .where('destination_route', 'match')
      .count('* as c').first();

    const feedbackCount = await db('match_feedback').count('* as c').first();
    const feedbackPositive = await db('match_feedback').where('was_relevant', true).count('* as c').first();

    const profiledCandidates = await db('candidates')
      .whereNotNull('role').whereNot('role', '')
      .whereNotNull('job_type').whereNot('job_type', '')
      .count('* as c').first();

    const profiledJobs = await db('jobs')
      .where('status', 'active')
      .whereNotNull('category').whereNot('category', '')
      .whereNotNull('employment_type').whereNot('employment_type', '')
      .count('* as c').first();

    // Interview stats from matched candidates
    const interviewStats = await db('interviews').select(db.raw(`
      count(*) as total,
      count(*) filter (where status = 'pending') as requested,
      count(*) filter (where status = 'confirmed') as accepted,
      count(*) filter (where status = 'cancelled') as declined,
      count(*) filter (where status = 'completed') as completed
    `)).first();

    ok(res, {
      total_matches: +(counts?.total || 0),
      pending_matches: +(counts?.pending || 0),
      accepted_matches: +(counts?.accepted || 0),
      denied_matches: +(counts?.denied || 0),
      match_notifications_sent: +(matchNotifs?.c || 0),
      total_feedback: +(feedbackCount?.c || 0),
      positive_feedback: +(feedbackPositive?.c || 0),
      profiled_candidates: +(profiledCandidates?.c || 0),
      profiled_jobs: +(profiledJobs?.c || 0),
      interviews_requested: +(interviewStats?.requested || 0),
      interviews_accepted: +(interviewStats?.accepted || 0),
      interviews_declined: +(interviewStats?.declined || 0),
      interviews_completed: +(interviewStats?.completed || 0),
    });
  } catch (err) { next(err); }
}

module.exports = { listMatches, listFeedback, matchStats, matchNotifications };
