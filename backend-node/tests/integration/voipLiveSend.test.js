/**
 * Integration test: the LIVE VoIP send path with a MOCK provider.
 *
 * Exercises sendRingToUser() in 'live' mode end-to-end WITHOUT a real APNs
 * network connection: a fake provider is injected via _setProviderForTest, so
 * we assert the exact Notification (apns-push-type: voip, <bundle>.voip topic,
 * {call_id, caller_name, call_type}) and the dead-token soft-revoke, against a
 * real local Postgres. The Apple .p8 is NEVER read — getProvider() returns the
 * injected mock before any key load.
 *
 * Skipped unless VOIP_LIVE_TESTS=1. Requires the voip_token column locally
 * (migration 056). No network, no production, no real credentials.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.VOIP_LIVE_TESTS === '1';

if (!RUN) {
  test('VoIP live-send test skipped (set VOIP_LIVE_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  require('dotenv').config({ quiet: true });
  const db = require('../../src/config/db');
  const flags = require('../../src/config/featureFlags');
  const voip = require('../../src/services/push/apnsVoipSender');
  const { _setProviderForTest } = voip._internal;

  const STAMP = `${Date.now()}`;
  const EMAIL = {
    caller: `voip-live-caller-${STAMP}@plagit.test`,
    callee: `voip-live-callee-${STAMP}@plagit.test`,
  };
  const VOIP_TOKEN = `voiptoken-${STAMP}-abcdef0123456789`;
  const ctx = { callerId: null, calleeId: null };

  // Snapshot env + flag so the suite never leaks the armed state.
  const ENV = ['APNS_KEY_ID', 'APNS_TEAM_ID', 'APNS_BUNDLE_ID', 'APNS_VOIP_KEY', 'VOIP_PUSH_ENABLED'];
  const SNAP = {};
  for (const k of ENV) SNAP[k] = process.env[k];
  const SNAP_FLAG = flags.voipPushEnabled;

  function arm() {
    flags.voipPushEnabled = true;
    process.env.APNS_KEY_ID = 'Q6W8V5Q28S';
    process.env.APNS_TEAM_ID = '6CVZ9J92UW';
    process.env.APNS_BUNDLE_ID = 'com.plagit.plagit';
    process.env.APNS_VOIP_KEY = 'fake-not-a-real-key';
  }
  function disarm() {
    for (const k of ENV) {
      if (SNAP[k] === undefined) delete process.env[k];
      else process.env[k] = SNAP[k];
    }
    flags.voipPushEnabled = SNAP_FLAG;
    _setProviderForTest(null);
  }

  function mockProvider(resultFor) {
    const calls = [];
    return {
      calls,
      send: async (note, token) => { calls.push({ note, token }); return resultFor(note, token); },
    };
  }

  async function makeUser(email, type, name) {
    const [u] = await db('users').insert({
      name: name || email, email, password_hash: 'test-not-a-real-hash', user_type: type,
    }).returning('id');
    return u.id;
  }
  async function cleanup() {
    const emails = Object.values(EMAIL);
    const users = await db('users').whereIn('email', emails).select('id');
    const ids = users.map((u) => u.id);
    if (ids.length) await db('device_tokens').whereIn('user_id', ids).del();
    await db('users').whereIn('email', emails).del();
  }

  test('setup: caller + callee + a registered VoIP token', async () => {
    await cleanup();
    ctx.callerId = await makeUser(EMAIL.caller, 'business', 'Nobu Restaurant');
    ctx.calleeId = await makeUser(EMAIL.callee, 'candidate', 'Elena');
    await db('device_tokens').insert({
      user_id: ctx.calleeId,
      token: `fcm-dummy-${STAMP}`,
      platform: 'ios',
      voip_token: VOIP_TOKEN,
    });
    arm();
  });

  test('live send → provider gets a voip push with the right topic + payload', async () => {
    const mock = mockProvider(() => ({ sent: [{ device: VOIP_TOKEN }], failed: [] }));
    _setProviderForTest(mock);

    const r = await voip.sendRingToUser(ctx.calleeId, {
      callId: 'call-xyz', callType: 'video', callerId: ctx.callerId,
    });

    assert.equal(r.transmitted, true);
    assert.equal(r.sent, 1);
    assert.equal(mock.calls.length, 1, 'provider.send called once');
    const { note, token } = mock.calls[0];
    assert.equal(token, VOIP_TOKEN, 'sent to the registered VoIP token');
    assert.equal(note.pushType, 'voip', 'apns-push-type: voip');
    assert.equal(note.topic, 'com.plagit.plagit.voip', 'apns-topic = <bundle>.voip');
    assert.equal(note.payload.call_id, 'call-xyz');
    assert.equal(note.payload.call_type, 'video');
    assert.equal(note.payload.caller_name, 'Nobu Restaurant', 'caller name resolved from users');
  });

  test('dead token (Unregistered) → voip token is soft-revoked', async () => {
    const mock = mockProvider((note, token) => ({
      sent: [],
      failed: [{ device: token, status: '410', response: { reason: 'Unregistered' } }],
    }));
    _setProviderForTest(mock);

    const r = await voip.sendRingToUser(ctx.calleeId, { callId: 'call-dead', callerId: ctx.callerId });
    assert.equal(r.sent, 0, 'nothing counted as sent');

    const row = await db('device_tokens').where({ voip_token: VOIP_TOKEN }).first();
    assert.ok(row.revoked_at, 'dead VoIP token soft-revoked');
  });

  test('teardown: disarm + restore + cleanup', async () => {
    disarm();
    await cleanup();
    await db.destroy();
  });
}
