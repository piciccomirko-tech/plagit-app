const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, delivery_state, search } = req.query;
    let base = db('notifications').leftJoin('users', 'notifications.recipient_id', 'users.id');
    if (delivery_state) base = base.where('notifications.delivery_state', delivery_state);
    if (search) base = base.where((b) => b.whereILike('users.name', `%${search}%`).orWhereILike('notifications.title', `%${search}%`));
    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone().select('notifications.*', 'users.name as recipient_name', 'users.user_type as recipient_type').orderBy('notifications.created_at', 'desc').limit(limit).offset((page - 1) * limit);
    paginated(res, rows, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

async function updateDeliveryState(req, res, next) {
  try {
    const upd = { delivery_state: req.body.state, updated_at: db.fn.now() };
    if (req.body.state === 'delivered' || req.body.state === 'sent') upd.sent_at = db.fn.now();
    const [u] = await db('notifications').where({ id: req.params.id }).update(upd).returning(['id','title']);
    if (!u) throw AppError.notFound(); await log(req.user.email, `Notification delivery → ${req.body.state}`, u.title, 'Notifications');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

async function markRead(req, res, next) {
  try {
    const [u] = await db('notifications').where({ id: req.params.id }).update({ is_read: req.body.read, updated_at: db.fn.now() }).returning(['id','title']);
    if (!u) throw AppError.notFound();
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { list, updateDeliveryState, markRead };
