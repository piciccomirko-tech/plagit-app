const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, status, search } = req.query;
    let base = db('applications')
      .leftJoin('candidates', 'applications.candidate_id', 'candidates.id')
      .leftJoin('jobs', 'applications.job_id', 'jobs.id')
      .leftJoin('businesses', 'jobs.business_id', 'businesses.id');
    if (status) base = base.where('applications.status', status);
    if (search) base = base.where((b) => b.whereILike('candidates.name', `%${search}%`).orWhereILike('jobs.title', `%${search}%`).orWhereILike('businesses.name', `%${search}%`));
    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone().select('applications.*', 'candidates.name as candidate_name', 'candidates.initials as candidate_initials', 'jobs.title as job_title', 'businesses.name as business_name').orderBy('applications.created_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function updateStatus(req, res, next) {
  try {
    const [u] = await db('applications').where({ id: req.params.id }).update({ status: req.body.status, updated_at: db.fn.now() }).returning(['id']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Application status → ${req.body.status}`, u.id, 'Applications');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { list, updateStatus };
