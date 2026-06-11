/**
 * Unit/integration test: premium entitlements foundation (Payments Step 1).
 *
 * Covers the derived is_premium logic, idempotent upsert, expiry/cancel
 * handling, the status payload, and sandbox gating — against local Postgres
 * (the `user_entitlements` table must be migrated). Skipped unless
 * ENTITLEMENT_TESTS=1.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.ENTITLEMENT_TESTS === '1';

if (!RUN) {
  test('entitlements test skipped (set ENTITLEMENT_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  require('dotenv').config({ quiet: true });
  const db = require('../../src/config/db');
  const ent = require('../../src/services/entitlements');

  const STAMP = `${Date.now()}`;
  const EMAIL = `ent-${STAMP}@plagit.test`;
  const REF = `appl-${STAMP}`;
  const ctx = { userId: null };
  const future = () => new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
  const past = () => new Date(Date.now() - 24 * 60 * 60 * 1000);

  async function cleanup() {
    const users = await db('users').where({ email: EMAIL }).select('id');
    const ids = users.map((u) => u.id);
    if (ids.length) await db('user_entitlements').whereIn('user_id', ids).del();
    await db('users').where({ email: EMAIL }).del();
  }

  test('setup: throwaway candidate user', async () => {
    await cleanup();
    const [u] = await db('users')
      .insert({ name: EMAIL, email: EMAIL, password_hash: 'test-not-a-real-hash', user_type: 'candidate' })
      .returning('id');
    ctx.userId = u.id;
  });

  test('no entitlement → not premium', async () => {
    assert.equal(await ent.isPremium(ctx.userId), false);
    const s = await ent.buildPremiumStatus(ctx.userId);
    assert.equal(s.is_premium, false);
    assert.equal(s.premium, null);
  });

  test('upsert active entitlement (future period) → premium + correct status', async () => {
    await ent.upsertEntitlement({
      userId: ctx.userId, product: 'plagit_premium', plan: 'monthly',
      provider: 'apple', providerRef: REF, status: 'active',
      currentPeriodStart: new Date(), currentPeriodEnd: future(),
    });
    assert.equal(await ent.isPremium(ctx.userId), true);
    const s = await ent.buildPremiumStatus(ctx.userId);
    assert.equal(s.is_premium, true);
    assert.equal(s.premium.product, 'plagit_premium');
    assert.equal(s.premium.plan, 'monthly');
    assert.equal(s.premium.provider, 'apple');
    assert.equal(s.premium.trial, false);
  });

  test('upsert same (provider, provider_ref) is idempotent — updates in place, no duplicate', async () => {
    await ent.upsertEntitlement({
      userId: ctx.userId, product: 'plagit_premium', plan: 'yearly', // renewal changed plan
      provider: 'apple', providerRef: REF, status: 'active',
      currentPeriodStart: new Date(), currentPeriodEnd: future(),
    });
    const rows = await db('user_entitlements').where({ provider: 'apple', provider_ref: REF });
    assert.equal(rows.length, 1, 'exactly one row (upsert, not duplicate insert)');
    assert.equal(rows[0].plan, 'yearly', 'row updated in place');
  });

  test('trialing status surfaces trial=true and is premium', async () => {
    await ent.upsertEntitlement({
      userId: ctx.userId, product: 'plagit_premium', plan: 'monthly',
      provider: 'apple', providerRef: REF, status: 'trialing',
      currentPeriodEnd: future(), trialEnd: future(),
    });
    assert.equal(await ent.isPremium(ctx.userId), true);
    const s = await ent.buildPremiumStatus(ctx.userId);
    assert.equal(s.premium.trial, true);
  });

  test('expired (period_end in the past) → not premium', async () => {
    await ent.upsertEntitlement({
      userId: ctx.userId, product: 'plagit_premium', plan: 'monthly',
      provider: 'apple', providerRef: REF, status: 'active',
      currentPeriodStart: past(), currentPeriodEnd: past(),
    });
    assert.equal(await ent.isPremium(ctx.userId), false);
  });

  test('cancelled status → not premium even with a future period', async () => {
    await ent.upsertEntitlement({
      userId: ctx.userId, product: 'plagit_premium', plan: 'monthly',
      provider: 'apple', providerRef: REF, status: 'cancelled',
      currentPeriodEnd: future(),
    });
    assert.equal(await ent.isPremium(ctx.userId), false);
  });

  test('sandbox entitlement is NOT honoured in production mode', async () => {
    await ent.upsertEntitlement({
      userId: ctx.userId, product: 'plagit_premium', plan: 'monthly',
      provider: 'stripe', providerRef: `sand-${STAMP}`, status: 'active',
      currentPeriodEnd: future(), environment: 'sandbox',
    });
    // HONOR_SANDBOX_ENTITLEMENTS unset → sandbox rows ignored.
    assert.equal(await ent.isPremium(ctx.userId), false);
  });

  test('upsert rejects rebinding a provider_ref to a DIFFERENT user (replay/takeover guard)', async () => {
    const EMAIL_B = `ent-b-${STAMP}@plagit.test`;
    const [b] = await db('users')
      .insert({ name: EMAIL_B, email: EMAIL_B, password_hash: 'x', user_type: 'candidate' })
      .returning('id');
    const REF2 = `shared-${STAMP}`;
    // User A claims the Apple subscription first.
    await ent.upsertEntitlement({
      userId: ctx.userId, product: 'plagit_premium', plan: 'monthly',
      provider: 'apple', providerRef: REF2, status: 'active', currentPeriodEnd: future(),
    });
    // User B submits the SAME provider_ref → must be rejected, not reassigned.
    let err = null;
    try {
      await ent.upsertEntitlement({
        userId: b.id, product: 'plagit_premium', plan: 'monthly',
        provider: 'apple', providerRef: REF2, status: 'active', currentPeriodEnd: future(),
      });
    } catch (e) { err = e; }
    assert.ok(err && err.code === 'ENTITLEMENT_OWNER_MISMATCH', 'rebind rejected');
    const row = await db('user_entitlements').where({ provider: 'apple', provider_ref: REF2 }).first();
    assert.equal(row.user_id, ctx.userId, 'ownership unchanged (still user A)');
    await db('user_entitlements').where({ user_id: b.id }).del();
    await db('users').where({ id: b.id }).del();
  });

  test('teardown', async () => {
    await cleanup();
    await db.destroy();
  });
}
