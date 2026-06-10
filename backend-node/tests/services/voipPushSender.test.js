/**
 * Unit tests for src/services/push/apnsVoipSender.js — the VoIP push SKELETON.
 *
 * Contract under test (Step D, flag-gated, OFF by default):
 *   • Mode resolution: OFF when VOIP_PUSH_ENABLED is off; LOG when armed but a
 *     credential is missing; STUB when armed with all four credentials present
 *     (STUB still NEVER transmits — the real .p8 sender is not wired yet).
 *   • Safety: sendRingToUser() in OFF mode is a pure no-op (no DB, no network),
 *     and it NEVER throws/rejects under any input — the call-site in
 *     callController.initiate relies on this (fire-and-forget).
 *   • Redaction: short() never leaks a full token.
 *
 * Pure: no bus, NO database, NO APNs network. resolveMode() reads env + the
 * live featureFlags object, so we flip those and restore. The module is loaded
 * once in OFF mode (the default test env), which is exactly the production
 * posture we assert is inert.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const flags = require('../../src/config/featureFlags');
const voip = require('../../src/services/push/apnsVoipSender');
const { resolveMode, short, MODE, CRED_KEYS } = voip._internal;

// Snapshot the env keys resolveMode reads + the live flag, so the suite never
// leaks state into the host shell or sibling test files.
const SNAP = {};
for (const k of [...CRED_KEYS, 'VOIP_PUSH_ENABLED']) SNAP[k] = process.env[k];
const SNAP_FLAG = flags.voipPushEnabled;

function clearCreds() {
  for (const k of CRED_KEYS) delete process.env[k];
}
function setAllCreds() {
  for (const k of CRED_KEYS) process.env[k] = 'fake-not-a-real-credential';
}
function restore() {
  for (const k of [...CRED_KEYS, 'VOIP_PUSH_ENABLED']) {
    if (SNAP[k] === undefined) delete process.env[k];
    else process.env[k] = SNAP[k];
  }
  flags.voipPushEnabled = SNAP_FLAG;
}

// ── Loaded posture: the module loads in OFF mode (production default) ────────
test('module loads in OFF mode under the default (unarmed) test env', () => {
  assert.equal(MODE, 'off');
});

test('OFF mode → sendRingToUser is a pure no-op (skipped, sent 0, no throw)', async () => {
  const r = await voip.sendRingToUser('any-user', { callId: 'c1', callType: 'audio' });
  assert.deepEqual(r, { mode: 'off', sent: 0, skipped: true });
});

test('sendRingToUser NEVER rejects, even on null/garbage input (fire-and-forget)', async () => {
  // callController calls this with `.catch(()=>{})`, but the sender itself must
  // also be reject-proof so a VoIP hiccup can never surface as an unhandled
  // rejection. All of these resolve.
  await assert.doesNotReject(() => voip.sendRingToUser(null, {}));
  await assert.doesNotReject(() => voip.sendRingToUser(undefined));
  await assert.doesNotReject(() => voip.sendRingToUser('u', null));
});

// ── resolveMode: the OFF / LOG / STUB decision logic ────────────────────────
test('resolveMode → "off" whenever the flag is off (creds irrelevant)', () => {
  try {
    flags.voipPushEnabled = false;
    setAllCreds(); // even with full creds, OFF flag wins
    assert.equal(resolveMode(), 'off');
  } finally { restore(); }
});

test('resolveMode → "log" when armed but ALL credentials are missing (no crash)', () => {
  try {
    flags.voipPushEnabled = true;
    clearCreds();
    assert.equal(resolveMode(), 'log');
  } finally { restore(); }
});

test('resolveMode → "log" when armed but a credential is partially missing', () => {
  try {
    flags.voipPushEnabled = true;
    setAllCreds();
    delete process.env.APNS_VOIP_KEY; // drop one of the four
    assert.equal(resolveMode(), 'log');
  } finally { restore(); }
});

test('resolveMode → "stub" when armed with ALL credentials (still no real send)', () => {
  try {
    flags.voipPushEnabled = true;
    setAllCreds();
    assert.equal(resolveMode(), 'stub');
    // Critical: there is NO "live" mode in the skeleton — real transmission
    // is intentionally impossible until the .p8 HTTP/2 sender lands.
    assert.notEqual(resolveMode(), 'live');
  } finally { restore(); }
});

// ── short(): token redaction never leaks a full token ───────────────────────
test('short() redacts a long token to first6…last4', () => {
  assert.equal(short('abcdef1234567890'), 'abcdef…7890');
});

test('short() returns *** for short / non-string tokens (never leaks)', () => {
  assert.equal(short('shorty'), '***');
  assert.equal(short(''), '***');
  assert.equal(short(null), '***');
  assert.equal(short(12345), '***');
});

// ── Guard: the four credential keys are the expected APNs names ─────────────
test('CRED_KEYS are the four APNs VoIP env var names', () => {
  assert.deepEqual(CRED_KEYS, ['APNS_VOIP_KEY', 'APNS_KEY_ID', 'APNS_TEAM_ID', 'APNS_BUNDLE_ID']);
});
