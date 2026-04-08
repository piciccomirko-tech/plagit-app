const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, status, severity, search } = req.query;
    let q = db('reports');
    if (status) q = q.where('status', status);
    if (severity) q = q.where('severity', severity);
    if (search) q = q.where((b) => b.whereILike('title', `%${search}%`).orWhereILike('reported_entity', `%${search}%`).orWhereILike('summary', `%${search}%`));
    const total = await q.clone().count('* as c').first().then(r => +r.c);
    const rows = await q.clone().select("*").orderBy('created_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function updateStatus(req, res, next) {
  try {
    const [u] = await db('reports').where({ id: req.params.id }).update({ status: req.body.status, updated_at: db.fn.now() }).returning(['id','title']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Report status → ${req.body.status}`, u.title, 'Reports');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function assignAdmin(req, res, next) {
  try {
    const [u] = await db('reports').where({ id: req.params.id }).update({ assigned_admin: req.body.admin, updated_at: db.fn.now() }).returning(['id','title']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Assigned report to ${req.body.admin}`, u.title, 'Reports');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { list, updateStatus, assignAdmin };
