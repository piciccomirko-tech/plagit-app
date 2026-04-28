/**
 * Integration tests for productCatalogController.
 *
 * Hits the real local Postgres (knex development) and invokes the
 * controller directly with a mock req/res so we exercise the SQL path
 * + DTO mapping without booting express. Skipped automatically unless
 * BOOST_ACTIVATION_TESTS=1 (same gate as the boostActivation suite).
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.BOOST_ACTIVATION_TESTS === '1';

if (!RUN) {
  test('productCatalog integration tests skipped (set BOOST_ACTIVATION_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const db = require('../../src/config/db');
  const {
    listJobProducts,
    deriveProductType,
    toDto,
  } = require('../../src/controllers/productCatalogController');

  // ── helpers ─────────────────────────────────────────────────────────
  function mockRes() {
    const state = { status: 200, body: null };
    return {
      _state: state,
      status(code) { state.status = code; return this; },
      json(body) { state.body = body; return this; },
    };
  }

  async function call() {
    const res = mockRes();
    let nextErr = null;
    await listJobProducts({}, res, (e) => { nextErr = e; });
    if (nextErr) throw nextErr;
    return res._state.body;
  }

  // ── tests ───────────────────────────────────────────────────────────
  test.after(async () => { await db.destroy(); });

  test('GET /business/job-products: 200 + 11 seeded active products', async () => {
    const body = await call();
    assert.equal(body.success, true);
    assert.ok(Array.isArray(body.data));
    assert.equal(body.data.length, 11);
  });

  test('DTO shape matches Phase-1 contract (12 keys, no leakage)', async () => {
    const body = await call();
    const sample = body.data[0];
    const expected = [
      'id', 'code', 'name', 'description',
      'product_type', 'price', 'currency',
      'credits_cost', 'duration_hours',
      'boost_priority', 'is_active', 'display_order',
    ].sort();
    assert.deepEqual(Object.keys(sample).sort(), expected);
    // Ensure raw DB internals never leak.
    assert.equal(sample.is_bundle, undefined);
    assert.equal(sample.bundle_contents, undefined);
    assert.equal(sample.apple_product_id, undefined);
    assert.equal(sample.google_product_id, undefined);
    assert.equal(sample.stripe_price_id, undefined);
    assert.equal(sample.price_minor, undefined);
    assert.equal(sample.sort_order, undefined);
  });

  test('sorted by display_order ASC', async () => {
    const body = await call();
    const orders = body.data.map((p) => p.display_order);
    const sorted = [...orders].sort((a, b) => a - b);
    assert.deepEqual(orders, sorted);
  });

  test('inactive product hidden after temporary flag-flip', async () => {
    const target = await db('job_products').where({ code: 'urgent_24h' }).first();
    try {
      await db('job_products').where({ id: target.id }).update({ is_active: false });
      const body = await call();
      assert.equal(body.data.length, 10);
      assert.ok(!body.data.some((p) => p.code === 'urgent_24h'));
    } finally {
      await db('job_products').where({ id: target.id }).update({ is_active: true });
    }
  });

  test('safe fallback empty array when nothing active', async () => {
    // Snapshot ids we toggle so we can restore — and so a parallel test
    // can't see them as inactive forever.
    const all = await db('job_products').where({ is_active: true }).select('id');
    try {
      await db('job_products').whereIn('id', all.map((r) => r.id)).update({ is_active: false });
      const body = await call();
      assert.equal(body.success, true);
      assert.deepEqual(body.data, []);
    } finally {
      await db('job_products').whereIn('id', all.map((r) => r.id)).update({ is_active: true });
    }
  });

  test('product_type derivation: bundle > credit_pack > boost_type > other', () => {
    assert.equal(deriveProductType({ is_bundle: true, boost_type: 'top' }), 'bundle');
    assert.equal(deriveProductType({ is_bundle: false, credits_granted: 5 }), 'credit_pack');
    assert.equal(deriveProductType({ boost_type: 'urgent' }), 'urgent');
    assert.equal(deriveProductType({ boost_type: 'top' }), 'top');
    assert.equal(deriveProductType({ boost_type: 'featured' }), 'featured');
    assert.equal(deriveProductType({}), 'other');
  });

  test('price field carries minor units (integer pence)', async () => {
    const body = await call();
    const urgent24 = body.data.find((p) => p.code === 'urgent_24h');
    assert.equal(urgent24.price, 499);
    assert.equal(urgent24.currency, 'GBP');
    assert.equal(Number.isInteger(urgent24.price), true);
  });

  test('credits_cost surfaced per approved table', async () => {
    const body = await call();
    const byCode = Object.fromEntries(body.data.map((p) => [p.code, p.credits_cost]));
    assert.equal(byCode.urgent_24h, 1);
    assert.equal(byCode.urgent_3d, 2);
    assert.equal(byCode.urgent_7d, 3);
    assert.equal(byCode.top_24h, 1);
    assert.equal(byCode.top_3d, 2);
    assert.equal(byCode.top_7d, 4);
    assert.equal(byCode.featured, 2);
    assert.equal(byCode.fast_hire_pack, 5);
  });

  test('toDto unit: maps fields without DB hit', () => {
    const row = {
      id: 'uuid-1',
      code: 'urgent_24h',
      name: 'Urgent — 24h',
      description: 'desc',
      boost_type: 'urgent',
      boost_priority: 25,
      duration_hours: 24,
      price_minor: 499,
      currency: 'GBP',
      credits_granted: 0,
      credits_cost: 1,
      is_bundle: false,
      is_active: true,
      sort_order: 10,
    };
    const dto = toDto(row);
    assert.equal(dto.product_type, 'urgent');
    assert.equal(dto.price, 499);
    assert.equal(dto.display_order, 10);
    assert.equal(dto.credits_cost, 1);
    assert.equal(dto.is_active, true);
  });
}
