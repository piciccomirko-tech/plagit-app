const db = require('../config/db');
const { ok } = require('../utils/response');
const AppError = require('../utils/AppError');
const entitlements = require('../services/entitlements');
const apple = require('../services/providers/apple');

async function verifyReceipt(req, res, next) {
  try {
    // Payments Step 2 — Apple StoreKit 2 path → provider-agnostic
    // user_entitlements. Validates the signed JWS server-side and upserts the
    // entitlement; returns the derived premium status. The legacy
    // candidate/business path (users.subscription_*) below is untouched and
    // still serves callers that don't send `provider`.
    if (req.body && req.body.provider === 'apple') {
      await apple.validatePurchase({ userId: req.user.id, jws: req.body.jws });
      const status = await entitlements.buildPremiumStatus(req.user.id);
      return ok(res, status);
    }

    const { signed_transaction, product_id } = req.body;
    if (!product_id) throw AppError.badRequest('product_id is required.');

    // Determine plan from product ID
    const planMap = {
      'com.plagit.candidate.monthly': 'candidate_monthly',
      'com.plagit.candidate.annual': 'candidate_annual',
      'com.plagit.business.basic.monthly': 'business_basic_monthly',
      'com.plagit.business.basic.annual': 'business_basic_annual',
      'com.plagit.business.pro.monthly': 'business_pro_monthly',
      'com.plagit.business.pro.annual': 'business_pro_annual',
      'com.plagit.business.premium.monthly': 'business_premium_monthly',
      'com.plagit.business.premium.annual': 'business_premium_annual',
    };
    const plan = planMap[product_id];
    if (!plan) throw AppError.badRequest('Invalid product ID.');

    // Calculate expiry based on plan type
    const isAnnual = product_id.includes('annual');
    const expiresAt = new Date(Date.now() + (isAnnual ? 365 : 30) * 24 * 60 * 60 * 1000);

    // Update user subscription
    await db('users').where({ id: req.user.id }).update({
      subscription_plan: plan,
      subscription_status: 'active',
      subscription_expires: expiresAt,
      subscription_product_id: product_id,
      original_transaction_id: signed_transaction ? signed_transaction.substring(0, 128) : null,
      updated_at: db.fn.now(),
    });

    ok(res, {
      subscription_plan: plan,
      subscription_status: 'active',
      subscription_expires: expiresAt.toISOString(),
    });
  } catch (err) { next(err); }
}

async function getStatus(req, res, next) {
  try {
    const user = await db('users')
      .where({ id: req.user.id })
      .select('subscription_plan', 'subscription_status', 'subscription_expires', 'subscription_product_id')
      .first();
    if (!user) throw AppError.notFound('User not found.');

    // Check if subscription has expired (with grace period)
    let status = user.subscription_status || 'inactive';
    let plan = user.subscription_plan || 'free';
    const now = new Date();

    if (user.subscription_expires && new Date(user.subscription_expires) < now) {
      // Check grace period (7 days after expiry)
      const graceEnd = new Date(new Date(user.subscription_expires).getTime() + 7 * 24 * 60 * 60 * 1000);
      if (now < graceEnd && status === 'active') {
        status = 'grace';
        await db('users').where({ id: req.user.id }).update({
          subscription_status: 'grace',
          subscription_grace_end: graceEnd,
        });
      } else if (now >= graceEnd || status !== 'grace') {
        status = 'expired';
        plan = 'free';
        await db('users').where({ id: req.user.id }).update({
          subscription_plan: 'free',
          subscription_status: 'expired',
          subscription_payment_state: 'none',
        });
      }
    }

    // Payments Step 1 — provider-agnostic premium derived from
    // user_entitlements (the new source of truth). Additive: `is_premium`
    // + `premium` are the fields the app will read; the legacy
    // subscription_* fields are kept untouched for backward-compat.
    const premium = await entitlements.buildPremiumStatus(req.user.id);

    ok(res, {
      ...premium,
      subscription_plan: plan,
      subscription_status: status,
      subscription_expires: user.subscription_expires ? new Date(user.subscription_expires).toISOString() : null,
      subscription_product_id: user.subscription_product_id || null,
    });
  } catch (err) { next(err); }
}

async function restorePurchase(req, res, next) {
  try {
    const { original_transaction_id, product_id } = req.body;
    if (!product_id) throw AppError.badRequest('product_id is required.');

    const planMap = {
      'com.plagit.candidate.monthly': 'candidate_monthly',
      'com.plagit.candidate.annual': 'candidate_annual',
      'com.plagit.business.basic.monthly': 'business_basic_monthly',
      'com.plagit.business.basic.annual': 'business_basic_annual',
      'com.plagit.business.pro.monthly': 'business_pro_monthly',
      'com.plagit.business.pro.annual': 'business_pro_annual',
      'com.plagit.business.premium.monthly': 'business_premium_monthly',
      'com.plagit.business.premium.annual': 'business_premium_annual',
    };
    const plan = planMap[product_id];
    if (!plan) throw AppError.badRequest('Invalid product ID.');

    const isAnnual = product_id.includes('annual');
    const expiresAt = new Date(Date.now() + (isAnnual ? 365 : 30) * 24 * 60 * 60 * 1000);

    await db('users').where({ id: req.user.id }).update({
      subscription_plan: plan,
      subscription_status: 'active',
      subscription_expires: expiresAt,
      subscription_product_id: product_id,
      original_transaction_id: original_transaction_id || null,
      updated_at: db.fn.now(),
    });

    ok(res, {
      subscription_plan: plan,
      subscription_status: 'active',
      subscription_expires: expiresAt.toISOString(),
    });
  } catch (err) { next(err); }
}

module.exports = { verifyReceipt, getStatus, restorePurchase };
