/**
 * Business-facing wallet read endpoint.
 *
 *   GET /v1/business/wallet   (read, no audit row)
 *
 * The logged-in Business reads its own credit wallet snapshot plus the
 * latest 20 ledger rows. Single endpoint, single handler, no mutation.
 *
 * Cross-tenant safety: the client never sends a businessId. We resolve
 * it server-side from the JWT (`req.user.id` → `businesses.user_id`).
 * Business A cannot leak Business B's wallet by guessing an id.
 *
 * Reuses the same `walletQuery.getWalletSnapshot()` service that powers
 * the admin endpoint (Step 6A) — DTO contract is identical so the
 * Flutter side can share the parser between admin and business views.
 *
 * Phase 1: this endpoint is read-only and is NOT gated by
 * BOOST_ACTIVATION_ENABLED. The Business must always be able to inspect
 * its own balance even when monetisation is paused.
 *
 * Errors:
 *   401 (auth middleware)        bearer missing or invalid
 *   404 BUSINESS_NOT_FOUND       authenticated user has no business row
 *
 * Wallet missing → 200 with safe-zero snapshot (NOT 404), per the
 * Step 6A contract: lazy wallet creation is a `walletGrant` concern;
 * read-side never errors on absence.
 *
 * No call to logService.log() — read endpoints don't generate audit
 * rows by convention in this codebase.
 */

'use strict';

const db = require('../config/db');
const AppError = require('../utils/AppError');
const { ok } = require('../utils/response');
const { getWalletSnapshot } = require('../services/walletQuery');

async function getMyWallet(req, res, next) {
  try {
    const biz = await db('businesses')
      .where({ user_id: req.user.id })
      .first('id');

    if (!biz) {
      throw AppError.notFound(
        'No business profile is associated with this user.',
        'BUSINESS_NOT_FOUND',
      );
    }

    const snapshot = await getWalletSnapshot(biz.id);
    ok(res, snapshot);
  } catch (e) { next(e); }
}

module.exports = {
  getMyWallet,
};
