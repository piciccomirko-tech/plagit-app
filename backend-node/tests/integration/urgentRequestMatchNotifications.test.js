/**
 * Integration tests for candidate-side urgent-request match notifications
 * (Stage N1-1). Covers the NEW src/services/urgentMatching.js fan-out and
 * its wiring into businessController.createUrgentRequest.
 *
 * Pattern matches tests/integration/urgentRequestNotifications.test.js:
 * direct service/controller invocation with mock req/res, no express
 * boot, hermetic throwaway users. Skipped unless URGENT_MATCH_TESTS=1.
 *
 * Contract asserted:
 *   1. Matcher selects only compatible candidates: role match + live
 *      availability + active user + within each candidate's radius; and
 *      enforces the per-request cap (25 geo / 10 fallback; overridable).
 *   2. Fan-out persists `urgent_request_match` (recipient = candidate
 *      user, linked_entity = urgent_request id) + emits `notification.new`
 *      SSE to user:<candidate>, and SKIPS candidates already at the
 *      per-candidate/day cap (5 / UTC day).
 *   3. Retry of the fan-out on the same urgent → ZERO duplicate rows
 *      (hiringNotify dedupe).
 *   4. createUrgentRequest triggers the fan-out end-to-end.
 *
 * Cleans up everything it inserts (urgent_requests, conversations,
 * notifications by linked_entity + recipient, throwaway users via
 * CASCADE) before and after, so reruns are safe against a local DB.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.URGENT_MATCH_TESTS === '1';

if (!RUN) {
  test('urgentRequestMatch notifications integration tests skipped (set URGENT_MATCH_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  require('dotenv').config();
  const db = require('../../src/config/db');
  const { bus } = require('../../src/services/realtime/eventBus');
  const urgentMatching = require('../../src/services/urgentMatching');
  const { createUrgentRequest, hiringNotify } = require('../../src/controllers/businessController');

  // London anchor for the urgent + near candidates; Edinburgh for the far one.
  const NEAR = { lat: 51.5074, lng: -0.1278 };
  const FAR = { lat: 55.9533, lng: -3.1883 }; // ~530 km away
  // Gibberish roles so the matcher (which scans the WHOLE candidates table)
  // cannot pick up real seed candidates. NOTE the matcher rule is
  // "urgent.role CONTAINS candidate.role", so the token must not embed any
  // real role substring (e.g. 'waiter'/'chef') — hence pure consonant soup.
  // No '_' / '%' so ILIKE has no wildcard surprises.
  const TEST_ROLE = 'zxqvkjwmqp';
  const WRONG_ROLE = 'wbnmflhgtr';
  const EMAIL_DOMAIN = '@plagit.test';
  const ALL_EMAILS = [
    'urgent-match-business', 'urgent-match-c1', 'urgent-match-c2', 'urgent-match-c3',
    'urgent-match-wrong', 'urgent-match-noavail', 'urgent-match-far', 'urgent-match-capped',
  ].map((s) => s + EMAIL_DOMAIN);

  // ── mock req/res ────────────────────────────────────────────────────────
  function mockReq({ params = {}, body = {}, user, query = {} } = {}) {
    return { params, body, query, user, ip: '127.0.0.1', get: () => null };
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

  // ── event-based waiting ─────────────────────────────────────────────────
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

  const events = [];
  const onEvent = (e) => { events.push(e); };
  bus.on('event', onEvent);
  function sseFor(recipientUserId, linkedEntity) {
    return events.find((e) => e.type === 'notification.new'
      && e.payload && e.payload.destination_route === 'urgent_request_match'
      && e.payload.linked_entity === linkedEntity
      && Array.isArray(e.audience) && e.audience.includes(`user:${recipientUserId}`));
  }
  function countMatch(recipientUserId, linkedEntity) {
    return db('notifications').where({
      recipient_id: recipientUserId,
      destination_route: 'urgent_request_match',
      linked_entity: linkedEntity,
    }).count('* as c').first().then((r) => Number(r.c));
  }

  // ── fixtures ──────────────────────────────────────────────────────────────
  const ctx = { bizUserId: null, bizId: null, urgentId: null, c: {} };

  async function makeUser(email, userType, { lat = null, lng = null } = {}) {
    const [u] = await db('users').insert({
      name: email,
      email,
      password_hash: 'test-not-a-real-hash',
      user_type: userType,
      latitude: lat,
      longitude: lng,
    }).returning('id');
    return u.id;
  }
  async function makeCandidate(key, email, {
    role = TEST_ROLE, primaryRole = TEST_ROLE, availability = 'now',
    lat = NEAR.lat, lng = NEAR.lng, radiusKm = null,
  } = {}) {
    const userId = await makeUser(email, 'candidate', { lat, lng });
    const [c] = await db('candidates').insert({
      user_id: userId,
      name: email,
      role,
      primary_role: primaryRole,
      availability_state: availability,
      availability_until: null,
      preferred_area_radius_km: radiusKm,
    }).returning('id');
    ctx.c[key] = { userId, candidateId: c.id };
  }

  async function cleanupAll() {
    const users = await db('users').whereIn('email', ALL_EMAILS).select('id');
    const userIds = users.map((u) => u.id);
    const urgents = ctx.bizId
      ? await db('urgent_requests').where({ business_id: ctx.bizId }).select('id')
      : [];
    const urgentIds = urgents.map((u) => u.id);
    if (urgentIds.length) await db('notifications').whereIn('linked_entity', urgentIds).del();
    if (userIds.length) await db('notifications').whereIn('recipient_id', userIds).del();
    if (ctx.bizId) {
      await db('urgent_requests').where({ business_id: ctx.bizId }).del();
      await db('conversations').where({ business_id: ctx.bizId }).del();
    }
    await db('users').whereIn('email', ALL_EMAILS).del();
  }

  // ── setup ───────────────────────────────────────────────────────────────
  test('setup: business + open urgent_request + a spread of candidates', async () => {
    await cleanupAll(); // clear leftovers from a prior crashed run

    ctx.bizUserId = await makeUser('urgent-match-business' + EMAIL_DOMAIN, 'business', NEAR);
    const [biz] = await db('businesses')
      .insert({ user_id: ctx.bizUserId, name: 'Urgent Match Venue', location: 'London' })
      .returning('id');
    ctx.bizId = biz.id;

    // 4 valid near matches (one of them will be pushed over the daily cap)
    await makeCandidate('m1', 'urgent-match-c1' + EMAIL_DOMAIN, {});
    await makeCandidate('m2', 'urgent-match-c2' + EMAIL_DOMAIN, {});
    await makeCandidate('m3', 'urgent-match-c3' + EMAIL_DOMAIN, {});
    await makeCandidate('capped', 'urgent-match-capped' + EMAIL_DOMAIN, {});
    // non-matches
    await makeCandidate('wrong', 'urgent-match-wrong' + EMAIL_DOMAIN, { role: WRONG_ROLE, primaryRole: WRONG_ROLE });
    await makeCandidate('noavail', 'urgent-match-noavail' + EMAIL_DOMAIN, { availability: null });
    await makeCandidate('far', 'urgent-match-far' + EMAIL_DOMAIN, { lat: FAR.lat, lng: FAR.lng, radiusKm: 10 });

    const startsAt = new Date(Date.now() + 2 * 60 * 60 * 1000); // +2h → within 'now' window
    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
    const [ur] = await db('urgent_requests').insert({
      business_id: ctx.bizId,
      role: TEST_ROLE,
      location: 'London',
      latitude: NEAR.lat,
      longitude: NEAR.lng,
      starts_at: startsAt.toISOString(),
      expires_at: expiresAt.toISOString(),
      status: 'open',
    }).returning('id');
    ctx.urgentId = ur.id;
    assert.ok(ctx.urgentId, 'open urgent_request created');
  });

  // ── 1. matcher: filters + per-request cap ────────────────────────────────
  test('matcher selects only compatible candidates and honours the per-request cap', async () => {
    const ur = await db('urgent_requests').where({ id: ctx.urgentId }).first();

    const all = await urgentMatching.findMatchingCandidatesForUrgentRequest(ur, { capGeo: 100 });
    const ids = new Set(all.map((m) => m.userId));

    // the 4 valid near matches are present...
    assert.ok(ids.has(ctx.c.m1.userId), 'near waiter m1 matched');
    assert.ok(ids.has(ctx.c.m2.userId), 'near waiter m2 matched');
    assert.ok(ids.has(ctx.c.m3.userId), 'near waiter m3 matched');
    assert.ok(ids.has(ctx.c.capped.userId), 'near waiter capped matched (daily cap is applied later)');
    // ...and the non-matches are excluded
    assert.equal(ids.has(ctx.c.wrong.userId), false, 'wrong role excluded');
    assert.equal(ids.has(ctx.c.noavail.userId), false, 'no-availability excluded');
    assert.equal(ids.has(ctx.c.far.userId), false, 'out-of-radius excluded');
    assert.equal(all.length, 4, 'exactly the 4 valid near matches');

    // per-request cap truncates to the top N
    const capped = await urgentMatching.findMatchingCandidatesForUrgentRequest(ur, { capGeo: 2 });
    assert.equal(capped.length, 2, 'per-request cap (2) truncates the match set');
  });

  // ── 2. fan-out: notify + SSE + per-candidate/day cap ─────────────────────
  test('fan-out persists urgent_request_match + SSE, and skips daily-capped candidates', async () => {
    // Push `capped` to the daily limit (5 urgent_request_match rows today).
    for (let i = 0; i < 5; i += 1) {
      // eslint-disable-next-line no-await-in-loop
      await db('notifications').insert({
        recipient_id: ctx.c.capped.userId,
        notification_type: 'in_app',
        title: 'seed urgent match',
        linked_entity: `seed-cap-${i}`,
        destination_route: 'urgent_request_match',
        delivery_state: 'delivered',
        is_read: false,
      });
    }

    const ur = await db('urgent_requests').where({ id: ctx.urgentId }).first();
    const result = await urgentMatching.notifyMatchingCandidatesForUrgentRequest(
      ur, hiringNotify, { capGeo: 100, businessName: 'Urgent Match Venue' },
    );
    assert.equal(result.matched, 4, 'matched the 4 near candidates');
    assert.equal(result.notified, 3, 'notified 3 (daily-capped one skipped)');

    for (const key of ['m1', 'm2', 'm3']) {
      const uid = ctx.c[key].userId;
      // eslint-disable-next-line no-await-in-loop
      const notif = await waitFor(() => db('notifications').where({
        recipient_id: uid,
        destination_route: 'urgent_request_match',
        linked_entity: ctx.urgentId,
      }).first());
      assert.ok(notif, `${key} received urgent_request_match`);
      assert.equal(notif.title, 'Urgent shift available');
      assert.match(notif.body || '', new RegExp(`needs a ${TEST_ROLE} now`));
      assert.ok(sseFor(uid, ctx.urgentId), `${key} got notification.new SSE`);
    }

    // daily-capped + non-matches got NOTHING for this urgent
    for (const key of ['capped', 'wrong', 'noavail', 'far']) {
      // eslint-disable-next-line no-await-in-loop
      const c = await countMatch(ctx.c[key].userId, ctx.urgentId);
      assert.equal(c, 0, `${key} not notified for this urgent`);
    }
  });

  // ── 3. retry → no duplicate rows ─────────────────────────────────────────
  test('repeated fan-out on the same urgent creates zero duplicates', async () => {
    const before = await countMatch(ctx.c.m1.userId, ctx.urgentId);
    assert.equal(before, 1, 'one row before retry');

    const ur = await db('urgent_requests').where({ id: ctx.urgentId }).first();
    await urgentMatching.notifyMatchingCandidatesForUrgentRequest(
      ur, hiringNotify, { capGeo: 100, businessName: 'Urgent Match Venue' },
    );

    await sleep(150);
    const after = await countMatch(ctx.c.m1.userId, ctx.urgentId);
    assert.equal(after, 1, 'retry created NO duplicate notification (dedupe)');
  });

  // ── 4. controller wiring: createUrgentRequest triggers the fan-out ───────
  test('createUrgentRequest fans out to a matching candidate end-to-end', async () => {
    const startsAt = new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString();
    const { res, err } = await call(createUrgentRequest, mockReq({
      user: { id: ctx.bizUserId, role: 'business' },
      body: {
        role: TEST_ROLE, starts_at: startsAt, location: 'London',
        latitude: NEAR.lat, longitude: NEAR.lng,
      },
    }));

    assert.equal(err, null, err && err.message);
    assert.equal(res.status, 201);
    const newUrgentId = res.body.data.id;
    assert.ok(newUrgentId && newUrgentId !== ctx.urgentId, 'a new urgent_request was created');

    const notif = await waitFor(() => db('notifications').where({
      recipient_id: ctx.c.m1.userId,
      destination_route: 'urgent_request_match',
      linked_entity: newUrgentId,
    }).first());
    assert.ok(notif, 'm1 notified for the controller-created urgent (wiring works)');
  });

  // ── cleanup ───────────────────────────────────────────────────────────────
  test('cleanup: remove test rows + throwaway users + close DB pool', async () => {
    await cleanupAll();
    bus.removeListener('event', onEvent);
    await db.destroy();
  });
}
