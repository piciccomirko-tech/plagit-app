/**
 * Integration tests for the push admin filter (Stage N5.1).
 *
 * Verifies subscriber._internal.resolvePushRecipients — the policy that
 * decides which user ids receive a REAL push for a bus event:
 *   PUSH_TYPES gate → admin-only-route denylist → audience user ids →
 *   drop admin recipients → drop the message sender.
 *
 * Closes the N5.5 finding: admin-only audit notifications were reaching
 * admins that had a (stale) device token, because the audience also
 * carries a `user:<adminId>` token and only the `role:admin` token was
 * skipped.
 *
 * Pure-ish: no bus, no FCM sender, just DB-backed user_type lookups.
 * Skipped unless PUSH_ADMIN_TESTS=1.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.PUSH_ADMIN_TESTS === '1';

if (!RUN) {
  test('push admin filter tests skipped (set PUSH_ADMIN_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  require('dotenv').config({ quiet: true });
  const db = require('../../src/config/db');
  const { _internal } = require('../../src/services/push/subscriber');
  const { resolvePushRecipients } = _internal;

  const EMAILS = [
    'pushf-admin@plagit.test',
    'pushf-cand@plagit.test',
    'pushf-biz@plagit.test',
  ];
  const ctx = { admin: null, cand: null, biz: null };

  function notif(route, audience) {
    return { type: 'notification.new', payload: { destination_route: route }, audience };
  }
  async function makeUser(email, type) {
    const [u] = await db('users').insert({
      name: email, email, password_hash: 'test-not-a-real-hash', user_type: type,
    }).returning('id');
    return u.id;
  }
  async function cleanup() {
    const us = await db('users').whereIn('email', EMAILS).select('id');
    const ids = us.map((u) => u.id);
    if (ids.length) await db('device_tokens').whereIn('user_id', ids).del();
    await db('users').whereIn('email', EMAILS).del();
  }

  // ── setup ───────────────────────────────────────────────────────────────
  test('setup: throwaway admin + candidate + business (admin gets a stale token)', async () => {
    await cleanup();
    ctx.admin = await makeUser(EMAILS[0], 'admin');
    ctx.cand = await makeUser(EMAILS[1], 'candidate');
    ctx.biz = await makeUser(EMAILS[2], 'business');
    // A leftover admin device token must NOT cause a push (this is the bug).
    await db('device_tokens').insert({ user_id: ctx.admin, token: 'dev-pushf-admin', platform: 'ios' });
  });

  // 1. admin-only audit route → no push at all
  test('urgent_request_created (admin-only) → no push recipients', async () => {
    const r = await resolvePushRecipients(notif('urgent_request_created', ['role:admin', `user:${ctx.admin}`]));
    assert.deepEqual(r, []);
  });
  test('chat_request_audit_created (admin-only) → no push recipients', async () => {
    const r = await resolvePushRecipients(notif('chat_request_audit_created', [`user:${ctx.admin}`]));
    assert.deepEqual(r, []);
  });

  // 3. urgent_request_match → candidate still pushes, admin in audience dropped
  test('urgent_request_match → candidate kept, admin dropped', async () => {
    const r = await resolvePushRecipients(
      notif('urgent_request_match', ['role:admin', `user:${ctx.cand}`, `user:${ctx.admin}`]),
    );
    assert.deepEqual(r, [ctx.cand]);
  });

  // 4. urgent_request_accepted → business still pushes, admin-audit dropped
  test('urgent_request_accepted → business kept, admin dropped', async () => {
    const r = await resolvePushRecipients(
      notif('urgent_request_accepted', [`user:${ctx.biz}`, `user:${ctx.admin}`]),
    );
    assert.deepEqual(r, [ctx.biz]);
  });

  // 5. call_missed → recipient still pushes
  test('call_missed → recipient kept', async () => {
    const r = await resolvePushRecipients(notif('call_missed', [`user:${ctx.cand}`]));
    assert.deepEqual(r, [ctx.cand]);
  });

  // 6. message.new → sender suppressed, recipient kept
  test('message.new → sender suppressed, recipient kept', async () => {
    const r = await resolvePushRecipients({
      type: 'message.new',
      payload: { sender_user_id: ctx.cand },
      audience: [`user:${ctx.cand}`, `user:${ctx.biz}`],
    });
    assert.deepEqual(r, [ctx.biz]);
  });

  // 7. admin with a device token is STILL excluded (no crash)
  test('admin with a stale device token is still excluded (no crash)', async () => {
    const r = await resolvePushRecipients(
      notif('urgent_request_match', [`user:${ctx.admin}`, `user:${ctx.cand}`]),
    );
    assert.deepEqual(r, [ctx.cand]);
    assert.equal(r.includes(ctx.admin), false, 'admin never in push recipients');
  });

  // non-push event type → nothing
  test('non-push event type (chat.typing) → no recipients', async () => {
    const r = await resolvePushRecipients({ type: 'chat.typing', payload: {}, audience: [`user:${ctx.cand}`] });
    assert.deepEqual(r, []);
  });

  // ── cleanup ───────────────────────────────────────────────────────────────
  test('cleanup: remove throwaway users + close DB pool', async () => {
    await cleanup();
    await db.destroy();
  });
}
