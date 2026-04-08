const db = require('../config/db');
const { ok, paginated } = require('../utils/response');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, category, search } = req.query;
    let q = db('admin_logs');
    if (category) q = q.where('category', category);
    if (search) q = q.where((b) => b.whereILike('action', `%${search}%`).orWhereILike('target', `%${search}%`).orWhereILike('admin_user', `%${search}%`));
    const total = await q.clone().count('* as c').first().then(r => +r.c);
    const rows = await q.clone().select("*").orderBy('created_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

module.exports = { list };
