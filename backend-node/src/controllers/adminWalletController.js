/**
 * Admin wallet endpoints.
 *
 *   POST /admin/businesses/:id/grant-credits
 *
 * Comp-style admin recharge — adds credits to a business wallet without
 * any payment. Admin-only (the route is mounted behind requireAdmin).
 *
 * Phase 1: this is the ONLY recharge path. No Stripe / Apple IAP /
 * Google Pay. The endpoint is NOT gated by BOOST_ACTIVATION_ENABLED —
 * admins must be able to top wallets even with monetisation paused.
 *
 * Body:
 *   {
 *     credits: int 1..100         (required)
 *     reason:  string ≤50         (optional, free text — no enum)
 *     note:    string ≤500        (optional)
 *   }
 *
 * Response (201):
 *   {
 *     businessId, creditsAdded, previousBalance, newBalance,
 *     transactionId, status: 'completed', grantedAt, grantedByAdminId
 *   }
 */

'use strict';

const { created } = require('../utils/response');
const { grantCredits } = require('../services/walletGrant');
const { log } = require('../services/logService');

async function grantCreditsHandler(req, res, next) {
  try {
    const { credits, reason = null, note = null } = req.body || {};

    const result = await grantCredits({
      businessId: req.params.id,
      credits,
      reason,
      note,
      adminUserId: req.user.id,
    });

    await log(
      req.user.email,
      `Granted ${result.creditsAdded} credits`,
      req.params.id,
      'Wallet',
      String(result.previousBalance),
      String(result.newBalance),
    );

    created(res, { ...result, status: 'completed' });
  } catch (e) { next(e); }
}

module.exports = { grantCredits: grantCreditsHandler };
