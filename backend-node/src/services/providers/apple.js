/**
 * Apple In-App Purchase — validation STRUCTURE ONLY (Payments Step 1).
 *
 * Step 2 will: verify the StoreKit 2 JWS signed transaction (signature + chain),
 * query the App Store Server API for the subscription's current state, map it to
 * an entitlement, and call entitlements.upsertEntitlement(). App Store Server
 * Notifications V2 will keep it fresh on renewal/cancel/refund.
 *
 * Until then this throws, so an unvalidated purchase can NEVER grant premium.
 *
 * Products (new, clean): com.plagit.premium.monthly | com.plagit.premium.yearly
 */
const AppError = require('../../utils/AppError');

// eslint-disable-next-line no-unused-vars
async function validatePurchase({ userId, jwsTransaction } = {}) {
  throw new AppError(
    'Apple purchase validation not implemented yet (Payments Step 2).',
    501,
    'NOT_IMPLEMENTED',
  );
}

module.exports = { validatePurchase };
