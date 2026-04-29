/**
 * Integration tests for the Step 4-ter status gate.
 *
 *   - /auth/login   → 403 ACCOUNT_BANNED when status='banned'
 *   - /auth/login   → 403 ACCOUNT_SUSPENDED when status='suspended'
 *   - /auth/login   → 200 + tokens when status='active'
 *   - /auth/login   → 401 on wrong password regardless of status
 *   - /auth/refresh → 403 + revoke for banned + suspended
 *
 * Same gating + mock-req/res pattern as adminUsersResetLink.test.js.
 * Skipped automatically unless ADMIN_AUDIT_TESTS=1.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.ADMIN_AUDIT_TESTS === '1';

if (!RUN) {
  test('auth status-gate tests skipped (set ADMIN_AUDIT_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const crypto = require('crypto');
  const db = require('../../src/config/db');
  const { login, refresh } = require('../../src/controllers/authController');

  const TARGET_ID = '782c0cd7-d7be-4446-b142-0f2dc295035e';   // elena@email.com
  const TARGET_EMAIL = 'elena@email.com';
  const KNOWN_PASSWORD = 'user2026';                           // seeded value

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
      'must_change_password', 'status',
    ).where({ id }).first();
    const tokens = await db('refresh_tokens').where({ user_id: id });
    return { user: u, tokens };
  }
  async function restoreAuth(id, snap) {
    await db('users').where({ id }).update({
      must_change_password: snap.user.must_change_password,
      status: snap.user.status,
      updated_at: db.fn.now(),
    });
    await db('refresh_tokens').where({ user_id: id }).del();
    if (snap.tokens && snap.tokens.length) {
      await db('refresh_tokens').insert(snap.tokens.map((t) => ({ ...t })));
    }
  }

  // ── tests ────────────────────────────────────────────────────────────

  test('login: status=active returns tokens (control)', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    try {
      await db('users').where({ id: TARGET_ID })
        .update({ status: 'active', must_change_password: false });

      const { res, err } = await call(login, mockReq({
        body: { email: TARGET_EMAIL, password: KNOWN_PASSWORD },
      }));
      assert.equal(err, null, err && err.message);
      assert.ok(res.body.data.access_token);
      assert.ok(res.body.data.refresh_token);
    } finally {
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('login: status=suspended → 403 ACCOUNT_SUSPENDED, no tokens', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    try {
      await db('users').where({ id: TARGET_ID })
        .update({ status: 'suspended', must_change_password: false });

      const { res, err } = await call(login, mockReq({
        body: { email: TARGET_EMAIL, password: KNOWN_PASSWORD },
      }));
      assert.ok(err);
      assert.equal(err.status, 403);
      assert.equal(err.code, 'ACCOUNT_SUSPENDED');
      assert.equal(res.body, null);
    } finally {
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('login: status=banned → 403 ACCOUNT_BANNED, no tokens', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    try {
      await db('users').where({ id: TARGET_ID })
        .update({ status: 'banned', must_change_password: false });

      const { res, err } = await call(login, mockReq({
        body: { email: TARGET_EMAIL, password: KNOWN_PASSWORD },
      }));
      assert.ok(err);
      assert.equal(err.status, 403);
      assert.equal(err.code, 'ACCOUNT_BANNED');
      assert.equal(res.body, null);
    } finally {
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('login: wrong password still 401 even when suspended (no info leak)', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    try {
      await db('users').where({ id: TARGET_ID })
        .update({ status: 'suspended', must_change_password: false });

      const { err } = await call(login, mockReq({
        body: { email: TARGET_EMAIL, password: 'definitely-not-the-password' },
      }));
      assert.ok(err);
      assert.equal(err.status, 401);
      // Password check happens before status check, so the client cannot
      // probe account status with a known-bad password.
      assert.notEqual(err.code, 'ACCOUNT_SUSPENDED');
      assert.notEqual(err.code, 'ACCOUNT_BANNED');
    } finally {
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('refresh: status=suspended → 403 ACCOUNT_SUSPENDED + presented refresh revoked', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    try {
      const token = crypto.randomBytes(32).toString('hex');
      await db('refresh_tokens').insert({
        user_id: TARGET_ID,
        token,
        expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      });
      await db('users').where({ id: TARGET_ID })
        .update({ status: 'suspended', must_change_password: false });

      const { err } = await call(refresh, mockReq({
        body: { refresh_token: token },
      }));
      assert.ok(err);
      assert.equal(err.status, 403);
      assert.equal(err.code, 'ACCOUNT_SUSPENDED');

      const stillThere = await db('refresh_tokens').where({ token }).first();
      assert.equal(stillThere, undefined, 'refresh token should be revoked');
    } finally {
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('refresh: status=banned → 403 ACCOUNT_BANNED + presented refresh revoked', async () => {
    const snap = await snapshotAuth(TARGET_ID);
    try {
      const token = crypto.randomBytes(32).toString('hex');
      await db('refresh_tokens').insert({
        user_id: TARGET_ID,
        token,
        expires_at: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
      });
      await db('users').where({ id: TARGET_ID })
        .update({ status: 'banned', must_change_password: false });

      const { err } = await call(refresh, mockReq({
        body: { refresh_token: token },
      }));
      assert.ok(err);
      assert.equal(err.status, 403);
      assert.equal(err.code, 'ACCOUNT_BANNED');

      const stillThere = await db('refresh_tokens').where({ token }).first();
      assert.equal(stillThere, undefined, 'refresh token should be revoked');
    } finally {
      await restoreAuth(TARGET_ID, snap);
    }
  });

  test('integration: cleanup — close DB pool', async () => {
    await db.destroy();
  });
}
