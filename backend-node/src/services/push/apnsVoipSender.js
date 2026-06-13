/**
 * APNs VoIP push sender — Step D (flag-gated, OFF by default).
 *
 * Wakes the callee's iOS device with an Apple PushKit VoIP push on
 * `call.ringing` so CallKit rings WhatsApp-style even when the app is killed.
 * firebase-admin CANNOT send VoIP pushes (it cannot set `apns-push-type: voip`),
 * so this uses a direct APNs HTTP/2 token connection (@parse/node-apn) with an
 * Apple `.p8` key.
 *
 * ── SAFETY (mirrors pushSender.js PUSH_REAL_ENABLED pattern) ──
 *   • Default OFF: `VOIP_PUSH_ENABLED` false → MODE 'off' → total no-op
 *     (no DB, no provider init, no network). Production stays dormant until we
 *     deliberately arm it.
 *   • Armed but credentials incomplete → MODE 'log' (never transmits).
 *   • Armed + all credentials present → MODE 'live' (real VoIP push).
 *   • Effective mode is resolved PER CALL, so flipping the flag/env at runtime
 *     (tests, staged rollout) takes effect without a reload.
 *   • Every path is reject-proof — a VoIP failure must never break call
 *     initiation (the call-site uses `.catch()` too, belt-and-suspenders).
 *
 * ── Credentials (set on Railway / local .env only — NEVER committed) ──
 *   VOIP_PUSH_ENABLED     '1'/'true' to arm.
 *   APNS_KEY_ID           10-char Apple key id (filename AuthKey_<id>.p8).
 *   APNS_TEAM_ID          10-char Apple team id.
 *   APNS_BUNDLE_ID        app bundle id → apns-topic is `<bundle>.voip`.
 *   APNS_VOIP_KEY         the .p8 contents inline (Railway), OR…
 *   APNS_VOIP_KEY_PATH    path to the .p8 file (local dev, keeps key off .env).
 *   APNS_VOIP_PRODUCTION  'false' to target the APNs sandbox (default: production,
 *                         which is what TestFlight/App Store builds use).
 *
 * ── SECURITY ──
 *   • The .p8 is read into memory ONLY when going live (getProvider). Its bytes
 *     are NEVER logged. Tokens are logged via short() (prefix/suffix) only.
 */

const os = require('os');
const fs = require('fs');
const db = require('../../config/db');
const flags = require('../../config/featureFlags');

// Always-required identifiers. The key MATERIAL is separate: either
// APNS_VOIP_KEY (inline) or APNS_VOIP_KEY_PATH (file).
const REQUIRED_IDS = ['APNS_KEY_ID', 'APNS_TEAM_ID', 'APNS_BUNDLE_ID'];

function hasKeyMaterialConfig() {
  return Boolean(process.env.APNS_VOIP_KEY || process.env.APNS_VOIP_KEY_PATH);
}

function hasCreds() {
  if (REQUIRED_IDS.some((k) => !process.env[k])) return false;
  return hasKeyMaterialConfig();
}

/**
 * Effective mode:
 *   'off'  — flag disabled (production default). Pure no-op.
 *   'log'  — armed but credentials incomplete. Logs intent, never sends.
 *   'live' — armed + all credentials present. Real VoIP push.
 */
function resolveMode() {
  if (!flags.voipPushEnabled) return 'off';
  return hasCreds() ? 'live' : 'log';
}

// Load-time posture, logged once so the dormant/armed state is visible in
// Railway logs. No credential values — only the resolved mode.
const MODE = resolveMode();
(function logBootMode() {
  /* eslint-disable no-console */
  if (MODE === 'off') {
    console.log('[voip:provider] VoIP push DISABLED (VOIP_PUSH_ENABLED off) — no-op');
  } else if (MODE === 'log') {
    const missing = [
      ...REQUIRED_IDS.filter((k) => !process.env[k]),
      ...(hasKeyMaterialConfig() ? [] : ['APNS_VOIP_KEY|APNS_VOIP_KEY_PATH']),
    ].join(', ');
    console.log(`[voip:provider] VoIP push armed but LOG MODE — missing: ${missing}`);
  } else {
    console.log('[voip:provider] VoIP push armed, creds present — LIVE');
  }
  /* eslint-enable no-console */
}());

/** Redact a device/voip token for safe logging: first6…last4. */
function short(token) {
  if (typeof token !== 'string' || token.length <= 12) return '***';
  return `${token.slice(0, 6)}…${token.slice(-4)}`;
}

// Expand a leading ~ to the home dir so APNS_VOIP_KEY_PATH can be "~/secure/…".
function expandHome(p) {
  return p.startsWith('~') ? p.replace(/^~/, os.homedir()) : p;
}

// Read the .p8 material — inline contents win; otherwise read the file. Only
// ever called from getProvider (i.e. only when going live). Never logged.
function loadKeyMaterial() {
  if (process.env.APNS_VOIP_KEY) return process.env.APNS_VOIP_KEY;
  if (process.env.APNS_VOIP_KEY_PATH) {
    return fs.readFileSync(expandHome(process.env.APNS_VOIP_KEY_PATH));
  }
  return null;
}

// ── Provider (lazy, cached, fail-closed) ────────────────────────────────────
let _provider = null;
let _providerFailed = false;

function getProvider() {
  if (_provider) return _provider;
  if (_providerFailed) return null;
  try {
    // eslint-disable-next-line global-require
    const apn = require('@parse/node-apn');
    const key = loadKeyMaterial();
    if (!key) { _providerFailed = true; return null; }
    const production = process.env.APNS_VOIP_PRODUCTION !== 'false';
    _provider = new apn.Provider({
      token: {
        key, // Buffer or string — never logged
        keyId: process.env.APNS_KEY_ID,
        teamId: process.env.APNS_TEAM_ID,
      },
      production,
    });
    // eslint-disable-next-line no-console
    console.log(`[voip:provider] APNs VoIP provider initialised (production=${production})`);
    return _provider;
  } catch (err) {
    _providerFailed = true;
    // eslint-disable-next-line no-console
    console.error('[voip:provider] init failed:', err && err.message);
    return null;
  }
}

/**
 * Build the PushKit VoIP notification. Pure (apart from Date.now) and exported
 * for tests so the headers/payload contract can be asserted without a network.
 * Headers that make Apple wake the app cold-start: apns-push-type: voip and
 * apns-topic: <bundle>.voip.
 */
function buildVoipNotification(ctx, callerName) {
  // eslint-disable-next-line global-require
  const apn = require('@parse/node-apn');
  const note = new apn.Notification();
  note.topic = `${process.env.APNS_BUNDLE_ID}.voip`;
  note.pushType = 'voip';
  note.priority = 10;
  // Short ring window — a VoIP push that arrives late should not ring.
  note.expiry = Math.floor(Date.now() / 1000) + 30;
  note.payload = {
    call_id: ctx.callId || null,
    caller_name: callerName || 'Plagit Call',
    call_type: ctx.callType || 'audio',
  };
  return note;
}

/** Resolve the caller display name for the CallKit screen. Cheap, fail-soft. */
async function resolveCallerName(callerId) {
  if (!callerId) return 'Plagit Call';
  try {
    const u = await db('users').where({ id: callerId }).select('name').first();
    return (u && u.name) || 'Plagit Call';
  } catch (_) {
    return 'Plagit Call';
  }
}

/**
 * Active VoIP (PushKit) tokens for a user. Distinct from FCM tokens — the
 * `voip_token` column is added by migration 056. Fail-soft to [].
 */
async function getVoipTokensForUser(userId) {
  try {
    const rows = await db('device_tokens')
      .where({ user_id: userId, platform: 'ios' })
      .whereNotNull('voip_token')
      .whereNull('revoked_at')
      .select('voip_token');
    return rows.map((r) => r.voip_token).filter(Boolean);
  } catch (_) {
    return [];
  }
}

// Soft-revoke a dead VoIP token so we stop pushing to it (Apple's contract:
// BadDeviceToken / Unregistered mean the token is permanently invalid).
async function maybeRevoke(failure, token) {
  const reason = (failure
    && ((failure.response && failure.response.reason) || failure.reason)) || '';
  if (reason === 'BadDeviceToken' || reason === 'Unregistered') {
    try {
      await db('device_tokens').where({ voip_token: token }).update({ revoked_at: db.fn.now() });
      // eslint-disable-next-line no-console
      console.log(`[voip:revoke] soft-revoked token=${short(token)} reason=${reason}`);
    } catch (_) { /* best-effort */ }
  }
}

/**
 * Best-effort "ring" to a callee. NEVER throws/rejects. Mode is resolved per
 * call: 'off' → no-op; 'log' → log only; 'live' → real VoIP push to each
 * active token, soft-revoking dead ones.
 *
 * @param {string} calleeUserId
 * @param {{callId: string, callType?: string, callerId?: string}} ctx
 */
async function sendRingToUser(calleeUserId, ctx = {}) {
  const mode = resolveMode();
  if (mode === 'off') return { mode: 'off', sent: 0, skipped: true };
  /* eslint-disable no-console */
  try {
    const tokens = await getVoipTokensForUser(calleeUserId);
    if (!tokens.length) {
      console.log(`[voip:${mode}] no VoIP token for callee — nothing to ring (call=${ctx.callId})`);
      return { mode, sent: 0, tokens: 0 };
    }

    if (mode === 'log') {
      for (const t of tokens) {
        console.log(`[voip:log] would ring token=${short(t)} call=${ctx.callId} type=${ctx.callType || 'audio'}`);
      }
      return { mode, sent: 0, tokens: tokens.length, transmitted: false };
    }

    // mode === 'live'
    const provider = getProvider();
    if (!provider) {
      console.warn(`[voip:live] provider unavailable — no send (call=${ctx.callId})`);
      return { mode, sent: 0, tokens: tokens.length, transmitted: false, providerDown: true };
    }
    const callerName = await resolveCallerName(ctx.callerId);
    let sent = 0;
    for (const t of tokens) {
      const note = buildVoipNotification(ctx, callerName);
      const res = await provider.send(note, t);
      const okCount = (res && res.sent && res.sent.length) || 0;
      sent += okCount;
      const failed = (res && res.failed) || [];
      for (const f of failed) await maybeRevoke(f, t);
      if (okCount) console.log(`[voip:live] rang token=${short(t)} call=${ctx.callId}`);
    }
    return { mode, sent, tokens: tokens.length, transmitted: true };
  } catch (err) {
    // Defensive: never let a VoIP path break the caller.
    console.error('[voip:error] sendRingToUser failed (non-fatal):', err && err.message);
    return { mode, sent: 0, error: true };
  }
  /* eslint-enable no-console */
}

/**
 * Build the PushKit "end/cancel" notification. Same VoIP envelope as the ring
 * (apns-push-type: voip, topic <bundle>.voip) but payload carries
 * `event: 'end'` so AppDelegate dismisses the ringing CallKit instead of
 * showing it. Exported for tests.
 */
function buildEndNotification(ctx) {
  // eslint-disable-next-line global-require
  const apn = require('@parse/node-apn');
  const note = new apn.Notification();
  note.topic = `${process.env.APNS_BUNDLE_ID}.voip`;
  note.pushType = 'voip';
  note.priority = 10;
  note.expiry = Math.floor(Date.now() / 1000) + 30;
  note.payload = { call_id: ctx.callId || null, event: 'end' };
  return note;
}

/**
 * Best-effort "cancel/end" VoIP push to a callee that is still RINGING when the
 * caller hangs up before pickup. Wakes the (possibly killed) device so it can
 * dismiss the CallKit ring → the call becomes missed without a manual swipe.
 * NEVER throws. Same mode-gating as [sendRingToUser].
 */
async function sendEndToUser(calleeUserId, ctx = {}) {
  const mode = resolveMode();
  if (mode === 'off') return { mode: 'off', sent: 0, skipped: true };
  /* eslint-disable no-console */
  try {
    const tokens = await getVoipTokensForUser(calleeUserId);
    if (!tokens.length) {
      console.log(`[voip:${mode}] no VoIP token for callee — no end push (call=${ctx.callId})`);
      return { mode, sent: 0, tokens: 0 };
    }
    if (mode === 'log') {
      for (const t of tokens) {
        console.log(`[voip:log] would END token=${short(t)} call=${ctx.callId}`);
      }
      return { mode, sent: 0, tokens: tokens.length, transmitted: false };
    }
    const provider = getProvider();
    if (!provider) {
      console.warn(`[voip:live] provider unavailable — no end (call=${ctx.callId})`);
      return { mode, sent: 0, tokens: tokens.length, transmitted: false, providerDown: true };
    }
    let sent = 0;
    for (const t of tokens) {
      const note = buildEndNotification(ctx);
      const res = await provider.send(note, t);
      const okCount = (res && res.sent && res.sent.length) || 0;
      sent += okCount;
      const failed = (res && res.failed) || [];
      for (const f of failed) await maybeRevoke(f, t);
      if (okCount) console.log(`[voip:live] END sent token=${short(t)} call=${ctx.callId}`);
    }
    return { mode, sent, tokens: tokens.length, transmitted: true };
  } catch (err) {
    console.error('[voip:error] sendEndToUser failed (non-fatal):', err && err.message);
    return { mode, sent: 0, error: true };
  }
  /* eslint-enable no-console */
}

// Test hook — inject a fake provider so the live path is exercisable WITHOUT a
// real APNs network connection. Never used in production code paths.
function _setProviderForTest(fake) {
  _provider = fake;
  _providerFailed = false;
}

module.exports = {
  sendRingToUser,
  sendEndToUser,
  // Exported for tests / introspection:
  _internal: {
    resolveMode,
    hasCreds,
    short,
    buildVoipNotification,
    buildEndNotification,
    resolveCallerName,
    getVoipTokensForUser,
    maybeRevoke,
    _setProviderForTest,
    MODE,
    REQUIRED_IDS,
  },
};
