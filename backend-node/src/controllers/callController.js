/**
 * Call lifecycle controller — voice + video calls (WebRTC P2P MVP).
 *
 * Step A scope: REST surface only. No SSE emit yet — the four
 * endpoints below mutate the `calls` table and validate the state
 * machine, so the table-of-truth is correct before the signaling
 * channel is wired in Step B.
 *
 * State machine (kept here instead of in the DB so we can iterate
 * without a migration). Allowed transitions:
 *
 *     ringing  → accepted | declined | missed | failed
 *     accepted → ended    | failed
 *     declined → (terminal)
 *     missed   → (terminal)
 *     ended    → (terminal)
 *     failed   → (terminal)
 *
 * "end" semantics (Mirko approved):
 *   • If the call is still `ringing` and the CALLER ends it → `missed`
 *     (the callee never picked up).
 *   • If the call is `accepted` and EITHER party ends it → `ended`
 *     and duration_s is computed from accepted_at.
 *   • If the call is already terminal, end is a no-op that returns
 *     the current row (idempotent — the Flutter side may call /end
 *     twice on a flaky network and we shouldn't 409).
 *
 * Participant rule: only the conversation's candidate user OR the
 * conversation's business user can initiate / accept / decline / end
 * a call. Non-participants get a 404 (not 403) to keep the existence
 * of the conversation private — mirrors `sendMessage`.
 */

const db = require('../config/db');
const { ok, created } = require('../utils/response');
const AppError = require('../utils/AppError');
const { bus } = require('../services/realtime/eventBus');
const { isCallLogColumnPresent } = require('../services/schemaFeatureFlags');

// ── State machine ──────────────────────────────────────────────────
const STATUS = Object.freeze({
  RINGING:  'ringing',
  ACCEPTED: 'accepted',
  DECLINED: 'declined',
  MISSED:   'missed',
  ENDED:    'ended',
  FAILED:   'failed',
});

const TERMINAL_STATES = new Set([
  STATUS.DECLINED, STATUS.MISSED, STATUS.ENDED, STATUS.FAILED,
]);

const ALLOWED_TRANSITIONS = Object.freeze({
  [STATUS.RINGING]:  new Set([STATUS.ACCEPTED, STATUS.DECLINED, STATUS.MISSED, STATUS.FAILED]),
  [STATUS.ACCEPTED]: new Set([STATUS.ENDED, STATUS.FAILED]),
  [STATUS.DECLINED]: new Set(),
  [STATUS.MISSED]:   new Set(),
  [STATUS.ENDED]:    new Set(),
  [STATUS.FAILED]:   new Set(),
});

function assertTransition(from, to) {
  const allowed = ALLOWED_TRANSITIONS[from];
  if (!allowed || !allowed.has(to)) {
    throw AppError.conflict(
      `Invalid call state transition: ${from} → ${to}.`,
      'CALL_INVALID_TRANSITION',
    );
  }
}

// ── Realtime publish ───────────────────────────────────────────────
//
// Map of DB status → SSE event type. One-to-one because we already
// model six terminal/non-terminal states and the Flutter side wants
// the same vocabulary.
const EVENT_TYPE_BY_STATUS = Object.freeze({
  [STATUS.RINGING]:  'call.ringing',
  [STATUS.ACCEPTED]: 'call.accepted',
  [STATUS.DECLINED]: 'call.declined',
  [STATUS.MISSED]:   'call.missed',
  [STATUS.ENDED]:    'call.ended',
  [STATUS.FAILED]:   'call.failed',
});

// Compact, JSON-safe call payload — only what the Flutter UI needs
// to render the call_log_bubble + incoming/outgoing screens. The DB
// row stays the source of truth; this snapshot is intentionally
// minimal so we don't leak internals over SSE.
//
// `identities` is an optional map { userId → identity } produced by
// `loadCallParticipantIdentities()`. When present, the payload is
// enriched with `caller` + `callee` objects so the receiver can
// render the real name + photo instead of generic "Plagit Call".
// Identities default to null per-side if the lookup row is missing
// (closed account, partial profile) — the Flutter client falls back
// to initials in that case.
function buildCallPayload(row, identities = null) {
  return {
    callId:         row.id,
    conversationId: row.conversation_id,
    callerId:       row.caller_id,
    calleeId:       row.callee_id,
    type:           row.type,
    status:         row.status,
    createdAt:      row.created_at ? new Date(row.created_at).toISOString() : null,
    acceptedAt:     row.accepted_at ? new Date(row.accepted_at).toISOString() : null,
    endedAt:        row.ended_at ? new Date(row.ended_at).toISOString() : null,
    durationS:      row.duration_s || 0,
    caller:         identities ? (identities[row.caller_id] || null) : null,
    callee:         identities ? (identities[row.callee_id] || null) : null,
  };
}

// Resolve display identity for both call participants in a single
// query. `users.photo_url` is the only canonical photo column; the
// display name is taken from the profile-level table (candidates /
// businesses) so brand names diverging from the legal user.name
// (e.g. "Nobu Restaurant" vs the owner's personal name) render
// correctly. Falls back gracefully if the profile row is missing.
async function loadCallParticipantIdentities(callerUserId, calleeUserId) {
  const ids = [callerUserId, calleeUserId].filter(Boolean);
  if (ids.length === 0) return {};

  const rows = await db('users')
    .leftJoin('candidates', 'candidates.user_id', 'users.id')
    .leftJoin('businesses', 'businesses.user_id', 'users.id')
    .whereIn('users.id', ids)
    .select(
      'users.id as user_id',
      'users.user_type',
      'users.name as user_name',
      'users.initials as user_initials',
      'users.photo_url',
      'users.avatar_hue as user_avatar_hue',
      'candidates.name as candidate_name',
      'candidates.initials as candidate_initials',
      'candidates.avatar_hue as candidate_avatar_hue',
      'businesses.name as business_name',
      'businesses.initials as business_initials',
      'businesses.avatar_hue as business_avatar_hue',
    );

  const out = {};
  for (const r of rows) {
    const isBusiness = r.user_type === 'business';
    const isCandidate = r.user_type === 'candidate';
    const name =
      (isBusiness && r.business_name) ||
      (isCandidate && r.candidate_name) ||
      r.user_name ||
      null;
    const initials =
      (isBusiness && r.business_initials) ||
      (isCandidate && r.candidate_initials) ||
      r.user_initials ||
      null;
    const avatarHue =
      (isBusiness && r.business_avatar_hue) ??
      (isCandidate && r.candidate_avatar_hue) ??
      r.user_avatar_hue ??
      null;

    out[r.user_id] = {
      id: r.user_id,
      role: r.user_type || null,
      name,
      initials,
      photoUrl: r.photo_url || null,
      avatarHue,
    };
  }
  return out;
}

// Best-effort enrichment helper — wraps a raw `calls` row in the
// same camelCase, identity-enriched payload shape the SSE channel
// publishes. Used by the REST handlers so the optimistic Flutter
// state (set from the POST response before the SSE echo lands)
// already carries the counterpart identity. Without this, the
// in-call / outgoing screens flash "Plagit Call" until the SSE
// arrives ~100-300ms later.
async function publicCallSnapshot(row) {
  let identities = null;
  try {
    identities = await loadCallParticipantIdentities(row.caller_id, row.callee_id);
  } catch (_) {
    // Identity enrichment is best-effort; fall back to the un-enriched
    // payload rather than failing the whole REST call.
  }
  return buildCallPayload(row, identities);
}

// ── Step 3A — missed call → chat message ────────────────────────────
//
// Persists a single `messages` row whenever a ringing call terminates
// without being answered (caller cancels: `ringing → missed`). The
// row carries `attachment_type='call_log'` + a JSONB metadata blob
// the Flutter side renders as a centred call-log card (see Step 3A.4
// — `CallLogBubble`).
//
// Step 3A scope (intentional limits, expanded in 3B):
//   • Triggered ONLY for `missed`. Declined / ended / failed do NOT
//     write a row. (Per product decision α 2026-05-18.)
//   • Does NOT update `conversations.last_message` — Messages list
//     preview keeps the previous message until 3B.
//   • Does NOT emit `message.new` SSE — chat views pull fresh state
//     via REST on re-open / SSE `ready`; no badge bump in 3A.
//   • Idempotent on `callId`: SSE replay / hot reload / backend
//     restart never double-insert.
//   • Gated by `isCallLogColumnPresent()` so a pre-migration backend
//     skips silently (zero downtime during deploy → migrate window).
//
// Helper is exported via `_internal` for unit testing; the call site
// from `publishCallEvent` lands in 3A.2 (not wired yet in this step).
async function maybeInsertCallLogMessage(row) {
  // Gate: only insert for the 'missed' status. Declined / ended /
  // failed return without touching the DB so this helper is safe to
  // call from any terminal-state branch.
  if (row.status !== STATUS.MISSED) return null;

  // Gate: schema readiness. Skip cleanly when the column doesn't
  // exist yet (the cache TTL re-probes every 30s, so the runtime
  // self-heals once `knex migrate:latest` finishes).
  if (!await isCallLogColumnPresent()) return null;

  const callId = row.id;
  const callType = row.type;   // 'audio' | 'video'
  const callStatus = row.status; // 'missed'

  // Idempotency guard — one chat row per callId. The check uses the
  // JSONB `->>` text extract operator with a parameter so old rows
  // (with a different callId) and stray inserts can never collide.
  const existing = await db('messages')
    .where({
      conversation_id: row.conversation_id,
      attachment_type: 'call_log',
    })
    .whereRaw("call_log_metadata->>'callId' = ?", [callId])
    .first();
  if (existing) return existing;

  const metadata = {
    callId,
    callType,
    callStatus,
    callerId: row.caller_id,
    calleeId: row.callee_id,
    conversationId: row.conversation_id,
    createdAt: row.created_at
      ? new Date(row.created_at).toISOString()
      : null,
    endedAt: row.ended_at
      ? new Date(row.ended_at).toISOString()
      : null,
  };

  const [inserted] = await db('messages')
    .insert({
      conversation_id: row.conversation_id,
      sender_id: row.caller_id, // caller is the "author" of the missed call
      body: '',                  // call_log rows carry no body text
      attachment_type: 'call_log',
      call_log_metadata: metadata,
    })
    .returning('*');

  return inserted;
}

// Publish the call's CURRENT status to both participants. Audience
// is computed from the row itself so we never accidentally include
// a third party — this is the privacy boundary for the call event.
//
// Enriches the payload with caller + callee identities via a single
// users+candidates+businesses join. Identity lookup failures are
// non-fatal: the SSE event still publishes with caller/callee=null
// and the Flutter UI falls back to initials from the userId.
async function publishCallEvent(row) {
  const eventType = EVENT_TYPE_BY_STATUS[row.status];
  if (!eventType) return null; // unknown status — defensive no-op
  const audience = [
    `user:${row.caller_id}`,
    `user:${row.callee_id}`,
  ];
  let identities = null;
  try {
    identities = await loadCallParticipantIdentities(row.caller_id, row.callee_id);
  } catch (_) {
    // Swallow: identity enrichment is best-effort. The call lifecycle
    // event MUST still ship even if the identity join fails.
  }
  // Step 3A.2 — persist a call-log chat row when the transition is
  // `ringing → missed` (caller cancelled before pickup). The helper
  // self-filters on status, so declined / ended / failed pass through
  // as no-ops. Wrapped in try/catch so a DB hiccup never blocks the
  // SSE publish below — the publish is the user-visible signal.
  try {
    await maybeInsertCallLogMessage(row);
  } catch (e) {
    // eslint-disable-next-line no-console
    console.warn('[callController] maybeInsertCallLogMessage failed:', e.message);
  }
  return bus.publish(eventType, { call: buildCallPayload(row, identities) }, audience);
}

// ── Participant resolver ───────────────────────────────────────────
//
// Resolves the two user IDs on either side of a conversation. We
// hop through candidates / businesses because `conversations` stores
// the profile id, not the user id. Returns { candidateUserId,
// businessUserId, conversation }. Throws 404 if the conversation
// doesn't exist OR the caller isn't a participant — same opacity
// rule as sendMessage.
async function resolveConversationParticipants(conversationId, requestingUserId) {
  const row = await db('conversations')
    .leftJoin('candidates', 'candidates.id', 'conversations.candidate_id')
    .leftJoin('businesses', 'businesses.id', 'conversations.business_id')
    .where('conversations.id', conversationId)
    .select(
      'conversations.id as conv_id',
      'conversations.candidate_id',
      'conversations.business_id',
      'candidates.user_id as candidate_user_id',
      'businesses.user_id as business_user_id',
    )
    .first();

  if (!row) {
    throw AppError.notFound('Conversation not found.');
  }

  const isParticipant =
    row.candidate_user_id === requestingUserId ||
    row.business_user_id === requestingUserId;

  if (!isParticipant) {
    // 404, not 403: keep the conversation's existence opaque.
    throw AppError.notFound('Conversation not found.');
  }

  return {
    conversationId: row.conv_id,
    candidateUserId: row.candidate_user_id,
    businessUserId: row.business_user_id,
  };
}

function otherParticipantUserId(participants, selfUserId) {
  return participants.candidateUserId === selfUserId
    ? participants.businessUserId
    : participants.candidateUserId;
}

async function loadCallOrThrow(callId) {
  const call = await db('calls').where({ id: callId }).first();
  if (!call) throw AppError.notFound('Call not found.');
  return call;
}

function assertIsParticipantOfCall(call, userId) {
  if (call.caller_id !== userId && call.callee_id !== userId) {
    // 404 keeps the call's existence opaque to non-participants.
    throw AppError.notFound('Call not found.');
  }
}

// ── POST /v1/calls/initiate ────────────────────────────────────────
//
// Body: { conversation_id, type? }  // type: 'audio' (default) | 'video'
// Auth: any participant of the conversation.
//
// Creates a new row in `calls` with status='ringing'. Rejects if
// there's already a non-terminal call in the same conversation — we
// don't want two simultaneous ringings polluting the chat history
// or the (future) SSE channel.
async function initiate(req, res, next) {
  try {
    const userId = req.user.id;
    const { conversation_id: conversationId, type } = req.body || {};

    if (!conversationId) {
      throw AppError.badRequest('conversation_id is required.', 'CALL_MISSING_CONV');
    }
    const callType = type || 'audio';
    if (callType !== 'audio' && callType !== 'video') {
      throw AppError.badRequest(
        "type must be 'audio' or 'video'.",
        'CALL_INVALID_TYPE',
      );
    }

    const participants = await resolveConversationParticipants(conversationId, userId);
    const calleeUserId = otherParticipantUserId(participants, userId);
    if (!calleeUserId) {
      // Other side of the convo is null (closed account, partial
      // data). Refuse instead of inserting a half-formed row.
      throw AppError.conflict(
        'The other participant is not available for calls.',
        'CALL_CALLEE_UNAVAILABLE',
      );
    }

    // Block concurrent ringings / accepted calls in the same
    // conversation. The Flutter UI should already prevent this, but
    // we defend at the API in case of double-tap on a slow network.
    const liveCall = await db('calls')
      .where({ conversation_id: conversationId })
      .whereIn('status', [STATUS.RINGING, STATUS.ACCEPTED])
      .first();
    if (liveCall) {
      throw AppError.conflict(
        'A call is already in progress in this conversation.',
        'CALL_ALREADY_LIVE',
      );
    }

    const [row] = await db('calls')
      .insert({
        conversation_id: conversationId,
        caller_id: userId,
        callee_id: calleeUserId,
        type: callType,
        status: STATUS.RINGING,
        // started_at, created_at, updated_at all default at the DB.
      })
      .returning('*');

    // SSE fan-out to both participants. `call.ringing` is the trigger
    // the Flutter side uses to push the incoming-call screen.
    await publishCallEvent(row);

    return created(res, { call: await publicCallSnapshot(row) });
  } catch (err) { next(err); }
}

// ── POST /v1/calls/:id/accept ──────────────────────────────────────
//
// Only the callee can accept. Transitions ringing → accepted and
// stamps accepted_at. Idempotent if already accepted (returns the
// current row with 200, no state change).
async function accept(req, res, next) {
  try {
    const userId = req.user.id;
    const call = await loadCallOrThrow(req.params.id);
    assertIsParticipantOfCall(call, userId);

    if (call.callee_id !== userId) {
      throw AppError.forbidden(
        'Only the callee can accept the call.',
        'CALL_NOT_CALLEE',
      );
    }

    if (call.status === STATUS.ACCEPTED) {
      // Idempotent re-accept: no state change, no event. The client
      // already received the original call.accepted; re-publishing
      // would cause double-handling on flaky retries.
      return ok(res, { call: await publicCallSnapshot(call) });
    }
    assertTransition(call.status, STATUS.ACCEPTED);

    const [updated] = await db('calls')
      .where({ id: call.id })
      .update({
        status: STATUS.ACCEPTED,
        accepted_at: db.fn.now(),
        updated_at: db.fn.now(),
      })
      .returning('*');

    await publishCallEvent(updated);

    return ok(res, { call: await publicCallSnapshot(updated) });
  } catch (err) { next(err); }
}

// ── POST /v1/calls/:id/decline ─────────────────────────────────────
//
// Only the callee can decline. Transitions ringing → declined (or
// returns the current row idempotently if already declined).
async function decline(req, res, next) {
  try {
    const userId = req.user.id;
    const call = await loadCallOrThrow(req.params.id);
    assertIsParticipantOfCall(call, userId);

    if (call.callee_id !== userId) {
      throw AppError.forbidden(
        'Only the callee can decline the call.',
        'CALL_NOT_CALLEE',
      );
    }

    if (call.status === STATUS.DECLINED) {
      // Idempotent re-decline — see accept handler for rationale.
      return ok(res, { call: await publicCallSnapshot(call) });
    }
    assertTransition(call.status, STATUS.DECLINED);

    const [updated] = await db('calls')
      .where({ id: call.id })
      .update({
        status: STATUS.DECLINED,
        ended_at: db.fn.now(),
        updated_at: db.fn.now(),
      })
      .returning('*');

    await publishCallEvent(updated);

    return ok(res, { call: await publicCallSnapshot(updated) });
  } catch (err) { next(err); }
}

// ── POST /v1/calls/:id/end ─────────────────────────────────────────
//
// Either participant can end. Behaviour depends on current state:
//   • ringing → missed  (caller cancelled before pickup)
//   • accepted → ended  (computes duration_s)
//   • already terminal → no-op, returns the row (idempotent — safe
//     to re-call from a flaky Flutter client)
//
// Optional body: { reason: 'failed' }  // explicit technical failure;
// transitions to `failed` instead of ended/missed. Restricted to
// reason='failed' for now — anything else is rejected to keep the
// API surface tight.
async function end(req, res, next) {
  try {
    const userId = req.user.id;
    const call = await loadCallOrThrow(req.params.id);
    assertIsParticipantOfCall(call, userId);

    // Idempotent end on terminal states — return the row as-is.
    if (TERMINAL_STATES.has(call.status)) {
      return ok(res, { call: await publicCallSnapshot(call) });
    }

    const reason = (req.body && req.body.reason) || null;
    if (reason && reason !== 'failed') {
      throw AppError.badRequest(
        "reason, if provided, must be 'failed'.",
        'CALL_INVALID_END_REASON',
      );
    }

    let nextStatus;
    if (reason === 'failed') {
      nextStatus = STATUS.FAILED;
    } else if (call.status === STATUS.RINGING) {
      nextStatus = STATUS.MISSED;
    } else {
      nextStatus = STATUS.ENDED;
    }
    assertTransition(call.status, nextStatus);

    // Compute duration only when transitioning from accepted →
    // ended/failed. Missed calls stay at duration_s=0.
    let durationSeconds = call.duration_s;
    if (call.status === STATUS.ACCEPTED && call.accepted_at) {
      durationSeconds = Math.max(
        0,
        Math.round((Date.now() - new Date(call.accepted_at).getTime()) / 1000),
      );
    }

    const [updated] = await db('calls')
      .where({ id: call.id })
      .update({
        status: nextStatus,
        ended_at: db.fn.now(),
        duration_s: durationSeconds,
        updated_at: db.fn.now(),
      })
      .returning('*');

    // One of call.missed / call.ended / call.failed, depending on
    // the transition we just executed.
    await publishCallEvent(updated);

    return ok(res, { call: await publicCallSnapshot(updated) });
  } catch (err) { next(err); }
}

module.exports = {
  initiate,
  accept,
  decline,
  end,
  // Exported for tests:
  _internal: {
    STATUS,
    TERMINAL_STATES,
    ALLOWED_TRANSITIONS,
    assertTransition,
    maybeInsertCallLogMessage,
  },
};
