/**
 * Integration tests for services/boostActivation.js
 *
 * These hit a real local Postgres (knex development). They:
 *   1. Create a throw-away business + active job per test.
 *   2. Run activate/revoke against the real DB.
 *   3. Roll the data back via DELETE in a finally block.
 *
 * Skipped automatically if BOOST_ACTIVATION_TESTS != 1, so CI / first
 * `npm test` run on a fresh checkout never blows up because the test
 * DB is missing. Local devs run:  BOOST_ACTIVATION_TESTS=1 npm test
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.BOOST_ACTIVATION_TESTS === '1';

if (!RUN) {
  test('boostActivation integration tests skipped (set BOOST_ACTIVATION_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const db = require('../../src/config/db');
  const {
    activateBoost,
    revokeBoost,
    getBoostStatus,
  } = require('../../src/services/boostActivation');

  // ── helpers ─────────────────────────────────────────────────────────
  async function createFixture() {
    // Reuse seeded test user/business if present, otherwise create fresh.
    const owner = await db('users').insert({
      email: `boost-test-${Date.now()}-${Math.random().toString(36).slice(2, 7)}@plagit.test`,
      password_hash: 'x',
      name: 'Boost Test',
      user_type: 'business',
    }).returning('*').then((r) => r[0]);

    const biz = await db('businesses').insert({
      user_id: owner.id,
      name: 'Boost Test Co',
    }).returning('*').then((r) => r[0]);

    const job = await db('jobs').insert({
      business_id: biz.id,
      title: 'Boost Test Job',
      location: 'London',
      status: 'active',
    }).returning('*').then((r) => r[0]);

    return { owner, biz, job };
  }

  async function cleanup({ owner, biz, job }) {
    if (job) {
      await db('job_visibility_events').where({ job_id: job.id }).del();
      await db('job_boosts').where({ job_id: job.id }).del();
      await db('jobs').where({ id: job.id }).del();
    }
    if (biz) {
      await db('business_credit_transactions').where({ business_id: biz.id }).del();
      await db('business_credit_wallet').where({ business_id: biz.id }).del();
      await db('job_payments').where({ business_id: biz.id }).del();
      await db('businesses').where({ id: biz.id }).del();
    }
    if (owner) {
      await db('users').where({ id: owner.id }).del();
    }
  }

  async function grantCredits(businessId, n) {
    await db('business_credit_wallet')
      .insert({ business_id: businessId, credits_available: n, credits_total_comped: n })
      .onConflict('business_id')
      .merge({
        credits_available: db.raw('business_credit_wallet.credits_available + ?', [n]),
        credits_total_comped: db.raw('business_credit_wallet.credits_total_comped + ?', [n]),
      });
  }

  // ── tests ───────────────────────────────────────────────────────────
  test.after(async () => { await db.destroy(); });

  test('admin grant: creates boost, denormalises jobs, writes audit', async () => {
    const fx = await createFixture();
    try {
      const result = await activateBoost({
        jobId: fx.job.id,
        productCode: 'urgent_24h',
        source: 'admin',
        adminUserId: fx.owner.id,
        notes: 'integration test',
      });

      assert.equal(result.status, 'active');
      assert.equal(result.boost_type, 'urgent');
      assert.equal(result.source, 'admin');

      const job = await db('jobs').where({ id: fx.job.id }).first();
      assert.equal(job.boost_status, 'active');
      assert.equal(job.boost_type, 'urgent');
      assert.equal(job.boost_source, 'admin');

      const events = await db('job_visibility_events')
        .where({ job_id: fx.job.id, event_type: 'boost_start' });
      assert.equal(events.length, 1);
      assert.equal(events[0].boost_id, result.id);
    } finally { await cleanup(fx); }
  });

  test('credit spend: debits wallet, writes ledger row, links boost', async () => {
    const fx = await createFixture();
    try {
      await grantCredits(fx.biz.id, 5);

      const result = await activateBoost({
        jobId: fx.job.id,
        businessId: fx.biz.id,
        productCode: 'top_3d',  // costs 2
        source: 'credit',
      });

      assert.equal(result.boost_type, 'top');
      assert.equal(result.walletAfter, 3);

      const wallet = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(wallet.credits_available, 3);
      assert.equal(wallet.credits_total_spent, 2);

      const tx = await db('business_credit_transactions').where({ business_id: fx.biz.id }).first();
      assert.equal(tx.delta, -2);
      assert.equal(tx.reason, 'spend');
      assert.equal(tx.balance_after, 3);
      assert.equal(tx.boost_id, result.id);
    } finally { await cleanup(fx); }
  });

  test('credit spend: rejects when wallet underfunded', async () => {
    const fx = await createFixture();
    try {
      await grantCredits(fx.biz.id, 1);

      await assert.rejects(
        () => activateBoost({
          jobId: fx.job.id,
          businessId: fx.biz.id,
          productCode: 'top_7d', // costs 4
          source: 'credit',
        }),
        (e) => e.code === 'INSUFFICIENT_CREDITS' && e.status === 400,
      );

      // Wallet untouched.
      const wallet = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(wallet.credits_available, 1);
    } finally { await cleanup(fx); }
  });

  test('dedupe: second active boost on same job hits 409 BOOST_ALREADY_ACTIVE', async () => {
    const fx = await createFixture();
    try {
      await activateBoost({
        jobId: fx.job.id,
        productCode: 'urgent_24h',
        source: 'admin',
        adminUserId: fx.owner.id,
      });

      await assert.rejects(
        () => activateBoost({
          jobId: fx.job.id,
          productCode: 'top_24h',
          source: 'admin',
          adminUserId: fx.owner.id,
        }),
        (e) => e.code === 'BOOST_ALREADY_ACTIVE' && e.status === 409,
      );
    } finally { await cleanup(fx); }
  });

  test('paused/closed job: rejects with 400 INVALID_JOB_STATE', async () => {
    const fx = await createFixture();
    try {
      await db('jobs').where({ id: fx.job.id }).update({ status: 'paused' });

      await assert.rejects(
        () => activateBoost({
          jobId: fx.job.id,
          productCode: 'urgent_24h',
          source: 'admin',
          adminUserId: fx.owner.id,
        }),
        (e) => e.code === 'INVALID_JOB_STATE' && e.status === 400,
      );
    } finally { await cleanup(fx); }
  });

  test('unknown product: 404 PRODUCT_NOT_FOUND', async () => {
    const fx = await createFixture();
    try {
      await assert.rejects(
        () => activateBoost({
          jobId: fx.job.id,
          productCode: 'definitely_not_real',
          source: 'admin',
          adminUserId: fx.owner.id,
        }),
        (e) => e.code === 'PRODUCT_NOT_FOUND' && e.status === 404,
      );
    } finally { await cleanup(fx); }
  });

  test('credit pack used as boost: 400 PRODUCT_NOT_BOOST', async () => {
    const fx = await createFixture();
    try {
      await assert.rejects(
        () => activateBoost({
          jobId: fx.job.id,
          productCode: 'credit_3',
          source: 'admin',
          adminUserId: fx.owner.id,
        }),
        (e) => e.code === 'PRODUCT_NOT_BOOST' && e.status === 400,
      );
    } finally { await cleanup(fx); }
  });

  test('bundle (fast_hire_pack): persists as boost_type=top', async () => {
    const fx = await createFixture();
    try {
      const result = await activateBoost({
        jobId: fx.job.id,
        productCode: 'fast_hire_pack',
        source: 'admin',
        adminUserId: fx.owner.id,
      });
      assert.equal(result.boost_type, 'top');
      assert.ok(result.boost_priority >= 80);
    } finally { await cleanup(fx); }
  });

  test('credit spend ownership: cross-business jobId rejected', async () => {
    const a = await createFixture();
    const b = await createFixture();
    try {
      await grantCredits(b.biz.id, 5);

      await assert.rejects(
        () => activateBoost({
          jobId: a.job.id,
          businessId: b.biz.id,
          productCode: 'urgent_24h',
          source: 'credit',
        }),
        (e) => e.code === 'JOB_NOT_OWNED' && e.status === 403,
      );

      // Wallet untouched.
      const wallet = await db('business_credit_wallet').where({ business_id: b.biz.id }).first();
      assert.equal(wallet.credits_available, 5);
    } finally {
      await cleanup(a);
      await cleanup(b);
    }
  });

  test('revokeBoost (no refund): flips status, resets jobs, writes audit', async () => {
    const fx = await createFixture();
    try {
      const grant = await activateBoost({
        jobId: fx.job.id,
        productCode: 'urgent_24h',
        source: 'admin',
        adminUserId: fx.owner.id,
      });

      const result = await revokeBoost({
        jobId: fx.job.id,
        adminUserId: fx.owner.id,
        reason: 'test revoke',
      });

      assert.equal(result.revoked, true);
      assert.equal(result.refundedCredits, 0);
      assert.equal(result.boostId, grant.id);

      const boost = await db('job_boosts').where({ id: grant.id }).first();
      assert.equal(boost.status, 'revoked');
      assert.ok(boost.revoked_at);

      const job = await db('jobs').where({ id: fx.job.id }).first();
      assert.equal(job.boost_status, 'revoked');
      assert.equal(job.boost_type, null);

      const audit = await db('job_visibility_events')
        .where({ job_id: fx.job.id, event_type: 'boost_revoked' });
      assert.equal(audit.length, 1);
    } finally { await cleanup(fx); }
  });

  test('revokeBoost with refundCredits=true: re-credits the wallet', async () => {
    const fx = await createFixture();
    try {
      await grantCredits(fx.biz.id, 5);

      await activateBoost({
        jobId: fx.job.id,
        businessId: fx.biz.id,
        productCode: 'top_3d', // 2 credits
        source: 'credit',
      });

      const walletAfterSpend = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(walletAfterSpend.credits_available, 3);

      const result = await revokeBoost({
        jobId: fx.job.id,
        adminUserId: fx.owner.id,
        reason: 'refund test',
        refundCredits: true,
      });
      assert.equal(result.refundedCredits, 2);

      const walletAfterRefund = await db('business_credit_wallet').where({ business_id: fx.biz.id }).first();
      assert.equal(walletAfterRefund.credits_available, 5);

      const refundTx = await db('business_credit_transactions')
        .where({ business_id: fx.biz.id, reason: 'refund' })
        .first();
      assert.equal(refundTx.delta, 2);
      assert.equal(refundTx.balance_after, 5);
    } finally { await cleanup(fx); }
  });

  test('revokeBoost: 404 NO_ACTIVE_BOOST when nothing active', async () => {
    const fx = await createFixture();
    try {
      await assert.rejects(
        () => revokeBoost({ jobId: fx.job.id, adminUserId: fx.owner.id }),
        (e) => e.code === 'NO_ACTIVE_BOOST' && e.status === 404,
      );
    } finally { await cleanup(fx); }
  });

  test('getBoostStatus returns normalised shape', async () => {
    const fx = await createFixture();
    try {
      const before = await getBoostStatus(fx.job.id);
      assert.equal(before.boost_status, 'none');
      assert.equal(before.activeBoost, null);

      await activateBoost({
        jobId: fx.job.id,
        productCode: 'featured',
        source: 'admin',
        adminUserId: fx.owner.id,
      });

      const after = await getBoostStatus(fx.job.id);
      assert.equal(after.boost_status, 'active');
      assert.equal(after.boost_type, 'featured');
      assert.ok(after.activeBoost);
    } finally { await cleanup(fx); }
  });
}
