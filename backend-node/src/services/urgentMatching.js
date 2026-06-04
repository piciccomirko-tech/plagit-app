/**
 * Urgent-request → candidate matching + notification fan-out (Stage N1-1).
 *
 * This is the REVERSE of the AL.5.3 candidate-side matcher in
 * candidateController.listUrgentRequestsForCandidate: given an
 * urgent_request, find the candidates it should notify. To avoid a
 * second, divergent matching algorithm the scoring primitives here
 * (haversineKm / availabilityFitScore / role-match rule / radius /
 * sort order) MIRROR AL.5.3 exactly. They are duplicated rather than
 * imported only to avoid a require cycle (candidateController already
 * imports hiringNotify from businessController); a future cleanup can
 * unify both call sites onto these exports.
 *
 * Dependency-injected `hiringNotify`: this module depends ONLY on the
 * db handle. The caller (businessController.createUrgentRequest) passes
 * its in-scope hiringNotify, so there is no businessController ⇄ service
 * import cycle. hiringNotify gives us persist + `notification.new` SSE +
 * the (recipient_id, linked_entity, destination_route) dedupe for free.
 *
 * Two caps (policy v1):
 *   • per-request   — max 25 candidates with reliable geo, max 10 in
 *                     fallback (no geo). Protects a single urgent post.
 *   • per-candidate — max 5 urgent_request_match notifications per
 *                     candidate per UTC day. Protects a candidate from
 *                     many businesses; the key push-storm guard.
 */

'use strict';

const db = require('../config/db');

const ROUTE = 'urgent_request_match';
const CAP_GEO = 25;
const CAP_FALLBACK = 10;
const PER_CANDIDATE_DAILY_CAP = 5;
const DEFAULT_RADIUS_KM = 10;
const MAX_RADIUS_KM = 200;
const FETCH_LIMIT = 500; // safety ceiling on the candidate pool fetched per request

// ── pure scoring primitives (mirror AL.5.3) ────────────────────────────────
function haversineKm(lat1, lng1, lat2, lng2) {
  if ([lat1, lng1, lat2, lng2].some((v) => typeof v !== 'number' || !Number.isFinite(v))) {
    return null;
  }
  const toRad = (d) => (d * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a = Math.sin(dLat / 2) ** 2
    + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return Math.min(R * 2 * Math.asin(Math.sqrt(Math.max(0, Math.min(1, a)))), R * Math.PI);
}

function sameUtcDay(a, b) {
  return a.getUTCFullYear() === b.getUTCFullYear()
    && a.getUTCMonth() === b.getUTCMonth()
    && a.getUTCDate() === b.getUTCDate();
}

const _NOW_WINDOW_MS = 4 * 60 * 60 * 1000;
const _GRACE_MS = 60 * 60 * 1000;
const _WEEKEND_LOOKAHEAD_MS = 7 * 24 * 60 * 60 * 1000;

function availabilityFitScore(state, startsAt, now) {
  if (!state) return 0;
  const ms = startsAt.getTime() - now.getTime();
  if (state === 'now') return ms <= _NOW_WINDOW_MS && ms >= -_GRACE_MS ? 5 : 0;
  if (state === 'today') return sameUtcDay(startsAt, now) ? 4 : 0;
  if (state === 'tomorrow') {
    const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000);
    return sameUtcDay(startsAt, tomorrow) ? 3 : 0;
  }
  if (state === 'this_weekend') {
    if (ms < -_GRACE_MS || ms > _WEEKEND_LOOKAHEAD_MS) return 0;
    const day = startsAt.getUTCDay();
    return (day === 0 || day === 6) ? 2 : 0;
  }
  if (state === 'evening_only' || state === 'full_time' || state === 'part_time') return 1;
  return 0;
}

// ── reverse matcher: urgent_request → ranked, per-request-capped candidates ─
async function findMatchingCandidatesForUrgentRequest(urgentRequest, opts = {}) {
  const capGeo = opts.capGeo ?? CAP_GEO;
  const capFallback = opts.capFallback ?? CAP_FALLBACK;

  const urRole = (urgentRequest.role || '').trim();
  if (!urRole) return [];

  const urLat = typeof urgentRequest.latitude === 'number' ? urgentRequest.latitude
    : (urgentRequest.latitude != null ? Number(urgentRequest.latitude) : null);
  const urLng = typeof urgentRequest.longitude === 'number' ? urgentRequest.longitude
    : (urgentRequest.longitude != null ? Number(urgentRequest.longitude) : null);
  const geoReliable = Number.isFinite(urLat) && Number.isFinite(urLng);
  const cap = geoReliable ? capGeo : capFallback;

  // Role + availability + active filters mirror the AL.5.3 SQL, inverted:
  // here urgent.role is the fixed haystack and the candidate's role(s)
  // are the needle. NULLIF/TRIM guards prevent an empty role column from
  // turning '%%' into a match-everything wildcard.
  const rows = await db('candidates as c')
    .join('users as u', 'u.id', 'c.user_id')
    .where('u.status', 'active')
    .whereNotNull('c.availability_state')
    .where((qb) => qb
      .whereNull('c.availability_until')
      .orWhere('c.availability_until', '>', db.fn.now()))
    .andWhere((qb) => {
      qb.whereRaw(
        `(COALESCE(NULLIF(TRIM(c.primary_role), ''), NULLIF(TRIM(c.role), '')) IS NOT NULL
          AND ? ILIKE '%' || COALESCE(NULLIF(TRIM(c.primary_role), ''), NULLIF(TRIM(c.role), '')) || '%')`,
        [urRole],
      ).orWhereRaw(
        `EXISTS (
           SELECT 1 FROM unnest(c.additional_roles) AS ar
           WHERE NULLIF(TRIM(ar), '') IS NOT NULL AND ? ILIKE '%' || TRIM(ar) || '%'
         )`,
        [urRole],
      );
    })
    .modify((qb) => {
      // Defensive: never notify a candidate already assigned to this shift
      // (null at create time, but the helper may be reused on later flows).
      if (urgentRequest.filled_by_candidate_id) {
        qb.whereNot('c.id', urgentRequest.filled_by_candidate_id);
      }
    })
    .select(
      'c.id as candidate_id',
      'c.name',
      'c.role',
      'c.primary_role',
      'c.additional_roles',
      'c.availability_state',
      'c.preferred_area_radius_km',
      'u.id as user_id',
      'u.latitude as user_latitude',
      'u.longitude as user_longitude',
    )
    .limit(FETCH_LIMIT);

  const now = new Date();
  const startsAt = new Date(urgentRequest.starts_at);
  const urRoleLower = urRole.toLowerCase();

  const scored = rows.map((r) => {
    const primary = (r.primary_role || r.role || '').trim().toLowerCase();
    const additional = Array.isArray(r.additional_roles)
      ? r.additional_roles.map((x) => String(x).trim().toLowerCase()).filter(Boolean)
      : [];
    let matchScore = 0;
    if (primary && urRoleLower.includes(primary)) matchScore = 2;
    else if (additional.some((ar) => urRoleLower.includes(ar))) matchScore = 1;

    const fit = availabilityFitScore(r.availability_state, startsAt, now);

    let distanceKm = null;
    if (geoReliable && typeof r.user_latitude === 'number' && typeof r.user_longitude === 'number') {
      const d = haversineKm(r.user_latitude, r.user_longitude, urLat, urLng);
      if (d !== null) distanceKm = Math.round(d * 10) / 10;
    }
    const radiusKm = Math.max(1, Math.min(r.preferred_area_radius_km || DEFAULT_RADIUS_KM, MAX_RADIUS_KM));

    return {
      userId: r.user_id,
      candidateId: r.candidate_id,
      name: r.name,
      matchScore,
      fit,
      distanceKm,
      radiusKm,
    };
  })
    .filter((s) => s.matchScore > 0)
    .filter((s) => {
      if (!geoReliable) return true; // no geo on the request → role+availability only
      if (s.distanceKm === null) return true; // candidate without geo → graceful pass, ranked last
      return s.distanceKm <= s.radiusKm; // respects each candidate's (premium-aware) radius
    });

  // Sort mirrors AL.5.3: match_score DESC, availability_fit DESC,
  // distance ASC (null last), then a stable id tiebreak for determinism.
  scored.sort((a, b) => {
    if (b.matchScore !== a.matchScore) return b.matchScore - a.matchScore;
    if (b.fit !== a.fit) return b.fit - a.fit;
    const aD = a.distanceKm === null ? Number.POSITIVE_INFINITY : a.distanceKm;
    const bD = b.distanceKm === null ? Number.POSITIVE_INFINITY : b.distanceKm;
    if (aD !== bD) return aD - bD;
    return String(a.candidateId).localeCompare(String(b.candidateId));
  });

  return scored.slice(0, cap);
}

// ── per-candidate/day cap: drop ids already at the daily notification cap ──
async function filterUnderDailyCap(userIds, opts = {}) {
  const route = opts.route || ROUTE;
  const perDay = opts.perDay ?? PER_CANDIDATE_DAILY_CAP;
  if (!userIds.length) return [];

  const startOfUtcDay = new Date();
  startOfUtcDay.setUTCHours(0, 0, 0, 0);

  const counts = await db('notifications')
    .whereIn('recipient_id', userIds)
    .where('destination_route', route)
    .where('created_at', '>=', startOfUtcDay.toISOString())
    .groupBy('recipient_id')
    .select('recipient_id')
    .count('* as c');

  const byId = new Map(counts.map((r) => [r.recipient_id, Number(r.c)]));
  return userIds.filter((id) => (byId.get(id) || 0) < perDay);
}

// ── orchestrator: match → daily-cap → fan-out hiringNotify ─────────────────
async function notifyMatchingCandidatesForUrgentRequest(urgentRequest, hiringNotify, opts = {}) {
  const matches = await findMatchingCandidatesForUrgentRequest(urgentRequest, opts);
  if (!matches.length) return { matched: 0, notified: 0 };

  const allowed = new Set(await filterUnderDailyCap(
    matches.map((m) => m.userId),
    { route: ROUTE, perDay: opts.perDay },
  ));

  let businessName = opts.businessName;
  if (businessName === undefined) {
    const biz = await db('businesses').where({ id: urgentRequest.business_id }).first();
    businessName = (biz && biz.name) || null;
  }
  const roleLabel = (urgentRequest.role || '').trim();
  const bizLabel = businessName || 'A business';

  let notified = 0;
  for (const m of matches) {
    if (!allowed.has(m.userId)) continue;
    const body = roleLabel
      ? `${bizLabel} needs a ${roleLabel} now`
      : `${bizLabel} posted an urgent shift`;
    // eslint-disable-next-line no-await-in-loop
    await hiringNotify(m.userId, 'Urgent shift available', 'in_app', urgentRequest.id, ROUTE, body);
    notified += 1;
  }
  return { matched: matches.length, notified };
}

module.exports = {
  ROUTE,
  CAP_GEO,
  CAP_FALLBACK,
  PER_CANDIDATE_DAILY_CAP,
  haversineKm,
  availabilityFitScore,
  findMatchingCandidatesForUrgentRequest,
  filterUnderDailyCap,
  notifyMatchingCandidatesForUrgentRequest,
};
