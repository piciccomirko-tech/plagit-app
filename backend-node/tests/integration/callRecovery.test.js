/**
 * Integration test: GET /v1/calls/:id/recovery — cold-start recovery.
 *
 * A callee that answered a CallKit call from a terminated/locked device has
 * no SSE, so it fetches the pending offer + the counterpart's ICE + terminal
 * state over REST. We seed a call, submit the caller's offer + ICE, then
 * assert recovery returns them to the callee; a non-participant is rejected;
 * and once the call is terminal the offer is gone and `terminal` is true.
 *
 * Runs the controllers directly (no Express boot) against local Postgres,
 * mirroring callInitiateVoip.test.js. Skipped unless CALL_RECOVERY_TESTS=1.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.CALL_RECOVERY_TESTS === '1';

if (!RUN) {
  test('call recovery test skipped (set CALL_RECOVERY_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  require('dotenv').config({ quiet: true });
  const db = require('../../src/config/db');
  const { initiate, recovery, decline } = require('../../src/controllers/callController');
  const { submitOffer, submitIce } = require('../../src/controllers/callSignalController');

  const STAMP = `${Date.now()}`;
  const EMAIL = {
    caller: `rec-caller-${STAMP}@plagit.test`,
    callee: `rec-callee-${STAMP}@plagit.test`,
    stranger: `rec-stranger-${STAMP}@plagit.test`,
  };
  const ctx = { callerId: null, calleeId: null, strangerId: null, convId: null, callId: null };

  function mockReq(userId, body, params) {
    return { user: { id: userId }, body: body || {}, params: params || {} };
  }
  function mockRes() {
    const state = { status: 200, body: null };
    return {
      _state: state,
      status(code) { state.status = code; return this; },
      json(body) { state.body = body; return this; },
    };
  }
  async function run(handler, userId, body, params) {
    const res = mockRes();
    let err = null;
    await handler(mockReq(userId, body, params), res, (e) => { err = e; });
    if (err) throw err;
    return res._state;
  }
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
      const calls = await db('calls').where(function () {
        this.whereIn('caller_id', ids).orWhereIn('callee_id', ids);
      }).select('id');
      const callIds = calls.map((c) => c.id);
      if (callIds.length) await db('call_signals').whereIn('call_id', callIds).del();
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

  test('setup: caller + callee + conversation + ringing call', async () => {
    await cleanup();
    ctx.callerId = await makeUser(EMAIL.caller, 'business');
    ctx.calleeId = await makeUser(EMAIL.callee, 'candidate');
    ctx.strangerId = await makeUser(EMAIL.stranger, 'candidate');
    ctx.convId = await makeConversation(ctx.calleeId, ctx.callerId);
    const r = await run(initiate, ctx.callerId, { conversation_id: ctx.convId, type: 'audio' });
    ctx.callId = r.body.data.call.callId;
  });

  test('caller submits offer + ICE (persisted in call_signals)', async () => {
    await run(submitOffer, ctx.callerId, { sdp: 'v=0\r\no=- 1 1 IN IP4 0.0.0.0\r\n' }, { id: ctx.callId });
    await run(submitIce, ctx.callerId, {
      candidates: [{ candidate: 'candidate:1 1 udp 1 1.1.1.1 9 typ host', sdpMid: '0', sdpMLineIndex: 0 }],
    }, { id: ctx.callId });
  });

  test('callee recovery returns the offer + counterpart ICE, non-terminal', async () => {
    const { status, body } = await run(recovery, ctx.calleeId, {}, { id: ctx.callId });
    assert.equal(status, 200);
    const rec = body.data.recovery;
    assert.equal(rec.terminal, false, 'call is live');
    assert.ok(rec.offer && typeof rec.offer.sdp === 'string' && rec.offer.sdp.length > 0, 'offer SDP recovered');
    assert.equal(rec.offer.fromUserId, ctx.callerId, 'offer attributed to caller');
    assert.equal(rec.pendingIce.length, 1, 'one counterpart ICE batch recovered');
    assert.ok(rec.pendingIce[0].candidates.length >= 1, 'ICE candidates present');
  });

  test('recovery rejects a non-participant', async () => {
    let err = null;
    try { await run(recovery, ctx.strangerId, {}, { id: ctx.callId }); } catch (e) { err = e; }
    assert.ok(err, 'non-participant is rejected');
  });

  test('after decline (terminal), recovery reports terminal + null offer', async () => {
    await run(decline, ctx.calleeId, {}, { id: ctx.callId });
    const { body } = await run(recovery, ctx.calleeId, {}, { id: ctx.callId });
    assert.equal(body.data.recovery.terminal, true, 'declined → terminal');
    assert.equal(body.data.recovery.offer, null, 'no offer surfaced once terminal');
  });

  test('teardown', async () => {
    await cleanup();
    await db.destroy();
  });
}
