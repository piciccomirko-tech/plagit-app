/**
 * Unit tests for pushSender.resolveMode() — the LOG vs LIVE kill-switch.
 *
 * Contract (N5.6-B safety): real push delivery is OFF by default. It only
 * goes LIVE when PUSH_REAL_ENABLED === 'true' AND a provider credential
 * (FCM_SERVICE_ACCOUNT_JSON or APNS_AUTH_KEY) is present. This lets us deploy
 * with FCM_SERVICE_ACCOUNT_JSON already set on the host and still stay in LOG
 * MODE until we flip PUSH_REAL_ENABLED on purpose.
 *
 * Pure: resolveMode() only reads env — no bus, no DB, no FCM provider — so
 * NO real push is ever dispatched by this suite.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const { resolveMode } = require('../../src/services/push/pushSender');
const db = require('../../src/config/db');

// The three env vars resolveMode reads. Snapshot + restore so the suite never
// leaks state into the host shell or other test files.
const KEYS = ['PUSH_REAL_ENABLED', 'FCM_SERVICE_ACCOUNT_JSON', 'APNS_AUTH_KEY'];
const saved = {};

// A syntactically-plausible but FAKE service account — never parsed/used to
// send anything here (resolveMode only checks presence).
const FAKE_FCM = '{"type":"service_account","project_id":"fake"}';

// Snapshot, then clear, so every test starts from a known-empty baseline
// regardless of what dotenv injected from .env or what's in the shell.
test.before(() => { for (const k of KEYS) { saved[k] = process.env[k]; delete process.env[k]; } });
test.afterEach(() => { for (const k of KEYS) delete process.env[k]; });
test.after(async () => {
  for (const k of KEYS) {
    if (saved[k] === undefined) delete process.env[k];
    else process.env[k] = saved[k];
  }
  // pushSender requires the knex config at module load; close the (idle) pool
  // so the test process exits cleanly. No query is ever run.
  await db.destroy();
});

// ── mandatory scenarios ─────────────────────────────────────────────────────

test('FCM present + PUSH_REAL_ENABLED absent  → log', () => {
  process.env.FCM_SERVICE_ACCOUNT_JSON = FAKE_FCM;
  assert.equal(resolveMode(), 'log');
});

test('FCM present + PUSH_REAL_ENABLED=false   → log', () => {
  process.env.FCM_SERVICE_ACCOUNT_JSON = FAKE_FCM;
  process.env.PUSH_REAL_ENABLED = 'false';
  assert.equal(resolveMode(), 'log');
});

test('FCM present + PUSH_REAL_ENABLED=true    → live', () => {
  process.env.FCM_SERVICE_ACCOUNT_JSON = FAKE_FCM;
  process.env.PUSH_REAL_ENABLED = 'true';
  assert.equal(resolveMode(), 'live');
});

test('FCM absent                              → log', () => {
  assert.equal(resolveMode(), 'log');
});

// ── extra coverage (defends the exact contract) ─────────────────────────────

test('FCM absent + PUSH_REAL_ENABLED=true     → log (opted in but no creds)', () => {
  process.env.PUSH_REAL_ENABLED = 'true';
  assert.equal(resolveMode(), 'log');
});

test('APNS present + PUSH_REAL_ENABLED=true    → live (APNS counts as provider)', () => {
  process.env.APNS_AUTH_KEY = 'fake-apns-key-not-used';
  process.env.PUSH_REAL_ENABLED = 'true';
  assert.equal(resolveMode(), 'live');
});

test('PUSH_REAL_ENABLED=TRUE (wrong case)      → log (strict === "true")', () => {
  process.env.FCM_SERVICE_ACCOUNT_JSON = FAKE_FCM;
  process.env.PUSH_REAL_ENABLED = 'TRUE';
  assert.equal(resolveMode(), 'log');
});
