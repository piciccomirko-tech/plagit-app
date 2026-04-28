/**
 * Unit tests for services/jobRanking.js
 *
 * Run with:  npm test
 * (uses Node's built-in `node --test` runner — no Jest/Mocha needed)
 *
 * The tests are flag-aware: they pass `enabled: true` explicitly to
 * exercise the formula. The production-default OFF path is covered by
 * the "pass-through" test.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const {
  rankJobs,
  computeBreakdown,
  applyFeaturedCap,
  applyMatchScoreFloor,
  CONSTANTS,
} = require('../../src/services/jobRanking');

const NOW = new Date('2026-04-28T12:00:00.000Z');

function hoursAgo(n) {
  return new Date(NOW.getTime() - n * 60 * 60 * 1000).toISOString();
}
function hoursAhead(n) {
  return new Date(NOW.getTime() + n * 60 * 60 * 1000).toISOString();
}

function makeJob(overrides = {}) {
  return {
    id: 'job_x',
    match_score: 60,
    boost_status: 'none',
    boost_type: null,
    boost_priority: 0,
    boost_starts_at: null,
    created_at: hoursAgo(1),
    expiry_date: null,
    ...overrides,
  };
}

// ---------------------------------------------------------------------------
// Pass-through behaviour
// ---------------------------------------------------------------------------

test('rankJobs pass-through when flag is OFF', () => {
  const a = makeJob({ id: 'a', match_score: 10 });
  const b = makeJob({ id: 'b', match_score: 90 });
  const out = rankJobs([a, b], { enabled: false, now: NOW });
  // identity preserved (same order, no __ranking injected)
  assert.equal(out[0].id, 'a');
  assert.equal(out[1].id, 'b');
  assert.equal(out[0].__ranking, undefined);
});

test('rankJobs returns input unchanged when not an array', () => {
  assert.equal(rankJobs(null, { enabled: true, now: NOW }), null);
  assert.equal(rankJobs(undefined, { enabled: true, now: NOW }), undefined);
});

// ---------------------------------------------------------------------------
// computeBreakdown — per-component scoring
// ---------------------------------------------------------------------------

test('urgent boost applies +5 only when matchScore >= 40', () => {
  const above = computeBreakdown(makeJob({
    match_score: 50, boost_status: 'active', boost_type: 'urgent', boost_priority: 25,
  }), NOW);
  assert.equal(above.components.urgentBonus, CONSTANTS.URGENT_BONUS);

  const below = computeBreakdown(makeJob({
    match_score: 30, boost_status: 'active', boost_type: 'urgent', boost_priority: 25,
  }), NOW);
  assert.equal(below.components.urgentBonus, 0);
});

test('top boost = priority * 0.2, capped at 20, gated at matchScore >= 50', () => {
  const above = computeBreakdown(makeJob({
    match_score: 60, boost_status: 'active', boost_type: 'top', boost_priority: 80,
  }), NOW);
  assert.equal(above.components.boostBonus, 16); // 80 * 0.2

  const capped = computeBreakdown(makeJob({
    match_score: 60, boost_status: 'active', boost_type: 'top', boost_priority: 200,
  }), NOW);
  assert.equal(capped.components.boostBonus, CONSTANTS.TOP_BONUS_CAP);

  const gated = computeBreakdown(makeJob({
    match_score: 49, boost_status: 'active', boost_type: 'top', boost_priority: 80,
  }), NOW);
  assert.equal(gated.components.boostBonus, 0);
});

test('featured boost +3 when matchScore >= 40, otherwise 0', () => {
  const above = computeBreakdown(makeJob({
    match_score: 45, boost_status: 'active', boost_type: 'featured',
  }), NOW);
  assert.equal(above.components.featuredBonus, CONSTANTS.FEATURED_BONUS);

  const below = computeBreakdown(makeJob({
    match_score: 39, boost_status: 'active', boost_type: 'featured',
  }), NOW);
  assert.equal(below.components.featuredBonus, 0);
});

test('inactive boost contributes nothing regardless of type/priority', () => {
  const out = computeBreakdown(makeJob({
    match_score: 80, boost_status: 'expired', boost_type: 'top', boost_priority: 80,
  }), NOW);
  assert.equal(out.components.urgentBonus, 0);
  assert.equal(out.components.boostBonus, 0);
  assert.equal(out.components.featuredBonus, 0);
});

test('freshness decays linearly over 72h', () => {
  const fresh = computeBreakdown(makeJob({ created_at: hoursAgo(0) }), NOW);
  assert.equal(fresh.components.freshnessBonus, CONSTANTS.FRESHNESS_MAX_BONUS);

  const half = computeBreakdown(makeJob({ created_at: hoursAgo(36) }), NOW);
  assert.equal(half.components.freshnessBonus, CONSTANTS.FRESHNESS_MAX_BONUS / 2);

  const expired = computeBreakdown(makeJob({ created_at: hoursAgo(80) }), NOW);
  assert.equal(expired.components.freshnessBonus, 0);
});

test('expiry penalty hits jobs within 24h of expiring (but not after)', () => {
  const soon = computeBreakdown(makeJob({ expiry_date: hoursAhead(6) }), NOW);
  assert.equal(soon.components.expiryPenalty, CONSTANTS.EXPIRY_PENALTY);

  const far = computeBreakdown(makeJob({ expiry_date: hoursAhead(48) }), NOW);
  assert.equal(far.components.expiryPenalty, 0);

  const past = computeBreakdown(makeJob({ expiry_date: hoursAgo(1) }), NOW);
  // Already expired — the SQL `status='active'` filter would have
  // dropped this, but the formula short-circuits at hrs <= 0 anyway.
  assert.equal(past.components.expiryPenalty, 0);
});

test('stale-boost penalty starts after 12h, ramps -2/h, caps at -10', () => {
  const fresh = computeBreakdown(makeJob({
    boost_status: 'active', boost_type: 'urgent', boost_starts_at: hoursAgo(6),
  }), NOW);
  assert.equal(fresh.components.staleBoostPenalty, 0);

  const ramping = computeBreakdown(makeJob({
    boost_status: 'active', boost_type: 'urgent', boost_starts_at: hoursAgo(15),
  }), NOW);
  assert.equal(ramping.components.staleBoostPenalty, 6); // (15-12)*2

  const capped = computeBreakdown(makeJob({
    boost_status: 'active', boost_type: 'urgent', boost_starts_at: hoursAgo(48),
  }), NOW);
  assert.equal(capped.components.staleBoostPenalty, CONSTANTS.STALE_PENALTY_CAP);
});

// ---------------------------------------------------------------------------
// rankJobs — ordering integration
// ---------------------------------------------------------------------------

test('higher matchScore wins over plain freshness alone', () => {
  const fresh = makeJob({ id: 'fresh', match_score: 30, created_at: hoursAgo(0) });
  const old   = makeJob({ id: 'old',   match_score: 80, created_at: hoursAgo(70) });
  const out = rankJobs([fresh, old], { enabled: true, now: NOW });
  assert.equal(out[0].id, 'old');
});

test('top boost lifts a 65-match job above an 80-match unboosted job', () => {
  const unboosted = makeJob({ id: 'plain', match_score: 80 });
  const topBoost  = makeJob({
    id: 'boosted',
    match_score: 65,
    boost_status: 'active',
    boost_type: 'top',
    boost_priority: 100, // +20 max — beats the 15-pt match deficit
  });
  const out = rankJobs([unboosted, topBoost], { enabled: true, now: NOW });
  // 80 + freshness vs 65 + 20 + freshness => boosted wins by ~5
  assert.equal(out[0].id, 'boosted');
});

// ---------------------------------------------------------------------------
// Floor — matchScore < 30 demoted out of the top 10
// ---------------------------------------------------------------------------

test('applyMatchScoreFloor pushes sub-30 matches below the top window', () => {
  const lows  = Array.from({ length: 5 }, (_, i) => ({
    job: { id: `lo_${i}` }, finalScore: 100, components: { matchScore: 10 },
    isFeatured: false, matchBelowFloor: true,
  }));
  const highs = Array.from({ length: 12 }, (_, i) => ({
    job: { id: `hi_${i}` }, finalScore: 50, components: { matchScore: 60 },
    isFeatured: false, matchBelowFloor: false,
  }));
  // Caller delivers them sorted by finalScore — lows first because
  // their nominal score is higher, but they should still be demoted.
  const out = applyMatchScoreFloor([...lows, ...highs]);
  // First 10 must all be high-match
  for (let i = 0; i < CONSTANTS.TOP_WINDOW; i += 1) {
    assert.equal(out[i].matchBelowFloor, false);
  }
  // Then the 5 lows should appear before the rest of the highs
  assert.equal(out[CONSTANTS.TOP_WINDOW].matchBelowFloor, true);
});

test('floor is a no-op when total list <= TOP_WINDOW', () => {
  const items = Array.from({ length: 5 }, (_, i) => ({
    job: { id: `j_${i}` }, finalScore: 50, components: { matchScore: 10 },
    isFeatured: false, matchBelowFloor: true,
  }));
  const out = applyMatchScoreFloor(items);
  assert.deepEqual(out.map((x) => x.job.id), items.map((x) => x.job.id));
});

// ---------------------------------------------------------------------------
// Featured cap — 1 featured per 8-block
// ---------------------------------------------------------------------------

test('applyFeaturedCap places at most 1 featured per 8-block', () => {
  // 3 featured + 7 normal, all sorted by finalScore in input order.
  const items = [
    { job: { id: 'f1' }, finalScore: 100, components: {}, isFeatured: true,  matchBelowFloor: false },
    { job: { id: 'f2' }, finalScore: 95,  components: {}, isFeatured: true,  matchBelowFloor: false },
    { job: { id: 'f3' }, finalScore: 90,  components: {}, isFeatured: true,  matchBelowFloor: false },
    ...Array.from({ length: 14 }, (_, i) => ({
      job: { id: `n${i}` }, finalScore: 80 - i, components: {},
      isFeatured: false, matchBelowFloor: false,
    })),
  ];
  const out = applyFeaturedCap(items);
  // Block 1 (positions 0..7): exactly one featured allowed.
  const block1 = out.slice(0, CONSTANTS.FEATURED_BLOCK_SIZE);
  const block1Featured = block1.filter((x) => x.isFeatured).length;
  assert.equal(block1Featured, 1);
  // Block 2 (positions 8..15): exactly one allowed too.
  const block2 = out.slice(CONSTANTS.FEATURED_BLOCK_SIZE, 2 * CONSTANTS.FEATURED_BLOCK_SIZE);
  const block2Featured = block2.filter((x) => x.isFeatured).length;
  assert.equal(block2Featured, 1);
});

test('rankJobs preserves array length even with displaced featured', () => {
  const jobs = [
    makeJob({ id: 'a', match_score: 80, boost_status: 'active', boost_type: 'featured' }),
    makeJob({ id: 'b', match_score: 75, boost_status: 'active', boost_type: 'featured' }),
    makeJob({ id: 'c', match_score: 70 }),
    makeJob({ id: 'd', match_score: 65 }),
  ];
  const out = rankJobs(jobs, { enabled: true, now: NOW });
  assert.equal(out.length, jobs.length);
  // Set equality: same id set
  const ids = new Set(out.map((j) => j.id));
  assert.deepEqual(ids, new Set(['a', 'b', 'c', 'd']));
});

// ---------------------------------------------------------------------------
// Output shape
// ---------------------------------------------------------------------------

test('rankJobs attaches __ranking only when enabled', () => {
  const job = makeJob({ id: 'only' });
  const off = rankJobs([job], { enabled: false, now: NOW });
  assert.equal(off[0].__ranking, undefined);

  const on = rankJobs([job], { enabled: true, now: NOW });
  assert.ok(on[0].__ranking);
  assert.ok(typeof on[0].__ranking.finalScore === 'number');
  assert.ok(on[0].__ranking.components);
  // input must not be mutated
  assert.equal(job.__ranking, undefined);
});
