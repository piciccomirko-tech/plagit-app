const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, status, search } = req.query;
    let base = db('interviews')
      .leftJoin('candidates', 'interviews.candidate_id', 'candidates.id')
      .leftJoin('jobs', 'interviews.job_id', 'jobs.id')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id');
    if (status) base = base.where('interviews.status', status);
    if (search) base = base.where((b) => b.whereILike('candidates.name', `%${search}%`).orWhereILike('businesses.name', `%${search}%`).orWhereILike('jobs.title', `%${search}%`));
    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone().select('interviews.*', 'candidates.name as candidate_name', 'candidates.initials as candidate_initials', 'jobs.title as job_title', 'businesses.name as business_name', 'businesses.is_verified as is_verified_business').orderBy('interviews.scheduled_at', 'asc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function updateStatus(req, res, next) {
  try {
    const [u] = await db('interviews').where({ id: req.params.id }).update({ status: req.body.status, updated_at: db.fn.now() }).returning(['id']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Interview status → ${req.body.status}`, u.id, 'Interviews');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function schedule(req, res, next) {
  try {
    const { application_id, scheduled_at, timezone, interview_type, location, meeting_link } = req.body;
    if (!application_id || !scheduled_at) throw AppError.badRequest('application_id and scheduled_at are required.');

    const app = await db('applications').where({ id: application_id }).first();
    if (!app) throw AppError.notFound('Application not found.');

    const [iv] = await db('interviews').insert({
      application_id,
      candidate_id: app.candidate_id,
      job_id: app.job_id,
      scheduled_at,
      timezone: timezone || 'UTC',
      interview_type: interview_type || 'video_call',
      location: location || null,
      meeting_link: meeting_link || null,
      status: 'pending',
    }).returning('*');

    // Update application status to interview
    await db('applications').where({ id: application_id }).update({ status: 'interview', has_interview: true, updated_at: db.fn.now() });

    await log(req.user.email, 'Scheduled interview', iv.id, 'Interviews');
    ok(res, iv);
  } catch (e) { next(e); }
}

module.exports = { list, updateStatus, schedule };
