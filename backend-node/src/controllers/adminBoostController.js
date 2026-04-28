/**
 * Admin-side boost endpoints.
 *
 *   POST   /admin/jobs/:id/grant-boost   — grant a boost on any job
 *   DELETE /admin/jobs/:id/boost         — revoke the active boost
 *
 * All endpoints respect the BOOST_ACTIVATION_ENABLED kill switch:
 * when the flag is OFF, every endpoint returns 503 BOOST_ACTIVATION_OFF
 * BEFORE touching the DB. This is the panic-button that lets us shut
 * monetisation off without a redeploy.
 */

'use strict';

const { ok, created } = require('../utils/response');
const AppError = require('../utils/AppError');
const flags = require('../config/featureFlags');
const { activateBoost, revokeBoost } = require('../services/boostActivation');
const { log } = require('../services/logService');

function ensureFlag() {
  if (!flags.activationEnabled) {
    throw AppError.unavailable(
      'Boost activation is currently disabled.',
      'BOOST_ACTIVATION_OFF',
    );
  }
}

// POST /admin/jobs/:id/grant-boost
// body: { productCode, source?: 'admin'|'comped'|'test', notes? }
async function grantBoost(req, res, next) {
  try {
    ensureFlag();
    const { productCode, source = 'admin', notes = null } = req.body || {};
    if (!productCode) {
      throw AppError.badRequest('productCode is required', 'PRODUCT_CODE_REQUIRED');
    }

    const result = await activateBoost({
      jobId: req.params.id,
      productCode,
      source,
      adminUserId: req.user.id,
      notes,
    });

    await log(req.user.email, `Granted boost ${productCode}`, req.params.id, 'Boost');
    created(res, result);
  } catch (e) { next(e); }
}

// DELETE /admin/jobs/:id/boost
// body: { reason?, refundCredits?: boolean }
async function revokeBoostHandler(req, res, next) {
  try {
    ensureFlag();
    const { reason = null, refundCredits = false } = req.body || {};

    const result = await revokeBoost({
      jobId: req.params.id,
      adminUserId: req.user.id,
      reason,
      refundCredits: !!refundCredits,
    });

    await log(req.user.email, 'Revoked boost', req.params.id, 'Boost');
    ok(res, result);
  } catch (e) { next(e); }
}

module.exports = { grantBoost, revokeBoost: revokeBoostHandler };
