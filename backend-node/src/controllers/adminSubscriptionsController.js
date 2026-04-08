const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const { log } = require('../services/logService');
const AppError = require('../utils/AppError');

// Price map for display
const PRICE_MAP = {
  candidate_monthly: 9, candidate_annual: 90,
  business_basic_monthly: 19, business_basic_annual: 190,
  business_pro_monthly: 29, business_pro_annual: 290,
  business_premium_monthly: 49, business_premium_annual: 490,
};

// ---------------------------------------------------------------------------
// GET /admin/subscriptions — List all subscribers
// ---------------------------------------------------------------------------
async function list(req, res, next) {
  try {
    const { page = 1, limit = 50, status, user_type, search } = req.query;

    let base = db('users')
      .whereNot('subscription_plan', 'free')
      .where('subscription_status', '!=', 'inactive');

    if (status) base = base.where('subscription_status', status);
    if (user_type) {
      if (user_type === 'candidate') base = base.where('user_type', 'candidate');
      else if (user_type.startsWith('biz_')) {
        base = base.where('user_type', 'business').whereILike('subscription_plan', `%${user_type.replace('biz_', '')}%`);
      } else {
        base = base.where('user_type', user_type);
      }
    }
    if (search) base = base.where((b) => b.whereILike('name', `%${search}%`).orWhereILike('email', `%${search}%`));

    const total = await base.clone().count('* as c').first().then(r => +r.c);
    const rows = await base.clone()
      .select(
        'id', 'name', 'email', 'user_type', 'avatar_hue',
        'subscription_plan', 'subscription_status', 'subscription_expires',
        'subscription_product_id', 'subscription_auto_renew',
        'subscription_payment_state', 'subscription_grace_end', 'subscription_trial_end',
        'created_at'
      )
      .orderBy('subscription_expires', 'asc')
      .limit(+limit).offset((+page - 1) * +limit);

    // Format for admin display
    const formatted = rows.map(u => {
      const plan = u.subscription_plan || 'free';
      const isAnnual = plan.includes('annual');
      const initials = (u.name || '').split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2);
      return {
        id: u.id,
        user_name: u.name,
        user_email: u.email,
        user_type: u.user_type,
        user_initials: initials,
        avatar_hue: u.avatar_hue,
        plan,
        status: u.subscription_status,
        billing_cycle: isAnnual ? 'annual' : 'monthly',
        amount: PRICE_MAP[plan] || 0,
        renewal_date: u.subscription_expires,
        auto_renew: u.subscription_auto_renew ?? true,
        payment_state: u.subscription_payment_state || 'paid',
        grace_end: u.subscription_grace_end,
        trial_end: u.subscription_trial_end,
        product_id: u.subscription_product_id,
        created_at: u.created_at,
      };
    });

    paginated(res, formatted, { page: +page, limit: +limit, total });
  } catch (e) { next(e); }
}

// ---------------------------------------------------------------------------
// GET /admin/subscriptions/stats — Billing metrics
// ---------------------------------------------------------------------------
async function stats(req, res, next) {
  try {
    const users = await db('users')
      .whereNot('subscription_plan', 'free')
      .select('subscription_plan', 'subscription_status', 'user_type', 'subscription_payment_state', 'subscription_auto_renew', 'subscription_expires');

    const now = new Date();
    const active = users.filter(u => u.subscription_status === 'active');
    const expired = users.filter(u => u.subscription_status === 'expired');
    const cancelled = users.filter(u => u.subscription_status === 'cancelled');
    const trial = users.filter(u => u.subscription_status === 'trial');
    const grace = users.filter(u => u.subscription_status === 'grace');
    const failedPayment = users.filter(u => u.subscription_payment_state === 'failed');
    const autoRenewOff = users.filter(u => u.subscription_auto_renew === false && u.subscription_status === 'active');

    // Expiring within 7 days
    const sevenDays = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
    const expiringSoon = active.filter(u => u.subscription_expires && new Date(u.subscription_expires) <= sevenDays);

    // MRR calculation
    let mrr = 0;
    for (const u of active) {
      const price = PRICE_MAP[u.subscription_plan] || 0;
      if (u.subscription_plan?.includes('annual')) mrr += price / 12;
      else mrr += price;
    }

    ok(res, {
      total_subscriptions: users.length,
      active_count: active.length,
      trial_count: trial.length,
      expired_count: expired.length,
      cancelled_count: cancelled.length,
      grace_count: grace.length,
      failed_payment_count: failedPayment.length,
      expiring_soon_count: expiringSoon.length,
      auto_renew_off_count: autoRenewOff.length,
      candidate_count: users.filter(u => u.user_type === 'candidate').length,
      business_count: users.filter(u => u.user_type === 'business').length,
      monthly_count: users.filter(u => u.subscription_plan?.includes('monthly')).length,
      annual_count: users.filter(u => u.subscription_plan?.includes('annual')).length,
      mrr: Math.round(mrr * 100) / 100,
    });
  } catch (e) { next(e); }
}

// ---------------------------------------------------------------------------
// PATCH /admin/subscriptions/:id/status — Update subscription status
// ---------------------------------------------------------------------------
async function updateStatus(req, res, next) {
  try {
    const { status } = req.body;
    if (!status) throw AppError.badRequest('Status is required.');
    await db('users').where({ id: req.params.id }).update({ subscription_status: status, updated_at: db.fn.now() });
    await log(req.user.email, `Subscription status → ${status}`, req.params.id, 'Billing');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

// ---------------------------------------------------------------------------
// PATCH /admin/subscriptions/:id/plan — Upgrade or downgrade plan
// ---------------------------------------------------------------------------
async function updatePlan(req, res, next) {
  try {
    const { plan } = req.body;
    if (!plan) throw AppError.badRequest('Plan is required.');
    await db('users').where({ id: req.params.id }).update({ subscription_plan: plan, updated_at: db.fn.now() });
    await log(req.user.email, `Updated plan to ${plan}`, req.params.id, 'Billing');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

// ---------------------------------------------------------------------------
// POST /admin/subscriptions/:id/cancel — Cancel subscription
// ---------------------------------------------------------------------------
async function cancel(req, res, next) {
  try {
    await db('users').where({ id: req.params.id }).update({
      subscription_status: 'cancelled',
      subscription_auto_renew: false,
      updated_at: db.fn.now(),
    });
    await log(req.user.email, 'Cancelled subscription', req.params.id, 'Billing');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

// ---------------------------------------------------------------------------
// POST /admin/subscriptions/:id/extend-trial — Extend trial period
// ---------------------------------------------------------------------------
async function extendTrial(req, res, next) {
  try {
    const { days = 7 } = req.body;
    const trialEnd = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
    await db('users').where({ id: req.params.id }).update({
      subscription_status: 'trial',
      subscription_trial_end: trialEnd,
      subscription_expires: trialEnd,
      updated_at: db.fn.now(),
    });
    await log(req.user.email, `Extended trial by ${days} days`, req.params.id, 'Billing');
    ok(res, { success: true, trial_end: trialEnd.toISOString() });
  } catch (e) { next(e); }
}

// ---------------------------------------------------------------------------
// POST /admin/subscriptions/:id/comp — Grant complimentary access
// ---------------------------------------------------------------------------
async function compAccess(req, res, next) {
  try {
    const { plan, days = 30 } = req.body;
    if (!plan) throw AppError.badRequest('Plan is required.');
    const expiresAt = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
    await db('users').where({ id: req.params.id }).update({
      subscription_plan: plan,
      subscription_status: 'comp',
      subscription_expires: expiresAt,
      subscription_payment_state: 'comp',
      updated_at: db.fn.now(),
    });
    await log(req.user.email, `Granted comp ${plan} for ${days} days`, req.params.id, 'Billing');
    ok(res, { success: true });
  } catch (e) { next(e); }
}

module.exports = { list, stats, updateStatus, updatePlan, cancel, extendTrial, compAccess };
