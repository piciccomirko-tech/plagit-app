/**
 * Integration tests for businessWalletController (Step 6B).
 *
 *   GET /v1/business/wallet  — read-only, scoped to logged-in business.
 *
 * Hits a real local Postgres (knex development) and invokes the
 * controller handler directly with a mocked req/res — same pattern as
 * tests/controllers/productCatalog.test.js. We don't boot express
 * because the auth middleware itself isn't under test here; what's
 * under test is the controller's own business-scoped resolution and
 * the cross-tenant isolation guarantee.
 *
 * Skipped automatically unless BOOST_ACTIVATION_TESTS=1.
 *
 * Each test creates throw-away businesses + admin user, exercises the
 * handler, and rolls everything back via cleanup() in finally.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.BOOST_ACTIVATION_TESTS === '1';

if (!RUN) {
  test('businessWallet integration tests skipped (set BOOST_ACTIVATION_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const db = require('../../src/config/db');
  const { getMyWallet } = require('../../src/controllers/businessWalletController');
  const { grantCredits } = require('../../src/services/walletGrant');

  // ── helpers ─────────────────────────────────────────────────────────
  function mockRes() {
    const state = { status: 200, body: null };
    return {
      _state: state,
      status(code) { state.status = code; return this; },
      json(body) { state.body = body; return this; },
    };
  }

  // Invoke handler with a mock req carrying req.user.id; capture either
  // the json body or the error pushed to next().
  async function call(userId) {
    const res = mockRes();
    let nextErr = null;
    await getMyWallet({ user: { id: userId } }, res, (e) => { nextErr = e; });
    if (nextErr) throw nextErr;
    return res._state.body;
  }

  async function createOwner() {
    const stamp = `${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
    return db('users').insert({
      email: `bizwallet-owner-${stamp}@plagit.test`,
      password_hash: 'x',
      name: 'BizWallet Owner',
      user_type: 'business',
    }).returning('*').then((r) => r[0]);
  }

  async function createCandidate() {
    const stamp = `${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
    return db('users').insert({
      email: `bizwallet-cand-${stamp}@plagit.test`,
      password_hash: 'x',
      name: 'BizWallet Cand',
      user_type: 'candidate',
    }).returning('*').then((r) => r[0]);
  }

  async function createAdmin() {
    const stamp = `${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
    return db('users').insert({
      email: `bizwallet-admin-${stamp}@plagit.test`,
      password_hash: 'x',
      name: 'BizWallet Admin',
      user_type: 'admin',
    }).returning('*').then((r) => r[0]);
  }

  async function createBiz(ownerId) {
    return db('businesses').insert({
      user_id: ownerId,
      name: 'BizWallet Co',
    }).returning('*').then((r) => r[0]);
  }

  async function createFixture() {
    const owner = await createOwner();
    const admin = await createAdmin();
    const biz = await createBiz(owner.id);
    return { owner, admin, biz };
  }

  async function cleanupBiz(biz) {
    if (!biz) return;
    await db('business_credit_transactions').where({ business_id: biz.id }).del();
    await db('business_credit_wallet').where({ business_id: biz.id }).del();
    await db('businesses').where({ id: biz.id }).del();
  }

  async function cleanupUser(u) {
    if (u) await db('users').where({ id: u.id }).del();
  }

  // ── tests ───────────────────────────────────────────────────────────
  test.after(async () => { await db.destroy(); });

  test('happy: business with wallet + txs → 200 full DTO', async () => {
    const fx = await createFixture();
    try {
      await grantCredits({
        businessId: fx.biz.id,
        credits: 7,
        reason: 'launch',
        note: 'welcome',
        adminUserId: fx.admin.id,
      });

      const body = await call(fx.owner.id);

      assert.equal(body.success, true);
      const d = body.data;
      assert.equal(d.businessId, fx.biz.id);
      assert.equal(d.walletId, fx.biz.id);
      assert.equal(d.creditsAvailable, 7);
      assert.equal(d.creditsSpent, 0);
      assert.equal(d.creditsTotalPurchased, 0);
      assert.equal(d.creditsTotalComped, 7);
      assert.ok(d.lastRechargeAt);
      assert.equal(d.recentTransactions.length, 1);

      const tx = d.recentTransactions[0];
      assert.equal(tx.transactionType, 'grant');
      assert.equal(tx.reason, 'admin_grant');
      assert.equal(tx.creditsDelta, 7);
      assert.equal(tx.creditsBefore, 0);
      assert.equal(tx.creditsAfter, 7);
      assert.equal(tx.note, '[launch] welcome');
      assert.equal(tx.adminUserId, fx.admin.id);
    } finally {
      await cleanupBiz(fx.biz);
      await cleanupUser(fx.owner);
      await cleanupUser(fx.admin);
    }
  });

  test('happy: business with NO wallet row → 200 safe-zero DTO', async () => {
    const fx = await createFixture();
    try {
      const body = await call(fx.owner.id);

      assert.equal(body.success, true);
      assert.deepEqual(body.data, {
        businessId: fx.biz.id,
        walletId: null,
        creditsAvailable: 0,
        creditsSpent: 0,
        creditsTotalPurchased: 0,
        creditsTotalComped: 0,
        lastRechargeAt: null,
        recentTransactions: [],
      });
    } finally {
      await cleanupBiz(fx.biz);
      await cleanupUser(fx.owner);
      await cleanupUser(fx.admin);
    }
  });

  test('recentTransactions DESC by created_at, cap 20', async () => {
    const fx = await createFixture();
    try {
      // Seed 25 grants — 1 credit each, sequential so created_at strictly increases.
      for (let i = 0; i < 25; i += 1) {
        // eslint-disable-next-line no-await-in-loop
        await grantCredits({
          businessId: fx.biz.id,
          credits: 1,
          reason: `n${i}`,
          adminUserId: fx.admin.id,
        });
      }

      const body = await call(fx.owner.id);
      const txs = body.data.recentTransactions;

      assert.equal(txs.length, 20);
      // DESC: each entry's createdAt >= the next entry's createdAt.
      for (let i = 0; i < txs.length - 1; i += 1) {
        assert.ok(
          new Date(txs[i].createdAt).getTime() >= new Date(txs[i + 1].createdAt).getTime(),
          `tx[${i}] not DESC`,
        );
      }
      // Newest seeded grant was n24 — must appear first.
      assert.equal(txs[0].note, '[n24]');
      // Oldest seeded grant inside the window of 20 is n5.
      assert.equal(txs[19].note, '[n5]');
    } finally {
      await cleanupBiz(fx.biz);
      await cleanupUser(fx.owner);
      await cleanupUser(fx.admin);
    }
  });

  test('cross-tenant isolation: Business A login NEVER sees Business B data', async () => {
    const ownerA = await createOwner();
    const ownerB = await createOwner();
    const admin = await createAdmin();
    const bizA = await createBiz(ownerA.id);
    const bizB = await createBiz(ownerB.id);

    try {
      // Seed both wallets with distinct amounts + ledger rows.
      await grantCredits({
        businessId: bizA.id, credits: 3, reason: 'A-only', adminUserId: admin.id,
      });
      await grantCredits({
        businessId: bizB.id, credits: 99, reason: 'B-only', adminUserId: admin.id,
      });

      const aBody = await call(ownerA.id);
      const bBody = await call(ownerB.id);

      // A sees only A.
      assert.equal(aBody.data.businessId, bizA.id);
      assert.equal(aBody.data.creditsAvailable, 3);
      assert.equal(aBody.data.recentTransactions.length, 1);
      assert.equal(aBody.data.recentTransactions[0].note, '[A-only]');
      assert.notEqual(aBody.data.businessId, bizB.id);

      // B sees only B.
      assert.equal(bBody.data.businessId, bizB.id);
      assert.equal(bBody.data.creditsAvailable, 99);
      assert.equal(bBody.data.recentTransactions.length, 1);
      assert.equal(bBody.data.recentTransactions[0].note, '[B-only]');
      assert.notEqual(bBody.data.businessId, bizA.id);
    } finally {
      await cleanupBiz(bizA);
      await cleanupBiz(bizB);
      await cleanupUser(ownerA);
      await cleanupUser(ownerB);
      await cleanupUser(admin);
    }
  });

  test('user with no business profile → 404 BUSINESS_NOT_FOUND', async () => {
    const cand = await createCandidate();
    try {
      await assert.rejects(
        () => call(cand.id),
        (e) => e.code === 'BUSINESS_NOT_FOUND' && e.status === 404,
      );
    } finally {
      await cleanupUser(cand);
    }
  });

  test('admin user with no business profile → 404 BUSINESS_NOT_FOUND', async () => {
    const admin = await createAdmin();
    try {
      await assert.rejects(
        () => call(admin.id),
        (e) => e.code === 'BUSINESS_NOT_FOUND' && e.status === 404,
      );
    } finally {
      await cleanupUser(admin);
    }
  });

  test('read-only idempotency: 3 calls in a row leave row counts unchanged', async () => {
    const fx = await createFixture();
    try {
      await grantCredits({
        businessId: fx.biz.id, credits: 4, reason: 'seed', adminUserId: fx.admin.id,
      });

      async function rowCounts() {
        const [w, t] = await Promise.all([
          db('business_credit_wallet').where({ business_id: fx.biz.id }).count('* as c').first(),
          db('business_credit_transactions').where({ business_id: fx.biz.id }).count('* as c').first(),
        ]);
        return { wallets: Number(w.c), txs: Number(t.c) };
      }

      const before = await rowCounts();

      await call(fx.owner.id);
      await call(fx.owner.id);
      await call(fx.owner.id);

      const after = await rowCounts();
      assert.deepEqual(after, before);
    } finally {
      await cleanupBiz(fx.biz);
      await cleanupUser(fx.owner);
      await cleanupUser(fx.admin);
    }
  });
}
