/**
 * Boost expiry sweep.
 *
 * Closes any active boost whose `ends_at` is in the past:
 *   - flips job_boosts.status to 'expired'
 *   - resets jobs.boost_status='expired' and clears the boost columns
 *   - writes one job_visibility_events row per expired boost
 *
 * The whole sweep runs in a single transaction so observers never see
 * a half-expired state. Re-running mid-sweep is safe — the predicate
 * `status='active' AND ends_at < now()` already excludes rows we just
 * processed.
 *
 * Multi-worker safety: callers (cron) acquire a Postgres advisory lock
 * before invoking this service. Without the lock, two replicas could
 * both run the sweep and each would still produce correct results
 * (idempotent), but the audit table would carry duplicate boost_end
 * events. The lock is the cheapest way to keep the audit trail clean.
 *
 * Returns a small report so the caller can log a single line:
 *   { expiredBoostCount, expiredJobCount, durationMs }
 */

const db = require('../config/db');

async function runBoostExpiry({ now = new Date() } = {}) {
  const startedAt = Date.now();

  return db.transaction(async (trx) => {
    // 1. Find the rows we're about to expire. We capture them up-front
    //    so the audit insert in step 3 can reference the exact set.
    const expiringBoosts = await trx('job_boosts')
      .where('status', 'active')
      .where('ends_at', '<', now)
      .select('id', 'job_id', 'boost_type');

    if (expiringBoosts.length === 0) {
      return { expiredBoostCount: 0, expiredJobCount: 0, durationMs: Date.now() - startedAt };
    }

    const boostIds = expiringBoosts.map((b) => b.id);
    const jobIds   = [...new Set(expiringBoosts.map((b) => b.job_id))];

    // 2. Flip job_boosts → 'expired'.
    await trx('job_boosts')
      .whereIn('id', boostIds)
      .update({ status: 'expired', updated_at: trx.fn.now() });

    // 3. Reset the denormalised boost state on the jobs themselves.
    //    We only touch jobs whose current boost_status is still 'active'
    //    so a job that was manually revoked between the read and write
    //    doesn't get its state stomped.
    const jobUpdate = await trx('jobs')
      .whereIn('id', jobIds)
      .where('boost_status', 'active')
      .update({
        boost_status: 'expired',
        boost_priority: 0,
        boost_type: null,
        boost_source: null,
        boost_product_id: null,
        updated_at: trx.fn.now(),
      });

    // 4. Audit row per expired boost. `boost_active` is false because
    //    these events represent the END of an active window.
    const events = expiringBoosts.map((b) => ({
      job_id: b.job_id,
      event_type: 'boost_end',
      source: 'system',
      candidate_id: null,
      boost_active: false,
      boost_type: b.boost_type,
      boost_id: b.id,
      context: null,
    }));
    await trx('job_visibility_events').insert(events);

    return {
      expiredBoostCount: expiringBoosts.length,
      expiredJobCount: jobUpdate,
      durationMs: Date.now() - startedAt,
    };
  });
}

module.exports = { runBoostExpiry };
