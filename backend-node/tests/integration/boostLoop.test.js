/**
 * End-to-end backend loop test (Step 6C).
 *
 * Verifies that the five existing surfaces compose into a complete,
 * idempotent economic loop:
 *
 *   admin grant credits
 *     → walletGrant.grantCredits          (Step 5)
 *   business reads wallet
 *     → businessWalletController.getMyWallet  (Step 6B)
 *   business spends credits
 *     → businessBoostController.useCreditBoost
 *       → boostActivation.activateBoost(source='credit')
 *   business reads boost status
 *     → businessBoostController.boostStatus
 *
 * Side effects asserted at every step:
 *   - business_credit_wallet      → balance + accumulators
 *   - business_credit_transactions → ledger row (grant + spend)
 *   - job_payments                 → comped row for the spend
 *   - job_boosts                   → active row, partial-unique-indexed
 *   - jobs                         → denormalised boost_* columns
 *
 * The flag gate (BOOST_ACTIVATION_ENABLED, default OFF) is exercised in
 * a dedicated test that mutates the exported flags object and restores
 * it in finally — env vars are never touched. The test asserts the
 * flag is OFF before and after the gate-flip block.
 *
 * Pattern matches tests/controllers/* — direct controller invocation
 * with mock req/res, no express boot. Skipped automatically unless
 * BOOST_ACTIVATION_TESTS=1.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.BOOST_ACTIVATION_TESTS === '1';

if (!RUN) {
  test('boostLoop integration tests skipped (set BOOST_ACTIVATION_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const db = require('../../src/config/db');
  const flags = require('../../src/config/featureFlags');
  const { grantCredits } = require('../../src/services/walletGrant');
  const { getMyWallet } = require('../../src/controllers/businessWalletController');
  const {
    useCreditBoost,
    boostStatus,
  } = require('../../src/controllers/businessBoostController');

  // The product code we exercise across the loop. Real seeded row:
  // urgent_24h → boost_type='urgent', credits_cost=1, duration_hours=24.
  const PRODUCT = 'urgent_24h';
  const PRODUCT_COST = 1;
  const PRODUCT_DURATION_HOURS = 24;

  // ── helpers ─────────────────────────────────────────────────────────
  function mockRes() {
    const state = { status: 200, body: null };
    return {
      _state: state,
      status(code) { state.status = code; return this; },
      json(body) { state.body = body; return this; },
    };
  }

  function callWallet(userId) {
    const res = mockRes();
    let nextErr = null;
    return getMyWallet({ user: { id: userId } }, res, (e) => { nextErr = e; })
      .then(() => {
        if (nextErr) throw nextErr;
        return res._state.body;
      });
  }

  function callUseBoost(userId, jobId, productCode) {
    const res = mockRes();
    let nextErr = null;
    return useCreditBoost(
      { user: { id: userId }, params: { id: jobId }, body: { productCode } },
      res,
      (e) => { nextErr = e; },
    ).then(() => {
      if (nextErr) throw nextErr;
      return { status: res._state.status, body: res._state.body };
    });
  }

  function callBoostStatus(userId, jobId) {
    const res = mockRes();
    let nextErr = null;
    return boostStatus(
      { user: { id: userId }, params: { id: jobId } },
      res,
      (e) => { nextErr = e; },
    ).then(() => {
      if (nextErr) throw nextErr;
      return res._state.body;
    });
  }

  async function createUser(userType) {
    const stamp = `${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
    return db('users').insert({
      email: `boostloop-${userType}-${stamp}@plagit.test`,
      password_hash: 'x',
      name: `BoostLoop ${userType}`,
      user_type: userType,
    }).returning('*').then((r) => r[0]);
  }

  async function createBiz(ownerId) {
    return db('businesses').insert({
      user_id: ownerId,
      name: 'BoostLoop Co',
    }).returning('*').then((r) => r[0]);
  }

  async function createJob(businessId, status = 'active') {
    return db('jobs').insert({
      business_id: businessId,
      title: 'BoostLoop Job',
      location: 'London',
      status,
    }).returning('*').then((r) => r[0]);
  }

  async function createFixture({ jobStatus = 'active' } = {}) {
    const owner = await createUser('business');
    const admin = await createUser('admin');
    const biz = await createBiz(owner.id);
    const job = await createJob(biz.id, jobStatus);
    return { owner, admin, biz, job };
  }

  async function cleanupBiz(biz) {
    if (!biz) return;
    await db('job_visibility_events').whereIn(
      'job_id',
      db('jobs').select('id').where({ business_id: biz.id }),
    ).del();
    await db('job_boosts').where({ business_id: biz.id }).del();
    await db('jobs').where({ business_id: biz.id }).del();
    await db('business_credit_transactions').where({ business_id: biz.id }).del();
    await db('business_credit_wallet').where({ business_id: biz.id }).del();
    await db('job_payments').where({ business_id: biz.id }).del();
    await db('businesses').where({ id: biz.id }).del();
  }

  async function cleanupUser(u) {
    if (u) await db('users').where({ id: u.id }).del();
  }

  async function cleanup(fx) {
    await cleanupBiz(fx.biz);
    await cleanupUser(fx.owner);
    await cleanupUser(fx.admin);
  }

  async function rowCounts(bizId, jobId) {
    const [w, t, b, p] = await Promise.all([
      db('business_credit_wallet').where({ business_id: bizId }).count('* as c').first(),
      db('business_credit_transactions').where({ business_id: bizId }).count('* as c').first(),
      db('job_boosts').where({ job_id: jobId }).count('* as c').first(),
      db('job_payments').where({ business_id: bizId }).count('* as c').first(),
    ]);
    return {
      wallets: Number(w.c),
      txs: Number(t.c),
      boosts: Number(b.c),
      payments: Number(p.c),
    };
  }

  // Activate the flag in a test-scoped block. ALWAYS restores OFF.
  async function withFlagOn(fn) {
    const original = flags.activationEnabled;
    flags.activationEnabled = true;
    try {
      return await fn();
    } finally {
      flags.activationEnabled = original;
    }
  }

  // ── tests ───────────────────────────────────────────────────────────
  test.after(async () => {
    // Defensive: make sure the flag is OFF when the suite exits even if
    // a test forgot a finally.
    flags.activationEnabled = false;
    await db.destroy();
  });

  test('1. full happy loop: grant → read → spend → read', async () => {
    const fx = await createFixture();
    try {
      // 1. admin grants 10 credits
      await grantCredits({
        businessId: fx.biz.id,
        credits: 10,
        reason: 'launch',
        adminUserId: fx.admin.id,
      });

      // 2. business reads wallet — sees 10 available, 0 spent
      const w1 = await callWallet(fx.owner.id);
      assert.equal(w1.data.creditsAvailable, 10);
      assert.equal(w1.data.creditsSpent, 0);
      assert.equal(w1.data.creditsTotalComped, 10);
      assert.equal(w1.data.recentTransactions.length, 1);
      assert.equal(w1.data.recentTransactions[0].transactionType, 'grant');

      // 3. business spends 1 credit on urgent_24h
      const spend = await withFlagOn(
        () => callUseBoost(fx.owner.id, fx.job.id, PRODUCT),
      );
      assert.equal(spend.status, 201);
      assert.equal(spend.body.success, true);
      assert.equal(spend.body.data.source, 'credit');
      assert.equal(spend.body.data.status, 'active');
      assert.equal(spend.body.data.boost_type, 'urgent');
      assert.equal(spend.body.data.product_code, PRODUCT);
      assert.equal(spend.body.data.walletAfter, 10 - PRODUCT_COST);

      // 4. business reads wallet again — sees decrement + spend tx on top
      const w2 = await callWallet(fx.owner.id);
      assert.equal(w2.data.creditsAvailable, 10 - PRODUCT_COST);
      assert.equal(w2.data.creditsSpent, PRODUCT_COST);
      assert.equal(w2.data.creditsTotalComped, 10);
      assert.equal(w2.data.recentTransactions.length, 2);
      assert.equal(w2.data.recentTransactions[0].transactionType, 'spend');
      assert.equal(w2.data.recentTransactions[0].creditsDelta, -PRODUCT_COST);
      assert.equal(w2.data.recentTransactions[0].creditsAfter, 10 - PRODUCT_COST);
      assert.equal(w2.data.recentTransactions[1].transactionType, 'grant');
    } finally { await cleanup(fx); }
  });

  test('2. ledger row linked to boost: spend tx has boost_id and balance_after correct', async () => {
    const fx = await createFixture();
    try {
      await grantCredits({
        businessId: fx.biz.id, credits: 5, reason: 'seed', adminUserId: fx.admin.id,
      });
      const spend = await withFlagOn(
        () => callUseBoost(fx.owner.id, fx.job.id, PRODUCT),
      );
      const boostId = spend.body.data.id;

      const tx = await db('business_credit_transactions')
        .where({ business_id: fx.biz.id, reason: 'spend' })
        .first();

      assert.ok(tx, 'spend ledger row missing');
      assert.equal(tx.delta, -PRODUCT_COST);
      assert.equal(tx.balance_after, 5 - PRODUCT_COST);
      assert.equal(tx.boost_id, boostId);
      assert.equal(tx.job_id, fx.job.id);
      assert.ok(tx.payment_id, 'comped payment_id should be linked');
    } finally { await cleanup(fx); }
  });

  test('3. job denormalisation: jobs.boost_* columns updated correctly', async () => {
    const fx = await createFixture();
    try {
      await grantCredits({
        businessId: fx.biz.id, credits: 5, adminUserId: fx.admin.id,
      });
      await withFlagOn(() => callUseBoost(fx.owner.id, fx.job.id, PRODUCT));

      const job = await db('jobs').where({ id: fx.job.id }).first();
      assert.equal(job.boost_status, 'active');
      assert.equal(job.boost_source, 'credit');
      assert.equal(job.boost_product_id, PRODUCT);
      assert.equal(job.boost_type, 'urgent');
      assert.equal(job.boost_priority, 25);
      assert.ok(job.boost_starts_at);
      assert.ok(job.boost_ends_at);

      const span = new Date(job.boost_ends_at).getTime() - new Date(job.boost_starts_at).getTime();
      assert.equal(span, PRODUCT_DURATION_HOURS * 3600 * 1000);
    } finally { await cleanup(fx); }
  });

  test('4. insufficient credits: rejected, no side effects', async () => {
    const fx = await createFixture();
    try {
      // Pre-create wallet at zero so the underflow path is exercised
      // (lazy create would otherwise also start at zero, same effect).
      await db('business_credit_wallet').insert({
        business_id: fx.biz.id, credits_available: 0,
      });

      const before = await rowCounts(fx.biz.id, fx.job.id);

      await assert.rejects(
        () => withFlagOn(() => callUseBoost(fx.owner.id, fx.job.id, PRODUCT)),
        (e) => e.code === 'INSUFFICIENT_CREDITS' && e.status === 400,
      );

      const after = await rowCounts(fx.biz.id, fx.job.id);
      // Wallet row count may be unchanged (we pre-created one).
      assert.equal(after.txs, before.txs, 'no ledger row');
      assert.equal(after.boosts, before.boosts, 'no boost row');
      assert.equal(after.payments, before.payments, 'no payment row');

      const wallet = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(wallet.credits_available, 0);
      assert.equal(wallet.credits_total_spent, 0);

      const job = await db('jobs').where({ id: fx.job.id }).first();
      // jobs.boost_status defaults to 'none' (not active) when no boost
      // has ever been applied — schema default, not null.
      assert.notEqual(job.boost_status, 'active');
    } finally { await cleanup(fx); }
  });

  test('5. duplicate active boost: second spend hits 409, wallet debited only once', async () => {
    const fx = await createFixture();
    try {
      await grantCredits({
        businessId: fx.biz.id, credits: 5, adminUserId: fx.admin.id,
      });

      // First spend succeeds.
      await withFlagOn(() => callUseBoost(fx.owner.id, fx.job.id, PRODUCT));

      // Second spend on same job → 409 BOOST_ALREADY_ACTIVE.
      await assert.rejects(
        () => withFlagOn(() => callUseBoost(fx.owner.id, fx.job.id, PRODUCT)),
        (e) => e.code === 'BOOST_ALREADY_ACTIVE' && e.status === 409,
      );

      // Wallet only debited ONCE.
      const wallet = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(wallet.credits_available, 5 - PRODUCT_COST);
      assert.equal(wallet.credits_total_spent, PRODUCT_COST);

      // Exactly ONE active boost on the job.
      const active = await db('job_boosts')
        .where({ job_id: fx.job.id, status: 'active' });
      assert.equal(active.length, 1);
    } finally { await cleanup(fx); }
  });

  test('6. flag OFF blocks activation: 503, zero side effects, flag restored', async () => {
    const fx = await createFixture();
    try {
      await grantCredits({
        businessId: fx.biz.id, credits: 5, adminUserId: fx.admin.id,
      });

      // Sanity: default state is OFF.
      assert.equal(flags.activationEnabled, false, 'flag must default to OFF');

      const before = await rowCounts(fx.biz.id, fx.job.id);

      // Spend WITHOUT flipping the flag — must be 503.
      await assert.rejects(
        () => callUseBoost(fx.owner.id, fx.job.id, PRODUCT),
        (e) => e.code === 'BOOST_ACTIVATION_OFF' && e.status === 503,
      );

      const after = await rowCounts(fx.biz.id, fx.job.id);
      assert.deepEqual(after, before, '503 must produce zero side effects');

      const wallet = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(wallet.credits_available, 5);
      assert.equal(wallet.credits_total_spent, 0);

      // After the 503 path: flag is still OFF (we never flipped it).
      assert.equal(flags.activationEnabled, false, 'flag must remain OFF');
    } finally { await cleanup(fx); }
  });

  test('7. flag OFF does NOT block reads (wallet + boost-status)', async () => {
    const fx = await createFixture();
    try {
      await grantCredits({
        businessId: fx.biz.id, credits: 3, adminUserId: fx.admin.id,
      });

      assert.equal(flags.activationEnabled, false, 'precondition');

      // Wallet read: 200.
      const w = await callWallet(fx.owner.id);
      assert.equal(w.success, true);
      assert.equal(w.data.creditsAvailable, 3);

      // boost-status on a job with no active boost: 200, no active row.
      // jobs.boost_status defaults to 'none' (schema default), and the
      // active boost lookup returns null.
      const s = await callBoostStatus(fx.owner.id, fx.job.id);
      assert.equal(s.success, true);
      assert.notEqual(s.data.boost_status, 'active');
      assert.equal(s.data.activeBoost, null);
    } finally { await cleanup(fx); }
  });

  test('8. boost status reflects activation + matches job_boosts row', async () => {
    const fx = await createFixture();
    try {
      await grantCredits({
        businessId: fx.biz.id, credits: 3, adminUserId: fx.admin.id,
      });
      const spend = await withFlagOn(
        () => callUseBoost(fx.owner.id, fx.job.id, PRODUCT),
      );

      const status = await callBoostStatus(fx.owner.id, fx.job.id);
      assert.equal(status.data.boost_status, 'active');
      assert.equal(status.data.boost_source, 'credit');
      assert.equal(status.data.boost_product_id, PRODUCT);
      assert.equal(status.data.boost_type, 'urgent');
      assert.ok(status.data.activeBoost);
      assert.equal(status.data.activeBoost.id, spend.body.data.id);
      assert.equal(status.data.activeBoost.source, 'credit');
      assert.equal(status.data.activeBoost.status, 'active');
    } finally { await cleanup(fx); }
  });

  test('9. cross-business ownership: B cannot spend on A\'s job', async () => {
    const fxA = await createFixture();
    const ownerB = await createUser('business');
    const bizB = await createBiz(ownerB.id);
    try {
      await grantCredits({
        businessId: bizB.id, credits: 5, adminUserId: fxA.admin.id,
      });

      const beforeB = await db('business_credit_wallet').where({ business_id: bizB.id }).first();

      await assert.rejects(
        () => withFlagOn(() => callUseBoost(ownerB.id, fxA.job.id, PRODUCT)),
        (e) => e.code === 'JOB_NOT_OWNED' && e.status === 403,
      );

      // B's wallet untouched.
      const afterB = await db('business_credit_wallet').where({ business_id: bizB.id }).first();
      assert.equal(afterB.credits_available, beforeB.credits_available);
      assert.equal(afterB.credits_total_spent, beforeB.credits_total_spent);

      // No boost on A's job.
      const aBoosts = await db('job_boosts').where({ job_id: fxA.job.id });
      assert.equal(aBoosts.length, 0);
    } finally {
      await cleanupBiz(bizB);
      await cleanupUser(ownerB);
      await cleanup(fxA);
    }
  });

  test('10. paused job: 400 INVALID_JOB_STATE, no side effects', async () => {
    const fx = await createFixture({ jobStatus: 'paused' });
    try {
      await grantCredits({
        businessId: fx.biz.id, credits: 5, adminUserId: fx.admin.id,
      });
      const before = await rowCounts(fx.biz.id, fx.job.id);

      await assert.rejects(
        () => withFlagOn(() => callUseBoost(fx.owner.id, fx.job.id, PRODUCT)),
        (e) => e.code === 'INVALID_JOB_STATE' && e.status === 400,
      );

      const after = await rowCounts(fx.biz.id, fx.job.id);
      assert.deepEqual(after, before);

      const wallet = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(wallet.credits_available, 5);
    } finally { await cleanup(fx); }
  });

  test('11. unknown productCode: 404 PRODUCT_NOT_FOUND, wallet untouched', async () => {
    const fx = await createFixture();
    try {
      await grantCredits({
        businessId: fx.biz.id, credits: 5, adminUserId: fx.admin.id,
      });

      await assert.rejects(
        () => withFlagOn(
          () => callUseBoost(fx.owner.id, fx.job.id, 'does_not_exist_xyz'),
        ),
        (e) => e.code === 'PRODUCT_NOT_FOUND' && e.status === 404,
      );

      const wallet = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(wallet.credits_available, 5);
      assert.equal(wallet.credits_total_spent, 0);

      const boosts = await db('job_boosts').where({ job_id: fx.job.id });
      assert.equal(boosts.length, 0);
    } finally { await cleanup(fx); }
  });

  test('12. wallet DTO bucketing post-loop: spend + grant in correct order', async () => {
    const fx = await createFixture();
    try {
      await grantCredits({
        businessId: fx.biz.id, credits: 4, reason: 'launch promo', adminUserId: fx.admin.id,
      });
      await withFlagOn(() => callUseBoost(fx.owner.id, fx.job.id, PRODUCT));

      const w = await callWallet(fx.owner.id);
      const txs = w.data.recentTransactions;

      assert.equal(txs.length, 2);
      // Newest first: the spend.
      assert.equal(txs[0].transactionType, 'spend');
      assert.equal(txs[0].reason, 'spend');
      assert.equal(txs[0].creditsDelta, -PRODUCT_COST);
      assert.equal(txs[0].creditsBefore, 4);
      assert.equal(txs[0].creditsAfter, 4 - PRODUCT_COST);
      // Then the grant.
      assert.equal(txs[1].transactionType, 'grant');
      assert.equal(txs[1].reason, 'admin_grant');
      assert.equal(txs[1].creditsDelta, 4);
      assert.equal(txs[1].creditsBefore, 0);
      assert.equal(txs[1].creditsAfter, 4);
      assert.equal(txs[1].note, '[launch promo]');
      assert.equal(txs[1].adminUserId, fx.admin.id);
    } finally { await cleanup(fx); }
  });
}
