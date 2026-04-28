/**
 * Boost expiry cron job.
 *
 * Schedule: every 5 minutes (`* /5 * * * *`).
 * Multi-worker safety: wrapped in a Postgres advisory lock so only one
 * Railway replica actually performs the sweep — the others observe the
 * lock-busy result and skip silently. The lock is released as soon as
 * the sweep finishes (or throws). See services/boostExpiry.js for why
 * the audit trail benefits from this even though the sweep itself is
 * idempotent.
 *
 * The advisory lock id is an arbitrary 32-bit int — pick distinct ones
 * for each cron job in this app so they never block each other.
 */

const cron = require('node-cron');
const db = require('../config/db');
const { runBoostExpiry } = require('../services/boostExpiry');

const SCHEDULE = '*/5 * * * *';
const LOCK_ID  = 7842301;

async function tick({ logger }) {
  let acquired = false;
  try {
    const { rows } = await db.raw('SELECT pg_try_advisory_lock(?) AS locked', [LOCK_ID]);
    acquired = rows && rows[0] && rows[0].locked === true;
    if (!acquired) {
      logger.log('[cron:boostExpiry] another worker holds the lock — skipping');
      return;
    }

    const report = await runBoostExpiry();
    if (report.expiredBoostCount > 0) {
      logger.log(
        `[cron:boostExpiry] expired ${report.expiredBoostCount} boost(s) ` +
        `across ${report.expiredJobCount} job(s) in ${report.durationMs}ms`
      );
    }
  } catch (err) {
    logger.error('[cron:boostExpiry] failed', err);
  } finally {
    if (acquired) {
      try { await db.raw('SELECT pg_advisory_unlock(?)', [LOCK_ID]); }
      catch (e) { logger.error('[cron:boostExpiry] unlock failed', e); }
    }
  }
}

function start({ logger = console } = {}) {
  const handle = cron.schedule(SCHEDULE, () => tick({ logger }), {
    name: 'boostExpiry',
    timezone: 'UTC',
  });
  logger.log(`[cron:boostExpiry] scheduled "${SCHEDULE}" (UTC)`);
  return handle;
}

module.exports = { start, tick, SCHEDULE, LOCK_ID };
