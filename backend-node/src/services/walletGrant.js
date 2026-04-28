/**
 * Admin wallet recharge service.
 *
 *   grantCredits({ businessId, credits, reason, note, adminUserId })
 *
 * Adds credits to a business wallet as an admin grant. Phase 1: this
 * is the only supported recharge path — no Stripe, no IAP, no real
 * payment. Anything paid (purchase, refund) lives in different code
 * paths (Phase 2).
 *
 * Transactional guarantees:
 *   - All work runs inside `db.transaction()`.
 *   - The wallet is locked `FOR UPDATE` so two concurrent admin grants
 *     against the same business serialise (no lost-update on the
 *     accumulators).
 *   - The wallet is created lazily on first grant — businesses don't
 *     get an empty row at signup. The `onConflict('business_id').ignore()`
 *     pattern (proven in boostActivation.lockOrCreateWallet) keeps two
 *     parallel first-grants safe at insert time too.
 *
 * Wallet update on grant:
 *   - credits_available     += credits
 *   - credits_total_comped  += credits      (admin grants are comp'd)
 *   - last_recharge_at      =  now()
 *
 * Ledger row:
 *   - reason         = 'admin_grant'
 *   - delta          = +credits
 *   - balance_after  = post-grant credits_available
 *   - admin_user_id  = grantor
 *   - notes          = `[reason] note` (or whichever side is set)
 *
 * Validation (cheap, before opening the transaction):
 *   - credits: integer in [1, MAX_GRANT_PER_REQUEST] (default 100)
 *   - reason : optional, ≤ 50 chars
 *   - note   : optional, ≤ 500 chars
 *
 * Errors:
 *   - 400 INVALID_CREDITS, INVALID_REASON, INVALID_NOTE,
 *         ADMIN_USER_REQUIRED, BUSINESS_ID_REQUIRED
 *   - 404 BUSINESS_NOT_FOUND  (business row missing)
 *
 * Phase scope:
 *   - We do NOT write a `job_payments` row for admin grants. Wallet +
 *     ledger is the only audit footprint by design (decided in Step 5
 *     planning). When a real-money path lands in Phase 2, it will use
 *     a different reason ('purchase') and write its own job_payments
 *     row from the payment provider webhook.
 */

'use strict';

const db = require('../config/db');
const AppError = require('../utils/AppError');

const MAX_GRANT_PER_REQUEST = 100;
const REASON_MAX_LEN = 50;
const NOTE_MAX_LEN = 500;

function validateInputs({ businessId, credits, reason, note, adminUserId }) {
  if (!businessId) {
    throw AppError.badRequest('businessId is required', 'BUSINESS_ID_REQUIRED');
  }
  if (!adminUserId) {
    throw AppError.badRequest('adminUserId is required', 'ADMIN_USER_REQUIRED');
  }
  if (
    typeof credits !== 'number'
    || !Number.isInteger(credits)
    || credits < 1
    || credits > MAX_GRANT_PER_REQUEST
  ) {
    throw AppError.badRequest(
      `credits must be an integer between 1 and ${MAX_GRANT_PER_REQUEST}`,
      'INVALID_CREDITS',
    );
  }
  if (reason != null) {
    if (typeof reason !== 'string' || reason.length > REASON_MAX_LEN) {
      throw AppError.badRequest(
        `reason must be a string ≤ ${REASON_MAX_LEN} chars`,
        'INVALID_REASON',
      );
    }
  }
  if (note != null) {
    if (typeof note !== 'string' || note.length > NOTE_MAX_LEN) {
      throw AppError.badRequest(
        `note must be a string ≤ ${NOTE_MAX_LEN} chars`,
        'INVALID_NOTE',
      );
    }
  }
}

function composeNotes(reason, note) {
  const r = reason ? reason.trim() : '';
  const n = note ? note.trim() : '';
  if (r && n) return `[${r}] ${n}`;
  if (r) return `[${r}]`;
  if (n) return n;
  return null;
}

async function lockOrCreateWallet(trx, businessId) {
  let wallet = await trx('business_credit_wallet')
    .where({ business_id: businessId })
    .forUpdate()
    .first();

  if (!wallet) {
    await trx('business_credit_wallet')
      .insert({ business_id: businessId })
      .onConflict('business_id')
      .ignore();
    wallet = await trx('business_credit_wallet')
      .where({ business_id: businessId })
      .forUpdate()
      .first();
  }
  return wallet;
}

/**
 * @param {object} args
 * @param {string} args.businessId
 * @param {number} args.credits        — integer in [1, MAX_GRANT_PER_REQUEST]
 * @param {string=} args.reason        — short tag, ≤50 chars
 * @param {string=} args.note          — long-form, ≤500 chars
 * @param {string} args.adminUserId    — grantor user id
 *
 * @returns {Promise<{
 *   businessId: string,
 *   creditsAdded: number,
 *   previousBalance: number,
 *   newBalance: number,
 *   transactionId: string,
 *   grantedAt: Date,
 *   grantedByAdminId: string,
 * }>}
 */
async function grantCredits({
  businessId,
  credits,
  reason = null,
  note = null,
  adminUserId,
}) {
  validateInputs({ businessId, credits, reason, note, adminUserId });

  return db.transaction(async (trx) => {
    const business = await trx('businesses').where({ id: businessId }).first();
    if (!business) {
      throw AppError.notFound(`Business ${businessId} not found`, 'BUSINESS_NOT_FOUND');
    }

    const wallet = await lockOrCreateWallet(trx, businessId);
    const previousBalance = wallet.credits_available;
    const newBalance = previousBalance + credits;

    await trx('business_credit_wallet')
      .where({ business_id: businessId })
      .update({
        credits_available: newBalance,
        credits_total_comped: wallet.credits_total_comped + credits,
        last_recharge_at: trx.fn.now(),
        updated_at: trx.fn.now(),
      });

    const [tx] = await trx('business_credit_transactions')
      .insert({
        business_id: businessId,
        delta: credits,
        reason: 'admin_grant',
        balance_after: newBalance,
        admin_user_id: adminUserId,
        notes: composeNotes(reason, note),
      })
      .returning(['id', 'created_at']);

    return {
      businessId,
      creditsAdded: credits,
      previousBalance,
      newBalance,
      transactionId: tx.id,
      grantedAt: tx.created_at,
      grantedByAdminId: adminUserId,
    };
  });
}

module.exports = {
  grantCredits,
  MAX_GRANT_PER_REQUEST,
  REASON_MAX_LEN,
  NOTE_MAX_LEN,
};
