/**
 * Integration tests for Step 4 admin account controls:
 *   - PATCH /v1/admin/users/:id/status        (now reason-mandatory)
 *   - POST  /v1/admin/users/:id/force-password-change
 *
 * Same gating + mock-req/res pattern as adminUsersResetLink.test.js.
 * Skipped automatically unless ADMIN_AUDIT_TESTS=1.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.ADMIN_AUDIT_TESTS === '1';

if (!RUN) {
  test('adminUsers status/forcePasswordChange tests skipped (set ADMIN_AUDIT_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const db = require('../../src/config/db');
  const {
    updateStatus,
    forcePasswordChange,
  } = require('../../src/controllers/adminUsersController');

  const ADMIN_ID = '20d5cc45-b3c0-4332-a4a9-cc4bdb822033';   // mirko@plagit.com
  const TARGET_ID = '782c0cd7-d7be-4446-b142-0f2dc295035e';  // elena@email.com

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
  function call(fn, req) {
    const res = mockRes();
    let nextErr = null;
    return fn(req, res, (e) => { nextErr = e; })
      .then(() => ({ res: res._state, err: nextErr }));
  }
  async function clearAudit(action) {
    await db('admin_audit_log').where({ target_user_id: TARGET_ID, action }).del();
  }
  async function snapshotUser(id) {
    return db('users').select(
      'id', 'status', 'must_change_password',
      'suspended_reason', 'suspended_at', 'suspended_by',
    ).where({ id }).first();
  }
  async function restoreUser(id, snap) {
    await db('users').where({ id }).update({
      status: snap.status,
      must_change_password: snap.must_change_password,
      suspended_reason: snap.suspended_reason,
      suspended_at: snap.suspended_at,
      suspended_by: snap.suspended_by,
      updated_at: db.fn.now(),
    });
  }
  const adminUser = { id: ADMIN_ID, role: 'admin', admin_role: 'super_admin' };

  // ── updateStatus ─────────────────────────────────────────────────────

  test('updateStatus: success → suspended writes reason+by, audit row, response minimal', async () => {
    const snap = await snapshotUser(TARGET_ID);
    await clearAudit('status_changed');
    try {
      const { res, err } = await call(updateStatus, mockReq({
        params: { id: TARGET_ID },
        body: { status: 'suspended', reason: 'integration test — suspend' },
        user: adminUser,
        ip: '203.0.113.10',
        ua: 'PlagitTest/status',
      }));
      assert.equal(err, null, err && err.message);
      assert.equal(res.status, 200);
      assert.equal(res.body.success, true);
      assert.equal(res.body.data.status, 'suspended');

      const u = await snapshotUser(TARGET_ID);
      assert.equal(u.status, 'suspended');
      assert.equal(u.suspended_reason, 'integration test — suspend');
      assert.equal(u.suspended_by, ADMIN_ID);
      assert.ok(u.suspended_at instanceof Date);

      const audit = await db('admin_audit_log')
        .where({ target_user_id: TARGET_ID, action: 'status_changed' })
        .orderBy('created_at', 'desc').first();
      assert.ok(audit);
      assert.equal(audit.admin_user_id, ADMIN_ID);
      assert.equal(audit.result, 'success');
      assert.equal(audit.reason, 'integration test — suspend');
      assert.equal(audit.metadata.old_status, snap.status);
      assert.equal(audit.metadata.new_status, 'suspended');
      assert.equal(audit.ip_address, '203.0.113.10');
    } finally {
      await restoreUser(TARGET_ID, snap);
      await clearAudit('status_changed');
    }
  });

  test('updateStatus: reactivating clears suspended_reason/at/by', async () => {
    const snap = await snapshotUser(TARGET_ID);
    await clearAudit('status_changed');
    try {
      // First suspend, then reactivate.
      await call(updateStatus, mockReq({
        params: { id: TARGET_ID },
        body: { status: 'suspended', reason: 'pre-step for reactivate test' },
        user: adminUser,
      }));
      const { err } = await call(updateStatus, mockReq({
        params: { id: TARGET_ID },
        body: { status: 'active', reason: 'unsuspend after appeal' },
        user: adminUser,
      }));
      assert.equal(err, null, err && err.message);

      const u = await snapshotUser(TARGET_ID);
      assert.equal(u.status, 'active');
      assert.equal(u.suspended_reason, null);
      assert.equal(u.suspended_at, null);
      assert.equal(u.suspended_by, null);
    } finally {
      await restoreUser(TARGET_ID, snap);
      await clearAudit('status_changed');
    }
  });

  test('updateStatus: rejects unknown status with INVALID_STATUS', async () => {
    const { err } = await call(updateStatus, mockReq({
      params: { id: TARGET_ID },
      body: { status: 'banned-but-typoed', reason: 'should not matter' },
      user: adminUser,
    }));
    assert.ok(err);
    assert.equal(err.status, 400);
    assert.equal(err.code, 'INVALID_STATUS');
  });

  test('updateStatus: rejects missing/short reason with REASON_REQUIRED', async () => {
    const { err: e1 } = await call(updateStatus, mockReq({
      params: { id: TARGET_ID },
      body: { status: 'suspended' },
      user: adminUser,
    }));
    assert.ok(e1);
    assert.equal(e1.code, 'REASON_REQUIRED');

    const { err: e2 } = await call(updateStatus, mockReq({
      params: { id: TARGET_ID },
      body: { status: 'suspended', reason: '  ab  ' },
      user: adminUser,
    }));
    assert.ok(e2);
    assert.equal(e2.code, 'REASON_REQUIRED');
  });

  test('updateStatus: rejects self-target with SELF_TARGET_FORBIDDEN', async () => {
    const { err } = await call(updateStatus, mockReq({
      params: { id: ADMIN_ID },
      body: { status: 'suspended', reason: 'should never apply' },
      user: adminUser,
    }));
    assert.ok(err);
    assert.equal(err.code, 'SELF_TARGET_FORBIDDEN');
  });

  test('updateStatus: 404 when target user does not exist', async () => {
    const { err } = await call(updateStatus, mockReq({
      params: { id: '00000000-0000-0000-0000-0000deadbeef' },
      body: { status: 'suspended', reason: 'ghost target' },
      user: adminUser,
    }));
    assert.ok(err);
    assert.equal(err.status, 404);
  });

  // ── forcePasswordChange ──────────────────────────────────────────────

  test('forcePasswordChange: success sets must_change_password + audit row', async () => {
    const snap = await snapshotUser(TARGET_ID);
    await clearAudit('force_password_change_required');
    try {
      const { res, err } = await call(forcePasswordChange, mockReq({
        params: { id: TARGET_ID },
        body: { reason: 'integration test — force pwd change' },
        user: adminUser,
        ip: '198.51.100.20',
        ua: 'PlagitTest/forcePwd',
      }));
      assert.equal(err, null, err && err.message);
      assert.equal(res.body.success, true);

      const u = await snapshotUser(TARGET_ID);
      assert.equal(u.must_change_password, true);

      const audit = await db('admin_audit_log')
        .where({ target_user_id: TARGET_ID, action: 'force_password_change_required' })
        .orderBy('created_at', 'desc').first();
      assert.ok(audit);
      assert.equal(audit.admin_user_id, ADMIN_ID);
      assert.equal(audit.result, 'success');
      assert.equal(audit.reason, 'integration test — force pwd change');
      assert.equal(audit.metadata.previously_required, snap.must_change_password === true);
      assert.equal(audit.ip_address, '198.51.100.20');
    } finally {
      await restoreUser(TARGET_ID, snap);
      await clearAudit('force_password_change_required');
    }
  });

  test('forcePasswordChange: idempotent (second call still 200, audit row records previously_required=true)', async () => {
    const snap = await snapshotUser(TARGET_ID);
    await clearAudit('force_password_change_required');
    try {
      await call(forcePasswordChange, mockReq({
        params: { id: TARGET_ID },
        body: { reason: 'first pass' },
        user: adminUser,
      }));
      const { err } = await call(forcePasswordChange, mockReq({
        params: { id: TARGET_ID },
        body: { reason: 'second pass — should still 200' },
        user: adminUser,
      }));
      assert.equal(err, null, err && err.message);

      const audit = await db('admin_audit_log')
        .where({ target_user_id: TARGET_ID, action: 'force_password_change_required' })
        .orderBy('created_at', 'desc').first();
      assert.equal(audit.metadata.previously_required, true);
    } finally {
      await restoreUser(TARGET_ID, snap);
      await clearAudit('force_password_change_required');
    }
  });

  test('forcePasswordChange: rejects missing reason and self-target', async () => {
    const { err: e1 } = await call(forcePasswordChange, mockReq({
      params: { id: TARGET_ID },
      body: {},
      user: adminUser,
    }));
    assert.equal(e1.code, 'REASON_REQUIRED');

    const { err: e2 } = await call(forcePasswordChange, mockReq({
      params: { id: ADMIN_ID },
      body: { reason: 'should never apply' },
      user: adminUser,
    }));
    assert.equal(e2.code, 'SELF_TARGET_FORBIDDEN');
  });

  test('integration: cleanup — close DB pool', async () => {
    await db.destroy();
  });
}
