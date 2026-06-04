/**
 * Integration tests for chat-request notifications (Stage AL.6.2 / AL.6.5).
 *
 * Verifies the EXISTING wiring in src/controllers/chatRequestsController.js
 * — this file changes NO production code, it only locks the current
 * behaviour with a regression test. Pattern matches
 * tests/integration/adminUsersResetLink.test.js: direct controller
 * invocation with mock req/res/next, no express boot. Skipped
 * automatically unless CHAT_REQUEST_TESTS=1.
 *
 * Contract asserted (candidate Elena → business Nobu, resolved by email
 * from the local seed DB):
 *   1. POST create  → `notifications` row with
 *      destination_route='chat_request_received', recipient = business
 *      user, linked_entity = chat_request id; + a `notification.new`
 *      SSE event on the bus addressed to user:<business>.
 *   2. duplicate POST while pending → 409 CHAT_REQUEST_ALREADY_PENDING,
 *      ZERO extra notification rows.
 *   3. PATCH accept → `notifications` row
 *      destination_route='chat_request_accepted', recipient = candidate
 *      (the requester); + a `notification.new` SSE event to
 *      user:<candidate>.
 *   4. repeated accept (idempotent) → ZERO extra notification rows.
 *   5. duplicate POST after accept (settled-pair bypass) → 200 bypassed,
 *      ZERO extra notification rows.
 *
 * Cleans up the chat_requests + notifications it creates (scoped to the
 * Elena↔Nobu pair, by linked_entity) before and after, so reruns are
 * safe against a local DB.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.CHAT_REQUEST_TESTS === '1';

if (!RUN) {
  test('chatRequest notifications integration tests skipped (set CHAT_REQUEST_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  require('dotenv').config();
  const db = require('../../src/config/db');
  const { bus } = require('../../src/services/realtime/eventBus');
  const {
    createChatRequest,
    respondToChatRequest,
  } = require('../../src/controllers/chatRequestsController');

  // Throwaway pair — created fresh per run so there is NO pre-existing
  // conversation between them. The real seed pair (elena↔nobu) already
  // share a conversation, which makes createChatRequest take the
  // `conversation_exists` bypass and never exercise the notify path.
  const CANDIDATE_EMAIL = 'chatreq-test-candidate@plagit.test';
  const BUSINESS_EMAIL = 'chatreq-test-business@plagit.test';

  // ── mock req/res (same shape as adminUsersResetLink.test.js) ────────────
  function mockReq({ params = {}, body = {}, user, query = {} } = {}) {
    return {
      params,
      body,
      query,
      user,
      ip: '127.0.0.1',
      get: () => null,
    };
  }
  function mockRes() {
    const state = { status: 200, body: null };
    return {
      _state: state,
      status(code) { state.status = code; return this; },
      json(body) { state.body = body; return this; },
    };
  }
  function call(controller, req) {
    const res = mockRes();
    let nextErr = null;
    return Promise.resolve(controller(req, res, (e) => { nextErr = e; }))
      .then(() => ({ res: res._state, err: nextErr }));
  }

  // ── event-based waiting (notify is fire-and-forget) ─────────────────────
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

  // Collect every bus event for the whole lifecycle; removed in cleanup.
  const events = [];
  const onEvent = (e) => { events.push(e); };
  bus.on('event', onEvent);

  function sseFor(route, recipientUserId) {
    return events.find((e) => e.type === 'notification.new'
      && e.payload
      && e.payload.destination_route === route
      && Array.isArray(e.audience)
      && e.audience.includes(`user:${recipientUserId}`));
  }
  function countNotifs(recipientUserId, route, linkedEntity) {
    return db('notifications')
      .where({ recipient_id: recipientUserId, destination_route: route, linked_entity: linkedEntity })
      .count('* as c').first().then((r) => Number(r.c));
  }

  // Shared lifecycle state — resolved in setup, reused across the run.
  const ctx = {
    candUserId: null,
    candId: null,
    bizUserId: null,
    bizId: null,
    chatRequestId: null,
  };

  async function cleanupPair() {
    if (!ctx.candId || !ctx.bizId) return;
    const rows = await db('chat_requests')
      .where({ candidate_id: ctx.candId, business_id: ctx.bizId })
      .select('id');
    const ids = rows.map((r) => r.id);
    if (ids.length) {
      // Removes both the user-facing notifications AND the admin audit
      // rows — all carry the chat_request id as linked_entity.
      await db('notifications').whereIn('linked_entity', ids).del();
    }
    await db('chat_requests')
      .where({ candidate_id: ctx.candId, business_id: ctx.bizId })
      .del();
    // accept() find-or-creates a conversation — drop it too.
    await db('conversations')
      .where({ candidate_id: ctx.candId, business_id: ctx.bizId })
      .del();
  }

  async function destroyThrowawayUsers() {
    // ON DELETE CASCADE on candidates.user_id / businesses.user_id drops
    // the profile rows with the user.
    await db('users').whereIn('email', [CANDIDATE_EMAIL, BUSINESS_EMAIL]).del();
  }

  // ── setup ───────────────────────────────────────────────────────────────
  test('setup: create isolated throwaway candidate + business (no prior conversation)', async () => {
    // Drop leftovers from any prior crashed run (cascade clears profiles).
    await destroyThrowawayUsers();

    const [candUser] = await db('users').insert({
      name: 'ChatReq Test Candidate',
      email: CANDIDATE_EMAIL,
      password_hash: 'test-not-a-real-hash',
      user_type: 'candidate',
    }).returning('id');
    const [bizUser] = await db('users').insert({
      name: 'ChatReq Test Business',
      email: BUSINESS_EMAIL,
      password_hash: 'test-not-a-real-hash',
      user_type: 'business',
    }).returning('id');
    const [cand] = await db('candidates')
      .insert({ user_id: candUser.id, name: 'ChatReq Test Candidate' }).returning('id');
    const [biz] = await db('businesses')
      .insert({ user_id: bizUser.id, name: 'ChatReq Test Business' }).returning('id');

    ctx.candUserId = candUser.id;
    ctx.candId = cand.id;
    ctx.bizUserId = bizUser.id;
    ctx.bizId = biz.id;

    // No conversation row exists for this brand-new pair → the
    // createChatRequest gate is exercised (not bypassed).
    const conv = await db('conversations')
      .where({ candidate_id: ctx.candId, business_id: ctx.bizId }).first();
    assert.equal(conv, undefined, 'fresh pair must have no pre-existing conversation');
  });

  // ── 1. create → chat_request_received notification + SSE ─────────────────
  test('create (candidate → business) persists chat_request_received + emits SSE', async () => {
    const { res, err } = await call(createChatRequest, mockReq({
      user: { id: ctx.candUserId, role: 'candidate' },
      body: { business_id: ctx.bizId, message: 'Hi, are you hiring?' },
    }));

    assert.equal(err, null, err && err.message);
    assert.equal(res.status, 201, 'create returns 201');
    assert.equal(res.body.success, true);
    assert.ok(res.body.data && res.body.data.id, 'response carries the chat_request id');
    assert.equal(res.body.data.status, 'pending');
    ctx.chatRequestId = res.body.data.id;

    // notify is fire-and-forget (fires after res.json) → poll for the row.
    const notif = await waitFor(() => db('notifications').where({
      recipient_id: ctx.bizUserId,
      destination_route: 'chat_request_received',
      linked_entity: ctx.chatRequestId,
    }).first());

    assert.ok(notif, 'chat_request_received notification persisted for the business');
    assert.equal(notif.recipient_id, ctx.bizUserId, 'recipient is the business user');
    assert.equal(notif.title, 'New chat request');
    assert.equal(notif.is_read, false);
    assert.match(notif.body || '', /wants to chat with you/);

    const evt = sseFor('chat_request_received', ctx.bizUserId);
    assert.ok(evt, 'notification.new SSE event emitted to user:<business>');
    assert.equal(evt.payload.linked_entity, ctx.chatRequestId);
    assert.equal(evt.payload.destination_route, 'chat_request_received');
  });

  // ── 2. duplicate POST while pending → 409, no extra notification ─────────
  test('duplicate POST while pending → 409 and zero extra notifications', async () => {
    const before = await countNotifs(ctx.bizUserId, 'chat_request_received', ctx.chatRequestId);
    assert.equal(before, 1, 'exactly one received-notification before the duplicate');

    const { err } = await call(createChatRequest, mockReq({
      user: { id: ctx.candUserId, role: 'candidate' },
      body: { business_id: ctx.bizId },
    }));

    assert.ok(err, 'duplicate-pending POST is rejected');
    assert.equal(err.status, 409);
    assert.equal(err.code, 'CHAT_REQUEST_ALREADY_PENDING');

    const after = await countNotifs(ctx.bizUserId, 'chat_request_received', ctx.chatRequestId);
    assert.equal(after, 1, 'duplicate POST created NO extra notification');
  });

  // ── 3. accept → chat_request_accepted notification + SSE ─────────────────
  test('accept (business) persists chat_request_accepted for the requester + emits SSE', async () => {
    const { res, err } = await call(respondToChatRequest, mockReq({
      user: { id: ctx.bizUserId, role: 'business' },
      params: { id: ctx.chatRequestId },
      body: { action: 'accept' },
    }));

    assert.equal(err, null, err && err.message);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.status, 'accepted');
    assert.ok(res.body.data.conversation_id, 'accept created/reused a conversation');

    const notif = await waitFor(() => db('notifications').where({
      recipient_id: ctx.candUserId,
      destination_route: 'chat_request_accepted',
      linked_entity: ctx.chatRequestId,
    }).first());

    assert.ok(notif, 'chat_request_accepted notification persisted for the requester (candidate)');
    assert.equal(notif.recipient_id, ctx.candUserId, 'recipient is the candidate (requester)');
    assert.equal(notif.title, 'Chat request accepted');
    assert.match(notif.body || '', /accepted your chat request/);

    const evt = sseFor('chat_request_accepted', ctx.candUserId);
    assert.ok(evt, 'notification.new SSE event emitted to user:<candidate>');
    assert.equal(evt.payload.linked_entity, ctx.chatRequestId);
  });

  // ── 4. repeated accept → idempotent, no extra notification ───────────────
  test('repeated accept is idempotent and creates zero extra notifications', async () => {
    const before = await countNotifs(ctx.candUserId, 'chat_request_accepted', ctx.chatRequestId);
    assert.equal(before, 1, 'exactly one accepted-notification before the retry');

    const { res, err } = await call(respondToChatRequest, mockReq({
      user: { id: ctx.bizUserId, role: 'business' },
      params: { id: ctx.chatRequestId },
      body: { action: 'accept' },
    }));

    assert.equal(err, null, err && err.message);
    assert.equal(res.body.data.status, 'accepted');

    await sleep(150); // give any (would-be) fire-and-forget notify time to land
    const after = await countNotifs(ctx.candUserId, 'chat_request_accepted', ctx.chatRequestId);
    assert.equal(after, 1, 'repeated accept created NO extra notification');
  });

  // ── 5. duplicate POST after accept → bypass, no extra notification ───────
  test('duplicate POST after accept bypasses and creates zero extra notifications', async () => {
    const beforeRecv = await countNotifs(ctx.bizUserId, 'chat_request_received', ctx.chatRequestId);

    const { res, err } = await call(createChatRequest, mockReq({
      user: { id: ctx.candUserId, role: 'candidate' },
      body: { business_id: ctx.bizId },
    }));

    assert.equal(err, null, err && err.message);
    assert.equal(res.status, 200, 'settled pair bypasses with 200 (not 201)');
    assert.equal(res.body.data.status, 'accepted');
    assert.equal(res.body.data.bypassed, true);

    await sleep(150);
    const afterRecv = await countNotifs(ctx.bizUserId, 'chat_request_received', ctx.chatRequestId);
    assert.equal(afterRecv, beforeRecv, 'bypassed POST created NO extra notification');
  });

  // ── cleanup ───────────────────────────────────────────────────────────────
  test('cleanup: remove test rows + throwaway users + close DB pool', async () => {
    await cleanupPair();
    await destroyThrowawayUsers();
    bus.removeListener('event', onEvent);
    await db.destroy();
  });
}
