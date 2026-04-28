/**
 * Boost-aware ranking engine for candidate-facing job lists.
 *
 * Pure function: given an array of jobs (each carrying its own
 * match_score and boost columns), returns a NEW array re-ordered by
 * the formula approved by Mirko in Step 2. Never mutates input.
 *
 * The formula:
 *
 *     finalScore = matchScore
 *                + urgentBonus      (+5,  gate: matchScore >= 40)
 *                + boostBonus       (top, min(20, priority*0.2),
 *                                    gate: matchScore >= 50)
 *                + featuredBonus    (+3,  gate: matchScore >= 40)
 *                + freshnessBonus   (linear +5..0 over 72h)
 *                - expiryPenalty    (-10 if expiry_date - now < 24h)
 *                - staleBoostPenalty (-2/h after 12h since boost_starts_at,
 *                                    cap -10, only while boost_status='active')
 *
 * Hard rules applied AFTER the score sort:
 *
 *  1. Floor for matchScore < 30 — these jobs cannot occupy any of the
 *     first 10 slots. They are reordered to the bottom of the top-10
 *     window (less aggressive than full exclusion — Mirko's call).
 *
 *  2. Featured cap — at most one job with boost_type='featured' may
 *     occupy positions 1..8. After position 8, another featured may
 *     appear, then another after position 16, etc. (1 per 8-block.)
 *
 * Pass-through behaviour: when `enabled` is false (the flag is OFF),
 * rankJobs() returns the input array order unchanged. This is the
 * production-safe default — Step 2 ships with `BOOST_RANKING_ENABLED`
 * unset on Railway, so no candidate sees any reorder until we flip it.
 */

const FRESHNESS_WINDOW_HOURS = 72;
const FRESHNESS_MAX_BONUS = 5;
const EXPIRY_THRESHOLD_HOURS = 24;
const EXPIRY_PENALTY = 10;
const STALE_GRACE_HOURS = 12;
const STALE_PENALTY_PER_HOUR = 2;
const STALE_PENALTY_CAP = 10;

const URGENT_BONUS = 5;
const URGENT_GATE = 40;
const FEATURED_BONUS = 3;
const FEATURED_GATE = 40;
const TOP_GATE = 50;
const TOP_BONUS_CAP = 20;
const TOP_PRIORITY_FACTOR = 0.2;

const SCORE_CLAMP_MAX = 130;
const SCORE_CLAMP_MIN = 0;

const FLOOR_MATCH_SCORE = 30;
const TOP_WINDOW = 10;
const FEATURED_BLOCK_SIZE = 8;

const HOUR_MS = 60 * 60 * 1000;

// ---------------------------------------------------------------------------
// hoursBetween — signed hours from `from` to `now`. Tolerates string dates,
// Date instances, and null. Returns null on invalid input so callers can
// short-circuit gracefully (no NaN poisoning the formula).
// ---------------------------------------------------------------------------
function hoursBetween(from, now) {
  if (!from) return null;
  const t = from instanceof Date ? from.getTime() : Date.parse(from);
  if (Number.isNaN(t)) return null;
  return (now.getTime() - t) / HOUR_MS;
}

// ---------------------------------------------------------------------------
// computeBreakdown — single-job score calculation. Exported for tests and
// the optional `?explain=1` admin debug path.
//
// Returns:
//   {
//     finalScore,
//     components: { matchScore, urgentBonus, boostBonus, featuredBonus,
//                    freshnessBonus, expiryPenalty, staleBoostPenalty },
//     gateApplied: boolean
//   }
// ---------------------------------------------------------------------------
function computeBreakdown(job, now = new Date()) {
  const matchScore = Number.isFinite(job.match_score) ? job.match_score : 0;

  const isActive = job.boost_status === 'active';
  const boostType = isActive ? job.boost_type : null;
  const priority  = isActive && Number.isFinite(job.boost_priority)
                    ? job.boost_priority : 0;

  // Per-component contribution. All gated independently so a partial
  // gate (e.g. 45 matchScore on a Top boost) silently zeroes that one
  // component without breaking the rest of the score.
  let urgentBonus  = 0;
  let boostBonus   = 0;
  let featuredBonus = 0;

  if (boostType === 'urgent' && matchScore >= URGENT_GATE) {
    urgentBonus = URGENT_BONUS;
  }
  if (boostType === 'top' && matchScore >= TOP_GATE) {
    boostBonus = Math.min(TOP_BONUS_CAP, priority * TOP_PRIORITY_FACTOR);
  }
  if (boostType === 'featured' && matchScore >= FEATURED_GATE) {
    featuredBonus = FEATURED_BONUS;
  }

  // Freshness — linear decay from FRESHNESS_MAX_BONUS at posting time
  // down to 0 at FRESHNESS_WINDOW_HOURS old. After the window, no bonus.
  let freshnessBonus = 0;
  const ageHrs = hoursBetween(job.created_at, now);
  if (ageHrs !== null && ageHrs >= 0) {
    if (ageHrs < FRESHNESS_WINDOW_HOURS) {
      freshnessBonus = FRESHNESS_MAX_BONUS *
        (1 - ageHrs / FRESHNESS_WINDOW_HOURS);
    }
  }

  // Expiry — flag jobs about to disappear so they sink rather than
  // monopolise the top slots in their final hours.
  let expiryPenalty = 0;
  if (job.expiry_date) {
    const t = Date.parse(job.expiry_date);
    if (!Number.isNaN(t)) {
      const hrsToExpiry = (t - now.getTime()) / HOUR_MS;
      if (hrsToExpiry > 0 && hrsToExpiry < EXPIRY_THRESHOLD_HOURS) {
        expiryPenalty = EXPIRY_PENALTY;
      }
    }
  }

  // Stale-boost penalty — anti "urgent forever". Applies only when the
  // boost is still active and its start is older than the grace window.
  let staleBoostPenalty = 0;
  if (isActive && job.boost_starts_at) {
    const boostAgeHrs = hoursBetween(job.boost_starts_at, now);
    if (boostAgeHrs !== null && boostAgeHrs > STALE_GRACE_HOURS) {
      const overage = boostAgeHrs - STALE_GRACE_HOURS;
      staleBoostPenalty = Math.min(
        STALE_PENALTY_CAP,
        overage * STALE_PENALTY_PER_HOUR
      );
    }
  }

  let finalScore =
    matchScore +
    urgentBonus +
    boostBonus +
    featuredBonus +
    freshnessBonus -
    expiryPenalty -
    staleBoostPenalty;

  // Clamp to a safe range. The lower bound prevents penalties from
  // dragging a 0-match job into negative territory; the upper bound
  // keeps ranking values within a single byte for any future ML.
  if (finalScore > SCORE_CLAMP_MAX) finalScore = SCORE_CLAMP_MAX;
  if (finalScore < SCORE_CLAMP_MIN) finalScore = SCORE_CLAMP_MIN;

  return {
    finalScore,
    components: {
      matchScore,
      urgentBonus,
      boostBonus,
      featuredBonus,
      freshnessBonus,
      expiryPenalty,
      staleBoostPenalty,
    },
    isFeatured: boostType === 'featured',
    matchBelowFloor: matchScore < FLOOR_MATCH_SCORE,
  };
}

// ---------------------------------------------------------------------------
// applyFeaturedCap — at most one featured per FEATURED_BLOCK_SIZE positions.
// We walk the array left-to-right; the first featured in each block is
// kept; further featured slots get bumped to the next block. Non-featured
// jobs slide up to fill the holes so the list length is preserved.
// ---------------------------------------------------------------------------
function applyFeaturedCap(scored) {
  const result = [];
  const heldFeatured = []; // featured jobs displaced from earlier blocks
  let blockFeaturedCount = 0;

  const flushIfBlockEnd = () => {
    if (result.length > 0 && result.length % FEATURED_BLOCK_SIZE === 0) {
      blockFeaturedCount = 0;
      // After a block boundary, try to seat a held featured first.
      if (heldFeatured.length > 0) {
        const next = heldFeatured.shift();
        result.push(next);
        blockFeaturedCount += 1;
      }
    }
  };

  for (const item of scored) {
    if (item.isFeatured) {
      if (blockFeaturedCount === 0) {
        result.push(item);
        blockFeaturedCount += 1;
      } else {
        heldFeatured.push(item);
      }
    } else {
      result.push(item);
    }
    flushIfBlockEnd();
  }

  // Drain leftovers — any held featured that didn't get a seat go to
  // the very end, preserving their relative order.
  for (const f of heldFeatured) result.push(f);

  return result;
}

// ---------------------------------------------------------------------------
// applyMatchScoreFloor — soft demotion for matchScore < 30.
// We move all sub-floor jobs out of the first TOP_WINDOW positions, but
// keep them visible immediately after, so candidates can still scroll
// to them. This is Option 1 from the plan — less aggressive than a
// hard exclusion.
// ---------------------------------------------------------------------------
function applyMatchScoreFloor(arr) {
  if (arr.length <= TOP_WINDOW) return arr;
  const top = [];
  const demoted = [];
  for (const item of arr) {
    if (top.length < TOP_WINDOW && item.matchBelowFloor) {
      demoted.push(item);
    } else {
      top.push(item);
    }
  }
  // Splice demoted right after the top window, preserving order.
  const head = top.slice(0, TOP_WINDOW);
  const tail = top.slice(TOP_WINDOW);
  return [...head, ...demoted, ...tail];
}

// ---------------------------------------------------------------------------
// rankJobs — the public entry point.
//
// Inputs:
//   jobs       — array of plain objects (DB rows or DTOs). Required fields:
//                  match_score (number, 0..100)
//                  boost_status, boost_type, boost_priority, boost_starts_at,
//                  created_at, expiry_date
//   options    — { enabled, log, now }
//                 enabled: boolean, defaults to featureFlags.rankingEnabled
//                 log:     boolean, defaults to featureFlags.rankingLog
//                 now:     Date, defaults to new Date(); injectable for tests
//
// Output: a NEW array. Each job carries an injected `__ranking` field
// (only when enabled) with the breakdown — controllers can strip it
// before serialising or pass it through when ?explain=1 is set.
// ---------------------------------------------------------------------------
function rankJobs(jobs, options = {}) {
  const flags = require('../config/featureFlags');
  const enabled = options.enabled ?? flags.rankingEnabled;
  const log     = options.log     ?? flags.rankingLog;
  const now     = options.now     ?? new Date();

  if (!Array.isArray(jobs)) return jobs;

  // Pass-through path — keeps Step 2 production-neutral.
  if (!enabled) return jobs;

  const scored = jobs.map((job) => {
    const breakdown = computeBreakdown(job, now);
    return {
      job,
      finalScore: breakdown.finalScore,
      components: breakdown.components,
      isFeatured: breakdown.isFeatured,
      matchBelowFloor: breakdown.matchBelowFloor,
    };
  });

  scored.sort((a, b) => {
    if (b.finalScore !== a.finalScore) return b.finalScore - a.finalScore;
    // Stable tiebreaker: matchScore wins over featured/freshness alone,
    // then featured. Same as quickjobsDeck legacy ordering.
    const am = a.components.matchScore;
    const bm = b.components.matchScore;
    if (bm !== am) return bm - am;
    if (a.isFeatured !== b.isFeatured) return a.isFeatured ? -1 : 1;
    return 0;
  });

  const floored = applyMatchScoreFloor(scored);
  const capped  = applyFeaturedCap(floored);

  if (log) {
    for (let i = 0; i < capped.length; i += 1) {
      const r = capped[i];
      // eslint-disable-next-line no-console
      console.log(
        `[ranking] pos=${i + 1} score=${r.finalScore.toFixed(2)} ` +
        `match=${r.components.matchScore} ` +
        `urgent=${r.components.urgentBonus} top=${r.components.boostBonus.toFixed(1)} ` +
        `featured=${r.components.featuredBonus} fresh=${r.components.freshnessBonus.toFixed(2)} ` +
        `exp=-${r.components.expiryPenalty} stale=-${r.components.staleBoostPenalty.toFixed(1)}`
      );
    }
  }

  return capped.map((r) => ({
    ...r.job,
    __ranking: {
      finalScore: r.finalScore,
      components: r.components,
    },
  }));
}

module.exports = {
  rankJobs,
  computeBreakdown,        // exported for tests
  applyFeaturedCap,        // exported for tests
  applyMatchScoreFloor,    // exported for tests
  // constants exported so tests assert against canonical values
  CONSTANTS: {
    URGENT_BONUS, URGENT_GATE, FEATURED_BONUS, FEATURED_GATE,
    TOP_GATE, TOP_BONUS_CAP, TOP_PRIORITY_FACTOR,
    FRESHNESS_WINDOW_HOURS, FRESHNESS_MAX_BONUS,
    EXPIRY_THRESHOLD_HOURS, EXPIRY_PENALTY,
    STALE_GRACE_HOURS, STALE_PENALTY_PER_HOUR, STALE_PENALTY_CAP,
    FLOOR_MATCH_SCORE, TOP_WINDOW, FEATURED_BLOCK_SIZE,
    SCORE_CLAMP_MIN, SCORE_CLAMP_MAX,
  },
};
