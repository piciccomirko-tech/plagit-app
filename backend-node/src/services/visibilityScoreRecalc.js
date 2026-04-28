/**
 * Visibility score batch recompute.
 *
 * `jobs.visibility_score` is a candidate-AGNOSTIC ranking baseline,
 * used by surfaces that don't have a candidate context (admin lists,
 * unauthenticated search, future analytics). It is intentionally NOT
 * the same as the per-candidate finalScore from jobRanking.
 *
 * Formula (Phase 1 placeholder per Mirko's confirmation):
 *
 *     visibility_score = NEUTRAL_BASELINE
 *                      + boost_priority
 *                      + freshnessBonus
 *                      - staleBoostPenalty
 *                      - expiryPenalty
 *
 * NEUTRAL_BASELINE = 30 — replaced with a real role_demand_score in
 * Step 8 (analytics). We keep it constant for now so all jobs share
 * the same fairness floor and the boost lift is the only meaningful
 * variation.
 *
 * Scope: top 500 active jobs by created_at DESC. Anything beyond the
 * top 500 is rarely surfaced anyway and re-computing it every 15 min
 * would waste cycles.
 */

const db = require('../config/db');
const { CONSTANTS } = require('./jobRanking');

const NEUTRAL_BASELINE = 30;
const BATCH_LIMIT = 500;

async function runVisibilityRecalc({ now = new Date() } = {}) {
  const startedAt = Date.now();

  const rows = await db('jobs')
    .where('status', 'active')
    .orderBy('created_at', 'desc')
    .limit(BATCH_LIMIT)
    .select(
      'id', 'created_at', 'expiry_date',
      'boost_status', 'boost_priority',
      'boost_starts_at'
    );

  if (rows.length === 0) {
    return { rowsScanned: 0, rowsUpdated: 0, durationMs: Date.now() - startedAt };
  }

  let updated = 0;

  for (const r of rows) {
    const score = computeVisibilityScore(r, now);

    // Only write when the value actually changed — avoids hot rows
    // bouncing their updated_at every 15 minutes.
    const result = await db('jobs')
      .where('id', r.id)
      .whereNot('visibility_score', score)
      .update({ visibility_score: score, updated_at: db.fn.now() });

    updated += result;
  }

  return {
    rowsScanned: rows.length,
    rowsUpdated: updated,
    durationMs: Date.now() - startedAt,
  };
}

function computeVisibilityScore(job, now) {
  const isActive = job.boost_status === 'active';
  const priority = isActive && Number.isFinite(job.boost_priority)
    ? job.boost_priority : 0;

  let freshness = 0;
  if (job.created_at) {
    const ageMs = now.getTime() - new Date(job.created_at).getTime();
    const ageHrs = ageMs / (60 * 60 * 1000);
    if (ageHrs >= 0 && ageHrs < CONSTANTS.FRESHNESS_WINDOW_HOURS) {
      freshness = CONSTANTS.FRESHNESS_MAX_BONUS *
        (1 - ageHrs / CONSTANTS.FRESHNESS_WINDOW_HOURS);
    }
  }

  let stale = 0;
  if (isActive && job.boost_starts_at) {
    const ageHrs = (now.getTime() - new Date(job.boost_starts_at).getTime())
      / (60 * 60 * 1000);
    if (ageHrs > CONSTANTS.STALE_GRACE_HOURS) {
      stale = Math.min(
        CONSTANTS.STALE_PENALTY_CAP,
        (ageHrs - CONSTANTS.STALE_GRACE_HOURS) * CONSTANTS.STALE_PENALTY_PER_HOUR
      );
    }
  }

  let expiry = 0;
  if (job.expiry_date) {
    const hrsToExpiry = (new Date(job.expiry_date).getTime() - now.getTime())
      / (60 * 60 * 1000);
    if (hrsToExpiry > 0 && hrsToExpiry < CONSTANTS.EXPIRY_THRESHOLD_HOURS) {
      expiry = CONSTANTS.EXPIRY_PENALTY;
    }
  }

  const raw = NEUTRAL_BASELINE + priority + freshness - stale - expiry;
  // Round to integer — visibility_score is stored as INT.
  return Math.max(0, Math.min(255, Math.round(raw)));
}

module.exports = { runVisibilityRecalc, computeVisibilityScore, NEUTRAL_BASELINE };
