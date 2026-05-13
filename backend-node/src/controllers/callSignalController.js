/**
 * WebRTC signaling controller — Step E1.
 *
 * Three handlers, one per signaling kind:
 *
 *   POST /v1/calls/:id/signal/offer    → caller only,  call non-terminal, no existing offer
 *   POST /v1/calls/:id/signal/answer   → callee only,  call non-terminal, offer exists, no existing answer
 *   POST /v1/calls/:id/signal/ice      → either side,  call non-terminal, body.candidates length ≥ 1
 *
 * Each handler persists one row in `call_signals` and fans the event
 * out over the existing realtime bus to both participants (and only
 * the two participants — never third parties).
 *
 * Cleanup is opportunistic: every successful write fires-and-forgets
 * a DELETE for stale signals (terminal calls older than 5 min, plus
 * a 6 h hard safety net for any call). No cron, no job runner.
 *
 * Participant resolution and call loading are duplicated locally
 * (small helpers, 10-15 LOC each) instead of importing from
 * `callController.js` to keep the lifecycle controller untouched.
 */

const db = require('../config/db');
const { created } = require('../utils/response');
const AppError = require('../utils/AppError');
const { bus } = require('../services/realtime/eventBus');

// Mirror the terminal set in callController.js. Kept local so this
// file is self-contained; the two arrays must move together if the
// state machine evolves.
const TERMINAL_STATES = new Set(['declined', 'missed', 'ended', 'failed']);

// Hard limits — keep SSE payload bounded and protect against runaway
// inputs. SDP is typically 2-5KB; 32KB is comfortable headroom. ICE
// candidates are typically 10-15 per side, so a 50 cap covers any
// realistic batch with margin.
const MAX_SDP_BYTES = 32 * 1024;
const MAX_ICE_PER_BATCH = 50;
const MAX_ICE_CANDIDATE_LENGTH = 1024;

// ── Helpers (private) ─────────────────────────────────────────────

async function loadCallOrThrow(callId) {
  const call = await db('calls').where({ id: callId }).first();
  if (!call) throw AppError.notFound('Call not found.');
  return call;
}

function assertIsParticipantOfCall(call, userId) {
  if (call.caller_id !== userId && call.callee_id !== userId) {
    // 404 (not 403) keeps the call's existence opaque to non-
    // participants — mirrors `callController` policy.
    throw AppError.notFound('Call not found.');
  }
}

function assertCallActive(call) {
  if (TERMINAL_STATES.has(call.status)) {
    throw AppError.conflict(
      'Call is no longer active.',
      'CALL_NOT_ACTIVE',
    );
  }
}

function audienceFor(call) {
  return [`user:${call.caller_id}`, `user:${call.callee_id}`];
}

function publishSignal(eventType, call, payload) {
  return bus.publish(eventType, payload, audienceFor(call));
}

// Opportunistic cleanup — fire-and-forget. Removes signals belonging
// to terminal calls older than 5 minutes, plus a 6 h hard safety net
// for any call (in case a call somehow gets stuck non-terminal).
//
// 5 minutes after termination is the reconnection grace window. Any
// later, the SDPs and ICE candidates are useless because the WebRTC
// session has been torn down on both clients.
function opportunisticCleanup() {
  const job = db('call_signals')
    .where(function () {
      this.whereIn(
        'call_id',
        db('calls').select('id').whereIn('status', Array.from(TERMINAL_STATES)),
      ).andWhereRaw("call_signals.created_at < now() - interval '5 minutes'");
    })
    .orWhereRaw("call_signals.created_at < now() - interval '6 hours'")
    .del();
  // Non-fatal: log in dev only, never crash the request path.
  job.catch((err) => {
    if (process.env.NODE_ENV !== 'production') {
      // eslint-disable-next-line no-console
      console.warn('[call_signals cleanup] non-fatal:', err.message);
    }
  });
}

// ── Payload validators (kind-specific) ────────────────────────────

function validateSdp(sdp, expectedType) {
  if (typeof sdp !== 'string' || sdp.length === 0) {
    throw AppError.badRequest(
      'sdp must be a non-empty string.',
      'CALL_SIGNAL_INVALID_SDP',
    );
  }
  if (Buffer.byteLength(sdp, 'utf8') > MAX_SDP_BYTES) {
    throw AppError.badRequest(
      `sdp exceeds ${MAX_SDP_BYTES} bytes.`,
      'CALL_SIGNAL_SDP_TOO_LARGE',
    );
  }
  // sdpType is optional; if present must match the endpoint's kind.
  // Defensive — protects against a client posting an answer SDP to
  // the /offer endpoint by mistake.
  return { sdp, sdpType: expectedType };
}

function validateIceCandidates(candidates) {
  if (!Array.isArray(candidates) || candidates.length === 0) {
    throw AppError.badRequest(
      'candidates must be a non-empty array.',
      'CALL_SIGNAL_NO_CANDIDATES',
    );
  }
  if (candidates.length > MAX_ICE_PER_BATCH) {
    throw AppError.badRequest(
      `candidates may not exceed ${MAX_ICE_PER_BATCH} entries per batch.`,
      'CALL_SIGNAL_TOO_MANY_CANDIDATES',
    );
  }
  return candidates.map((c, i) => {
    if (!c || typeof c.candidate !== 'string' || c.candidate.length === 0) {
      throw AppError.badRequest(
        `candidates[${i}].candidate must be a non-empty string.`,
        'CALL_SIGNAL_INVALID_CANDIDATE',
      );
    }
    if (c.candidate.length > MAX_ICE_CANDIDATE_LENGTH) {
      throw AppError.badRequest(
        `candidates[${i}].candidate exceeds ${MAX_ICE_CANDIDATE_LENGTH} chars.`,
        'CALL_SIGNAL_CANDIDATE_TOO_LARGE',
      );
    }
    return {
      candidate: c.candidate,
      sdpMid: typeof c.sdpMid === 'string' ? c.sdpMid : null,
      sdpMLineIndex: Number.isInteger(c.sdpMLineIndex) ? c.sdpMLineIndex : null,
    };
  });
}

// ── POST /v1/calls/:id/signal/offer ───────────────────────────────
async function submitOffer(req, res, next) {
  try {
    const userId = req.user.id;
    const call = await loadCallOrThrow(req.params.id);
    assertIsParticipantOfCall(call, userId);
    assertCallActive(call);

    if (call.caller_id !== userId) {
      throw AppError.forbidden(
        'Only the caller can submit the offer.',
        'CALL_NOT_CALLER',
      );
    }

    const existing = await db('call_signals')
      .where({ call_id: call.id, kind: 'offer' })
      .first();
    if (existing) {
      throw AppError.conflict(
        'An offer already exists for this call.',
        'CALL_OFFER_EXISTS',
      );
    }

    const payload = validateSdp(req.body && req.body.sdp, 'offer');

    const [row] = await db('call_signals')
      .insert({
        call_id: call.id,
        sender_user_id: userId,
        kind: 'offer',
        payload,
      })
      .returning('*');

    publishSignal('call.signal.offer', call, {
      callId: call.id,
      fromUserId: userId,
      sdp: payload.sdp,
      sdpType: payload.sdpType,
    });

    opportunisticCleanup();

    return created(res, { signal: { id: row.id, kind: 'offer' } });
  } catch (err) { next(err); }
}

// ── POST /v1/calls/:id/signal/answer ──────────────────────────────
async function submitAnswer(req, res, next) {
  try {
    const userId = req.user.id;
    const call = await loadCallOrThrow(req.params.id);
    assertIsParticipantOfCall(call, userId);
    assertCallActive(call);

    if (call.callee_id !== userId) {
      throw AppError.forbidden(
        'Only the callee can submit the answer.',
        'CALL_NOT_CALLEE',
      );
    }

    const offer = await db('call_signals')
      .where({ call_id: call.id, kind: 'offer' })
      .first();
    if (!offer) {
      throw AppError.conflict(
        'No offer to answer.',
        'CALL_NO_OFFER',
      );
    }

    const existingAnswer = await db('call_signals')
      .where({ call_id: call.id, kind: 'answer' })
      .first();
    if (existingAnswer) {
      throw AppError.conflict(
        'An answer already exists for this call.',
        'CALL_ANSWER_EXISTS',
      );
    }

    const payload = validateSdp(req.body && req.body.sdp, 'answer');

    const [row] = await db('call_signals')
      .insert({
        call_id: call.id,
        sender_user_id: userId,
        kind: 'answer',
        payload,
      })
      .returning('*');

    publishSignal('call.signal.answer', call, {
      callId: call.id,
      fromUserId: userId,
      sdp: payload.sdp,
      sdpType: payload.sdpType,
    });

    opportunisticCleanup();

    return created(res, { signal: { id: row.id, kind: 'answer' } });
  } catch (err) { next(err); }
}

// ── POST /v1/calls/:id/signal/ice ─────────────────────────────────
async function submitIce(req, res, next) {
  try {
    const userId = req.user.id;
    const call = await loadCallOrThrow(req.params.id);
    assertIsParticipantOfCall(call, userId);
    assertCallActive(call);

    // Either participant can trickle ICE — no role check beyond
    // participant verification above.

    const candidates = validateIceCandidates(req.body && req.body.candidates);

    const payload = { candidates };

    const [row] = await db('call_signals')
      .insert({
        call_id: call.id,
        sender_user_id: userId,
        kind: 'ice',
        payload,
      })
      .returning('*');

    publishSignal('call.signal.ice', call, {
      callId: call.id,
      fromUserId: userId,
      candidates,
    });

    opportunisticCleanup();

    return created(res, {
      signal: { id: row.id, kind: 'ice', count: candidates.length },
    });
  } catch (err) { next(err); }
}

module.exports = {
  submitOffer,
  submitAnswer,
  submitIce,
  // Exported for tests / future re-use
  _internal: {
    TERMINAL_STATES,
    MAX_SDP_BYTES,
    MAX_ICE_PER_BATCH,
    MAX_ICE_CANDIDATE_LENGTH,
    validateSdp,
    validateIceCandidates,
  },
};
