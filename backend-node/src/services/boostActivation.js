/**
 * Boost activation service.
 *
 * Two operations, both fully transactional:
 *
 *   activateBoost({ jobId, productCode, source, ... })
 *     - admin grant ('admin')   → no wallet movement, no payment row
 *     - credit spend ('credit') → debit wallet + ledger row + comped payment row
 *     - comped/test            → no wallet, no payment, just audit
 *
 *   revokeBoost({ jobId, ..., refundCredits })
 *     - flips active boost to 'revoked'
 *     - resets jobs.boost_* columns
 *     - optionally re-credits the wallet (Phase 1 default: NO refund)
 *     - writes a 'boost_revoked' audit row
 *
 * Concurrency guarantees:
 *   - Both operations open `db.transaction()`.
 *   - We `SELECT ... FOR UPDATE` the target job to serialise concurrent
 *     activations on the same job within a single replica.
 *   - The migration 028 partial unique index on
 *     `job_boosts (job_id) WHERE status='active'` is the hard fence
 *     that catches cross-replica races: the loser hits a Postgres
 *     unique-violation, which we translate to 409 BOOST_ALREADY_ACTIVE.
 *
 * Phase scope:
 *   - Bundles (is_bundle=true, e.g. fast_hire_pack) are stored as a
 *     single boost row with effective boost_type='top'. The richer
 *     bundle expansion (separate urgent + top + featured rows) is a
 *     Phase 2 concern; the ranking engine already gives 'top' the best
 *     visibility lift, which is the user-visible promise of the bundle.
 *   - Only jobs with status='active' can receive boosts. Closed/paused
 *     jobs return 400 INVALID_JOB_STATE.
 *
 * Returns the freshly inserted job_boosts row, decorated with the
 * post-debit wallet balance when applicable.
 */

'use strict';

const db = require('../config/db');
const AppError = require('../utils/AppError');

const VALID_SOURCES = new Set(['admin', 'credit', 'comped', 'test']);

const PG_UNIQUE_VIOLATION = '23505';

function ensureSource(source) {
  if (!VALID_SOURCES.has(source)) {
    throw AppError.badRequest(`Invalid boost source: ${source}`, 'INVALID_SOURCE');
  }
}

/**
 * Resolve the effective boost shape for a product. Bundles collapse to
 * boost_type='top' with the bundle's own priority value.
 *
 * Throws 404 PRODUCT_NOT_FOUND if the code is unknown or inactive.
 * Throws 400 PRODUCT_NOT_BOOST if the product has no boost_type and
 * isn't a bundle (e.g. credit packs).
 */
async function resolveProduct(trx, productCode) {
  const product = await trx('job_products')
    .where({ code: productCode, is_active: true })
    .first();

  if (!product) {
    throw AppError.notFound(`Unknown product: ${productCode}`, 'PRODUCT_NOT_FOUND');
  }

  if (!product.boost_type && !product.is_bundle) {
    throw AppError.badRequest(
      `Product ${productCode} is not a boost product`,
      'PRODUCT_NOT_BOOST',
    );
  }

  // Bundles are persisted as effective top-tier boosts in Phase 1.
  const effectiveType = product.is_bundle ? 'top' : product.boost_type;
  const effectivePriority = product.is_bundle
    ? Math.max(product.boost_priority || 0, 80)
    : product.boost_priority;

  return { product, effectiveType, effectivePriority };
}

/**
 * Lock the job row and validate it can receive a boost.
 * Returns the locked row.
 */
async function lockActiveJob(trx, jobId, businessId) {
  const job = await trx('jobs')
    .where({ id: jobId })
    .forUpdate()
    .first();

  if (!job) {
    throw AppError.notFound(`Job ${jobId} not found`, 'JOB_NOT_FOUND');
  }
  if (businessId && job.business_id !== businessId) {
    throw AppError.forbidden('Job does not belong to this business', 'JOB_NOT_OWNED');
  }
  if (job.status !== 'active') {
    throw AppError.badRequest(
      `Cannot boost a job in state ${job.status}`,
      'INVALID_JOB_STATE',
    );
  }
  return job;
}

/**
 * Lazily create a wallet row and return it locked FOR UPDATE.
 */
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
 * Activate a boost.
 *
 * @param {object} args
 * @param {string} args.jobId
 * @param {string} args.businessId      — required for source='credit'; ignored for admin (resolved from job)
 * @param {string} args.productCode
 * @param {'admin'|'credit'|'comped'|'test'} args.source
 * @param {string=} args.adminUserId    — required for source='admin'
 * @param {string=} args.notes
 * @param {Date=}   args.now
 */
async function activateBoost({
  jobId,
  businessId,
  productCode,
  source,
  adminUserId = null,
  notes = null,
  now = new Date(),
}) {
  ensureSource(source);

  if (source === 'admin' && !adminUserId) {
    throw AppError.badRequest('adminUserId required for admin grant', 'ADMIN_USER_REQUIRED');
  }

  try {
    return await db.transaction(async (trx) => {
      const { product, effectiveType, effectivePriority } = await resolveProduct(trx, productCode);

      const job = await lockActiveJob(trx, jobId, source === 'credit' ? businessId : null);
      const ownerBusinessId = job.business_id;

      const startsAt = now;
      const endsAt = new Date(startsAt.getTime() + (product.duration_hours || 0) * 3600 * 1000);

      let creditTxId = null;
      let paymentId = null;
      let walletAfter = null;

      // ── credit spend ────────────────────────────────────────────────
      if (source === 'credit') {
        const wallet = await lockOrCreateWallet(trx, ownerBusinessId);
        const cost = product.credits_cost ?? 1;

        if (wallet.credits_available < cost) {
          throw AppError.badRequest(
            `Insufficient credits: have ${wallet.credits_available}, need ${cost}`,
            'INSUFFICIENT_CREDITS',
          );
        }

        const newBalance = wallet.credits_available - cost;

        await trx('business_credit_wallet')
          .where({ business_id: ownerBusinessId })
          .update({
            credits_available: newBalance,
            credits_total_spent: wallet.credits_total_spent + cost,
            updated_at: trx.fn.now(),
          });

        // Comped payment row gives admin/finance a single timeline view
        // of every boost activation, even credit-funded ones.
        const [pay] = await trx('job_payments')
          .insert({
            business_id: ownerBusinessId,
            job_id: jobId,
            product_code: product.code,
            amount_minor: 0,
            currency: product.currency || 'GBP',
            provider: 'admin',
            payment_status: 'comped',
            notes: `Credit-funded boost (${cost} credits)`,
          })
          .returning('id');
        paymentId = pay.id || pay;

        const [tx] = await trx('business_credit_transactions')
          .insert({
            business_id: ownerBusinessId,
            delta: -cost,
            reason: 'spend',
            job_id: jobId,
            payment_id: paymentId,
            balance_after: newBalance,
            notes: `Boost ${product.code}`,
          })
          .returning('id');
        creditTxId = tx.id || tx;
        walletAfter = newBalance;
      }

      // ── insert job_boosts row ───────────────────────────────────────
      let inserted;
      try {
        const [row] = await trx('job_boosts')
          .insert({
            job_id: jobId,
            business_id: ownerBusinessId,
            product_code: product.code,
            boost_type: effectiveType,
            boost_priority: effectivePriority,
            starts_at: startsAt,
            ends_at: endsAt,
            status: 'active',
            source,
            payment_id: paymentId,
            credit_tx_id: creditTxId,
            admin_user_id: source === 'admin' ? adminUserId : null,
            notes,
          })
          .returning('*');
        inserted = row;
      } catch (e) {
        if (e && e.code === PG_UNIQUE_VIOLATION) {
          throw AppError.conflict(
            'This job already has an active boost',
            'BOOST_ALREADY_ACTIVE',
          );
        }
        throw e;
      }

      // Backfill the credit_tx_id with the new boost id so the ledger
      // row points at the boost it paid for.
      if (creditTxId) {
        await trx('business_credit_transactions')
          .where({ id: creditTxId })
          .update({ boost_id: inserted.id, updated_at: trx.fn.now() });
      }

      // ── denormalise on jobs ─────────────────────────────────────────
      await trx('jobs')
        .where({ id: jobId })
        .update({
          boost_status: 'active',
          boost_type: effectiveType,
          boost_priority: effectivePriority,
          boost_starts_at: startsAt,
          boost_ends_at: endsAt,
          boost_source: source,
          boost_product_id: product.code,
          updated_at: trx.fn.now(),
        });

      // ── audit ───────────────────────────────────────────────────────
      await trx('job_visibility_events').insert({
        job_id: jobId,
        event_type: 'boost_start',
        source: 'system',
        candidate_id: null,
        boost_active: true,
        boost_type: effectiveType,
        boost_id: inserted.id,
        context: null,
      });

      return { ...inserted, walletAfter };
    });
  } catch (e) {
    // Last-line defence: serialisation/unique race outside the inner try.
    if (e && e.code === PG_UNIQUE_VIOLATION && !(e instanceof AppError)) {
      throw AppError.conflict(
        'This job already has an active boost',
        'BOOST_ALREADY_ACTIVE',
      );
    }
    throw e;
  }
}

/**
 * Revoke an active boost (admin override or business-side cancel).
 *
 * @param {object} args
 * @param {string} args.jobId
 * @param {string=} args.businessId    — when set, ownership is enforced
 * @param {string=} args.adminUserId   — set on the boost row + ledger
 * @param {string=} args.reason
 * @param {boolean=} args.refundCredits — Phase 1 default: false
 */
async function revokeBoost({
  jobId,
  businessId = null,
  adminUserId = null,
  reason = null,
  refundCredits = false,
} = {}) {
  return db.transaction(async (trx) => {
    const job = await lockActiveJob(trx, jobId, businessId).catch((err) => {
      // A revoke on a non-active job (paused/closed) should still work
      // — the boost itself still exists. We only block here when the
      // ownership check fails or job is missing entirely.
      if (err.code === 'JOB_NOT_FOUND' || err.code === 'JOB_NOT_OWNED') throw err;
      return null;
    });

    const boost = await trx('job_boosts')
      .where({ job_id: jobId, status: 'active' })
      .forUpdate()
      .first();

    if (!boost) {
      throw AppError.notFound('No active boost on this job', 'NO_ACTIVE_BOOST');
    }
    if (businessId && boost.business_id !== businessId) {
      throw AppError.forbidden('Boost belongs to another business', 'BOOST_NOT_OWNED');
    }

    await trx('job_boosts')
      .where({ id: boost.id })
      .update({
        status: 'revoked',
        revoked_at: trx.fn.now(),
        revoke_reason: reason,
        admin_user_id: adminUserId || boost.admin_user_id,
        updated_at: trx.fn.now(),
      });

    await trx('jobs')
      .where({ id: jobId })
      .where('boost_status', 'active')
      .update({
        boost_status: 'revoked',
        boost_priority: 0,
        boost_type: null,
        boost_source: null,
        boost_product_id: null,
        updated_at: trx.fn.now(),
      });

    let refundedCredits = 0;
    if (refundCredits && boost.source === 'credit') {
      const product = await trx('job_products').where({ code: boost.product_code }).first();
      const cost = product?.credits_cost ?? 1;

      const wallet = await lockOrCreateWallet(trx, boost.business_id);
      const newBalance = wallet.credits_available + cost;

      await trx('business_credit_wallet')
        .where({ business_id: boost.business_id })
        .update({
          credits_available: newBalance,
          credits_total_spent: Math.max(0, wallet.credits_total_spent - cost),
          updated_at: trx.fn.now(),
        });

      await trx('business_credit_transactions').insert({
        business_id: boost.business_id,
        delta: cost,
        reason: 'refund',
        job_id: jobId,
        boost_id: boost.id,
        balance_after: newBalance,
        admin_user_id: adminUserId,
        notes: reason ? `Refund: ${reason}` : 'Boost revoke refund',
      });

      refundedCredits = cost;
    }

    await trx('job_visibility_events').insert({
      job_id: jobId,
      event_type: 'boost_revoked',
      source: 'system',
      candidate_id: null,
      boost_active: false,
      boost_type: boost.boost_type,
      boost_id: boost.id,
      context: null,
    });

    return {
      boostId: boost.id,
      jobId,
      revoked: true,
      refundedCredits,
      jobStillActive: !!job,
    };
  });
}

/**
 * Read the current boost state for a job (read-only, no lock).
 */
async function getBoostStatus(jobId) {
  const job = await db('jobs').where({ id: jobId }).first();
  if (!job) throw AppError.notFound('Job not found', 'JOB_NOT_FOUND');

  const activeBoost = await db('job_boosts')
    .where({ job_id: jobId, status: 'active' })
    .first();

  return {
    jobId,
    boost_status: job.boost_status,
    boost_type: job.boost_type,
    boost_priority: job.boost_priority,
    boost_starts_at: job.boost_starts_at,
    boost_ends_at: job.boost_ends_at,
    boost_source: job.boost_source,
    boost_product_id: job.boost_product_id,
    activeBoost: activeBoost || null,
  };
}

module.exports = {
  activateBoost,
  revokeBoost,
  getBoostStatus,
};
