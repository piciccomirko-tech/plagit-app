/**
 * Integration tests for callRingSweepJob.tick() (Step C ring timeout).
 *
 * Hits a real local Postgres. Skipped unless CALL_SWEEP_TESTS=1.
 *
 * Contracts asserted:
 *   1. Stale ringing call (>60s) → flipped to missed by tick()
 *   2. Fresh ringing call (<60s)  → untouched by tick()
 *   3. Non-ringing calls (accepted, ended) → untouched by tick()
 *   4. SSE bus receives call.missed for the expired call
 *   5. tick() is idempotent (re-run on already-missed row → no-op)
 */

'use strict';

const test   = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.CALL_SWEEP_TESTS === '1';

if (!RUN) {
  test('callRingSweep integration tests skipped (set CALL_SWEEP_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  require('dotenv').config();
  const db      = require('../../src/config/db');
  const { bus } = require('../../src/services/realtime/eventBus');
  const { tick, RING_TIMEOUT_S } = require('../../src/cron/callRingSweepJob');

  // ── bus collector ─────────────────────────────────────────────────────
  const events = [];
  const onEvent = (e) => { events.push(e); };
  bus.on('event', onEvent);

  function sleep(ms) { return new Promise((r) => { setTimeout(r, ms); }); }
  async function waitFor(fn, { timeout = 3000, interval = 25 } = {}) {
    const deadline = Date.now() + timeout;
    for (;;) {
      const v = await fn(); // eslint-disable-line no-await-in-loop
      if (v) return v;
      if (Date.now() >= deadline) return null;
      await sleep(interval); // eslint-disable-line no-await-in-loop
    }
  }

  const STAMP = `${Date.now()}`;
  const EMAIL = {
    caller: `sweep-caller-${STAMP}@plagit.test`,
    callee: `sweep-callee-${STAMP}@plagit.test`,
  };

  const ctx = { callerId: null, calleeId: null, convId: null };

  async function makeUser(email, type) {
    const [u] = await db('users').insert({
      name: email, email, password_hash: 'test', user_type: type,
    }).returning('id');
    return u.id;
  }

  async function makeConversation(candidateUserId, businessUserId) {
    const [cand] = await db('candidates').insert({ user_id: candidateUserId, name: 'SweepCand' }).returning('id');
    const [biz]  = await db('businesses').insert({ user_id: businessUserId,  name: 'SweepBiz'  }).returning('id');
    const [conv] = await db('conversations').insert({
      candidate_id: cand.id,
      business_id:  biz.id,
    }).returning('id');
    return conv.id;
  }

  async function insertCall({ callerId, calleeId, convId, status = 'ringing', ageSeconds = 0 }) {
    const startedAt = new Date(Date.now() - ageSeconds * 1000).toISOString();
    const [row] = await db('calls').insert({
      conversation_id: convId, caller_id: callerId, callee_id: calleeId,
      type: 'audio', status, started_at: startedAt,
    }).returning('*');
    return row;
  }

  async function cleanup() {
    const users = await db('users').whereIn('email', Object.values(EMAIL)).select('id');
    const ids   = users.map((u) => u.id);
    if (ids.length) {
      await db('calls').where(function () {
        this.whereIn('caller_id', ids).orWhereIn('callee_id', ids);
      }).del();
      await db('notifications').whereIn('recipient_id', ids).del();
      await db('messages').whereIn('sender_id', ids).del();
      await db('conversations').whereIn('candidate_id', function () {
        this.select('id').from('candidates').whereIn('user_id', ids);
      }).del();
      await db('candidates').whereIn('user_id', ids).del();
      await db('businesses').whereIn('user_id', ids).del();
    }
    await db('users').whereIn('email', Object.values(EMAIL)).del();
  }

  // ── setup ─────────────────────────────────────────────────────────────
  test('setup: create throwaway users + conversation', async () => {
    await cleanup();
    ctx.callerId = await makeUser(EMAIL.caller, 'business');
    ctx.calleeId = await makeUser(EMAIL.callee, 'candidate');
    ctx.convId   = await makeConversation(ctx.calleeId, ctx.callerId);
  });

  // ── 1. Stale ringing → missed ─────────────────────────────────────────
  test('stale ringing call is flipped to missed by tick()', async () => {
    const row = await insertCall({
      callerId: ctx.callerId, calleeId: ctx.calleeId, convId: ctx.convId,
      ageSeconds: RING_TIMEOUT_S + 5,
    });
    ctx.staleCallId = row.id;

    await tick({ logger: { log: () => {}, warn: () => {}, error: () => {} } });

    const updated = await db('calls').where({ id: row.id }).first();
    assert.equal(updated.status, 'missed', 'status flipped to missed');
    assert.ok(updated.ended_at, 'ended_at stamped');
  });

  // ── 4. SSE bus receives call.missed ────────────────────────────────────
  test('SSE bus receives call.missed for the expired call', async () => {
    const ev = await waitFor(() => events.find(
      (e) => e.type === 'call.missed'
           && e.payload && e.payload.call && e.payload.call.callId === ctx.staleCallId,
    ));
    assert.ok(ev, 'call.missed SSE event emitted for stale call');
    assert.ok(
      Array.isArray(ev.audience)
        && ev.audience.includes(`user:${ctx.callerId}`)
        && ev.audience.includes(`user:${ctx.calleeId}`),
      'audience includes both participants',
    );
  });

  // ── 2. Fresh ringing → untouched ─────────────────────────────────────
  test('fresh ringing call is NOT touched by tick()', async () => {
    const row = await insertCall({
      callerId: ctx.callerId, calleeId: ctx.calleeId, convId: ctx.convId,
      ageSeconds: 5,
    });
    ctx.freshCallId = row.id;

    await tick({ logger: { log: () => {}, warn: () => {}, error: () => {} } });

    const unchanged = await db('calls').where({ id: row.id }).first();
    assert.equal(unchanged.status, 'ringing', 'fresh call left as ringing');
    await db('calls').where({ id: row.id }).del();
  });

  // ── 3. Accepted / ended calls → untouched ────────────────────────────
  test('non-ringing calls are not touched by tick()', async () => {
    const accepted = await insertCall({
      callerId: ctx.callerId, calleeId: ctx.calleeId, convId: ctx.convId,
      status: 'accepted', ageSeconds: 120,
    });
    const ended = await insertCall({
      callerId: ctx.callerId, calleeId: ctx.calleeId, convId: ctx.convId,
      status: 'ended', ageSeconds: 120,
    });

    await tick({ logger: { log: () => {}, warn: () => {}, error: () => {} } });

    const a = await db('calls').where({ id: accepted.id }).first();
    const e = await db('calls').where({ id: ended.id    }).first();
    assert.equal(a.status, 'accepted', 'accepted call untouched');
    assert.equal(e.status, 'ended',    'ended call untouched');

    await db('calls').whereIn('id', [accepted.id, ended.id]).del();
  });

  // ── 5. Idempotent re-run ──────────────────────────────────────────────
  test('tick() is idempotent (re-run on already-missed row → no-op)', async () => {
    const beforeCount = events.filter(
      (ev) => ev.type === 'call.missed'
            && ev.payload && ev.payload.call && ev.payload.call.callId === ctx.staleCallId,
    ).length;

    await tick({ logger: { log: () => {}, warn: () => {}, error: () => {} } });

    const afterCount = events.filter(
      (ev) => ev.type === 'call.missed'
            && ev.payload && ev.payload.call && ev.payload.call.callId === ctx.staleCallId,
    ).length;

    assert.equal(afterCount, beforeCount, 'no extra missed event emitted on re-run');
  });

  // ── cleanup ───────────────────────────────────────────────────────────
  test('cleanup: remove test rows + close DB pool', async () => {
    bus.removeListener('event', onEvent);
    await cleanup();
    await db.destroy();
  });
}
