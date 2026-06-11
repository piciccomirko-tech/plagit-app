/**
 * Premium entitlements — provider-agnostic source of truth.
 *
 * `user_entitlements` rows are written ONLY after server-side validation
 * (verify endpoint + provider webhooks, Step 2). This module derives the
 * premium state the app consumes and exposes the single idempotent upsert
 * that every provider funnels into.
 */
const db = require('../config/db');

// Statuses that grant premium while current_period_end is still in the future.
// `past_due` is honoured during the store's billing-grace window — the provider
// extends current_period_end during grace, so the `> now()` guard bounds it.
const ACTIVE_STATUSES = Object.freeze(['active', 'trialing', 'past_due']);

// Production honours only production entitlements. Enable on a TestFlight/test
// backend so sandbox StoreKit purchases grant premium for QA without paying.
// NEVER enable on the real production server.
function honorSandbox() {
  return process.env.HONOR_SANDBOX_ENTITLEMENTS === 'true';
}

/**
 * The user's effective (furthest-expiring) currently-active entitlement, or
 * null. A user may hold more than one (e.g. bought on iOS then on web) — any
 * active row makes them premium; the furthest period_end is the effective one.
 */
async function getActiveEntitlement(userId) {
  if (!userId) return null;
  let q = db('user_entitlements')
    .where({ user_id: userId })
    .whereIn('status', ACTIVE_STATUSES)
    .where('current_period_end', '>', db.fn.now())
    .orderBy('current_period_end', 'desc');
  if (!honorSandbox()) q = q.where({ environment: 'production' });
  return (await q.first()) || null;
}

async function isPremium(userId) {
  return (await getActiveEntitlement(userId)) !== null;
}

/**
 * Idempotent upsert keyed on (provider, provider_ref). The single convergence
 * point for the verify endpoint AND every provider webhook — renewals,
 * cancellations and re-validations update the SAME row. The fields MUST come
 * from the provider's server API (validated), never from the client.
 */
async function upsertEntitlement(e) {
  const row = {
    user_id: e.userId,
    product: e.product,
    plan: e.plan,
    provider: e.provider,
    provider_ref: e.providerRef,
    status: e.status,
    current_period_start: e.currentPeriodStart || null,
    current_period_end: e.currentPeriodEnd || null,
    trial_end: e.trialEnd || null,
    cancel_at_period_end: e.cancelAtPeriodEnd === true,
    environment: e.environment || 'production',
    raw_payload: e.rawPayload || null,
    updated_at: db.fn.now(),
  };
  const [out] = await db('user_entitlements')
    .insert(row)
    .onConflict(['provider', 'provider_ref'])
    .merge() // existing row (same subscription) is updated in place
    .returning('*');
  return out;
}

/**
 * Premium block for GET /v1/subscription/status. Additive: the app reads
 * `is_premium`; the rest is informational for the manage screen. `provider`
 * is informational only — the app must NOT branch on it.
 */
async function buildPremiumStatus(userId) {
  const ent = await getActiveEntitlement(userId);
  if (!ent) return { is_premium: false, premium: null };
  return {
    is_premium: true,
    premium: {
      product: ent.product,
      plan: ent.plan,
      status: ent.status,
      trial: ent.status === 'trialing',
      current_period_end: ent.current_period_end
        ? new Date(ent.current_period_end).toISOString()
        : null,
      cancel_at_period_end: ent.cancel_at_period_end === true,
      provider: ent.provider,
    },
  };
}

module.exports = {
  ACTIVE_STATUSES,
  getActiveEntitlement,
  isPremium,
  upsertEntitlement,
  buildPremiumStatus,
};
