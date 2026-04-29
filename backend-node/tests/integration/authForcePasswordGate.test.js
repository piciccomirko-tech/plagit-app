/**
 * Integration tests for the Step 4-bis login gate.
 *
 *   - /auth/login          → 403 FORCE_PASSWORD_CHANGE_REQUIRED when
 *                            users.must_change_password = true. No
 *                            access_token / refresh_token issued.
 *   - /auth/refresh        → same gate, presented refresh token is
 *                            revoked so it cannot be reused.
 *   - /auth/reset-password → on success, lifts must_change_password
 *                            and stamps password_changed_at, so login
 *                            works normally again.
 *   - normal login         → unaffected for users without the flag.
 *   - banned status        → still blocked (existing behavior).
 *
 * Same gating + mock-req/res pattern as adminUsersResetLink.test.js.
 * Skipped automatically unless ADMIN_AUDIT_TESTS=1.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.ADMIN_AUDIT_TESTS === '1';

if (!RUN) {
  test('auth force-password gate tests skipped (set ADMIN_AUDIT_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const crypto = require('crypto');
  const bcrypt = require('bcryptjs');
  const db = require('../../src/config/db');
  const {
    login,
    refresh,
    resetPassword,
  } = require('../../src/controllers/authController');

  // Real seeded user we control from these tests. Same target used by
  // the adminUsers tests — we restore everything in finally blocks so
  // reruns are clean.
  const TARGET_ID = '782c0cd7-d7be-4446-b142-0f2dc295035e';   // elena@email.com
  const TARGET_EMAIL = 'elena@email.com';
  const KNOWN_PASSWORD = 'user2026';                           // seeded value
  const NEW_PASSWORD = 'NewLongerPwd2026';

  function mockReq({ body = {} } = {}) {
    return { body, get: () => null };
  }
  function mockRes() {
    const state = { status: 200, body: null };
    return {
      _state: state,
      status(c) { state.status = c; return this; },
      json(b) { state.body = b; return this; },
    };
  }
  function call(fn, req) {
    const res = mockRes();
    let nextErr = null;
    return fn(req, res, (e) => { nextErr = e; })
      .then(() => ({ res: res._state, err: nextErr }));
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
      await db('refresh_tokens').insert(
        snap.tokens.map((t) => ({ ...t })),
      );
    }
  }
  async function clearTokensFor(userId) {
    await db('password_reset_tokens').where({ user_id: userId }).del();
  }

  // ── tests ────────────────────────────────────────────────────────────

  test('login: normal user with flag=false gets tokens (control)', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    try {
      await db('users').where({ id: TARGET_ID })
        .update({ must_change_password: false, status: 'active' });

      const { res, err } = await call(login, mockReq({
        body: { email: TARGET_EMAIL, password: KNOWN_PASSWORD },
      }));
      assert.equal(err, null, err && err.message);
      assert.ok(res.body.data.access_token, 'access token returned');
      assert.ok(res.body.data.refresh_token, 'refresh token returned');
    } finally {
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('login: must_change_password=true → 403 FORCE_PASSWORD_CHANGE_REQUIRED, no token', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    try {
      await db('users').where({ id: TARGET_ID })
        .update({ must_change_password: true, status: 'active' });

      const { res, err } = await call(login, mockReq({
        body: { email: TARGET_EMAIL, password: KNOWN_PASSWORD },
      }));
      assert.ok(err);
      assert.equal(err.status, 403);
      assert.equal(err.code, 'FORCE_PASSWORD_CHANGE_REQUIRED');
      // Response is null because next() was called with the error —
      // make sure no token slipped through anyway.
      assert.equal(res.body, null);
    } finally {
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('login: banned status still blocks regardless of flag (existing behavior)', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    try {
      await db('users').where({ id: TARGET_ID })
        .update({ must_change_password: false, status: 'banned' });
      const { err } = await call(login, mockReq({
        body: { email: TARGET_EMAIL, password: KNOWN_PASSWORD },
      }));
      assert.ok(err);
      assert.equal(err.status, 403);
    } finally {
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('login: wrong password still 401 even when flag=true (no info leak)', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    try {
      await db('users').where({ id: TARGET_ID })
        .update({ must_change_password: true, status: 'active' });
      const { err } = await call(login, mockReq({
        body: { email: TARGET_EMAIL, password: 'definitely-not-the-password' },
      }));
      assert.ok(err);
      assert.equal(err.status, 401);
    } finally {
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('refresh: must_change_password=true → 403 + presented refresh token revoked', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    try {
      // Seed a refresh token directly so we can test the gate.
      const token = crypto.randomBytes(32).toString('hex');
      await db('refresh_tokens').insert({
        user_id: TARGET_ID,
        token,
        expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      });
      await db('users').where({ id: TARGET_ID })
        .update({ must_change_password: true, status: 'active' });

      const { err } = await call(refresh, mockReq({
        body: { refresh_token: token },
      }));
      assert.ok(err);
      assert.equal(err.status, 403);
      assert.equal(err.code, 'FORCE_PASSWORD_CHANGE_REQUIRED');

      // The presented token must have been deleted.
      const stillThere = await db('refresh_tokens').where({ token }).first();
      assert.equal(stillThere, undefined, 'refresh token should be revoked');
    } finally {
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('reset-password lifts the flag and stamps password_changed_at', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    await clearTokensFor(TARGET_ID);
    try {
      await db('users').where({ id: TARGET_ID })
        .update({ must_change_password: true, status: 'active' });

      // Seed a valid reset token row matching what the controller expects.
      const code = '424242';
      const tokenHash = crypto.createHash('sha256').update('seed-token').digest('hex');
      await db('password_reset_tokens').insert({
        user_id: TARGET_ID,
        token_hash: tokenHash,
        code,
        expires_at: new Date(Date.now() + 15 * 60 * 1000),
      });

      const { err: resetErr } = await call(resetPassword, mockReq({
        body: { email: TARGET_EMAIL, code, new_password: NEW_PASSWORD },
      }));
      assert.equal(resetErr, null, resetErr && resetErr.message);

      const after = await db('users').select(
        'must_change_password', 'password_changed_at', 'password_hash',
      ).where({ id: TARGET_ID }).first();
      assert.equal(after.must_change_password, false, 'flag lifted');
      assert.ok(after.password_changed_at instanceof Date, 'stamp set');
      // Sanity: new hash was actually written.
      const matchesNew = await bcrypt.compare(NEW_PASSWORD, after.password_hash);
      assert.equal(matchesNew, true);

      // And login now works normally.
      const { err: loginErr, res: loginRes } = await call(login, mockReq({
        body: { email: TARGET_EMAIL, password: NEW_PASSWORD },
      }));
      assert.equal(loginErr, null);
      assert.ok(loginRes.body.data.access_token);
    } finally {
      await clearTokensFor(TARGET_ID);
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('integration: cleanup — close DB pool', async () => {
    await db.destroy();
  });
}
