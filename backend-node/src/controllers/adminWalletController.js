/**
 * Admin wallet endpoints.
 *
 *   POST /admin/businesses/:id/grant-credits   (write)
 *   GET  /admin/businesses/:id/wallet          (read, no audit row)
 *
 * Both are admin-only (the route is mounted behind requireAdmin) and
 * neither is gated by BOOST_ACTIVATION_ENABLED — admins must be able
 * to top wallets and read balances even with monetisation paused.
 *
 * Phase 1: grantCredits is the ONLY recharge path. No Stripe / Apple
 * IAP / Google Pay.
 *
 * grantCredits body:
 *   {
 *     credits: int 1..100         (required)
 *     reason:  string ≤50         (optional, free text — no enum)
 *     note:    string ≤500        (optional)
 *   }
 * grantCredits response (201):
 *   {
 *     businessId, creditsAdded, previousBalance, newBalance,
 *     transactionId, status: 'completed', grantedAt, grantedByAdminId
 *   }
 *
 * getWallet response (200):
 *   {
 *     businessId, walletId, creditsAvailable, creditsSpent,
 *     creditsTotalPurchased, creditsTotalComped, lastRechargeAt,
 *     recentTransactions: [ { id, transactionType, reason, creditsDelta,
 *                             creditsBefore, creditsAfter, note,
 *                             createdAt, adminUserId } ]
 *   }
 *
 * getWallet does NOT call logService.log() — read endpoints don't
 * generate audit rows by convention in this codebase.
 */

'use strict';

const { ok, created } = require('../utils/response');
const { grantCredits } = require('../services/walletGrant');
const { getWalletSnapshot } = require('../services/walletQuery');
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

async function getWalletHandler(req, res, next) {
  try {
    const snapshot = await getWalletSnapshot(req.params.id);
    ok(res, snapshot);
  } catch (e) { next(e); }
}

module.exports = {
  grantCredits: grantCreditsHandler,
  getWallet: getWalletHandler,
};
