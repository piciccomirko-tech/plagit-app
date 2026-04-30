/**
 * Integration tests for Step 5 admin temp-password endpoint:
 *   - POST /v1/admin/users/:id/set-temp-password (super_admin only)
 *
 * Covers controller behavior + the route guard via a stub of
 * requireRole, then verifies the temp pwd works end-to-end through
 * the auth flow:
 *   - login with the temp pwd → 403 FORCE_PASSWORD_CHANGE_REQUIRED
 *   - reset-password lifts the gate → next login works normally
 *
 * Skipped automatically unless ADMIN_AUDIT_TESTS=1.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.ADMIN_AUDIT_TESTS === '1';

if (!RUN) {
  test('adminUsers setTempPassword tests skipped (set ADMIN_AUDIT_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const crypto = require('crypto');
  const bcrypt = require('bcryptjs');
  const db = require('../../src/config/db');
  const { setTempPassword } = require('../../src/controllers/adminUsersController');
  const { login, resetPassword } = require('../../src/controllers/authController');
  const { requireRole } = require('../../src/middleware/auth');

  const ADMIN_ID = '20d5cc45-b3c0-4332-a4a9-cc4bdb822033';   // mirko@plagit.com
  const TARGET_ID = '782c0cd7-d7be-4446-b142-0f2dc295035e';  // elena@email.com
  const TARGET_EMAIL = 'elena@email.com';
  const KNOWN_PASSWORD = 'user2026';
  const POST_RESET_PASSWORD = 'AfterTempPwd2026';

  const superAdmin = { id: ADMIN_ID, role: 'admin', admin_role: 'super_admin' };
  const supportAdmin = { id: ADMIN_ID, role: 'admin', admin_role: 'support_admin' };

  function mockReq({ params = {}, body = {}, user, ip = '127.0.0.1', ua = 'node-test' } = {}) {
    return {
      params, body, user, ip,
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
  function call(fn, req) {
    const res = mockRes();
    let nextErr = null;
    return fn(req, res, (e) => { nextErr = e; })
      .then(() => ({ res: res._state, err: nextErr }));
  }
  // requireRole is express middleware that ends the response itself
  // (res.status(403).json) instead of forwarding via next(err). Capture
  // both: any next argument AND the res state, so a denial can be
  // detected either way.
  function callMiddleware(mw, req) {
    const res = mockRes();
    let nextCalled = false;
    let nextArg;
    mw(req, res, (e) => { nextCalled = true; nextArg = e; });
    return { res: res._state, nextCalled, nextArg };
  }
  async function clearAudit() {
    await db('admin_audit_log')
      .where({ target_user_id: TARGET_ID, action: 'temp_password_set' }).del();
  }
  async function snapshotAuth(id) {
    const u = await db('users').select(
      'password_hash', 'must_change_password', 'password_changed_at', 'status',
    ).where({ id }).first();
    const tokens = await db('refresh_tokens').where({ user_id: id });
    return { user: u, tokens };
  }
  async function restoreAuth(id, snap) {
    await db('users').where({ id }).update({
      password_hash: snap.user.password_hash,
      must_change_password: snap.user.must_change_password,
      password_changed_at: snap.user.password_changed_at,
      status: snap.user.status,
      updated_at: db.fn.now(),
    });
    await db('refresh_tokens').where({ user_id: id }).del();
    if (snap.tokens && snap.tokens.length) {
      await db('refresh_tokens').insert(snap.tokens.map((t) => ({ ...t })));
    }
    await db('password_reset_tokens').where({ user_id: id }).del();
  }

  // ── tests ────────────────────────────────────────────────────────────

  test('setTempPassword: success path returns plaintext once + flags + audit + revoke', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    await clearAudit();
    try {
      // Seed two refresh tokens to verify revoke counts.
      await db('refresh_tokens').insert([
        { user_id: TARGET_ID, token: crypto.randomBytes(32).toString('hex'),
          expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) },
        { user_id: TARGET_ID, token: crypto.randomBytes(32).toString('hex'),
          expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) },
      ]);

      const { res, err } = await call(setTempPassword, mockReq({
        params: { id: TARGET_ID },
        body: { reason: 'integration test — temp pwd' },
        user: superAdmin,
        ip: '203.0.113.55',
        ua: 'PlagitTest/tempPwd',
      }));
      assert.equal(err, null, err && err.message);

      // (1) success path: plaintext returned once
      const tempPwd = res.body.data.temporary_password;
      assert.equal(typeof tempPwd, 'string');
      assert.ok(tempPwd.length >= 12, 'temp pwd must be strong');
      assert.equal(res.body.data.success, true);
      assert.ok(res.body.data.message.length > 0);

      // (2) password hash changed AND verifies against the returned plaintext
      const after = await db('users').select(
        'password_hash', 'must_change_password',
      ).where({ id: TARGET_ID }).first();
      assert.notEqual(after.password_hash, snap.user.password_hash, 'hash rotated');
      assert.equal(await bcrypt.compare(tempPwd, after.password_hash), true);

      // (3) must_change_password flipped on
      assert.equal(after.must_change_password, true);

      // (4) refresh tokens revoked
      const remaining = await db('refresh_tokens').where({ user_id: TARGET_ID });
      assert.equal(remaining.length, 0);

      // (5) audit row created with correct shape
      const audit = await db('admin_audit_log')
        .where({ target_user_id: TARGET_ID, action: 'temp_password_set' })
        .orderBy('created_at', 'desc').first();
      assert.ok(audit);
      assert.equal(audit.admin_user_id, ADMIN_ID);
      assert.equal(audit.result, 'success');
      assert.equal(audit.reason, 'integration test — temp pwd');
      assert.equal(audit.metadata.refresh_tokens_revoked, 2);
      assert.equal(audit.ip_address, '203.0.113.55');

      // (6) response does NOT include the hash, anywhere
      const flat = JSON.stringify(res.body);
      assert.equal(flat.includes(after.password_hash), false, 'hash leaked into response');
      assert.equal(flat.includes('password_hash'), false, 'field name leaked into response');

      // Audit metadata also must NOT contain plaintext or hash.
      const auditFlat = JSON.stringify(audit.metadata);
      assert.equal(auditFlat.includes(tempPwd), false, 'plaintext leaked into audit metadata');
      assert.equal(auditFlat.includes(after.password_hash), false, 'hash leaked into audit metadata');
    } finally {
      await restoreAuth(TARGET_ID, snap);
      await clearAudit();
    }
  });

  test('setTempPassword: rejects missing/short reason with REASON_REQUIRED', async () => {
    const { err: e1 } = await call(setTempPassword, mockReq({
      params: { id: TARGET_ID },
      body: {},
      user: superAdmin,
    }));
    assert.ok(e1);
    assert.equal(e1.code, 'REASON_REQUIRED');

    const { err: e2 } = await call(setTempPassword, mockReq({
      params: { id: TARGET_ID },
      body: { reason: '  ab  ' },
      user: superAdmin,
    }));
    assert.ok(e2);
    assert.equal(e2.code, 'REASON_REQUIRED');
  });

  test('setTempPassword: rejects self-target with SELF_TARGET_FORBIDDEN', async () => {
    const { err } = await call(setTempPassword, mockReq({
      params: { id: ADMIN_ID },
      body: { reason: 'should never apply to self' },
      user: superAdmin,
    }));
    assert.ok(err);
    assert.equal(err.code, 'SELF_TARGET_FORBIDDEN');
  });

  test('setTempPassword route guard: support_admin denied (super_admin only)', () => {
    // Exercise the route-level guard directly, since the controller
    // itself does not check admin_role.
    const guard = requireRole('super_admin');

    const denied = callMiddleware(guard, mockReq({ user: supportAdmin }));
    assert.equal(denied.nextCalled, false, 'next must NOT be called on denial');
    assert.equal(denied.res.status, 403);
    assert.equal(denied.res.body.success, false);

    const allowed = callMiddleware(guard, mockReq({ user: superAdmin }));
    assert.equal(allowed.nextCalled, true, 'super_admin must pass through');
    assert.equal(allowed.nextArg, undefined);
  });

  test('setTempPassword: 404 when target user does not exist', async () => {
    const { err } = await call(setTempPassword, mockReq({
      params: { id: '00000000-0000-0000-0000-0000deadbeef' },
      body: { reason: 'ghost target' },
      user: superAdmin,
    }));
    assert.ok(err);
    assert.equal(err.status, 404);
  });

  test('login with temp pwd → 403 FORCE_PASSWORD_CHANGE_REQUIRED, then reset lifts the gate', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    await clearAudit();
    try {
      // (a) Set the temp pwd via the controller — captures real plaintext.
      const { res: setRes, err: setErr } = await call(setTempPassword, mockReq({
        params: { id: TARGET_ID },
        body: { reason: 'e2e temp pwd → reset → login' },
        user: superAdmin,
      }));
      assert.equal(setErr, null, setErr && setErr.message);
      const tempPwd = setRes.body.data.temporary_password;

      // (b) Login with the temp pwd → blocked by Step 4-bis gate.
      const { err: loginGateErr } = await call(login, mockReq({
        body: { email: TARGET_EMAIL, password: tempPwd },
      }));
      assert.ok(loginGateErr);
      assert.equal(loginGateErr.status, 403);
      assert.equal(loginGateErr.code, 'FORCE_PASSWORD_CHANGE_REQUIRED');

      // (c) Run reset-password as if the user used "Forgot Password" —
      // seed a valid token row, then call the controller.
      await db('password_reset_tokens').where({ user_id: TARGET_ID }).del();
      const code = '525252';
      const tokenHash = crypto.createHash('sha256').update('seed-temp').digest('hex');
      await db('password_reset_tokens').insert({
        user_id: TARGET_ID,
        token_hash: tokenHash,
        code,
        expires_at: new Date(Date.now() + 15 * 60 * 1000),
      });
      const { err: resetErr } = await call(resetPassword, mockReq({
        body: { email: TARGET_EMAIL, code, new_password: POST_RESET_PASSWORD },
      }));
      assert.equal(resetErr, null, resetErr && resetErr.message);

      // (d) New login with the new password succeeds and the gate is gone.
      const { err: loginOkErr, res: loginOkRes } = await call(login, mockReq({
        body: { email: TARGET_EMAIL, password: POST_RESET_PASSWORD },
      }));
      assert.equal(loginOkErr, null, loginOkErr && loginOkErr.message);
      assert.ok(loginOkRes.body.data.access_token);
    } finally {
      await db('password_reset_tokens').where({ user_id: TARGET_ID }).del();
      await restoreAuth(TARGET_ID, snap);
      await clearAudit();
    }
  });

  test('integration: cleanup — close DB pool', async () => {
    await db.destroy();
  });
}
