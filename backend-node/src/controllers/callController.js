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

    return created(res, { call: row });
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
      return ok(res, { call });
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

    return ok(res, { call: updated });
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
      return ok(res, { call });
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

    return ok(res, { call: updated });
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
      return ok(res, { call });
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

    return ok(res, { call: updated });
  } catch (err) { next(err); }
}

module.exports = {
  initiate,
  accept,
  decline,
  end,
  // Exported for tests:
  _internal: { STATUS, TERMINAL_STATES, ALLOWED_TRANSITIONS, assertTransition },
};
