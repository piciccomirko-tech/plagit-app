/**
 * Integration tests for GET /v1/calls/active (CallKit VoIP cold-start).
 *
 * Tests the `getActive` controller directly (no Express boot) against a
 * real local Postgres. Skipped unless CALL_ACTIVE_TESTS=1.
 *
 * Contracts asserted:
 *   1. Fresh ringing call → caller receives it
 *   2. Fresh ringing call → callee receives it
 *   3. Non-participant → 404
 *   4. Stale ringing call (>90s) → 404
 *   5. Accepted call → 404 (only ringing returned)
 *   6. Terminal call (missed/declined/ended) → 404
 *   7. Empty (no call at all) → 404
 */

'use strict';

const test   = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.CALL_ACTIVE_TESTS === '1';

if (!RUN) {
  test('callActive integration tests skipped (set CALL_ACTIVE_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  require('dotenv').config();
  const db = require('../../src/config/db');
  const { getActive } = require('../../src/controllers/callController');

  // ── mock req/res helpers ────────────────────────────────────────────
  function mockReq(userId) {
    return { user: { id: userId } };
  }

  function mockRes() {
    const state = { status: 200, body: null };
    return {
      _state: state,
      status(code) { state.status = code; return this; },
      json(body)   { state.body  = body; return this; },
    };
  }

  async function callHandler(userId) {
    const res  = mockRes();
    let   err  = null;
    await getActive(mockReq(userId), res, (e) => { err = e; });
    if (err) throw err;
    return res._state.body;
  }

  // ── DB helpers ───────────────────────────────────────────────────────
  const STAMP = `${Date.now()}`;
  const EMAIL = {
    caller:  `call-active-caller-${STAMP}@plagit.test`,
    callee:  `call-active-callee-${STAMP}@plagit.test`,
    stranger:`call-active-stranger-${STAMP}@plagit.test`,
  };

  const ctx = { callerId: null, calleeId: null, strangerId: null, convId: null };

  async function makeUser(email, type) {
    const [u] = await db('users').insert({
      name: email, email, password_hash: 'test-not-a-real-hash', user_type: type,
    }).returning('id');
    return u.id;
  }

  async function makeConversation(candidateUserId, businessUserId) {
    // Need candidate + business profile rows to satisfy FKs
    const [cand] = await db('candidates').insert({ user_id: candidateUserId, name: 'Test Cand' }).returning('id');
    const [biz]  = await db('businesses').insert({ user_id: businessUserId,  name: 'Test Biz'  }).returning('id');
    const [conv] = await db('conversations').insert({
      candidate_id: cand.id,
      business_id:  biz.id,
    }).returning('id');
    return { convId: conv.id, candProfileId: cand.id, bizProfileId: biz.id };
  }

  async function insertCall({ convId, callerId, calleeId, status = 'ringing', ageSeconds = 0 }) {
    const startedAt = new Date(Date.now() - ageSeconds * 1000).toISOString();
    const [row] = await db('calls').insert({
      conversation_id: convId,
      caller_id:       callerId,
      callee_id:       calleeId,
      type:            'audio',
      status,
      started_at:      startedAt,
    }).returning('*');
    return row;
  }

  async function cleanup() {
    const emails = Object.values(EMAIL);
    const users  = await db('users').whereIn('email', emails).select('id');
    const ids    = users.map((u) => u.id);
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

  // ── setup ────────────────────────────────────────────────────────────
  test('setup: create throwaway users + conversation', async () => {
    await cleanup();
    ctx.callerId   = await makeUser(EMAIL.caller,   'business');
    ctx.calleeId   = await makeUser(EMAIL.callee,   'candidate');
    ctx.strangerId = await makeUser(EMAIL.stranger,  'candidate');
    const { convId } = await makeConversation(ctx.calleeId, ctx.callerId);
    ctx.convId = convId;
  });

  // ── 1. Fresh ringing call → caller gets it ────────────────────────────
  test('fresh ringing call is returned for the caller', async () => {
    const row = await insertCall({ convId: ctx.convId, callerId: ctx.callerId, calleeId: ctx.calleeId, ageSeconds: 5 });
    ctx.freshCallId = row.id;

    const body = await callHandler(ctx.callerId);
    assert.ok(body.success, 'success flag');
    assert.equal(body.data.call.callId, row.id);
    assert.equal(body.data.call.status, 'ringing');
  });

  // ── 2. Fresh ringing call → callee gets it ───────────────────────────
  test('fresh ringing call is returned for the callee', async () => {
    const body = await callHandler(ctx.calleeId);
    assert.equal(body.data.call.callId, ctx.freshCallId);
  });

  // ── 3. Non-participant → 404 ─────────────────────────────────────────
  test('non-participant receives 404', async () => {
    await assert.rejects(
      () => callHandler(ctx.strangerId),
      (err) => { assert.equal(err.statusCode, 404); return true; },
    );
  });

  // ── cleanup between cases ────────────────────────────────────────────
  test('cleanup fresh call before stale test', async () => {
    await db('calls').where({ id: ctx.freshCallId }).del();
  });

  // ── 4. Stale ringing call (>90s) → 404 ──────────────────────────────
  test('stale ringing call (>90s old) returns 404', async () => {
    const row = await insertCall({
      convId: ctx.convId, callerId: ctx.callerId, calleeId: ctx.calleeId, ageSeconds: 95,
    });
    ctx.staleCallId = row.id;

    await assert.rejects(
      () => callHandler(ctx.calleeId),
      (err) => { assert.equal(err.statusCode, 404); return true; },
    );
    await db('calls').where({ id: row.id }).del();
  });

  // ── 5. Accepted call → 404 ──────────────────────────────────────────
  test('accepted call returns 404 (only ringing returned)', async () => {
    const row = await insertCall({
      convId: ctx.convId, callerId: ctx.callerId, calleeId: ctx.calleeId, status: 'accepted', ageSeconds: 10,
    });
    await assert.rejects(
      () => callHandler(ctx.calleeId),
      (err) => { assert.equal(err.statusCode, 404); return true; },
    );
    await db('calls').where({ id: row.id }).del();
  });

  // ── 6. Terminal calls → 404 ──────────────────────────────────────────
  test('terminal call (missed) returns 404', async () => {
    const row = await insertCall({
      convId: ctx.convId, callerId: ctx.callerId, calleeId: ctx.calleeId, status: 'missed', ageSeconds: 10,
    });
    await assert.rejects(
      () => callHandler(ctx.calleeId),
      (err) => { assert.equal(err.statusCode, 404); return true; },
    );
    await db('calls').where({ id: row.id }).del();
  });

  // ── 7. No call at all → 404 ──────────────────────────────────────────
  test('no call at all returns 404', async () => {
    await assert.rejects(
      () => callHandler(ctx.calleeId),
      (err) => { assert.equal(err.statusCode, 404); return true; },
    );
  });

  // ── cleanup ───────────────────────────────────────────────────────────
  test('cleanup: remove test rows + close DB pool', async () => {
    await cleanup();
    await db.destroy();
  });
}
