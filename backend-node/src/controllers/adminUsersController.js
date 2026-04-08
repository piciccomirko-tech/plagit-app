const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

const SAFE_COLS = ['id','name','initials','email','phone','user_type','admin_role','location','role','status','is_verified','profile_strength','flag_count','avatar_hue','plan','created_at','updated_at'];

async function listUsers(req, res, next) {
  try {
    const { page = 1, limit = 50, status, user_type, search } = req.query;
    let q = db('users');
    if (status) q = q.where('status', status);
    if (user_type) q = q.where('user_type', user_type);
    if (search) q = q.where((b) => b.whereILike('name', `%${search}%`).orWhereILike('email', `%${search}%`).orWhereILike('location', `%${search}%`));
    const total = await q.clone().count('* as c').first().then(r => +r.c);
    const users = await q.clone().select(SAFE_COLS).orderBy('created_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, users, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function getUser(req, res, next) {
  try {
    const user = await db('users').select(SAFE_COLS).where({ id: req.params.id }).first();
    if (!user) throw AppError.notFound('User not found.');
    ok(res, user);
  } catch (e) { next(e); }
}

async function updateUser(req, res, next) {
  try {
    const { name, email, role, location, status, is_verified } = req.body;
    const [updated] = await db('users').where({ id: req.params.id })
      .update({ name, email, role, location, status, is_verified, updated_at: db.fn.now() }).returning(SAFE_COLS);
    if (!updated) throw AppError.notFound('User not found.');
    await log(req.user.email, 'Updated user', updated.name, 'Users');
    ok(res, updated);
  } catch (e) { next(e); }
}

async function updateStatus(req, res, next) {
  try {
    const { status } = req.body;
    const [u] = await db('users').where({ id: req.params.id }).update({ status, updated_at: db.fn.now() }).returning(['id','name','status']);
    if (!u) throw AppError.notFound('User not found.');
    await log(req.user.email, `Set status to ${status}`, u.name, 'Users');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function setVerified(req, res, next) {
  try {
    const { verified } = req.body;
    const upd = { is_verified: verified, updated_at: db.fn.now() };
    if (verified) upd.status = 'active';
    const [u] = await db('users').where({ id: req.params.id }).update(upd).returning(['id','name']);
    if (!u) throw AppError.notFound('User not found.');
    await log(req.user.email, verified ? 'Verified user' : 'Unverified user', u.name, 'Users');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function deleteUser(req, res, next) {
  try {
    const u = await db('users').where({ id: req.params.id }).first();
    if (!u) throw AppError.notFound('User not found.');
    await db('users').where({ id: req.params.id }).del();
    await log(req.user.email, 'Deleted user', u.name, 'Users');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function sendMessage(req, res, next) {
  try {
    const { subject, body } = req.body;
    const u = await db('users').where({ id: req.params.id }).first();
    if (!u) throw AppError.notFound('User not found.');
    // TODO: integrate real notification service
    await log(req.user.email, `Sent message: ${subject}`, u.name, 'Users');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { listUsers, getUser, updateUser, updateStatus, setVerified, deleteUser, sendMessage };
