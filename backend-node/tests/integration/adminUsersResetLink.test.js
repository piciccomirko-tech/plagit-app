/**
 * Integration tests for POST /v1/admin/users/:id/send-reset-link
 *
 * Pattern matches tests/integration/boostLoop.test.js — direct
 * controller invocation with mock req/res, no express boot. Skipped
 * automatically unless ADMIN_AUDIT_TESTS=1.
 *
 * Asserts the security contract from the controller header:
 *   - response NEVER contains token/code/expiry
 *   - password_reset_tokens row created with 1h expiry, used=false
 *   - admin_audit_log row written with action=password_reset_link_sent,
 *     correct admin_user_id/target_user_id, ip_address, user_agent
 *   - 404 when target user does not exist
 *   - rate limit (4th active token) returns AppError + audit row
 *     result='failed' with metadata.error='rate_limited'
 *
 * Cleans up everything it inserts in finally blocks so reruns are safe.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.ADMIN_AUDIT_TESTS === '1';

if (!RUN) {
  test('adminUsers sendResetLink integration tests skipped (set ADMIN_AUDIT_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const crypto = require('crypto');
  const db = require('../../src/config/db');
  const { sendResetLink } = require('../../src/controllers/adminUsersController');

  // Same seeded users as adminAuditService.test.js — both must exist
  // in the local plagit DB.
  const ADMIN_ID = '20d5cc45-b3c0-4332-a4a9-cc4bdb822033';   // mirko@plagit.com
  const TARGET_ID = '782c0cd7-d7be-4446-b142-0f2dc295035e';  // elena@email.com

  // ── helpers ────────────────────────────────────────────────────────────
  function mockReq({ params = {}, body = {}, user, ip = '127.0.0.1', ua = 'node-test' } = {}) {
    return {
      params,
      body,
      user,
      ip,
      get: (h) => (h && h.toLowerCase() === 'user-agent' ? ua : null),
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
  function callSend(req) {
    const res = mockRes();
    let nextErr = null;
    return sendResetLink(req, res, (e) => { nextErr = e; })
      .then(() => ({ res: res._state, err: nextErr }));
  }
  async function clearAdminTokensFor(userId) {
    await db('password_reset_tokens').where({ user_id: userId }).del();
  }
  async function clearAuditFor(targetId) {
    await db('admin_audit_log').where({ target_user_id: targetId }).del();
  }

  // ── tests ──────────────────────────────────────────────────────────────

  test('integration: success path writes token + audit, response has no token/code', async () => {
    await clearAdminTokensFor(TARGET_ID);
    await clearAuditFor(TARGET_ID);

    const before = Date.now();
    const { res, err } = await callSend(mockReq({
      params: { id: TARGET_ID },
      body: { reason: 'integration test — safe to delete' },
      user: { id: ADMIN_ID, role: 'admin', admin_role: 'super_admin' },
      ip: '203.0.113.7',
      ua: 'PlagitTest/sendResetLink',
    }));
    const after = Date.now();

    try {
      assert.equal(err, null, err && err.message);
      assert.equal(res.status, 200);
      assert.equal(res.body.success, true);

      const tokens = await db('password_reset_tokens').where({ user_id: TARGET_ID });
      assert.equal(tokens.length, 1, 'one reset token row inserted');
      const t = tokens[0];

      // Security contract: the actual code, token_hash, and expiry MUST
      // NOT appear in the response body, in any field. The generic
      // message string ("Reset code sent to user email.") is allowed.
      const flat = JSON.stringify(res.body);
      assert.equal(flat.includes(t.code), false, 'response leaks the 6-digit code');
      assert.equal(flat.includes(t.token_hash), false, 'response leaks the token hash');
      assert.equal(flat.includes(new Date(t.expires_at).toISOString()), false,
        'response leaks the expiry timestamp');
      assert.equal(Object.prototype.hasOwnProperty.call(res.body.data || {}, 'token'), false);
      assert.equal(Object.prototype.hasOwnProperty.call(res.body.data || {}, 'code'), false);
      assert.equal(t.used, false);
      assert.equal(typeof t.token_hash, 'string');
      assert.equal(t.token_hash.length, 64, 'sha256 hex is 64 chars');
      assert.match(t.code, /^\d{6}$/);
      const ttlMs = new Date(t.expires_at).getTime() - before;
      assert.ok(ttlMs > 55 * 60 * 1000 && ttlMs < 65 * 60 * 1000,
        `expires_at should be ~1h from now, got ${ttlMs}ms`);

      const audit = await db('admin_audit_log')
        .where({ target_user_id: TARGET_ID, action: 'password_reset_link_sent' })
        .orderBy('created_at', 'desc')
        .first();
      assert.ok(audit, 'audit row written');
      assert.equal(audit.admin_user_id, ADMIN_ID);
      assert.equal(audit.result, 'success');
      assert.equal(audit.ip_address, '203.0.113.7');
      assert.equal(audit.user_agent, 'PlagitTest/sendResetLink');
      assert.equal(audit.reason, 'integration test — safe to delete');
      assert.equal(audit.metadata.email_delivered, true);
      assert.equal(audit.metadata.ttl_minutes, 60);
      const createdMs = new Date(audit.created_at).getTime();
      assert.ok(createdMs >= before - 2000 && createdMs <= after + 2000);
    } finally {
      await clearAdminTokensFor(TARGET_ID);
      await clearAuditFor(TARGET_ID);
    }
  });

  test('integration: 404 when target user does not exist (no token, no audit)', async () => {
    const FAKE_ID = '00000000-0000-0000-0000-0000deadbeef';
    const { res, err } = await callSend(mockReq({
      params: { id: FAKE_ID },
      body: {},
      user: { id: ADMIN_ID, role: 'admin', admin_role: 'super_admin' },
    }));

    assert.ok(err, 'expected an error to be passed to next()');
    assert.equal(err.status, 404);

    const tokens = await db('password_reset_tokens').where({ user_id: FAKE_ID });
    assert.equal(tokens.length, 0);
    const audit = await db('admin_audit_log').where({ target_user_id: FAKE_ID });
    assert.equal(audit.length, 0);
  });

  test('integration: rate limit (4th active token) rejects + writes failed audit', async () => {
    await clearAdminTokensFor(TARGET_ID);
    await clearAuditFor(TARGET_ID);

    // Pre-seed 3 active tokens directly so we hit the cap on the 1st call.
    const seedRows = [];
    try {
      for (let i = 0; i < 3; i += 1) {
        const code = String(100000 + i);
        const tokenHash = crypto.createHash('sha256').update(`seed-${i}`).digest('hex');
        const [row] = await db('password_reset_tokens').insert({
          user_id: TARGET_ID,
          token_hash: tokenHash,
          code,
          expires_at: new Date(Date.now() + 60 * 60 * 1000),
        }).returning('id');
        seedRows.push(row.id);
      }

      const { res, err } = await callSend(mockReq({
        params: { id: TARGET_ID },
        body: { reason: 'rate-limit test' },
        user: { id: ADMIN_ID, role: 'admin', admin_role: 'super_admin' },
        ip: '198.51.100.9',
        ua: 'PlagitTest/rateLimit',
      }));

      assert.ok(err, 'expected rate-limit error');
      assert.equal(err.status, 400);
      assert.equal(err.code, 'RESET_RATE_LIMITED');

      const tokensNow = await db('password_reset_tokens').where({ user_id: TARGET_ID });
      assert.equal(tokensNow.length, 3, 'no new token was inserted');

      const audit = await db('admin_audit_log')
        .where({ target_user_id: TARGET_ID, action: 'password_reset_link_sent' })
        .orderBy('created_at', 'desc')
        .first();
      assert.ok(audit, 'failed-audit row written');
      assert.equal(audit.result, 'failed');
      assert.equal(audit.metadata.error, 'rate_limited');
      assert.equal(audit.metadata.max_active, 3);
      assert.equal(audit.ip_address, '198.51.100.9');
      assert.equal(audit.user_agent, 'PlagitTest/rateLimit');
    } finally {
      await clearAdminTokensFor(TARGET_ID);
      await clearAuditFor(TARGET_ID);
    }
  });

  test('integration: cleanup — close DB pool', async () => {
    await db.destroy();
  });
}
