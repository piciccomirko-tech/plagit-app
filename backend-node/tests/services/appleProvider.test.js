/**
 * Unit test: Apple provider PURE mapping + status lifecycle (Payments Step 2
 * scaffolding). No credentials, no JWS signature verification, no DB queries —
 * exercises the credential-free logic with mock decoded StoreKit 2 payloads.
 * Runs in the default suite.
 */

'use strict';

require('dotenv').config({ quiet: true });
const test = require('node:test');
const assert = require('node:assert/strict');

const { _internal } = require('../../src/services/providers/apple');
const {
  PRODUCT_PLAN, mapEnvironment, isFreeTrial, transactionToEntitlement, notificationStatusHint,
} = _internal;

const USER = 'user-123';
const NOW = Date.now();
const FUTURE = NOW + 30 * 24 * 60 * 60 * 1000;
const PAST = NOW - 24 * 60 * 60 * 1000;

function tx(over = {}) {
  return {
    productId: 'com.plagit.premium.monthly',
    originalTransactionId: 'ot-1',
    purchaseDate: NOW,
    expiresDate: FUTURE,
    environment: 'Sandbox',
    type: 'Auto-Renewable Subscription',
    ...over,
  };
}

test('product → plan mapping', () => {
  assert.deepEqual(PRODUCT_PLAN['com.plagit.premium.monthly'], { product: 'plagit_premium', plan: 'monthly' });
  assert.deepEqual(PRODUCT_PLAN['com.plagit.premium.yearly'], { product: 'plagit_premium', plan: 'yearly' });
});

test('mapEnvironment: Production→production, else sandbox', () => {
  assert.equal(mapEnvironment('Production'), 'production');
  assert.equal(mapEnvironment('Sandbox'), 'sandbox');
  assert.equal(mapEnvironment(undefined), 'sandbox');
});

test('active subscription → status active + correct entitlement fields', () => {
  const e = transactionToEntitlement(tx(), USER, null);
  assert.equal(e.status, 'active');
  assert.equal(e.product, 'plagit_premium');
  assert.equal(e.plan, 'monthly');
  assert.equal(e.provider, 'apple');
  assert.equal(e.providerRef, 'ot-1');
  assert.equal(e.environment, 'sandbox');
  assert.equal(e.currentPeriodEnd.getTime(), FUTURE);
  assert.equal(e.cancelAtPeriodEnd, false);
});

test('expired (expiresDate in the past) → status expired', () => {
  assert.equal(transactionToEntitlement(tx({ expiresDate: PAST }), USER, null).status, 'expired');
});

test('intro free-trial offer → status trialing + trialEnd', () => {
  const e = transactionToEntitlement(tx({ offerType: 1 }), USER, { offerDiscountType: 'FREE_TRIAL' });
  assert.equal(e.status, 'trialing');
  assert.ok(e.trialEnd instanceof Date);
});

test('revoked (refund) → status cancelled', () => {
  assert.equal(transactionToEntitlement(tx({ revocationDate: NOW }), USER, null).status, 'cancelled');
});

test('auto-renew off → cancelAtPeriodEnd true, still active until expiry', () => {
  const e = transactionToEntitlement(tx(), USER, { autoRenewStatus: 0 });
  assert.equal(e.cancelAtPeriodEnd, true);
  assert.equal(e.status, 'active');
});

test('yearly product → yearly plan', () => {
  assert.equal(transactionToEntitlement(tx({ productId: 'com.plagit.premium.yearly' }), USER, null).plan, 'yearly');
});

test('unknown product → null (ignored)', () => {
  assert.equal(transactionToEntitlement(tx({ productId: 'com.other.thing' }), USER, null), null);
});

test('isFreeTrial: renewal FREE_TRIAL wins, else offerType=1', () => {
  assert.equal(isFreeTrial({ offerType: 0 }, { offerDiscountType: 'FREE_TRIAL' }), true);
  assert.equal(isFreeTrial({ offerType: 1 }, null), true);
  assert.equal(isFreeTrial({ offerType: 0 }, null), false);
});

test('notification status hints (ASSN V2 lifecycle)', () => {
  assert.equal(notificationStatusHint('SUBSCRIBED'), 'active');
  assert.equal(notificationStatusHint('DID_RENEW'), 'active');
  assert.equal(notificationStatusHint('EXPIRED'), 'expired');
  assert.equal(notificationStatusHint('REFUND'), 'cancelled');
  assert.equal(notificationStatusHint('REVOKE'), 'cancelled');
  assert.equal(notificationStatusHint('DID_FAIL_TO_RENEW', 'GRACE_PERIOD'), 'past_due');
  assert.equal(notificationStatusHint('DID_FAIL_TO_RENEW', undefined), 'expired');
  assert.equal(notificationStatusHint('DID_CHANGE_RENEWAL_STATUS'), null);
});

test('teardown: close db pool (apple.js requires db on load)', async () => {
  await require('../../src/config/db').destroy();
});
