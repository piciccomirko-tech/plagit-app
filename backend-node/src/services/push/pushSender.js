const db = require('../../config/db');

/**
 * Push notification sender.
 *
 * Provider strategy:
 *   • If `FCM_SERVICE_ACCOUNT_JSON` is set, the firebase-admin SDK is lazily
 *     initialised on first dispatch and used to send to FCM tokens (iOS via
 *     APNS bridge, Android natively).
 *   • Otherwise we run in LOG MODE — every dispatched payload is printed as
 *     `[push:log]` so the bus → fan-out pipeline is verifiable in dev
 *     without provider credentials.
 *
 * SECURITY:
 *   • Never log full tokens (only `short()` prefix/suffix).
 *   • Never log the service-account JSON or any field from it.
 *   • Provider error messages are logged but truncated.
 */

const MODE = resolveMode();

let _admin = null;
let _adminInitFailed = false;

function resolveMode() {
  if (process.env.FCM_SERVICE_ACCOUNT_JSON || process.env.APNS_AUTH_KEY) {
    return 'live';
  }
  return 'log';
}

function getAdmin() {
  if (_admin) return _admin;
  if (_adminInitFailed) return null;
  const raw = process.env.FCM_SERVICE_ACCOUNT_JSON;
  if (!raw) { _adminInitFailed = true; return null; }
  try {
    // eslint-disable-next-line global-require
    const admin = require('firebase-admin');
    if (!admin.apps.length) {
      const creds = JSON.parse(raw);
      admin.initializeApp({ credential: admin.credential.cert(creds) });
    }
    _admin = admin;
    // eslint-disable-next-line no-console
    console.log('[push:provider] firebase-admin initialised');
    return _admin;
  } catch (err) {
    _adminInitFailed = true;
    // eslint-disable-next-line no-console
    console.error('[push:provider] firebase-admin init failed:', truncErr(err));
    return null;
  }
}

async function getTokensForUser(userId) {
  try {
    const rows = await db('device_tokens')
      .where({ user_id: userId })
      .select('token', 'platform', 'app_version');
    return rows;
  } catch (_) {
    return [];
  }
}

function isDevToken(token) {
  return typeof token === 'string' && token.startsWith('dev-');
}

async function dispatchOne({ token, platform }, payload) {
  if (MODE === 'log' || isDevToken(token)) {
    // eslint-disable-next-line no-console
    console.log(
      `[push:log] platform=${platform} token=${short(token)} ` +
        `title="${payload.title}" body="${safe(payload.body)}" ` +
        `data=${JSON.stringify(payload.data || {})}`
    );
    return { ok: true, mode: 'log' };
  }
  const admin = getAdmin();
  if (!admin) {
    // eslint-disable-next-line no-console
    console.log(
      `[push:fallback-log] (provider init failed) platform=${platform} ` +
        `token=${short(token)} title="${payload.title}"`
    );
    return { ok: true, mode: 'fallback-log' };
  }
  try {
    const message = {
      token,
      notification: {
        title: payload.title,
        body: safe(payload.body),
      },
      data: stringifyData(payload.data || {}),
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
            'mutable-content': 1,
          },
        },
      },
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          channelId: 'plagit_default',
        },
      },
    };
    const id = await admin.messaging().send(message);
    // eslint-disable-next-line no-console
    console.log(
      `[push:sent] platform=${platform} token=${short(token)} mid=${id}`
    );
    return { ok: true, mode: 'live', id };
  } catch (err) {
    const code = err?.errorInfo?.code || err?.code || '';
    // eslint-disable-next-line no-console
    console.error(
      `[push:err] platform=${platform} token=${short(token)} code=${code} msg=${truncErr(err)}`
    );
    if (
      code === 'messaging/registration-token-not-registered' ||
      code === 'messaging/invalid-registration-token' ||
      code === 'messaging/invalid-argument'
    ) {
      try {
        await db('device_tokens').where({ token }).del();
        // eslint-disable-next-line no-console
        console.log(`[push:cleanup] removed stale token=${short(token)}`);
      } catch (_) { /* best-effort */ }
    }
    return { ok: false, mode: 'live', code };
  }
}

function stringifyData(data) {
  const out = {};
  for (const [k, v] of Object.entries(data || {})) {
    if (v === null || v === undefined) continue;
    out[k] = String(v);
  }
  return out;
}

function short(token) {
  if (!token) return '';
  return token.length > 12 ? `${token.slice(0, 6)}…${token.slice(-4)}` : '<short>';
}

function safe(s) {
  if (s == null) return '';
  return String(s).replace(/\s+/g, ' ').slice(0, 160);
}

function truncErr(err) {
  const m = err?.message || String(err || '');
  return m.replace(/\s+/g, ' ').slice(0, 200);
}

/**
 * Send a push notification to every device registered for a given user.
 *
 * @param {string} userId
 * @param {{title: string, body: string, data?: object}} payload
 */
async function sendToUser(userId, payload) {
  if (!userId || !payload || !payload.title) return { sent: 0, tokens: 0 };
  const devices = await getTokensForUser(userId);
  if (devices.length === 0) {
    // eslint-disable-next-line no-console
    console.log(`[push:skip] userId=${userId} no registered devices`);
    return { sent: 0, tokens: 0 };
  }
  const results = await Promise.allSettled(
    devices.map((d) => dispatchOne(d, payload))
  );
  const sent = results.filter((r) => r.status === 'fulfilled' && r.value?.ok).length;
  return { sent, tokens: devices.length };
}

module.exports = { sendToUser, MODE };
