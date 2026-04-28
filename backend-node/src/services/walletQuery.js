/**
 * Admin wallet read service.
 *
 *   getWalletSnapshot(businessId)
 *
 * Pure read — no INSERT, no UPDATE, no transaction. Returns a DTO-shaped
 * snapshot of a business credit wallet plus the latest 20 ledger rows.
 *
 * Behaviour:
 *   - businesses row missing  → 404 BUSINESS_NOT_FOUND
 *   - wallet row missing      → safe zero snapshot (walletId=null,
 *                                 all balances=0, recentTransactions=[])
 *   - wallet row present      → full snapshot, transactions DESC
 *
 * The wallet table has no synthetic `id` column — `business_id` IS the
 * primary key. We surface that PK as `walletId` in the DTO so the
 * Flutter side has a stable handle without coupling to the schema
 * detail that wallet PK == business id.
 *
 * Validation lives here (single source of truth):
 *   - 400 INVALID_BUSINESS_ID  — param missing or not UUID-shaped
 *   - 404 BUSINESS_NOT_FOUND   — well-formed UUID but no business row
 *
 * The controller stays a thin pass-through.
 */

'use strict';

const db = require('../config/db');
const AppError = require('../utils/AppError');

const RECENT_LIMIT = 20;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Map raw ledger `reason` to a UI-friendly bucket.
 *
 *   admin_grant | comped | test_grant   → 'grant'
 *   spend                               → 'spend'
 *   refund                              → 'refund'
 *   purchase                            → 'purchase'
 *   anything else                       → 'other'
 *
 * Pure function — exported for unit testing.
 */
function bucketTransactionType(reason) {
  switch (reason) {
    case 'admin_grant':
    case 'comped':
    case 'test_grant':
      return 'grant';
    case 'spend':
    case 'refund':
    case 'purchase':
      return reason;
    default:
      return 'other';
  }
}

function txToDto(row) {
  return {
    id: row.id,
    transactionType: bucketTransactionType(row.reason),
    reason: row.reason,
    creditsDelta: row.delta,
    creditsBefore: row.balance_after - row.delta,
    creditsAfter: row.balance_after,
    note: row.notes,
    createdAt: row.created_at,
    adminUserId: row.admin_user_id,
  };
}

function emptySnapshot(businessId) {
  return {
    businessId,
    walletId: null,
    creditsAvailable: 0,
    creditsSpent: 0,
    creditsTotalPurchased: 0,
    creditsTotalComped: 0,
    lastRechargeAt: null,
    recentTransactions: [],
  };
}

/**
 * @param {string} businessId — business UUID
 * @returns {Promise<{
 *   businessId: string,
 *   walletId: string|null,
 *   creditsAvailable: number,
 *   creditsSpent: number,
 *   creditsTotalPurchased: number,
 *   creditsTotalComped: number,
 *   lastRechargeAt: Date|null,
 *   recentTransactions: Array<object>,
 * }>}
 */
async function getWalletSnapshot(businessId) {
  if (!businessId || typeof businessId !== 'string' || !UUID_RE.test(businessId)) {
    throw AppError.badRequest(
      'businessId must be a valid UUID',
      'INVALID_BUSINESS_ID',
    );
  }

  const biz = await db('businesses').where({ id: businessId }).first('id');
  if (!biz) {
    throw AppError.notFound(`Business ${businessId} not found`, 'BUSINESS_NOT_FOUND');
  }

  const wallet = await db('business_credit_wallet')
    .where({ business_id: businessId })
    .first();

  if (!wallet) return emptySnapshot(businessId);

  const txs = await db('business_credit_transactions')
    .where({ business_id: businessId })
    .orderBy('created_at', 'desc')
    .limit(RECENT_LIMIT);

  return {
    businessId,
    walletId: wallet.business_id,
    creditsAvailable: wallet.credits_available,
    creditsSpent: wallet.credits_total_spent,
    creditsTotalPurchased: wallet.credits_total_purchased,
    creditsTotalComped: wallet.credits_total_comped,
    lastRechargeAt: wallet.last_recharge_at,
    recentTransactions: txs.map(txToDto),
  };
}

module.exports = {
  getWalletSnapshot,
  bucketTransactionType,
  RECENT_LIMIT,
  UUID_RE,
};
