/**
 * Unit tests for src/services/push/apnsVoipSender.js — the VoIP push sender.
 *
 * Contract under test (Step D, flag-gated, OFF by default):
 *   • Mode resolution: OFF when VOIP_PUSH_ENABLED is off; LOG when armed but a
 *     credential is missing; LIVE when armed with all ids + key material.
 *   • Safety: sendRingToUser() in OFF mode is a pure no-op (no DB, no provider,
 *     no network), and it NEVER throws/rejects under any input.
 *   • Payload/headers: buildVoipNotification() sets apns-push-type: voip and
 *     apns-topic: <bundle>.voip with {call_id, caller_name, call_type}.
 *   • Redaction: short() never leaks a full token.
 *
 * Pure: no bus, NO database, NO APNs network. resolveMode() and the env/flag
 * are flipped + restored. The module loads in OFF mode (the production posture)
 * which we assert is inert. The live send PATH (token fetch + provider.send +
 * revoke) is covered separately by tests/integration/voipLiveSend.test.js with
 * a mock provider.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const flags = require('../../src/config/featureFlags');
const voip = require('../../src/services/push/apnsVoipSender');
const {
  resolveMode, hasCreds, short, buildVoipNotification, MODE, REQUIRED_IDS,
} = voip._internal;

// Snapshot every env key the sender reads + the live flag, restore after each
// mutating test so nothing leaks into sibling suites or the host shell.
const ENV_KEYS = [...REQUIRED_IDS, 'APNS_VOIP_KEY', 'APNS_VOIP_KEY_PATH', 'VOIP_PUSH_ENABLED'];
const SNAP = {};
for (const k of ENV_KEYS) SNAP[k] = process.env[k];
const SNAP_FLAG = flags.voipPushEnabled;

function clearAll() {
  for (const k of ENV_KEYS) delete process.env[k];
}
function armWithCreds() {
  flags.voipPushEnabled = true;
  process.env.APNS_KEY_ID = 'Q6W8V5Q28S';
  process.env.APNS_TEAM_ID = '6CVZ9J92UW';
  process.env.APNS_BUNDLE_ID = 'com.plagit.plagit';
  process.env.APNS_VOIP_KEY = 'fake-not-a-real-key';
}
function restore() {
  for (const k of ENV_KEYS) {
    if (SNAP[k] === undefined) delete process.env[k];
    else process.env[k] = SNAP[k];
  }
  flags.voipPushEnabled = SNAP_FLAG;
}

// ── Loaded posture: the module loads OFF (production default) ────────────────
test('module loads in OFF mode under the default (unarmed) test env', () => {
  assert.equal(MODE, 'off');
});

test('OFF mode → sendRingToUser is a pure no-op (skipped, sent 0)', async () => {
  const r = await voip.sendRingToUser('any-user', { callId: 'c1', callType: 'audio' });
  assert.deepEqual(r, { mode: 'off', sent: 0, skipped: true });
});

test('sendRingToUser NEVER rejects, even on null/garbage input', async () => {
  await assert.doesNotReject(() => voip.sendRingToUser(null, {}));
  await assert.doesNotReject(() => voip.sendRingToUser(undefined));
  await assert.doesNotReject(() => voip.sendRingToUser('u', null));
});

// ── resolveMode: OFF / LOG / LIVE decision ──────────────────────────────────
test('resolveMode → "off" whenever the flag is off (creds irrelevant)', () => {
  try {
    armWithCreds();
    flags.voipPushEnabled = false; // OFF flag wins over full creds
    assert.equal(resolveMode(), 'off');
  } finally { restore(); }
});

test('resolveMode → "log" when armed but the ids are missing (no crash)', () => {
  try {
    clearAll();
    flags.voipPushEnabled = true;
    assert.equal(resolveMode(), 'log');
  } finally { restore(); }
});

test('resolveMode → "log" when ids present but NO key material', () => {
  try {
    clearAll();
    flags.voipPushEnabled = true;
    process.env.APNS_KEY_ID = 'Q6W8V5Q28S';
    process.env.APNS_TEAM_ID = '6CVZ9J92UW';
    process.env.APNS_BUNDLE_ID = 'com.plagit.plagit';
    // neither APNS_VOIP_KEY nor APNS_VOIP_KEY_PATH set
    assert.equal(resolveMode(), 'log');
  } finally { restore(); }
});

test('resolveMode → "live" when armed with all ids + inline key material', () => {
  try {
    armWithCreds();
    assert.equal(resolveMode(), 'live');
    assert.equal(hasCreds(), true);
  } finally { restore(); }
});

test('resolveMode → "live" also when key comes from APNS_VOIP_KEY_PATH', () => {
  try {
    clearAll();
    flags.voipPushEnabled = true;
    process.env.APNS_KEY_ID = 'Q6W8V5Q28S';
    process.env.APNS_TEAM_ID = '6CVZ9J92UW';
    process.env.APNS_BUNDLE_ID = 'com.plagit.plagit';
    process.env.APNS_VOIP_KEY_PATH = '/tmp/does-not-need-to-exist.p8'; // not read here
    assert.equal(resolveMode(), 'live');
  } finally { restore(); }
});

// ── buildVoipNotification: the headers/payload contract ─────────────────────
test('buildVoipNotification sets voip push-type, <bundle>.voip topic, payload', () => {
  try {
    process.env.APNS_BUNDLE_ID = 'com.plagit.plagit';
    const note = buildVoipNotification({ callId: 'call-123', callType: 'video' }, 'Nobu Restaurant');
    assert.equal(note.pushType, 'voip', 'apns-push-type: voip');
    assert.equal(note.topic, 'com.plagit.plagit.voip', 'apns-topic = <bundle>.voip');
    assert.equal(note.priority, 10);
    assert.deepEqual(note.payload, {
      call_id: 'call-123',
      caller_name: 'Nobu Restaurant',
      call_type: 'video',
    });
  } finally { restore(); }
});

test('buildVoipNotification falls back to safe defaults', () => {
  try {
    process.env.APNS_BUNDLE_ID = 'com.plagit.plagit';
    const note = buildVoipNotification({}, null);
    assert.equal(note.payload.caller_name, 'Plagit Call');
    assert.equal(note.payload.call_type, 'audio');
    assert.equal(note.payload.call_id, null);
  } finally { restore(); }
});

// ── short(): redaction never leaks a full token ─────────────────────────────
test('short() redacts a long token to first6…last4', () => {
  assert.equal(short('abcdef1234567890'), 'abcdef…7890');
});

test('short() returns *** for short / non-string tokens', () => {
  assert.equal(short('shorty'), '***');
  assert.equal(short(''), '***');
  assert.equal(short(null), '***');
  assert.equal(short(12345), '***');
});

// ── Guard: the required id keys are the expected APNs names ──────────────────
test('REQUIRED_IDS are the three APNs id env var names', () => {
  assert.deepEqual(REQUIRED_IDS, ['APNS_KEY_ID', 'APNS_TEAM_ID', 'APNS_BUNDLE_ID']);
});
