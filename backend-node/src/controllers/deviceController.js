const db = require('../config/db');
const { ok } = require('../utils/response');
const AppError = require('../utils/AppError');

/**
 * POST /v1/devices/register
 *
 * Body: { token: string, platform: 'ios'|'android'|'web', app_version?: string }
 *
 * Upsert semantics — if the token already exists it is re-bound to the
 * current user (handles re-install + re-login).
 */
async function registerDevice(req, res, next) {
  try {
    const { token, platform, app_version } = req.body || {};
    if (!token || typeof token !== 'string') {
      throw AppError.badRequest('token is required');
    }
    const plat = (platform || 'ios').toLowerCase();
    if (!['ios', 'android', 'web'].includes(plat)) {
      throw AppError.badRequest('platform must be ios|android|web');
    }
    const existing = await db('device_tokens').where({ token }).first();
    if (existing) {
      await db('device_tokens').where({ id: existing.id }).update({
        user_id: req.user.id,
        platform: plat,
        app_version: app_version || null,
        last_seen_at: db.fn.now(),
        updated_at: db.fn.now(),
      });
    } else {
      await db('device_tokens').insert({
        user_id: req.user.id,
        token,
        platform: plat,
        app_version: app_version || null,
        last_seen_at: db.fn.now(),
      });
    }
    ok(res, { registered: true });
  } catch (err) { next(err); }
}

/**
 * DELETE /v1/devices/:token
 *
 * Removes the device token — used on logout so pushes stop reaching a
 * device that no longer belongs to this user.
 */
async function unregisterDevice(req, res, next) {
  try {
    const { token } = req.params;
    if (!token) throw AppError.badRequest('token is required');
    await db('device_tokens').where({ token, user_id: req.user.id }).del();
    ok(res, { unregistered: true });
  } catch (err) { next(err); }
}

module.exports = { registerDevice, unregisterDevice };
