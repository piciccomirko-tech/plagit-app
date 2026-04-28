/**
 * Visibility score recompute cron job.
 *
 * Schedule: every 15 minutes (`* /15 * * * *`).
 * Recomputes `jobs.visibility_score` for the top 500 active jobs (see
 * services/visibilityScoreRecalc.js). Cheaper than the boost expiry
 * sweep — pure read + conditional write — so a 15 min cadence is fine.
 *
 * Uses its own Postgres advisory lock id so it never contends with the
 * boost expiry job.
 */

const cron = require('node-cron');
const db = require('../config/db');
const { runVisibilityRecalc } = require('../services/visibilityScoreRecalc');

const SCHEDULE = '*/15 * * * *';
const LOCK_ID  = 7842302;

async function tick({ logger }) {
  let acquired = false;
  try {
    const { rows } = await db.raw('SELECT pg_try_advisory_lock(?) AS locked', [LOCK_ID]);
    acquired = rows && rows[0] && rows[0].locked === true;
    if (!acquired) {
      logger.log('[cron:visibilityRecalc] another worker holds the lock — skipping');
      return;
    }

    const report = await runVisibilityRecalc();
    if (report.rowsUpdated > 0) {
      logger.log(
        `[cron:visibilityRecalc] updated ${report.rowsUpdated}/${report.rowsScanned} ` +
        `job(s) in ${report.durationMs}ms`
      );
    }
  } catch (err) {
    logger.error('[cron:visibilityRecalc] failed', err);
  } finally {
    if (acquired) {
      try { await db.raw('SELECT pg_advisory_unlock(?)', [LOCK_ID]); }
      catch (e) { logger.error('[cron:visibilityRecalc] unlock failed', e); }
    }
  }
}

function start({ logger = console } = {}) {
  const handle = cron.schedule(SCHEDULE, () => tick({ logger }), {
    name: 'visibilityRecalc',
    timezone: 'UTC',
  });
  logger.log(`[cron:visibilityRecalc] scheduled "${SCHEDULE}" (UTC)`);
  return handle;
}

module.exports = { start, tick, SCHEDULE, LOCK_ID };
