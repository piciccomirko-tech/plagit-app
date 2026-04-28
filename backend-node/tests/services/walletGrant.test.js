/**
 * Integration tests for services/walletGrant.js
 *
 * Hits a real local Postgres (knex development). Same gating contract
 * as the boostActivation suite — skipped unless BOOST_ACTIVATION_TESTS=1.
 *
 * Each test creates a throw-away business + admin user, exercises the
 * service, and rolls everything back via cleanup() in finally.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.BOOST_ACTIVATION_TESTS === '1';

if (!RUN) {
  test('walletGrant integration tests skipped (set BOOST_ACTIVATION_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const db = require('../../src/config/db');
  const {
    grantCredits,
    MAX_GRANT_PER_REQUEST,
  } = require('../../src/services/walletGrant');

  // ── helpers ─────────────────────────────────────────────────────────
  async function createFixture() {
    const stamp = `${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;

    const owner = await db('users').insert({
      email: `wallet-biz-${stamp}@plagit.test`,
      password_hash: 'x',
      name: 'Wallet Test Biz',
      user_type: 'business',
    }).returning('*').then((r) => r[0]);

    const admin = await db('users').insert({
      email: `wallet-admin-${stamp}@plagit.test`,
      password_hash: 'x',
      name: 'Wallet Test Admin',
      user_type: 'admin',
    }).returning('*').then((r) => r[0]);

    const biz = await db('businesses').insert({
      user_id: owner.id,
      name: 'Wallet Test Co',
    }).returning('*').then((r) => r[0]);

    return { owner, admin, biz };
  }

  async function cleanup({ owner, admin, biz }) {
    if (biz) {
      await db('business_credit_transactions').where({ business_id: biz.id }).del();
      await db('business_credit_wallet').where({ business_id: biz.id }).del();
      await db('businesses').where({ id: biz.id }).del();
    }
    if (owner) await db('users').where({ id: owner.id }).del();
    if (admin) await db('users').where({ id: admin.id }).del();
  }

  // ── tests ───────────────────────────────────────────────────────────
  test.after(async () => { await db.destroy(); });

  test('happy path: lazy-creates wallet, returns expected envelope', async () => {
    const fx = await createFixture();
    try {
      const before = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(before, undefined);

      const result = await grantCredits({
        businessId: fx.biz.id,
        credits: 10,
        reason: 'launch promo',
        note: 'Welcome to Plagit',
        adminUserId: fx.admin.id,
      });

      assert.equal(result.businessId, fx.biz.id);
      assert.equal(result.creditsAdded, 10);
      assert.equal(result.previousBalance, 0);
      assert.equal(result.newBalance, 10);
      assert.ok(result.transactionId);
      assert.ok(result.grantedAt);
      assert.equal(result.grantedByAdminId, fx.admin.id);
    } finally { await cleanup(fx); }
  });

  test('happy path: existing wallet — accumulators advance, balance grows', async () => {
    const fx = await createFixture();
    try {
      // Pre-seed a wallet with a non-zero starting state.
      await db('business_credit_wallet').insert({
        business_id: fx.biz.id,
        credits_available: 5,
        credits_total_comped: 5,
      });

      const result = await grantCredits({
        businessId: fx.biz.id,
        credits: 7,
        reason: 'top up',
        adminUserId: fx.admin.id,
      });

      assert.equal(result.previousBalance, 5);
      assert.equal(result.newBalance, 12);

      const wallet = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(wallet.credits_available, 12);
      assert.equal(wallet.credits_total_comped, 12);
      assert.equal(wallet.credits_total_spent, 0);
      assert.equal(wallet.credits_total_purchased, 0);
      assert.ok(wallet.last_recharge_at);
    } finally { await cleanup(fx); }
  });

  test('ledger row: reason=admin_grant, delta+, balance_after correct, admin_user_id set', async () => {
    const fx = await createFixture();
    try {
      const result = await grantCredits({
        businessId: fx.biz.id,
        credits: 3,
        reason: 'comp',
        note: 'investor demo',
        adminUserId: fx.admin.id,
      });

      const tx = await db('business_credit_transactions')
        .where({ business_id: fx.biz.id })
        .first();

      assert.equal(tx.id, result.transactionId);
      assert.equal(tx.reason, 'admin_grant');
      assert.equal(tx.delta, 3);
      assert.equal(tx.balance_after, 3);
      assert.equal(tx.admin_user_id, fx.admin.id);
      assert.equal(tx.notes, '[comp] investor demo');
      assert.equal(tx.job_id, null);
      assert.equal(tx.payment_id, null);
      assert.equal(tx.boost_id, null);
    } finally { await cleanup(fx); }
  });

  test('notes composition: only reason → "[reason]"; only note → note; neither → null', async () => {
    const fx = await createFixture();
    try {
      const r1 = await grantCredits({
        businessId: fx.biz.id, credits: 1, reason: 'gift', adminUserId: fx.admin.id,
      });
      const r2 = await grantCredits({
        businessId: fx.biz.id, credits: 1, note: 'standalone', adminUserId: fx.admin.id,
      });
      const r3 = await grantCredits({
        businessId: fx.biz.id, credits: 1, adminUserId: fx.admin.id,
      });

      const txs = await db('business_credit_transactions')
        .where({ business_id: fx.biz.id })
        .orderBy('created_at', 'asc');

      assert.equal(txs.find((t) => t.id === r1.transactionId).notes, '[gift]');
      assert.equal(txs.find((t) => t.id === r2.transactionId).notes, 'standalone');
      assert.equal(txs.find((t) => t.id === r3.transactionId).notes, null);
    } finally { await cleanup(fx); }
  });

  test('rejects credits=0 with 400 INVALID_CREDITS', async () => {
    const fx = await createFixture();
    try {
      await assert.rejects(
        () => grantCredits({
          businessId: fx.biz.id, credits: 0, adminUserId: fx.admin.id,
        }),
        (e) => e.code === 'INVALID_CREDITS' && e.status === 400,
      );
    } finally { await cleanup(fx); }
  });

  test('rejects negative credits with 400 INVALID_CREDITS', async () => {
    const fx = await createFixture();
    try {
      await assert.rejects(
        () => grantCredits({
          businessId: fx.biz.id, credits: -5, adminUserId: fx.admin.id,
        }),
        (e) => e.code === 'INVALID_CREDITS' && e.status === 400,
      );
    } finally { await cleanup(fx); }
  });

  test('rejects fractional credits with 400 INVALID_CREDITS', async () => {
    const fx = await createFixture();
    try {
      await assert.rejects(
        () => grantCredits({
          businessId: fx.biz.id, credits: 1.5, adminUserId: fx.admin.id,
        }),
        (e) => e.code === 'INVALID_CREDITS' && e.status === 400,
      );
    } finally { await cleanup(fx); }
  });

  test(`rejects credits > MAX_GRANT_PER_REQUEST (${MAX_GRANT_PER_REQUEST}) with 400 INVALID_CREDITS`, async () => {
    const fx = await createFixture();
    try {
      await assert.rejects(
        () => grantCredits({
          businessId: fx.biz.id,
          credits: MAX_GRANT_PER_REQUEST + 1,
          adminUserId: fx.admin.id,
        }),
        (e) => e.code === 'INVALID_CREDITS' && e.status === 400,
      );
    } finally { await cleanup(fx); }
  });

  test('rejects oversized reason (>50 chars) with 400 INVALID_REASON', async () => {
    const fx = await createFixture();
    try {
      await assert.rejects(
        () => grantCredits({
          businessId: fx.biz.id,
          credits: 1,
          reason: 'x'.repeat(51),
          adminUserId: fx.admin.id,
        }),
        (e) => e.code === 'INVALID_REASON' && e.status === 400,
      );
    } finally { await cleanup(fx); }
  });

  test('rejects oversized note (>500 chars) with 400 INVALID_NOTE', async () => {
    const fx = await createFixture();
    try {
      await assert.rejects(
        () => grantCredits({
          businessId: fx.biz.id,
          credits: 1,
          note: 'x'.repeat(501),
          adminUserId: fx.admin.id,
        }),
        (e) => e.code === 'INVALID_NOTE' && e.status === 400,
      );
    } finally { await cleanup(fx); }
  });

  test('rejects unknown businessId with 404 BUSINESS_NOT_FOUND', async () => {
    const fx = await createFixture();
    try {
      await assert.rejects(
        () => grantCredits({
          businessId: '00000000-0000-0000-0000-000000000000',
          credits: 5,
          adminUserId: fx.admin.id,
        }),
        (e) => e.code === 'BUSINESS_NOT_FOUND' && e.status === 404,
      );
    } finally { await cleanup(fx); }
  });

  test('concurrent grants serialise: no lost updates on accumulators', async () => {
    const fx = await createFixture();
    try {
      // Fire 5 grants of 10 in parallel — all should land.
      await Promise.all(Array.from({ length: 5 }, () => grantCredits({
        businessId: fx.biz.id,
        credits: 10,
        reason: 'race',
        adminUserId: fx.admin.id,
      })));

      const wallet = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(wallet.credits_available, 50);
      assert.equal(wallet.credits_total_comped, 50);

      const txs = await db('business_credit_transactions').where({ business_id: fx.biz.id });
      assert.equal(txs.length, 5);

      // Every ledger row's balance_after must be a multiple of 10 in [10, 50].
      const balances = txs.map((t) => t.balance_after).sort((a, b) => a - b);
      assert.deepEqual(balances, [10, 20, 30, 40, 50]);
    } finally { await cleanup(fx); }
  });
}
