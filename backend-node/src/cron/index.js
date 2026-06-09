/**
 * Cron registry.
 *
 * Single entrypoint the server boot calls once. Internally it:
 *   1. Checks the BOOST_CRON_ENABLED feature flag — if OFF, we no-op
 *      and return immediately. Production stays untouched until Mirko
 *      flips the flag.
 *   2. Registers each scheduled job with node-cron.
 *
 * Each job module exports a `start()` function that schedules itself
 * and returns the cron handle. We don't currently need to stop them
 * (the process exits when the server exits), but holding the handles
 * keeps a future graceful-shutdown path easy.
 */

const flags = require('../config/featureFlags');

let started = false;
const handles = [];

function startIfEnabled({ logger = console } = {}) {
  if (started) return handles;

  if (flags.cronEnabled) {
    const boostExpiry      = require('./boostExpiryJob');
    const visibilityRecalc = require('./visibilityRecalcJob');

    handles.push(boostExpiry.start({ logger }));
    handles.push(visibilityRecalc.start({ logger }));
  } else {
    logger.log('[cron] BOOST_CRON_ENABLED is OFF — boost jobs skipped');
  }

  // Ring-sweep is gated independently so it can be enabled without
  // enabling the boost cron jobs (and vice versa).
  if (flags.callRingSweepEnabled) {
    const callRingSweep = require('./callRingSweepJob');
    handles.push(callRingSweep.start({ logger }));
  } else {
    logger.log('[cron] CALL_RING_SWEEP_ENABLED is OFF — ring sweep skipped');
  }

  started = true;
  logger.log(`[cron] registered ${handles.length} job(s)`);
  return handles;
}

module.exports = { startIfEnabled };
