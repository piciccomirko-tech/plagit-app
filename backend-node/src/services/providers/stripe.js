/**
 * Stripe (web) — validation STRUCTURE ONLY (Payments Step 1).
 *
 * Step 2 will: verify the webhook signature (whsec_…), handle
 * checkout.session.completed + customer.subscription.* events, map the
 * subscription to an entitlement, and call entitlements.upsertEntitlement().
 * Stripe is webhook-driven (no client→verify call needed).
 *
 * Until then this throws, so no unvalidated event can grant premium.
 *
 * Products (new, clean): Stripe Price objects for monthly | yearly (GBP base).
 */
const AppError = require('../../utils/AppError');

// eslint-disable-next-line no-unused-vars
async function handleWebhookEvent({ signature, rawBody } = {}) {
  throw new AppError(
    'Stripe webhook handling not implemented yet (Payments Step 2).',
    501,
    'NOT_IMPLEMENTED',
  );
}

module.exports = { handleWebhookEvent };
