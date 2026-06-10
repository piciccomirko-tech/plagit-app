/**
 * Integration test: callController.initiate() is resilient to VoIP push
 * failures (Step D fire-and-forget contract).
 *
 * The VoIP ring is best-effort: initiate() calls voipPush.sendRingToUser(...)
 * with a trailing `.catch(()=>{})` AFTER the SSE fan-out, so a VoIP error must
 * NEVER break call creation. We prove it by stubbing the sender to REJECT and
 * asserting initiate still returns 201 with a ringing call row.
 *
 * Runs the controller directly (no Express boot) against a real local
 * Postgres, mirroring callActiveEndpoint.test.js. Skipped unless
 * CALL_VOIP_INIT_TESTS=1. No APNs network — the sender is stubbed.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.CALL_VOIP_INIT_TESTS === '1';

if (!RUN) {
  test('callInitiate VoIP-resilience test skipped (set CALL_VOIP_INIT_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  require('dotenv').config({ quiet: true });
  const db = require('../../src/config/db');
  const { initiate } = require('../../src/controllers/callController');
  const voipPush = require('../../src/services/push/apnsVoipSender');

  const STAMP = `${Date.now()}`;
  const EMAIL = {
    caller: `call-init-caller-${STAMP}@plagit.test`,
    callee: `call-init-callee-${STAMP}@plagit.test`,
  };
  const ctx = { callerId: null, calleeId: null, convId: null, callId: null };

  // ── mock req/res ────────────────────────────────────────────────────
  function mockReq(userId, body) {
    return { user: { id: userId }, body };
  }
  function mockRes() {
    const state = { status: 200, body: null };
    return {
      _state: state,
      status(code) { state.status = code; return this; },
      json(body) { state.body = body; return this; },
    };
  }
  async function callInitiate(userId, body) {
    const res = mockRes();
    let err = null;
    await initiate(mockReq(userId, body), res, (e) => { err = e; });
    if (err) throw err;
    return res._state;
  }

  // ── seeding (mirrors callActiveEndpoint.test.js) ────────────────────
  async function makeUser(email, type) {
    const [u] = await db('users').insert({
      name: email, email, password_hash: 'test-not-a-real-hash', user_type: type,
    }).returning('id');
    return u.id;
  }
  async function makeConversation(candidateUserId, businessUserId) {
    const [cand] = await db('candidates').insert({ user_id: candidateUserId, name: 'Test Cand' }).returning('id');
    const [biz] = await db('businesses').insert({ user_id: businessUserId, name: 'Test Biz' }).returning('id');
    const [conv] = await db('conversations').insert({ candidate_id: cand.id, business_id: biz.id }).returning('id');
    return conv.id;
  }
  async function cleanup() {
    const emails = Object.values(EMAIL);
    const users = await db('users').whereIn('email', emails).select('id');
    const ids = users.map((u) => u.id);
    if (ids.length) {
      await db('calls').where(function () {
        this.whereIn('caller_id', ids).orWhereIn('callee_id', ids);
      }).del();
      await db('conversations').whereIn('candidate_id', function () {
        this.select('id').from('candidates').whereIn('user_id', ids);
      }).del();
      await db('candidates').whereIn('user_id', ids).del();
      await db('businesses').whereIn('user_id', ids).del();
    }
    await db('users').whereIn('email', emails).del();
  }

  // Restore the real sender after the suite so we never leak the stub.
  const realSend = voipPush.sendRingToUser;

  test('setup: throwaway caller + callee + conversation', async () => {
    await cleanup();
    ctx.callerId = await makeUser(EMAIL.caller, 'business');
    ctx.calleeId = await makeUser(EMAIL.callee, 'candidate');
    ctx.convId = await makeConversation(ctx.calleeId, ctx.callerId);
  });

  test('initiate still returns 201 when the VoIP sender REJECTS', async () => {
    // Stub the sender to throw — the controller must swallow it.
    let called = false;
    voipPush.sendRingToUser = () => {
      called = true;
      return Promise.reject(new Error('boom-voip'));
    };

    const { status, body } = await callInitiate(ctx.callerId, {
      conversation_id: ctx.convId,
      type: 'audio',
    });

    assert.equal(status, 201, 'call still created despite VoIP failure');
    assert.ok(body && body.success, 'success flag set');
    assert.equal(body.data.call.status, 'ringing', 'call is ringing');
    assert.ok(called, 'the VoIP sender was actually invoked (wiring present)');
    ctx.callId = body.data.call.callId;

    // The ringing row is really in the DB.
    const row = await db('calls').where({ id: ctx.callId }).first();
    assert.ok(row, 'call row persisted');
    assert.equal(row.status, 'ringing');
  });

  test('teardown: restore real sender + delete seed', async () => {
    voipPush.sendRingToUser = realSend;
    await cleanup();
    await db.destroy();
  });
}
