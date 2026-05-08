// Polymorphic entity-share preview builder.
//
// Given a `(type, id, viewerRole)` tuple, performs a read-only lookup
// against the right table (`candidates` / `businesses` / `jobs` /
// `interviews`) and returns a compact envelope the chat client can
// render as a card without having to refetch the entity.
//
// Returns `null` when:
//   - the entity is missing (e.g. job deleted, candidate hard-removed)
//   - the type is unsupported
//
// The envelope is read-only and never mutates DB state. Routes are
// resolved against the GoRouter paths actually wired in the Flutter
// app (lib/routes/app_router.dart).

const db = require('../config/db');

const SUPPORTED_TYPES = new Set([
  'profile_candidate',
  'profile_business',
  'job',
  'interview',
]);

/** Allowlist guard used by sendMessage controllers before insert. */
function isSupportedShareType(type) {
  return typeof type === 'string' && SUPPORTED_TYPES.has(type);
}

/**
 * Build the compact preview envelope for a chat-attached entity.
 *
 * @param {object} args
 * @param {string} args.type       'profile_candidate'|'profile_business'|'job'|'interview'
 * @param {string} args.id         uuid of the target entity
 * @param {string} args.viewerRole 'candidate'|'business'|'admin'
 * @returns {Promise<object|null>} envelope or null
 */
async function buildEntityShareEnvelope({ type, id, viewerRole }) {
  if (!isSupportedShareType(type)) return null;
  if (typeof id !== 'string' || id.length === 0) return null;

  switch (type) {
    case 'profile_candidate':
      return _candidateProfile(id, viewerRole);
    case 'profile_business':
      return _businessProfile(id, viewerRole);
    case 'job':
      return _job(id, viewerRole);
    case 'interview':
      return _interview(id, viewerRole);
    default:
      return null;
  }
}

// ── per-type lookups ──────────────────────────────────────────────

async function _candidateProfile(id, viewerRole) {
  // Tolerate both `candidates.id` (canonical) and `candidates.user_id`
  // (what `/v1/candidate/profile` returns to the client). The OR keeps
  // the schema honest while making the API forgiving — clients that
  // share "their" profile id from the auth provider don't need to know
  // about the candidates ↔ users join detail.
  const row = await db('candidates')
    .leftJoin('users', 'candidates.user_id', 'users.id')
    .where(function () {
      this.where('candidates.id', id).orWhere('candidates.user_id', id);
    })
    .select(
      'candidates.id',
      'candidates.name',
      'candidates.role',
      'candidates.location',
      'users.photo_url',
    )
    .first();
  if (!row) return null;
  return {
    type: 'profile_candidate',
    id: row.id,
    title: row.name || 'Candidate',
    subtitle: _joinNonEmpty([row.role, row.location], ' · '),
    image_url: row.photo_url || null,
    // Viewer-aware route. A business clicking the card opens the
    // candidate detail; a candidate clicking their own shared card
    // lands on their own profile (we don't yet have a "public other
    // candidate" view in the candidate flow).
    route: viewerRole === 'business'
      ? `/business/candidate/${row.id}`
      : '/candidate/profile',
  };
}

async function _businessProfile(id, viewerRole) {
  // Same dual-id tolerance as `_candidateProfile` — accept either
  // the businesses row id or the underlying user id.
  const row = await db('businesses')
    .leftJoin('users', 'businesses.user_id', 'users.id')
    .where(function () {
      this.where('businesses.id', id).orWhere('businesses.user_id', id);
    })
    .select(
      'businesses.id',
      'businesses.name',
      'businesses.venue_type',
      'businesses.location',
      'users.photo_url',
    )
    .first();
  if (!row) return null;
  return {
    type: 'profile_business',
    id: row.id,
    title: row.name || 'Business',
    subtitle: _joinNonEmpty([row.venue_type, row.location], ' · '),
    image_url: row.photo_url || null,
    // Business viewer → own-profile tab. Candidate viewer → the
    // dedicated `/candidate/business/:id` view added in Phase 4
    // (backed by GET /v1/candidate/businesses/:id).
    route: viewerRole === 'business'
      ? '/business/profile'
      : `/candidate/business/${row.id}`,
  };
}

async function _job(id, viewerRole) {
  const row = await db('jobs')
    .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
    .where('jobs.id', id)
    .select(
      'jobs.id',
      'jobs.title',
      'jobs.location as job_location',
      'jobs.employment_type',
      'businesses.name as business_name',
    )
    .first();
  if (!row) return null;
  return {
    type: 'job',
    id: row.id,
    title: row.title || 'Job',
    subtitle: _joinNonEmpty(
      [row.business_name, row.job_location, row.employment_type],
      ' · ',
    ),
    image_url: null,
    route: viewerRole === 'business'
      ? `/business/job/${row.id}`
      : `/candidate/job/${row.id}`,
  };
}

async function _interview(id, viewerRole) {
  const row = await db('interviews')
    .leftJoin('jobs', 'interviews.job_id', 'jobs.id')
    .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
    .where('interviews.id', id)
    .select(
      'interviews.id',
      'interviews.scheduled_at',
      'interviews.interview_type',
      'interviews.status',
      'jobs.title as job_title',
      'businesses.name as business_name',
    )
    .first();
  if (!row) return null;
  // Subtitle keeps text-only fields. The schedule timestamp travels
  // separately as `scheduled_at` (ISO, UTC) so the client can format
  // it with the user's locale + timezone — pinning a server-side
  // pretty string would be wrong for any user outside UAE.
  const typeLabel = (row.interview_type || '').toString().replace('_', ' ');
  return {
    type: 'interview',
    id: row.id,
    title: row.job_title
      ? `Interview · ${row.job_title}`
      : 'Interview',
    subtitle: _joinNonEmpty([row.business_name, typeLabel], ' · '),
    image_url: null,
    scheduled_at: row.scheduled_at ? row.scheduled_at.toISOString() : null,
    route: viewerRole === 'business'
      ? `/business/interview/${row.id}`
      : `/candidate/interview/${row.id}`,
  };
}

// ── helpers ───────────────────────────────────────────────────────

function _joinNonEmpty(parts, sep) {
  return parts
    .filter((s) => typeof s === 'string' && s.trim().length > 0)
    .join(sep);
}

/**
 * Batch helper for listMessages — given an array of `(type, id)`
 * pairs collected from a thread page, runs at most 4 grouped queries
 * (one per supported type) and returns a `Map<idKey, envelope>`
 * keyed by `${type}:${id}`. Avoids N+1 lookups when a thread has
 * many entity-share rows.
 *
 * Items with unsupported types or missing ids are silently skipped.
 * Items pointing at a missing entity get no envelope (the caller
 * should treat the absent map entry as "deleted" → null on the row).
 *
 * @param {Array<{type:string,id:string}>} items
 * @param {string} viewerRole 'candidate'|'business'|'admin'
 * @returns {Promise<Map<string, object>>}
 */
async function batchEntityShareEnvelopes(items, viewerRole) {
  const result = new Map();
  if (!Array.isArray(items) || items.length === 0) return result;

  // Group ids by supported type. Stable insertion order isn't
  // required — the caller looks up by key.
  const byType = new Map();
  for (const it of items) {
    if (!it || !isSupportedShareType(it.type)) continue;
    if (typeof it.id !== 'string' || it.id.length === 0) continue;
    const set = byType.get(it.type) || new Set();
    set.add(it.id);
    byType.set(it.type, set);
  }
  if (byType.size === 0) return result;

  // Run at most one grouped query per type, in parallel.
  const fetchers = [];
  for (const [type, ids] of byType.entries()) {
    fetchers.push(_fetchByType(type, [...ids], viewerRole, result));
  }
  await Promise.all(fetchers);
  return result;
}

async function _fetchByType(type, ids, viewerRole, out) {
  switch (type) {
    case 'profile_candidate': {
      // Dual-id tolerance — see `_candidateProfile`. We map BOTH
      // ids back to the canonical row so callers passing user_id
      // also hit the cache key correctly.
      const rows = await db('candidates')
        .leftJoin('users', 'candidates.user_id', 'users.id')
        .where(function () {
          this.whereIn('candidates.id', ids).orWhereIn('candidates.user_id', ids);
        })
        .select(
          'candidates.id',
          'candidates.user_id',
          'candidates.name',
          'candidates.role',
          'candidates.location',
          'users.photo_url',
        );
      for (const r of rows) {
        const env = {
          type: 'profile_candidate',
          id: r.id,
          title: r.name || 'Candidate',
          subtitle: _joinNonEmpty([r.role, r.location], ' · '),
          image_url: r.photo_url || null,
          route: viewerRole === 'business'
            ? `/business/candidate/${r.id}`
            : '/candidate/profile',
        };
        // Index under both ids the caller might have asked for.
        out.set(`profile_candidate:${r.id}`, env);
        if (r.user_id) out.set(`profile_candidate:${r.user_id}`, env);
      }
      return;
    }
    case 'profile_business': {
      const rows = await db('businesses')
        .leftJoin('users', 'businesses.user_id', 'users.id')
        .where(function () {
          this.whereIn('businesses.id', ids).orWhereIn('businesses.user_id', ids);
        })
        .select(
          'businesses.id',
          'businesses.user_id',
          'businesses.name',
          'businesses.venue_type',
          'businesses.location',
          'users.photo_url',
        );
      for (const r of rows) {
        const env = {
          type: 'profile_business',
          id: r.id,
          title: r.name || 'Business',
          subtitle: _joinNonEmpty([r.venue_type, r.location], ' · '),
          image_url: r.photo_url || null,
          // See `_businessProfile` — candidate viewer hits the
          // dedicated `/candidate/business/:id` view (Phase 4).
          route: viewerRole === 'business'
            ? '/business/profile'
            : `/candidate/business/${r.id}`,
        };
        out.set(`profile_business:${r.id}`, env);
        if (r.user_id) out.set(`profile_business:${r.user_id}`, env);
      }
      return;
    }
    case 'job': {
      const rows = await db('jobs')
        .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
        .whereIn('jobs.id', ids)
        .select(
          'jobs.id',
          'jobs.title',
          'jobs.location as job_location',
          'jobs.employment_type',
          'businesses.name as business_name',
        );
      for (const r of rows) {
        out.set(`job:${r.id}`, {
          type: 'job',
          id: r.id,
          title: r.title || 'Job',
          subtitle: _joinNonEmpty(
            [r.business_name, r.job_location, r.employment_type],
            ' · ',
          ),
          image_url: null,
          route: viewerRole === 'business'
            ? `/business/job/${r.id}`
            : `/candidate/job/${r.id}`,
        });
      }
      return;
    }
    case 'interview': {
      const rows = await db('interviews')
        .leftJoin('jobs', 'interviews.job_id', 'jobs.id')
        .leftJoin('businesses', 'jobs.business_id', 'businesses.id')
        .whereIn('interviews.id', ids)
        .select(
          'interviews.id',
          'interviews.scheduled_at',
          'interviews.interview_type',
          'interviews.status',
          'jobs.title as job_title',
          'businesses.name as business_name',
        );
      for (const r of rows) {
        const typeLabel = (r.interview_type || '').toString().replace('_', ' ');
        out.set(`interview:${r.id}`, {
          type: 'interview',
          id: r.id,
          title: r.job_title ? `Interview · ${r.job_title}` : 'Interview',
          subtitle: _joinNonEmpty([r.business_name, typeLabel], ' · '),
          image_url: null,
          scheduled_at: r.scheduled_at ? r.scheduled_at.toISOString() : null,
          route: viewerRole === 'business'
            ? `/business/interview/${r.id}`
            : `/candidate/interview/${r.id}`,
        });
      }
      return;
    }
    default:
      // Unsupported types are filtered upstream by the caller, so
      // reaching here means a bug. Be defensive — no-op.
      return;
  }
}

module.exports = {
  buildEntityShareEnvelope,
  isSupportedShareType,
  batchEntityShareEnvelopes,
};
