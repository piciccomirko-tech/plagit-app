/**
 * Integration tests for services/walletQuery.js
 *
 * Hits real local Postgres. Same gating contract as the other Boost
 * suites — skipped unless BOOST_ACTIVATION_TESTS=1.
 *
 * Coverage:
 *   1.  happy: full snapshot with wallet + ledger rows
 *   2.  safe-zero: business exists but wallet row missing
 *   3.  LIMIT 20 enforced when ledger has > 20 rows
 *   4.  ordering: most recent first
 *   5.  bucketing: every reason → correct transactionType
 *   6.  creditsBefore arithmetic for both grants and spends
 *   7.  note passthrough byte-identical
 *   8.  adminUserId surfaced for grants, null for spends
 *   9.  404 BUSINESS_NOT_FOUND for unknown UUID
 *   10. 400 INVALID_BUSINESS_ID for malformed input
 *   11. read-only: idempotent (no row count change after two calls)
 *   12. cross-business isolation (B's tx never appear when querying A)
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.BOOST_ACTIVATION_TESTS === '1';

if (!RUN) {
  test('walletQuery integration tests skipped (set BOOST_ACTIVATION_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const db = require('../../src/config/db');
  const {
    getWalletSnapshot,
    bucketTransactionType,
    RECENT_LIMIT,
  } = require('../../src/services/walletQuery');

  // ── helpers ─────────────────────────────────────────────────────────
  async function createFixture() {
    const stamp = `${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;

    const owner = await db('users').insert({
      email: `wq-biz-${stamp}@plagit.test`,
      password_hash: 'x',
      name: 'WQ Test Biz',
      user_type: 'business',
    }).returning('*').then((r) => r[0]);

    const admin = await db('users').insert({
      email: `wq-admin-${stamp}@plagit.test`,
      password_hash: 'x',
      name: 'WQ Test Admin',
      user_type: 'admin',
    }).returning('*').then((r) => r[0]);

    const biz = await db('businesses').insert({
      user_id: owner.id,
      name: 'WQ Test Co',
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

  async function seedWallet(biz, fields = {}) {
    await db('business_credit_wallet').insert({
      business_id: biz.id,
      credits_available: 0,
      credits_total_comped: 0,
      credits_total_purchased: 0,
      credits_total_spent: 0,
      ...fields,
    });
  }

  async function seedTx(biz, row) {
    const [r] = await db('business_credit_transactions').insert({
      business_id: biz.id,
      ...row,
    }).returning('*');
    return r;
  }

  // ── tests ───────────────────────────────────────────────────────────
  test.after(async () => { await db.destroy(); });

  test('1. happy: full snapshot with wallet + ledger rows', async () => {
    const fx = await createFixture();
    try {
      await seedWallet(fx.biz, {
        credits_available: 8,
        credits_total_comped: 10,
        credits_total_purchased: 0,
        credits_total_spent: 2,
        last_recharge_at: db.fn.now(),
      });
      await seedTx(fx.biz, {
        delta: 10, reason: 'admin_grant', balance_after: 10,
        admin_user_id: fx.admin.id, notes: '[promo] welcome',
      });
      await seedTx(fx.biz, {
        delta: -2, reason: 'spend', balance_after: 8,
        notes: 'Boost urgent_24h',
      });

      const snap = await getWalletSnapshot(fx.biz.id);
      assert.equal(snap.businessId, fx.biz.id);
      assert.equal(snap.walletId, fx.biz.id);
      assert.equal(snap.creditsAvailable, 8);
      assert.equal(snap.creditsSpent, 2);
      assert.equal(snap.creditsTotalComped, 10);
      assert.equal(snap.creditsTotalPurchased, 0);
      assert.ok(snap.lastRechargeAt);
      assert.equal(snap.recentTransactions.length, 2);
    } finally { await cleanup(fx); }
  });

  test('2. safe zero: business exists but wallet row missing', async () => {
    const fx = await createFixture();
    try {
      const snap = await getWalletSnapshot(fx.biz.id);
      assert.equal(snap.businessId, fx.biz.id);
      assert.equal(snap.walletId, null);
      assert.equal(snap.creditsAvailable, 0);
      assert.equal(snap.creditsSpent, 0);
      assert.equal(snap.creditsTotalPurchased, 0);
      assert.equal(snap.creditsTotalComped, 0);
      assert.equal(snap.lastRechargeAt, null);
      assert.deepEqual(snap.recentTransactions, []);
    } finally { await cleanup(fx); }
  });

  test('3. LIMIT 20 enforced when ledger has > 20 rows', async () => {
    const fx = await createFixture();
    try {
      await seedWallet(fx.biz, { credits_available: 25, credits_total_comped: 25 });
      // Insert 25 sequential grants. Tiny await between inserts so each
      // gets a distinct created_at (Postgres NOW() is per-statement).
      for (let i = 1; i <= 25; i++) {
        await seedTx(fx.biz, {
          delta: 1, reason: 'admin_grant', balance_after: i,
          admin_user_id: fx.admin.id, notes: `tx-${i}`,
        });
      }

      const snap = await getWalletSnapshot(fx.biz.id);
      assert.equal(snap.recentTransactions.length, RECENT_LIMIT);
      assert.equal(snap.recentTransactions.length, 20);
      // The 5 oldest (tx-1..tx-5) must be excluded.
      const notes = snap.recentTransactions.map((t) => t.note);
      assert.ok(!notes.includes('tx-1'));
      assert.ok(!notes.includes('tx-5'));
      assert.ok(notes.includes('tx-25'));
    } finally { await cleanup(fx); }
  });

  test('4. ordering: most recent first', async () => {
    const fx = await createFixture();
    try {
      await seedWallet(fx.biz);
      const a = await seedTx(fx.biz, {
        delta: 1, reason: 'admin_grant', balance_after: 1,
        admin_user_id: fx.admin.id, notes: 'first',
      });
      const b = await seedTx(fx.biz, {
        delta: 1, reason: 'admin_grant', balance_after: 2,
        admin_user_id: fx.admin.id, notes: 'second',
      });
      const c = await seedTx(fx.biz, {
        delta: 1, reason: 'admin_grant', balance_after: 3,
        admin_user_id: fx.admin.id, notes: 'third',
      });

      const snap = await getWalletSnapshot(fx.biz.id);
      const ids = snap.recentTransactions.map((t) => t.id);
      assert.deepEqual(ids, [c.id, b.id, a.id]);
    } finally { await cleanup(fx); }
  });

  test('5. bucketing: every reason → correct transactionType', async () => {
    // Pure helper, no DB needed.
    assert.equal(bucketTransactionType('admin_grant'), 'grant');
    assert.equal(bucketTransactionType('comped'),      'grant');
    assert.equal(bucketTransactionType('test_grant'),  'grant');
    assert.equal(bucketTransactionType('spend'),       'spend');
    assert.equal(bucketTransactionType('refund'),      'refund');
    assert.equal(bucketTransactionType('purchase'),    'purchase');
    assert.equal(bucketTransactionType('bogus'),       'other');
    assert.equal(bucketTransactionType(undefined),     'other');
  });

  test('6. creditsBefore arithmetic for both grants and spends', async () => {
    const fx = await createFixture();
    try {
      await seedWallet(fx.biz, { credits_available: 7, credits_total_comped: 10, credits_total_spent: 3 });
      await seedTx(fx.biz, {
        delta: 10, reason: 'admin_grant', balance_after: 10,
        admin_user_id: fx.admin.id, notes: 'g',
      });
      await seedTx(fx.biz, {
        delta: -3, reason: 'spend', balance_after: 7, notes: 's',
      });

      const snap = await getWalletSnapshot(fx.biz.id);
      // Newest first: spend, then grant.
      const [spend, grant] = snap.recentTransactions;
      assert.equal(spend.creditsAfter, 7);
      assert.equal(spend.creditsDelta, -3);
      assert.equal(spend.creditsBefore, 10);   // 7 - (-3) = 10
      assert.equal(grant.creditsAfter, 10);
      assert.equal(grant.creditsDelta, 10);
      assert.equal(grant.creditsBefore, 0);    // 10 - 10 = 0
    } finally { await cleanup(fx); }
  });

  test('7. note passthrough byte-identical', async () => {
    const fx = await createFixture();
    try {
      await seedWallet(fx.biz);
      const note = '[promo] €25 off — special UTF-8 ✨';
      await seedTx(fx.biz, {
        delta: 5, reason: 'admin_grant', balance_after: 5,
        admin_user_id: fx.admin.id, notes: note,
      });

      const snap = await getWalletSnapshot(fx.biz.id);
      assert.equal(snap.recentTransactions[0].note, note);
    } finally { await cleanup(fx); }
  });

  test('8. adminUserId surfaced for grants, null for spends', async () => {
    const fx = await createFixture();
    try {
      await seedWallet(fx.biz);
      await seedTx(fx.biz, {
        delta: 5, reason: 'admin_grant', balance_after: 5,
        admin_user_id: fx.admin.id, notes: 'g',
      });
      await seedTx(fx.biz, {
        delta: -1, reason: 'spend', balance_after: 4, notes: 's',
      });

      const snap = await getWalletSnapshot(fx.biz.id);
      const spend = snap.recentTransactions.find((t) => t.reason === 'spend');
      const grant = snap.recentTransactions.find((t) => t.reason === 'admin_grant');
      assert.equal(grant.adminUserId, fx.admin.id);
      assert.equal(spend.adminUserId, null);
    } finally { await cleanup(fx); }
  });

  test('9. 404 BUSINESS_NOT_FOUND for unknown UUID', async () => {
    await assert.rejects(
      () => getWalletSnapshot('00000000-0000-0000-0000-000000000000'),
      (e) => e.code === 'BUSINESS_NOT_FOUND' && e.status === 404,
    );
  });

  test('10. 400 INVALID_BUSINESS_ID for malformed input', async () => {
    for (const bad of ['', 'not-a-uuid', '123', null, undefined, 42]) {
      await assert.rejects(
        () => getWalletSnapshot(bad),
        (e) => e.code === 'INVALID_BUSINESS_ID' && e.status === 400,
      );
    }
  });

  test('11. read-only: idempotent (no row count change)', async () => {
    const fx = await createFixture();
    try {
      await seedWallet(fx.biz, { credits_available: 5, credits_total_comped: 5 });
      await seedTx(fx.biz, {
        delta: 5, reason: 'admin_grant', balance_after: 5,
        admin_user_id: fx.admin.id, notes: 'seed',
      });

      const before = {
        wallets: +(await db('business_credit_wallet').count('* as c').first()).c,
        txs:     +(await db('business_credit_transactions').count('* as c').first()).c,
      };

      await getWalletSnapshot(fx.biz.id);
      await getWalletSnapshot(fx.biz.id);
      await getWalletSnapshot(fx.biz.id);

      const after = {
        wallets: +(await db('business_credit_wallet').count('* as c').first()).c,
        txs:     +(await db('business_credit_transactions').count('* as c').first()).c,
      };
      assert.deepEqual(after, before);
    } finally { await cleanup(fx); }
  });

  test('12. cross-business isolation', async () => {
    const a = await createFixture();
    const b = await createFixture();
    try {
      await seedWallet(a.biz, { credits_available: 1 });
      await seedWallet(b.biz, { credits_available: 99 });
      await seedTx(a.biz, {
        delta: 1, reason: 'admin_grant', balance_after: 1,
        admin_user_id: a.admin.id, notes: 'A only',
      });
      await seedTx(b.biz, {
        delta: 99, reason: 'admin_grant', balance_after: 99,
        admin_user_id: b.admin.id, notes: 'B only — must not appear in A query',
      });

      const snap = await getWalletSnapshot(a.biz.id);
      assert.equal(snap.creditsAvailable, 1);
      assert.equal(snap.recentTransactions.length, 1);
      assert.equal(snap.recentTransactions[0].note, 'A only');
      assert.ok(!snap.recentTransactions.some((t) => /B only/.test(t.note || '')));
    } finally {
      await cleanup(a);
      await cleanup(b);
    }
  });
}
