/**
 * Tests for src/services/adminAuditService.js
 *
 * Two concerns:
 *   1. PURE validation tests (always run) — verify the enum whitelist,
 *      required-field guards, and the request-context extractor without
 *      touching the database.
 *   2. INTEGRATION tests against a real local Postgres — gated behind
 *      ADMIN_AUDIT_TESTS=1 so a fresh checkout / CI without a DB never
 *      fails. Local run:  ADMIN_AUDIT_TESTS=1 npm test
 *
 * Mirrors the gating pattern of boostActivation.test.js.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const {
  logAdminAction,
  extractRequestContext,
  ALLOWED_ACTIONS,
  ALLOWED_RESULTS,
} = require('../../src/services/adminAuditService');

// ---------------------------------------------------------------------------
// PURE validation tests
// ---------------------------------------------------------------------------

test('ALLOWED_ACTIONS contains the seven approved codes and is frozen', () => {
  const expected = [
    'account_deleted',
    'email_changed',
    'force_password_change_required',
    'password_reset_link_sent',
    'role_changed',
    'status_changed',
    'temp_password_set',
  ];
  assert.deepEqual([...ALLOWED_ACTIONS].sort(), expected.sort());
  assert.equal(Object.isFrozen(ALLOWED_ACTIONS), true);
});

test('ALLOWED_RESULTS = [success, failed], frozen', () => {
  assert.deepEqual([...ALLOWED_RESULTS], ['success', 'failed']);
  assert.equal(Object.isFrozen(ALLOWED_RESULTS), true);
});

test('logAdminAction rejects missing admin_user_id', async () => {
  await assert.rejects(
    () => logAdminAction({ action: 'status_changed' }),
    /admin_user_id is required/,
  );
});

test('logAdminAction rejects missing action', async () => {
  await assert.rejects(
    () => logAdminAction({ admin_user_id: '00000000-0000-0000-0000-000000000001' }),
    /action is required/,
  );
});

test('logAdminAction rejects non-whitelisted action', async () => {
  await assert.rejects(
    () => logAdminAction({
      admin_user_id: '00000000-0000-0000-0000-000000000001',
      action: 'delete_universe',
    }),
    /not whitelisted/,
  );
});

test('logAdminAction rejects invalid result value', async () => {
  await assert.rejects(
    () => logAdminAction({
      admin_user_id: '00000000-0000-0000-0000-000000000001',
      action: 'status_changed',
      result: 'maybe',
    }),
    /result "maybe" is invalid/,
  );
});

test('extractRequestContext returns nulls for missing req', () => {
  assert.deepEqual(extractRequestContext(null), { ip_address: null, user_agent: null });
  assert.deepEqual(extractRequestContext(undefined), { ip_address: null, user_agent: null });
});

test('extractRequestContext reads ip + user-agent from express-shaped req', () => {
  const fakeReq = {
    ip: '203.0.113.42',
    get: (h) => (h.toLowerCase() === 'user-agent' ? 'PlagitTest/1.0' : null),
  };
  assert.deepEqual(extractRequestContext(fakeReq), {
    ip_address: '203.0.113.42',
    user_agent: 'PlagitTest/1.0',
  });
});

test('extractRequestContext tolerates req without .get()', () => {
  const fakeReq = { ip: '198.51.100.7' };
  assert.deepEqual(extractRequestContext(fakeReq), {
    ip_address: '198.51.100.7',
    user_agent: null,
  });
});

// ---------------------------------------------------------------------------
// INTEGRATION tests (real Postgres) — gated
// ---------------------------------------------------------------------------

const RUN_INTEGRATION = process.env.ADMIN_AUDIT_TESTS === '1';

if (!RUN_INTEGRATION) {
  test('adminAuditService integration tests skipped (set ADMIN_AUDIT_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const db = require('../../src/config/db');

  // Use the local seed admin from reference_plagit_admin_credentials.md
  // and elena as a stable target. Both must exist in the local plagit DB.
  const ADMIN_ID = '20d5cc45-b3c0-4332-a4a9-cc4bdb822033';
  const TARGET_ID = '782c0cd7-d7be-4446-b142-0f2dc295035e';

  test('integration: logAdminAction writes a row with all fields', async () => {
    const inserted = await logAdminAction({
      admin_user_id: ADMIN_ID,
      target_user_id: TARGET_ID,
      action: 'status_changed',
      reason: 'integration test — safe to delete',
      metadata: { test: true, old_status: 'active', new_status: 'active' },
      result: 'success',
      ip_address: '127.0.0.1',
      user_agent: 'node-test',
    });
    assert.ok(inserted && inserted.id, 'expected an inserted id');

    const row = await db('admin_audit_log').where({ id: inserted.id }).first();
    try {
      assert.equal(row.admin_user_id, ADMIN_ID);
      assert.equal(row.target_user_id, TARGET_ID);
      assert.equal(row.action, 'status_changed');
      assert.equal(row.reason, 'integration test — safe to delete');
      assert.equal(row.result, 'success');
      assert.equal(row.ip_address, '127.0.0.1');
      assert.equal(row.user_agent, 'node-test');
      assert.equal(row.metadata.test, true);
      assert.ok(row.created_at instanceof Date);
    } finally {
      await db('admin_audit_log').where({ id: inserted.id }).del();
    }
  });

  test('integration: logAdminAction with swallow=true returns null on DB error', async () => {
    // Force an FK violation by using a fake admin_user_id.
    const result = await logAdminAction(
      {
        admin_user_id: '00000000-0000-0000-0000-000000000000',
        action: 'status_changed',
      },
      { swallow: true },
    );
    assert.equal(result, null);
  });

  test('integration: logAdminAction without swallow re-throws DB errors', async () => {
    await assert.rejects(
      () => logAdminAction({
        admin_user_id: '00000000-0000-0000-0000-000000000000',
        action: 'status_changed',
      }),
    );
  });

  test('integration: cleanup — close DB pool', async () => {
    await db.destroy();
  });
}
