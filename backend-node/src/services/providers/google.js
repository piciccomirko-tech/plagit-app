/**
 * Google Play Billing — validation STRUCTURE ONLY (Payments Step 1).
 *
 * Step 2 will: validate the purchaseToken via the Play Developer API
 * (purchases.subscriptionsv2.get) with a service account, map the
 * subscriptionState to an entitlement, and call entitlements.upsertEntitlement().
 * Real-time Developer Notifications (Pub/Sub) will keep it fresh.
 *
 * Until then this throws, so an unvalidated purchase can NEVER grant premium.
 *
 * Products (new, clean): plagit_premium_monthly | plagit_premium_yearly
 */
const AppError = require('../../utils/AppError');

// eslint-disable-next-line no-unused-vars
async function validatePurchase({ userId, purchaseToken, productId } = {}) {
  throw new AppError(
    'Google purchase validation not implemented yet (Payments Step 2).',
    501,
    'NOT_IMPLEMENTED',
  );
}

module.exports = { validatePurchase };
