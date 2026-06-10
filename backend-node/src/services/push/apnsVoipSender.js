/**
 * APNs VoIP push sender — SKELETON (Step D, flag-gated, OFF by default).
 *
 * Purpose: when a call starts (`call.ringing`), wake the callee's iOS device
 * via an Apple PushKit VoIP push so CallKit rings WhatsApp-style even when the
 * app is killed. firebase-admin CANNOT send VoIP pushes (it cannot set the
 * `apns-push-type: voip` header), so the real sender needs a direct APNs
 * HTTP/2 connection authenticated with an Apple `.p8` key.
 *
 * ── SAFETY — this is a SKELETON. It NEVER transmits a real push yet. ──
 *   • Default OFF: `VOIP_PUSH_ENABLED` is false unless explicitly set.
 *   • OFF                       → no-op. One boot log, no DB query, no network.
 *   • ON but credentials missing → LOG MODE. Logs `[voip:log]`, no send, no crash.
 *   • ON and credentials present → STILL no send. Logs `[voip:stub]`.
 *     Real transmission is intentionally deferred until the Apple `.p8` VoIP
 *     key is provisioned and the `apn` HTTP/2 client is wired (see TODO below).
 *
 * Mirroring the existing `pushSender.js` safety pattern (PUSH_REAL_ENABLED):
 * the code can be deployed with this module present and stay completely
 * dormant in production until we deliberately arm it.
 *
 * ── Required env (NONE committed — set on Railway only when going live) ──
 *   VOIP_PUSH_ENABLED   '1'/'true' to arm (stays in stub until the real
 *                       sender lands — arming alone does NOT transmit).
 *   APNS_VOIP_KEY       the `.p8` private key contents — NEVER logged.
 *   APNS_KEY_ID         10-char Apple key id.
 *   APNS_TEAM_ID        10-char Apple team id.
 *   APNS_BUNDLE_ID      app bundle id (apns-topic will be `<bundle>.voip`).
 *
 * ── SECURITY ──
 *   • Never log the `.p8` key or any of its bytes.
 *   • Never log full device tokens — `short()` prefix/suffix only.
 */

const db = require('../../config/db');
const flags = require('../../config/featureFlags');

// The four credentials the REAL sender will need. Presence-checked only —
// values are never read into a log line.
const CRED_KEYS = ['APNS_VOIP_KEY', 'APNS_KEY_ID', 'APNS_TEAM_ID', 'APNS_BUNDLE_ID'];

/**
 * Resolve the operating mode once at load:
 *   'off'  — flag disabled (production default). Total no-op.
 *   'log'  — armed but at least one credential is missing. Log, never send.
 *   'stub' — armed and all credentials present, but the real HTTP/2 sender
 *            is not implemented yet, so we STILL do not transmit.
 */
function resolveMode() {
  if (!flags.voipPushEnabled) return 'off';
  const missing = CRED_KEYS.filter((k) => !process.env[k]);
  if (missing.length) return 'log';
  return 'stub';
}

const MODE = resolveMode();

// Visible-once boot line so the dormant/armed state is obvious in Railway logs.
// No credential values, ever — only the resolved mode and which keys are absent.
(function logBootMode() {
  /* eslint-disable no-console */
  if (MODE === 'off') {
    console.log('[voip:provider] VoIP push DISABLED (VOIP_PUSH_ENABLED off) — no-op');
  } else if (MODE === 'log') {
    const missing = CRED_KEYS.filter((k) => !process.env[k]).join(', ');
    console.log(`[voip:provider] VoIP push armed but LOG MODE — missing creds: ${missing}`);
  } else {
    console.log('[voip:provider] VoIP push armed, creds present — STUB MODE (real sender not wired yet)');
  }
  /* eslint-enable no-console */
}());

/** Redact a device/voip token for safe logging: first6…last4. */
function short(token) {
  if (typeof token !== 'string' || token.length <= 12) return '***';
  return `${token.slice(0, 6)}…${token.slice(-4)}`;
}

/**
 * Fetch the callee's active VoIP (PushKit) tokens. Distinct from FCM tokens:
 * the `voip_token` column is added by migration 056 (NOT yet in production).
 * Wrapped so a missing column / DB hiccup degrades to `[]` instead of throwing
 * — but note this only runs when armed, which never happens in production.
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

/**
 * Best-effort "ring" to a callee. SKELETON: never transmits. Returns a small
 * result object describing what it WOULD do, so callers/tests can assert
 * behaviour without any network. NEVER throws — call-site treats it as
 * fire-and-forget so a VoIP hiccup can never break call initiation.
 *
 * @param {string} calleeUserId
 * @param {{callId: string, callType?: string, callerId?: string}} ctx
 */
async function sendRingToUser(calleeUserId, ctx = {}) {
  if (MODE === 'off') {
    return { mode: 'off', sent: 0, skipped: true };
  }
  /* eslint-disable no-console */
  try {
    const tokens = await getVoipTokensForUser(calleeUserId);
    if (!tokens.length) {
      console.log(`[voip:${MODE}] no VoIP token for callee — nothing to ring (call=${ctx.callId})`);
      return { mode: MODE, sent: 0, tokens: 0 };
    }
    for (const t of tokens) {
      // STUB/LOG: describe the intended push; do NOT transmit.
      // The real payload (when wired) will carry: call_id, caller_name,
      // call_type, with headers apns-push-type:voip + apns-topic:<bundle>.voip.
      console.log(
        `[voip:${MODE}] would ring token=${short(t)} call=${ctx.callId} type=${ctx.callType || 'audio'}`,
      );
    }
    return { mode: MODE, sent: 0, tokens: tokens.length, transmitted: false };
  } catch (err) {
    // Defensive: never let a VoIP path break the caller.
    console.error('[voip:error] sendRingToUser failed (non-fatal):', err && err.message);
    return { mode: MODE, sent: 0, error: true };
  }
  /* eslint-enable no-console */
}

// ── TODO (when the Apple .p8 VoIP key is provisioned) ──────────────────────
//   1. `npm i apn` (or a maintained HTTP/2 APNs client).
//   2. Lazily init the provider from APNS_VOIP_KEY / KEY_ID / TEAM_ID, like
//      getAdmin() in pushSender.js. Cache it; fail closed on init error.
//   3. In sendRingToUser, when MODE === 'stub' (rename to 'live'), build the
//      VoIP payload {call_id, caller_name, call_type} and send with headers
//      apns-push-type: 'voip' and apns-topic: `${APNS_BUNDLE_ID}.voip`.
//   4. Handle BadDeviceToken / Unregistered → soft-revoke that voip_token.
//   5. Resolve caller_name (cheap users lookup) before sending.

module.exports = {
  sendRingToUser,
  // Exported for tests / introspection:
  _internal: { resolveMode, getVoipTokensForUser, short, MODE, CRED_KEYS },
};
