const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, status, search } = req.query;
    let q = db('featured_content');
    if (status) q = q.where('status', status);
    if (search) q = q.where((b) => b.whereILike('title', `%${search}%`).orWhereILike('linked_entity', `%${search}%`).orWhereILike('type', `%${search}%`));
    const total = await q.clone().count('* as c').first().then(r => +r.c);
    const rows = await q.clone().select("*").orderBy('priority', 'asc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function updateStatus(req, res, next) {
  try {
    const [u] = await db('featured_content').where({ id: req.params.id }).update({ status: req.body.status, updated_at: db.fn.now() }).returning(['id','title']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Featured status → ${req.body.status}`, u.title, 'Community');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function setPinned(req, res, next) {
  try {
    const [u] = await db('featured_content').where({ id: req.params.id }).update({ is_pinned: req.body.pinned, updated_at: db.fn.now() }).returning(['id']);
    if (!u) throw AppError.notFound(); ok(res, { success: true });
  } catch (e) { next(e); }
}

async function remove(req, res, next) {
  try {
    const r = await db('featured_content').where({ id: req.params.id }).first(); if (!r) throw AppError.notFound();
    await db('featured_content').where({ id: req.params.id }).del(); await log(req.user.email, 'Deleted featured item', r.title, 'Community');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { list, updateStatus, setPinned, remove };
