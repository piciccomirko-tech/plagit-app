/**
 * Call ring-timeout sweep cron job.
 *
 * Schedule: every minute (`* * * * *`).
 *
 * Problem: without a server-side timeout, calls stuck in `ringing`
 * never flip to `missed` unless the caller explicitly hits /end.
 * If the caller's app crashes, the network drops, or they just close
 * the app, the row stays `ringing` forever — and GET /calls/active
 * would keep returning a phantom call to any VoIP cold-start.
 *
 * This job sweeps `ringing` calls older than RING_TIMEOUT_S (60s)
 * and transitions them to `missed`, then fires publishCallEvent so:
 *   • The callee (if SSE-connected) sees the missed-call state update
 *   • The missed-call bell notification is persisted (via
 *     maybeNotifyMissedCall inside publishCallEvent)
 *   • The call-log chat bubble is inserted (via maybeInsertCallLogMessage)
 *
 * Multi-worker safety: Postgres advisory lock (id distinct from
 * boostExpiryJob's 7842301) so only one Railway replica runs the sweep.
 *
 * Gated by CALL_RING_SWEEP_ENABLED env flag (default OFF). Production
 * stays untouched until the flag is explicitly set.
 */

const cron = require('node-cron');
const db   = require('../config/db');

const SCHEDULE       = '* * * * *'; // every minute
const LOCK_ID        = 7842302;     // distinct from boostExpiry (7842301)
const RING_TIMEOUT_S = 60;

async function tick({ logger = console } = {}) {
  let acquired = false;
  try {
    const { rows } = await db.raw('SELECT pg_try_advisory_lock(?) AS locked', [LOCK_ID]);
    acquired = rows && rows[0] && rows[0].locked === true;
    if (!acquired) {
      // Another worker is already sweeping — skip silently.
      return;
    }

    const cutoff = new Date(Date.now() - RING_TIMEOUT_S * 1000).toISOString();
    const expired = await db('calls')
      .where({ status: 'ringing' })
      .where('started_at', '<', cutoff)
      .update({
        status:     'missed',
        ended_at:   db.fn.now(),
        updated_at: db.fn.now(),
      })
      .returning('*');

    if (expired.length === 0) return;

    logger.log(`[cron:callRingSweep] expired ${expired.length} stale ringing call(s) → missed`);

    // Publish SSE + bell notification for each expired call.
    // publishCallEvent handles maybeInsertCallLogMessage and
    // maybeNotifyMissedCall internally (both self-filter on status).
    // Lazy-require avoids a module-load cycle during test isolation.
    const { publishCallEvent } = require('../controllers/callController');
    for (const row of expired) {
      try {
        await publishCallEvent(row);
      } catch (e) {
        logger.warn(`[cron:callRingSweep] publishCallEvent failed for call ${row.id}:`, e.message);
      }
    }
  } catch (err) {
    logger.error('[cron:callRingSweep] tick failed:', err);
  } finally {
    if (acquired) {
      try {
        await db.raw('SELECT pg_advisory_unlock(?)', [LOCK_ID]);
      } catch (e) {
        logger.error('[cron:callRingSweep] advisory unlock failed:', e);
      }
    }
  }
}

function start({ logger = console } = {}) {
  const handle = cron.schedule(SCHEDULE, () => tick({ logger }), {
    name: 'callRingSweep',
    timezone: 'UTC',
  });
  logger.log(`[cron:callRingSweep] scheduled "${SCHEDULE}" (UTC), timeout=${RING_TIMEOUT_S}s`);
  return handle;
}

module.exports = { start, tick, SCHEDULE, LOCK_ID, RING_TIMEOUT_S };
