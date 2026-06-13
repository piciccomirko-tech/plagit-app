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
// Stage N1-3 — reuse the shared notify helper (persist + `notification.new`
// SSE + (recipient_id, linked_entity, destination_route) dedupe) for the
// missed-call bell notification. No import cycle: businessController does
// not require callController. Same precedent as candidate/chatRequests.
const { hiringNotify } = require('./businessController');
// Step D — VoIP push sender (SKELETON, flag-gated OFF). Wakes the callee's iOS
// device via PushKit so CallKit can ring cold-start. No-op in production until
// VOIP_PUSH_ENABLED is armed AND the real .p8 sender is wired — see the module.
const voipPush = require('../services/push/apnsVoipSender');
const presence = require('../services/realtime/presence');

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
  // Gate: insert for `missed` (caller cancelled pre-pickup) AND
  // `ended` (call was answered and then hung up). Other terminal
  // states stay no-op:
  //   • `declined` → product decision α 2026-05-18: no callee bubble
  //   • `failed`   → technical error, surfaced via SSE only
  // Ringing/accepted are non-terminal and never reach this branch
  // (publishCallEvent only fires on terminal status transitions).
  const isMissed = row.status === STATUS.MISSED;
  const isAnswered = row.status === STATUS.ENDED;
  if (!isMissed && !isAnswered) return null;

  // Gate: schema readiness. Skip cleanly when the column doesn't
  // exist yet (the cache TTL re-probes every 30s, so the runtime
  // self-heals once `knex migrate:latest` finishes).
  if (!await isCallLogColumnPresent()) return null;

  const callId = row.id;
  const callType = row.type;   // 'audio' | 'video'
  const callStatus = row.status; // 'missed' | 'ended'

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

  // Real elapsed time the call lasted while accepted. The state
  // machine computes `duration_s` only on the `accepted → ended`
  // transition (see `end()` below); missed rows always carry 0.
  // We ship it through the JSONB blob so the Flutter `CallLogBubble`
  // can render "8 sec" / "1 min 05 sec" on answered rows without
  // touching the row's other columns.
  const durationS = Number.isFinite(row.duration_s) ? row.duration_s : 0;

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
    durationS,
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

  // Step 3B.1 — keep the Messages list preview in sync. We write a
  // CALLER-perspective string (`📞 Voice call` / `📹 Video call`);
  // the Flutter side overrides it to "Missed voice/video call" on
  // the callee row by inspecting `last_message_sender_id` exposed in
  // listConversations. Same emoji-prefix convention the rest of the
  // app uses (`🎤 Voice message`, `🖼 Photo`, etc.) so the existing
  // `LastMessagePreview` widget can map 📞/📹 to the right glyph.
  //
  // Bumping `updated_at` puts the conversation at the top of the
  // inbox just like any other new message — without it, the missed
  // call would be invisible until the next regular message bumps it.
  const previewText = callType === 'video' ? '📹 Video call' : '📞 Voice call';
  try {
    await db('conversations')
      .where({ id: row.conversation_id })
      .update({
        last_message: previewText,
        updated_at: db.fn.now(),
      });
  } catch (e) {
    // Non-fatal: the chat-side bubble already rendered correctly
    // because the message row was inserted above. Preview lag is a
    // soft degradation, not a hard failure.
    // eslint-disable-next-line no-console
    console.warn('[callController] conv preview update failed:', e.message);
  }

  // Step 4 — emit `message.new` so the existing chat/messages
  // SSE plumbing kicks the Messages-tab + Home-Messages badges
  // automatically. Same audience pattern as sendMessage so the
  // Flutter `MessagesProvider` handlers in candidate_providers.dart
  // (line 364) and business_providers.dart (line 369) reload the
  // inbox without any code change. The bell channel
  // (`notification.new`) is intentionally NOT touched — call_log
  // is a chat event, not a system notification.
  //
  // Idempotency: this point is reached ONLY after a fresh INSERT
  // (the earlier `if (existing) return existing` guard short-circuits
  // duplicates), so SSE replay / hot reload / backend restart never
  // produces a double-fire badge bump.
  try {
    bus.publish(
      'message.new',
      {
        message: {
          id: inserted.id,
          conversation_id: row.conversation_id,
          body: '',
          attachment_type: 'call_log',
          sender_id: row.caller_id,
          is_read: false,
          created_at: inserted.created_at,
          call_log_metadata: metadata,
        },
        conversation_id: row.conversation_id,
        sender_user_id: row.caller_id,
        recipient_user_id: row.callee_id,
      },
      [
        'role:admin',
        `user:${row.caller_id}`,
        `user:${row.callee_id}`,
      ],
    );
  } catch (e) {
    // Same soft-fail rationale as the conv update: the row exists,
    // the chat refresh on next pull-to-refresh / app re-open will
    // surface it anyway. We never want to abort the call lifecycle
    // because of a bus hiccup.
    // eslint-disable-next-line no-console
    console.warn('[callController] message.new emit failed:', e.message);
  }

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
// Stage N1-3 — persist a missed-call BELL notification. Self-filters on
// `missed` so declined / ended / failed pass through as no-ops (mirrors
// maybeInsertCallLogMessage's gate, but for the bell surface instead of
// the chat-log bubble). On `ringing → missed` the CALLEE is the party who
// missed the call, so they are the recipient. hiringNotify provides
// persist + `notification.new` SSE + the (recipient_id, linked_entity,
// destination_route) dedupe, so a retried/replayed terminal transition
// never doubles the row. route 'call_missed' is NOT in the bell-excluded
// set, so it surfaces on the bell + unread count (unlike the chat-stream
// 'message' call-log row). linked_entity = call id (per-call dedupe).
async function maybeNotifyMissedCall(row, identities) {
  if (row.status !== STATUS.MISSED) return;
  const callerName = (identities
    && identities[row.caller_id]
    && identities[row.caller_id].name) || 'Someone';
  const kind = row.type === 'video' ? 'video' : 'voice';
  await hiringNotify(
    row.callee_id,
    'Missed call',
    'in_app',
    row.id,
    'call_missed',
    `Missed ${kind} call from ${callerName}`,
  );
}

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
  // Stage N1-3 — bell notification for missed calls (self-filtering).
  // Best-effort: a notify hiccup must never block the SSE publish below,
  // which is still the primary realtime signal.
  try {
    await maybeNotifyMissedCall(row, identities);
  } catch (e) {
    // eslint-disable-next-line no-console
    console.warn('[callController] maybeNotifyMissedCall failed:', e.message);
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

    // Step D — best-effort VoIP ring to the callee (PushKit/CallKit cold-start).
    // Strictly non-fatal: a VoIP push must NEVER break call initiation (SSE
    // already fired above), so it is fire-and-forget and swallows its errors.
    //
    // Foreground suppression: when the callee's app is FOREGROUND it already
    // shows the in-app IncomingCallView from the `call.ringing` SSE above, so
    // a CallKit banner on top would be double UI. Skip the push in that case.
    // `isForeground` is false for background / locked / terminated / unknown /
    // stale state → the push IS sent → CallKit rings (background never broken).
    // Skip the VoIP push ONLY when the callee is truly foreground AND online.
    // A force-killed app cannot report `foreground:false` (its async POST is
    // torn down with the process), so its foreground flag lingers up to the
    // 15s TTL → a quick follow-up call would be wrongly suppressed. The killed
    // app DOES drop its SSE socket (→ isOnline=false within ~1-2s), so adding
    // the online conjunction means killed/background always rings.
    if (presence.isForeground(calleeUserId) && presence.isOnline(calleeUserId)) {
      // eslint-disable-next-line no-console
      console.log(`[voip:gate] callee foreground — VoIP push skipped (in-app UI), call=${row.id}`);
    } else {
      voipPush
        .sendRingToUser(calleeUserId, {
          callId: row.id,
          callType,
          callerId: userId,
        })
        .catch(() => { /* non-fatal: the sender logs its own failures */ });
    }

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

    // BUG1 — caller cancelled before pickup: a still-RINGING callee may be
    // killed (no SSE), so the SSE `call.missed` above never reaches it and the
    // CallKit ring lingers until a manual swipe. Push a VoIP "end" so the
    // device dismisses CallKit on its own → missed, no swipe. Only when the
    // CALLER cancels a still-RINGING call (callee-side decline already dismisses
    // its own CallKit, and accepted-end is delivered over the live SSE).
    if (call.status === STATUS.RINGING && userId === call.caller_id) {
      voipPush
        .sendEndToUser(call.callee_id, { callId: call.id })
        .catch(() => { /* non-fatal: the sender logs its own failures */ });
    }

    return ok(res, { call: await publicCallSnapshot(updated) });
  } catch (err) { next(err); }
}

// ── GET /v1/calls/active ───────────────────────────────────────────
//
// Returns the single non-terminal (ringing) call for the requesting
// user where they are either caller or callee, created in the last
// 90 seconds. Used by the Flutter side on cold-start (CallKit VoIP
// push wakes the app → app fetches call state to hydrate CallProvider
// before SSE reconnects). Returns 404 when there is no active call.
//
// 90s freshness window: aligned with the ring-sweep cron (which flips
// calls older than 60s to missed) plus a 30s grace for slow networks.
// Stale ringing rows beyond 90s are silently ignored here — the sweep
// will clean them up within the next minute.
async function getActive(req, res, next) {
  try {
    const userId = req.user.id;
    const call = await db('calls')
      .where(function () {
        this.where('caller_id', userId).orWhere('callee_id', userId);
      })
      .where('status', STATUS.RINGING)
      .whereRaw("started_at > NOW() - INTERVAL '90 seconds'")
      .orderBy('started_at', 'desc')
      .first();

    if (!call) {
      throw AppError.notFound('No active call.', 'CALL_NONE_ACTIVE');
    }
    return ok(res, { call: await publicCallSnapshot(call) });
  } catch (err) { next(err); }
}

// ── GET /v1/calls/:id/recovery ─────────────────────────────────────
//
// Cold-start recovery for a callee that answered a CallKit call while the
// app was terminated/locked and therefore had NO SSE connection to receive
// the offer / ICE / terminal events. Returns the persisted call snapshot
// plus any pending offer + the counterpart's ICE so the cold-started engine
// can negotiate over REST instead of waiting for an SSE that never arrives.
// Participant-only, read-only.
async function recovery(req, res, next) {
  try {
    const userId = req.user.id;
    const call = await db('calls').where({ id: req.params.id }).first();
    if (!call) throw AppError.notFound('Call not found.', 'CALL_NOT_FOUND');
    if (call.caller_id !== userId && call.callee_id !== userId) {
      throw AppError.forbidden('Not a participant of this call.', 'CALL_NOT_PARTICIPANT');
    }

    const isTerminal = TERMINAL_STATES.has(call.status);

    // Persisted offer (caller's) + the counterpart's ICE the recovering side
    // missed while it had no SSE. `andWhereNot` keeps only the OTHER party's
    // candidates — the recovering side doesn't need its own echoed back.
    const offerRow = isTerminal
      ? null
      : await db('call_signals').where({ call_id: call.id, kind: 'offer' }).first();
    const iceRows = isTerminal
      ? []
      : await db('call_signals')
        .where({ call_id: call.id, kind: 'ice' })
        .andWhereNot({ sender_user_id: userId })
        .orderBy('created_at', 'asc');

    return ok(res, {
      recovery: {
        call: await publicCallSnapshot(call),
        terminal: isTerminal,
        offer: offerRow
          ? {
            sdp: offerRow.payload.sdp,
            sdpType: offerRow.payload.sdpType,
            fromUserId: offerRow.sender_user_id,
          }
          : null,
        pendingIce: iceRows.map((r) => ({
          fromUserId: r.sender_user_id,
          candidates: (r.payload && r.payload.candidates) || [],
        })),
      },
    });
  } catch (err) { next(err); }
}

module.exports = {
  initiate,
  accept,
  decline,
  end,
  getActive,
  recovery,
  // Exported for the ring-sweep cron (publishes SSE + bell notifications
  // on the ringing→missed transition it triggers server-side):
  publishCallEvent,
  // Exported for tests:
  _internal: {
    STATUS,
    TERMINAL_STATES,
    ALLOWED_TRANSITIONS,
    assertTransition,
    maybeInsertCallLogMessage,
    maybeNotifyMissedCall,
  },
};
