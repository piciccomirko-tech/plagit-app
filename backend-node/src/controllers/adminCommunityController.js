const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, status, search } = req.query;
    let q = db('community_posts');
    if (status) q = q.where('status', status);
    if (search) q = q.where((b) => b.whereILike('title', `%${search}%`).orWhereILike('author', `%${search}%`).orWhereILike('category', `%${search}%`));
    const total = await q.clone().count('* as c').first().then(r => +r.c);
    const rows = await q.clone().select("*").orderBy('created_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function updateStatus(req, res, next) {
  try {
    const [u] = await db('community_posts').where({ id: req.params.id }).update({ status: req.body.status, updated_at: db.fn.now() }).returning(['id','title']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Post status → ${req.body.status}`, u.title, 'Community');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function setPinned(req, res, next) {
  try {
    const [u] = await db('community_posts').where({ id: req.params.id }).update({ is_pinned: req.body.pinned, updated_at: db.fn.now() }).returning(['id','title']);
    if (!u) throw AppError.notFound(); ok(res, { success: true });
  } catch (e) { next(e); }
}

async function setFeaturedOnHome(req, res, next) {
  try {
    const [u] = await db('community_posts').where({ id: req.params.id }).update({ is_featured_on_home: req.body.featured, updated_at: db.fn.now() }).returning(['id','title']);
    if (!u) throw AppError.notFound(); ok(res, { success: true });
  } catch (e) { next(e); }
}

async function remove(req, res, next) {
  try {
    const r = await db('community_posts').where({ id: req.params.id }).first(); if (!r) throw AppError.notFound();
    await db('community_posts').where({ id: req.params.id }).del(); await log(req.user.email, 'Deleted post', r.title, 'Community');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { list, updateStatus, setPinned, setFeaturedOnHome, remove };
