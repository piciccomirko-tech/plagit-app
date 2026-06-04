/**
 * Integration tests for GET /v1/business/notifications/count (Stage N1-2).
 *
 * Verifies the new businessController.notificationsUnreadCount — symmetric
 * to candidateController.candidateUnreadCount. Pattern matches the other
 * integration tests: direct controller invocation with mock req/res, no
 * express boot, hermetic throwaway users. Skipped unless
 * BUSINESS_NOTIF_COUNT_TESTS=1.
 *
 * Contract asserted:
 *   1. business with 0 unread → { count: 0 }
 *   2. business with a mix → counts only UNREAD, non-chat-route rows
 *      (NULL route kept; 'message'/'group' excluded — the bell rule)
 *   3. read notifications are NOT counted
 *   5. recipient_id isolation: business A's count excludes business B's rows
 *   4. (see note) the platform applies NO per-endpoint role guard — every
 *      business route is `authenticate`-only and scoped by recipient_id.
 *      A candidate token therefore reaches the controller but only ever
 *      sees its OWN count, never a business's rows (no cross-user leak).
 *   6. unauthenticated request → 401 (the `authenticate` middleware that
 *      guards the whole business router).
 *
 * Cleans up the notifications + throwaway users it inserts, before and
 * after, so reruns are safe against a local DB.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.BUSINESS_NOTIF_COUNT_TESTS === '1';

if (!RUN) {
  test('business notifications count integration tests skipped (set BUSINESS_NOTIF_COUNT_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  require('dotenv').config();
  const db = require('../../src/config/db');
  const { notificationsUnreadCount } = require('../../src/controllers/businessController');
  const { authenticate } = require('../../src/middleware/auth');

  const EMAIL_A = 'biz-count-a@plagit.test';
  const EMAIL_B = 'biz-count-b@plagit.test';
  const EMAIL_CAND = 'biz-count-cand@plagit.test';
  const EMAIL_ZERO = 'biz-count-zero@plagit.test';
  const ALL_EMAILS = [EMAIL_A, EMAIL_B, EMAIL_CAND, EMAIL_ZERO];

  function mockReq({ user, headers = {} } = {}) {
    return { user, headers, query: {}, get: () => null };
  }
  function mockRes() {
    const state = { status: 200, body: null };
    return {
      _state: state,
      status(code) { state.status = code; return this; },
      json(body) { state.body = body; return this; },
    };
  }
  async function callCount(userId) {
    const res = mockRes();
    let err = null;
    await notificationsUnreadCount(mockReq({ user: { id: userId } }), res, (e) => { err = e; });
    return { res: res._state, err };
  }

  const ctx = { aId: null, bId: null, candId: null, zeroId: null };

  async function makeUser(email, userType) {
    const [u] = await db('users').insert({
      name: email, email, password_hash: 'test-not-a-real-hash', user_type: userType,
    }).returning('id');
    return u.id;
  }
  async function seedNotif(userId, { route = null, read = false } = {}) {
    await db('notifications').insert({
      recipient_id: userId,
      notification_type: 'in_app',
      title: 'seed',
      destination_route: route,
      is_read: read,
      delivery_state: 'delivered',
    });
  }
  async function cleanup() {
    const users = await db('users').whereIn('email', ALL_EMAILS).select('id');
    const ids = users.map((u) => u.id);
    if (ids.length) await db('notifications').whereIn('recipient_id', ids).del();
    await db('users').whereIn('email', ALL_EMAILS).del();
  }

  // ── setup ───────────────────────────────────────────────────────────────
  test('setup: throwaway business A, business B, candidate + seeded notifications', async () => {
    await cleanup();
    ctx.aId = await makeUser(EMAIL_A, 'business');
    ctx.bId = await makeUser(EMAIL_B, 'business');
    ctx.candId = await makeUser(EMAIL_CAND, 'candidate');
    ctx.zeroId = await makeUser(EMAIL_ZERO, 'business'); // a business with no notifications at all

    // Business A: 3 should count (2 bell routes + 1 NULL route), 3 should NOT
    // (1 read + 1 'message' + 1 'group').
    await seedNotif(ctx.aId, { route: 'job' });
    await seedNotif(ctx.aId, { route: 'interview' });
    await seedNotif(ctx.aId, { route: null });
    await seedNotif(ctx.aId, { route: 'job', read: true }); // read → excluded
    await seedNotif(ctx.aId, { route: 'message' });          // chat route → excluded
    await seedNotif(ctx.aId, { route: 'group' });            // chat route → excluded

    // Business B: 5 unread bell rows — must NOT leak into A's count.
    for (let i = 0; i < 5; i += 1) {
      // eslint-disable-next-line no-await-in-loop
      await seedNotif(ctx.bId, { route: 'job' });
    }

    // Candidate: 1 unread bell row.
    await seedNotif(ctx.candId, { route: 'application' });
  });

  // ── 1. zero unread → count 0 ─────────────────────────────────────────────
  test('business with 0 unread → count 0', async () => {
    const { res, err } = await callCount(ctx.zeroId);
    assert.equal(err, null, err && err.message);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.count, 0, 'business with no notifications reports 0');
  });

  // ── 2 + 3. correct count: only unread, non-chat-route rows ───────────────
  test('business with a mix → counts only unread non-chat rows (read + message/group excluded)', async () => {
    const { res, err } = await callCount(ctx.aId);
    assert.equal(err, null, err && err.message);
    assert.equal(res.body.data.count, 3, '2 bell routes + 1 NULL; read + message + group excluded');
  });

  // ── 5. recipient_id isolation: A excludes B ──────────────────────────────
  test('business A count excludes business B rows (recipient_id isolation)', async () => {
    const a = await callCount(ctx.aId);
    const b = await callCount(ctx.bId);
    assert.equal(a.res.body.data.count, 3, 'A unaffected by B');
    assert.equal(b.res.body.data.count, 5, 'B sees only its own');
  });

  // ── 4. no role guard — candidate token sees only its OWN count (no leak) ─
  test('candidate token reaches the controller but sees only its own count', async () => {
    const { res, err } = await callCount(ctx.candId);
    assert.equal(err, null, err && err.message);
    // Candidate gets its own 1 unread row — NOT business A's 3 or B's 5.
    assert.equal(res.body.data.count, 1, 'candidate sees only its own notifications, no business leak');
  });

  // ── 6. unauthenticated → 401 (the authenticate guard on the business router)
  test('unauthenticated request → 401', () => {
    const res = mockRes();
    let nexted = false;
    authenticate(mockReq({ headers: {} }), res, () => { nexted = true; });
    assert.equal(res._state.status, 401, 'no Bearer token → 401');
    assert.equal(nexted, false, 'next() not called when unauthenticated');
  });

  // ── cleanup ───────────────────────────────────────────────────────────────
  test('cleanup: remove test rows + throwaway users + close DB pool', async () => {
    await cleanup();
    await db.destroy();
  });
}
