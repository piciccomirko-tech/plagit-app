/**
 * Integration tests for missed-call bell notifications (Stage N1-3).
 *
 * Verifies callController._internal.maybeNotifyMissedCall — the helper
 * publishCallEvent invokes on every terminal transition. It self-filters
 * on `missed`, so a missed call persists a bell `notification.new` for the
 * callee (the party who missed it) even if the realtime SSE never arrives.
 *
 * Pattern matches the other integration tests: direct function invocation,
 * no express boot, hermetic throwaway users. Skipped unless
 * CALL_MISSED_TESTS=1.
 *
 * Contract asserted:
 *   1. missed → `notifications` row (route 'call_missed', recipient = callee,
 *      linked_entity = call id)
 *   2. is_read = false
 *   3. unread bell count increases ('call_missed' is NOT bell-excluded)
 *   4. `notification.new` SSE emitted to user:<callee>
 *   5. retry / repeated terminal transition → ZERO duplicates (hiringNotify
 *      dedupe on recipient_id + linked_entity + destination_route)
 *   6. answered/ended (and accepted) → NO call_missed notification
 *
 * Cleans up the notifications + throwaway users it inserts, before and
 * after, so reruns are safe against a local DB.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.CALL_MISSED_TESTS === '1';

if (!RUN) {
  test('call missed notification integration tests skipped (set CALL_MISSED_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  require('dotenv').config();
  const db = require('../../src/config/db');
  const { bus } = require('../../src/services/realtime/eventBus');
  const { _internal } = require('../../src/controllers/callController');
  const { maybeNotifyMissedCall } = _internal;

  const EMAIL_CALLER = 'call-missed-caller@plagit.test';
  const EMAIL_CALLEE = 'call-missed-callee@plagit.test';
  const ALL_EMAILS = [EMAIL_CALLER, EMAIL_CALLEE];

  // ── bus collector + waiting ─────────────────────────────────────────────
  const events = [];
  const onEvent = (e) => { events.push(e); };
  bus.on('event', onEvent);
  function sleep(ms) { return new Promise((r) => { setTimeout(r, ms); }); }
  async function waitFor(fn, { timeout = 3000, interval = 25 } = {}) {
    const deadline = Date.now() + timeout;
    for (;;) {
      // eslint-disable-next-line no-await-in-loop
      const v = await fn();
      if (v) return v;
      if (Date.now() >= deadline) return null;
      // eslint-disable-next-line no-await-in-loop
      await sleep(interval);
    }
  }
  function sseCallMissed(recipientUserId, linkedEntity) {
    return events.find((e) => e.type === 'notification.new'
      && e.payload && e.payload.destination_route === 'call_missed'
      && e.payload.linked_entity === linkedEntity
      && Array.isArray(e.audience) && e.audience.includes(`user:${recipientUserId}`));
  }

  // mirror of candidate/business _excludeChatRoutes: NULL kept, message/group out.
  function countUnreadBell(userId) {
    return db('notifications').where({ recipient_id: userId, is_read: false })
      .where(function () {
        this.whereNull('destination_route').orWhereNotIn('destination_route', ['message', 'group']);
      })
      .count('* as c').first().then((r) => Number(r.c));
  }
  function countCallMissed(userId, linkedEntity) {
    const q = db('notifications').where({ recipient_id: userId, destination_route: 'call_missed' });
    if (linkedEntity) q.where({ linked_entity: linkedEntity });
    return q.count('* as c').first().then((r) => Number(r.c));
  }

  const ctx = { callerId: null, calleeId: null, callId: 'call-missed-test-0001' };

  async function makeUser(email, type) {
    const [u] = await db('users').insert({
      name: email, email, password_hash: 'test-not-a-real-hash', user_type: type,
    }).returning('id');
    return u.id;
  }
  async function cleanup() {
    const users = await db('users').whereIn('email', ALL_EMAILS).select('id');
    const ids = users.map((u) => u.id);
    if (ids.length) await db('notifications').whereIn('recipient_id', ids).del();
    await db('users').whereIn('email', ALL_EMAILS).del();
  }

  // ── setup ───────────────────────────────────────────────────────────────
  test('setup: throwaway caller + callee users', async () => {
    await cleanup();
    ctx.callerId = await makeUser(EMAIL_CALLER, 'business');
    ctx.calleeId = await makeUser(EMAIL_CALLEE, 'candidate');
  });

  // ── 1-4. missed → persisted + is_read false + count up + SSE ─────────────
  test('missed call persists call_missed for the callee, unread, + emits SSE', async () => {
    const before = await countUnreadBell(ctx.calleeId);
    assert.equal(before, 0, 'callee starts with 0 unread bell notifications');

    const identities = { [ctx.callerId]: { name: 'Nobu London' } };
    await maybeNotifyMissedCall(
      { id: ctx.callId, status: 'missed', caller_id: ctx.callerId, callee_id: ctx.calleeId, type: 'audio' },
      identities,
    );

    const notif = await waitFor(() => db('notifications').where({
      recipient_id: ctx.calleeId,
      destination_route: 'call_missed',
      linked_entity: ctx.callId,
    }).first());
    assert.ok(notif, 'call_missed notification persisted');                 // 1
    assert.equal(notif.recipient_id, ctx.calleeId, 'recipient is the callee');
    assert.equal(notif.title, 'Missed call');
    assert.equal(notif.is_read, false, 'is_read=false');                    // 2
    assert.match(notif.body || '', /Missed voice call from Nobu London/);

    const after = await countUnreadBell(ctx.calleeId);
    assert.equal(after, 1, 'unread bell count increased (call_missed is bell-eligible)'); // 3

    assert.ok(sseCallMissed(ctx.calleeId, ctx.callId), 'notification.new SSE → user:callee'); // 4
  });

  // ── 5. retry → no duplicates ─────────────────────────────────────────────
  test('repeated missed transition creates zero duplicates', async () => {
    const identities = { [ctx.callerId]: { name: 'Nobu London' } };
    await maybeNotifyMissedCall(
      { id: ctx.callId, status: 'missed', caller_id: ctx.callerId, callee_id: ctx.calleeId, type: 'audio' },
      identities,
    );
    await sleep(120);
    const c = await countCallMissed(ctx.calleeId, ctx.callId);
    assert.equal(c, 1, 'still exactly one row after retry (dedupe)');
  });

  // ── 6. answered/ended/accepted → no call_missed ──────────────────────────
  test('ended / accepted calls do NOT create a call_missed notification', async () => {
    await maybeNotifyMissedCall(
      { id: 'call-missed-test-ENDED', status: 'ended', caller_id: ctx.callerId, callee_id: ctx.calleeId, type: 'audio' },
      {},
    );
    await maybeNotifyMissedCall(
      { id: 'call-missed-test-ACCEPTED', status: 'accepted', caller_id: ctx.callerId, callee_id: ctx.calleeId, type: 'video' },
      {},
    );
    await sleep(120);
    assert.equal(await countCallMissed(ctx.calleeId, 'call-missed-test-ENDED'), 0, 'ended → none');
    // total call_missed for callee is still just the single missed one from test 1
    assert.equal(await countCallMissed(ctx.calleeId, null), 1, 'no stray call_missed rows from non-missed states');
  });

  // ── cleanup ───────────────────────────────────────────────────────────────
  test('cleanup: remove test rows + throwaway users + close DB pool', async () => {
    await cleanup();
    bus.removeListener('event', onEvent);
    await db.destroy();
  });
}
