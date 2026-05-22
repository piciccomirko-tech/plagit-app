const db = require('../config/db');
const { ok } = require('../utils/response');
const AppError = require('../utils/AppError');

/**
 * Phase 3.2 — push token registration foundation.
 *
 * Two endpoints mounted at /v1/push/* (see routes/push.js):
 *   • POST /v1/push/register-token   — upsert a token for the caller
 *   • POST /v1/push/unregister-token — soft-revoke (sets revoked_at)
 *
 * Both require an authenticated user. The caller's identity (id +
 * role) is read from the JWT (`req.user`) — never trusted from the
 * request body — so a token can only ever be tied to the current
 * caller's account.
 *
 * Soft-revoke is the canonical unregister path: row stays for audit,
 * `revoked_at` records when the device went quiet. The legacy
 * /v1/devices/* endpoints (mig 016 era, hard DELETE) are left in
 * place untouched for backward compatibility with the existing
 * Flutter DeviceService — P3.3 will migrate Flutter to /push/* and
 * the old endpoints can be retired in a future cleanup.
 *
 * Body field mapping: the spec uses `fcm_token`; the DB column is
 * historically named `token` (it has always held FCM tokens). We
 * accept the new name in the request body and persist to the
 * existing column so neither schema nor 44 live rows need to move.
 */

const ALLOWED_PLATFORMS = new Set(['ios', 'android', 'web']);

/**
 * POST /v1/push/register-token
 *
 * Idempotent upsert keyed by `fcm_token`. Re-registering the same
 * token:
 *   • refreshes last_seen_at
 *   • clears revoked_at  (so a previously-unregistered device that
 *                         comes back online reactivates)
 *   • updates user_id / role / platform / apns_token / device_id /
 *     app_version to the current caller's values (covers logout →
 *     new login on the same device)
 *
 * First-time insert seeds all the same columns. role is denormed
 * from the JWT — never trusted from the body.
 */
async function registerToken(req, res, next) {
  try {
    const body = req.body || {};
    const fcmToken   = typeof body.fcm_token === 'string' ? body.fcm_token.trim() : '';
    const platform   = typeof body.platform === 'string' ? body.platform.trim().toLowerCase() : '';
    const apnsToken  = typeof body.apns_token === 'string' ? body.apns_token.trim() : null;
    const deviceId   = typeof body.device_id === 'string' ? body.device_id.trim() : null;
    const appVersion = typeof body.app_version === 'string' ? body.app_version.trim() : null;

    if (!fcmToken) throw AppError.badRequest('fcm_token is required.');
    if (!ALLOWED_PLATFORMS.has(platform)) {
      throw AppError.badRequest('platform must be ios, android, or web.');
    }

    const role = req.user?.role;
    const userId = req.user?.id;
    if (!userId || !role) throw AppError.unauthorized();

    const existing = await db('device_tokens').where({ token: fcmToken }).first();

    if (existing) {
      await db('device_tokens')
        .where({ id: existing.id })
        .update({
          user_id: userId,
          role,
          platform,
          apns_token: apnsToken || existing.apns_token, // keep prior if not supplied
          device_id:  deviceId  || existing.device_id,
          app_version: appVersion || existing.app_version,
          last_seen_at: db.fn.now(),
          revoked_at: null,
          updated_at: db.fn.now(),
        });
      return ok(res, {
        id: existing.id,
        fcm_token: fcmToken,
        reactivated: existing.revoked_at != null,
      });
    }

    const [inserted] = await db('device_tokens').insert({
      user_id: userId,
      role,
      token: fcmToken,
      platform,
      apns_token: apnsToken,
      device_id: deviceId,
      app_version: appVersion,
      last_seen_at: db.fn.now(),
    }).returning('id');

    return ok(res, { id: inserted.id, fcm_token: fcmToken, reactivated: false });
  } catch (err) { next(err); }
}

/**
 * POST /v1/push/unregister-token
 *
 * Soft-revoke. Sets `revoked_at = NOW()` on the row matching the
 * caller's user_id AND the supplied `fcm_token`. Returns a uniform
 * `not found` for both "token doesn't exist" and "token belongs to
 * someone else", so the endpoint can't be used to enumerate which
 * tokens exist in the system.
 *
 * Re-running on an already-revoked row is a no-op (idempotent).
 */
async function unregisterToken(req, res, next) {
  try {
    const body = req.body || {};
    const fcmToken = typeof body.fcm_token === 'string' ? body.fcm_token.trim() : '';
    if (!fcmToken) throw AppError.badRequest('fcm_token is required.');

    const userId = req.user?.id;
    if (!userId) throw AppError.unauthorized();

    const updated = await db('device_tokens')
      .where({ token: fcmToken, user_id: userId })
      .update({ revoked_at: db.fn.now(), updated_at: db.fn.now() })
      .returning('id');

    if (!updated || updated.length === 0) {
      // Either no such token or it belongs to a different user. Same
      // response either way — no leakage.
      throw AppError.notFound('Token not found.', 'PUSH_TOKEN_NOT_FOUND');
    }

    return ok(res, { id: updated[0].id, revoked: true });
  } catch (err) { next(err); }
}

module.exports = { registerToken, unregisterToken };
