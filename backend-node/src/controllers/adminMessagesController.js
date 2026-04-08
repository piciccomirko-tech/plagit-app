const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, status, search } = req.query;
    let base = db('conversations')
      .leftJoin('candidates', 'conversations.candidate_id', 'candidates.id')
      .leftJoin('businesses', 'conversations.business_id', 'businesses.id')
      .leftJoin('jobs', 'conversations.job_id', 'jobs.id');
    if (status) base = base.where('conversations.status', status);
    if (search) base = base.where((b) => b.whereILike('candidates.name', `%${search}%`).orWhereILike('businesses.name', `%${search}%`));
    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone().select('conversations.*', 'candidates.name as candidate_name', 'candidates.initials as candidate_initials', 'businesses.name as business_name', 'businesses.initials as business_initials', 'jobs.title as job_title').orderBy('conversations.updated_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function updateStatus(req, res, next) {
  try {
    const [u] = await db('conversations').where({ id: req.params.id }).update({ status: req.body.status, updated_at: db.fn.now() }).returning(['id']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Conversation status → ${req.body.status}`, u.id, 'Messages');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function remove(req, res, next) {
  try {
    const r = await db('conversations').where({ id: req.params.id }).first(); if (!r) throw AppError.notFound();
    await db('conversations').where({ id: req.params.id }).del(); await log(req.user.email, 'Deleted conversation', r.id, 'Messages');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { list, updateStatus, remove };
