const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, status, search } = req.query;
    let q = db('businesses');
    if (status) q = q.where('status', status);
    if (search) q = q.where((b) => b.whereILike('name', `%${search}%`).orWhereILike('email', `%${search}%`).orWhereILike('venue_type', `%${search}%`));
    const total = await q.clone().count('* as c').first().then(r => +r.c);
    const rows = await q.clone().select('*').orderBy('created_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function get(req, res, next) {
  try {
    const row = await db('businesses').where({ id: req.params.id }).first();
    if (!row) throw AppError.notFound('Business not found.');
    ok(res, row);
  } catch (e) { next(e); }
}

async function updateStatus(req, res, next) {
  try {
    const [u] = await db('businesses').where({ id: req.params.id }).update({ status: req.body.status, updated_at: db.fn.now() }).returning(['id','name']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Set status to ${req.body.status}`, u.name, 'Businesses');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function setVerified(req, res, next) {
  try {
    const [u] = await db('businesses').where({ id: req.params.id }).update({ is_verified: req.body.verified, updated_at: db.fn.now() }).returning(['id','name']);
    if (!u) throw AppError.notFound(); await log(req.user.email, req.body.verified ? 'Verified' : 'Unverified', u.name, 'Businesses');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function setFeatured(req, res, next) {
  try {
    const [u] = await db('businesses').where({ id: req.params.id }).update({ is_featured: req.body.featured, updated_at: db.fn.now() }).returning(['id','name']);
    if (!u) throw AppError.notFound(); await log(req.user.email, req.body.featured ? 'Featured' : 'Unfeatured', u.name, 'Businesses');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function remove(req, res, next) {
  try {
    const row = await db('businesses').where({ id: req.params.id }).first();
    if (!row) throw AppError.notFound(); await db('businesses').where({ id: req.params.id }).del();
    await log(req.user.email, 'Deleted business', row.name, 'Businesses');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { list, get, updateStatus, setVerified, setFeatured, remove };
