const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, verification_status, search } = req.query;
    let q = db('candidates');
    if (verification_status) q = q.where('verification_status', verification_status);
    if (search) q = q.where((b) => b.whereILike('name', `%${search}%`).orWhereILike('role', `%${search}%`).orWhereILike('location', `%${search}%`));
    const total = await q.clone().count('* as c').first().then(r => +r.c);
    const rows = await q.clone().select("*").orderBy('created_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function get(req, res, next) {
  try { const r = await db('candidates').where({ id: req.params.id }).first(); if (!r) throw AppError.notFound(); ok(res, r); } catch (e) { next(e); }
}

async function updateVerification(req, res, next) {
  try {
    const [u] = await db('candidates').where({ id: req.params.id }).update({ verification_status: req.body.status, updated_at: db.fn.now() }).returning(['id','name']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Set verification to ${req.body.status}`, u.name, 'Candidates');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { list, get, updateVerification };
