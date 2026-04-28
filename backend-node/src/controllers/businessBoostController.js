/**
 * Business-side boost endpoints.
 *
 *   POST /business/jobs/:id/use-credit-boost   — spend credits to boost a job
 *   GET  /business/jobs/:id/boost-status       — read current boost state
 *
 * The activation endpoint is gated by BOOST_ACTIVATION_ENABLED. The
 * read endpoint is always on — surfacing the current state never
 * spends money.
 */

'use strict';

const db = require('../config/db');
const { ok, created } = require('../utils/response');
const AppError = require('../utils/AppError');
const flags = require('../config/featureFlags');
const { activateBoost, getBoostStatus } = require('../services/boostActivation');

async function getBizId(userId) {
  const biz = await db('businesses').where({ user_id: userId }).first();
  if (!biz) throw AppError.badRequest('Business profile not found.', 'BUSINESS_NOT_FOUND');
  return biz.id;
}

function ensureFlag() {
  if (!flags.activationEnabled) {
    throw AppError.unavailable(
      'Boost activation is currently disabled.',
      'BOOST_ACTIVATION_OFF',
    );
  }
}

// POST /business/jobs/:id/use-credit-boost
// body: { productCode }
async function useCreditBoost(req, res, next) {
  try {
    ensureFlag();
    const { productCode } = req.body || {};
    if (!productCode) {
      throw AppError.badRequest('productCode is required', 'PRODUCT_CODE_REQUIRED');
    }

    const businessId = await getBizId(req.user.id);

    const result = await activateBoost({
      jobId: req.params.id,
      businessId,
      productCode,
      source: 'credit',
    });

    created(res, result);
  } catch (e) { next(e); }
}

// GET /business/jobs/:id/boost-status
async function boostStatus(req, res, next) {
  try {
    const businessId = await getBizId(req.user.id);

    // Ownership: status is sensitive (shows next-bill timing on Phase 2),
    // so we enforce that the caller owns the job.
    const job = await db('jobs').where({ id: req.params.id }).first();
    if (!job) throw AppError.notFound('Job not found', 'JOB_NOT_FOUND');
    if (job.business_id !== businessId) {
      throw AppError.forbidden('Job does not belong to this business', 'JOB_NOT_OWNED');
    }

    const status = await getBoostStatus(req.params.id);
    ok(res, status);
  } catch (e) { next(e); }
}

module.exports = { useCreditBoost, boostStatus };
