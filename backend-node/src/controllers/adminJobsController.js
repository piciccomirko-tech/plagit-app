const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, status, search } = req.query;
    let base = db('jobs').leftJoin('businesses', 'jobs.business_id', 'businesses.id');
    if (status) base = base.where('jobs.status', status);
    if (search) base = base.where((b) => b.whereILike('jobs.title', `%${search}%`).orWhereILike('businesses.name', `%${search}%`).orWhereILike('jobs.location', `%${search}%`));
    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone().select('jobs.*', 'businesses.name as business_name', 'businesses.initials as business_initials', 'businesses.is_verified as is_verified_business').orderBy('jobs.created_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function get(req, res, next) {
  try { const r = await db('jobs').where({ id: req.params.id }).first(); if (!r) throw AppError.notFound(); ok(res, r); } catch (e) { next(e); }
}

async function updateStatus(req, res, next) {
  try {
    const [u] = await db('jobs').where({ id: req.params.id }).update({ status: req.body.status, updated_at: db.fn.now() }).returning(['id','title']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Set job status to ${req.body.status}`, u.title, 'Jobs');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function setFeatured(req, res, next) {
  try {
    const [u] = await db('jobs').where({ id: req.params.id }).update({ is_featured: req.body.featured, updated_at: db.fn.now() }).returning(['id','title']);
    if (!u) throw AppError.notFound(); await log(req.user.email, req.body.featured ? 'Featured job' : 'Unfeatured job', u.title, 'Jobs');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function remove(req, res, next) {
  try {
    const r = await db('jobs').where({ id: req.params.id }).first(); if (!r) throw AppError.notFound();
    await db('jobs').where({ id: req.params.id }).del(); await log(req.user.email, 'Deleted job', r.title, 'Jobs');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { list, get, updateStatus, setFeatured, remove };
