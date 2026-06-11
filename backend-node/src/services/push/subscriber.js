const { bus } = require('../realtime/eventBus');
const { sendToUser } = require('./pushSender');
const db = require('../../config/db');

/**
 * Bus → push subscriber.
 *
 * Listens to the same realtime bus that drives SSE and, for the
 * notification-worthy event types, fans out a push to every device
 * registered to the target user.
 *
 * Events that DO trigger pushes:
 *   • message.new                 (new chat message)
 *   • notification.new            (generic in-app notification)
 *   • interview.scheduled         (new interview on candidate's calendar)
 *   • interview.status_changed    (counterpart changed state)
 *   • application.status_changed  (recruiter moved the candidate)
 *   • conversation.member_added   (Phase 2 — user added to a group;
 *                                  group action itself is NOT awaited
 *                                  on push delivery, so a push or DB
 *                                  failure here can never break the
 *                                  add-member API path)
 *
 * Events that DO NOT trigger pushes (UX-only, not push-worthy):
 *   • chat.typing
 *   • presence.update
 *   • message.delivered / message.read
 *   • conversation.member_removed / member_left  — covered by inbox
 *     refresh; the removed user's open chat already auto-pops via
 *     the Stage C.2X SSE handler. Push here would just be noise.
 *   • conversation.updated (rename / photo / hue) — low-signal,
 *     same inbox-refresh argument
 *   • conversation.new — fires alongside member_added on group
 *     create, so adding both would double-push the inviter's
 *     recipients. Keep member_added as the canonical group push
 *     trigger.
 *
 * Audience tokens in each event already describe the target users
 * (`user:<id>`), so the subscriber simply extracts them and calls
 * `sendToUser` once per unique recipient. `role:admin` tokens are
 * intentionally skipped — admins use the desktop panel, not push.
 */

const PUSH_TYPES = new Set([
  'message.new',
  'notification.new',
  'interview.scheduled',
  'interview.status_changed',
  'application.status_changed',
  'conversation.member_added',
]);

function uniqueUserIds(audience) {
  if (!Array.isArray(audience)) return [];
  const ids = new Set();
  for (const token of audience) {
    if (typeof token !== 'string') continue;
    if (token.startsWith('user:')) ids.add(token.slice(5));
  }
  return [...ids];
}

// Stage N5.1 — admin-only notification routes NEVER push. These are
// platform-audit feeds fanned to admins (desktop panel, not push). The
// event audience also carries a `user:<adminId>` token, so the
// `role:admin` skip in uniqueUserIds is not enough on its own.
const ADMIN_ONLY_ROUTES = new Set([
  'chat_request_audit_created',
  'chat_request_audit_accepted',
  'urgent_request_created',
]);

// Stage N5.1 — defence-in-depth: never deliver a real push to an admin
// recipient, whatever the route. The client-side opt-out (DeviceService
// skips register for role='admin') is NOT authoritative — a stale admin
// token must still never receive a push. Single grouped query, no
// per-recipient round-trip. Fails OPEN on a DB hiccup (returns the input)
// so a transient error never silently drops legitimate user pushes; the
// ADMIN_ONLY_ROUTES denylist above still blocks the audit feeds anyway.
async function filterOutAdmins(userIds) {
  if (!userIds.length) return userIds;
  try {
    const admins = await db('users')
      .whereIn('id', userIds)
      .where('user_type', 'admin')
      .pluck('id');
    if (!admins.length) return userIds;
    const adminSet = new Set(admins);
    const kept = userIds.filter((id) => !adminSet.has(id));
    // Safe log: count only — no ids / tokens / PII.
    // eslint-disable-next-line no-console
    console.log(`[push:skip-admin] dropped ${userIds.length - kept.length} admin recipient(s)`);
    return kept;
  } catch (_) {
    return userIds;
  }
}

// Resolve the final user ids that should receive a real push for this
// event: PUSH_TYPES gate → admin-only-route denylist → audience user ids →
// drop admins → drop the message sender. Returns [] when nothing should be
// pushed. Extracted so the policy is unit-testable without the bus or the
// FCM sender.
async function resolvePushRecipients(evt) {
  if (!evt || !PUSH_TYPES.has(evt.type)) return [];
  // Call-log chat events (the 📞/📹 bubble inserted when a call is
  // missed/ended) flow through `message.new` but are NOT real chat messages —
  // pushing them shows a misleading "New message". Skip the push here. A
  // dedicated missed-call notification is a separate future step.
  if (
    evt.type === 'message.new'
    && evt.payload && evt.payload.message
    && evt.payload.message.attachment_type === 'call_log'
  ) {
    // eslint-disable-next-line no-console
    console.log('[push:skip-call-log] message.new attachment_type=call_log (no push)');
    return [];
  }
  const route = evt.type === 'notification.new'
    ? (evt.payload && evt.payload.destination_route) : null;
  if (route && ADMIN_ONLY_ROUTES.has(route)) {
    // eslint-disable-next-line no-console
    console.log(`[push:skip-admin-route] route=${route} (admin-only, no push)`);
    return [];
  }
  const targets = uniqueUserIds(evt.audience);
  if (targets.length === 0) return [];
  const senderId = evt.type === 'message.new'
    ? (evt.payload && evt.payload.sender_user_id) : null;
  const nonAdmin = await filterOutAdmins(targets);
  return nonAdmin.filter((uid) => uid !== senderId);
}

// Media messages (voice/photo/video/document) carry an empty `body` —
// the attachment is self-describing in-app, but a push with an empty body
// shows only the sender name on the lock screen. Fall back to a label
// derived from attachment_type so the recipient knows WHAT arrived.
// Pure (no DB) so it is unit-testable; text/captions pass through as-is.
const ATTACHMENT_PUSH_BODY = Object.freeze({
  audio: 'Voice message',
  image: 'Photo',
  video: 'Video',
  document: 'Document',
});

function messagePushBody(message) {
  const body = (message && message.body) || '';
  if (body.trim()) return body;
  const type = message && message.attachment_type;
  return ATTACHMENT_PUSH_BODY[type] || 'New message';
}

async function buildPayload(type, payload) {
  switch (type) {
    case 'message.new': {
      const senderId = payload.sender_user_id;
      let senderName = 'New message';
      if (senderId) {
        try {
          const u = await db('users').where({ id: senderId }).select('name').first();
          if (u && u.name) senderName = u.name;
        } catch (_) { /* ignore */ }
      }
      const body = messagePushBody(payload.message);
      return {
        title: senderName,
        body: body.slice(0, 160),
        data: {
          type,
          conversation_id: payload.conversation_id,
          sender_user_id: senderId,
        },
      };
    }
    case 'notification.new': {
      return {
        title: payload.title || 'Plagit',
        body: payload.body || payload.message || '',
        data: {
          type,
          notification_id: payload.id,
          destination: payload.destination_route,
          linked_entity: payload.linked_entity,
        },
      };
    }
    case 'interview.scheduled': {
      return {
        title: 'Interview scheduled',
        body: payload.job_title
          ? `You have a new interview for ${payload.job_title}.`
          : 'You have a new interview.',
        data: {
          type,
          interview_id: payload.interview_id || payload.id,
        },
      };
    }
    case 'interview.status_changed': {
      return {
        title: 'Interview updated',
        body: payload.status
          ? `Interview status is now ${payload.status}.`
          : 'An interview status has changed.',
        data: {
          type,
          interview_id: payload.interview_id || payload.id,
          status: payload.status,
        },
      };
    }
    case 'application.status_changed': {
      return {
        title: 'Application update',
        body: payload.status
          ? `Your application is now ${payload.status}.`
          : 'Your application status has changed.',
        data: {
          type,
          application_id: payload.application_id || payload.id,
          status: payload.status,
        },
      };
    }
    case 'conversation.member_added': {
      // Phase 2 — group lifecycle push. The same broadcast reaches
      // the newly-added members AND the pre-existing members
      // (audience excludes only the actor), so the push body is
      // intentionally generic enough to read sensibly for both
      // framings ("Marco added you to staff" vs "Marco was added
      // to staff"). On the client side the deep link routes both
      // groups to /group/chat/:id via the Phase 1 catalog entry.
      //
      // Both DB lookups are wrapped in try/catch — a failed name
      // resolution must not block the push delivery (we degrade to
      // a generic title/body) and must NEVER bubble back to the
      // group action that triggered the bus event (the bus.publish
      // call in groupController.addGroupMember is fire-and-forget
      // by design).
      const convId = payload.conversation_id;
      const actorId = payload.actor_user_id;
      let groupName = 'Plagit Groups';
      let actorName = 'Someone';
      if (convId) {
        try {
          const conv = await db('conversations')
            .where({ id: convId })
            .select('name')
            .first();
          if (conv && conv.name) groupName = conv.name;
        } catch (_) { /* ignore — keep default title */ }
      }
      if (actorId) {
        try {
          const u = await db('users')
            .where({ id: actorId })
            .select('name')
            .first();
          if (u && u.name) actorName = u.name;
        } catch (_) { /* ignore — keep default actor */ }
      }
      return {
        title: groupName,
        body: `${actorName} added you to ${groupName}`,
        data: {
          type,
          // Mirror the catalog contract — Phase 1 NotificationType
          // `group` reads `destination_route` + `linked_entity` from
          // the push payload's `data` block to compute the deep
          // link (/group/chat/:id) via _groupDeepLink.
          destination_route: 'group',
          linked_entity: convId,
          conversation_id: convId,
          actor_user_id: actorId,
        },
      };
    }
    default:
      return null;
  }
}

function start() {
  bus.on('event', async (evt) => {
    try {
      // Stage N5.1 — recipient resolution (incl. admin-only-route skip +
      // admin-recipient drop + message-sender suppression) is centralized
      // in resolvePushRecipients so SSE-echo and audit feeds never push.
      const recipients = await resolvePushRecipients(evt);
      if (recipients.length === 0) return;
      const payload = await buildPayload(evt.type, evt.payload || {});
      if (!payload) return;
      await Promise.all(recipients.map((uid) => sendToUser(uid, payload)));
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error('[push:subscriber] failed:', err.message);
    }
  });
  // eslint-disable-next-line no-console
  console.log('[push:subscriber] started');
}

module.exports = {
  start,
  // Exported for tests:
  _internal: {
    resolvePushRecipients, filterOutAdmins, ADMIN_ONLY_ROUTES, messagePushBody,
  },
};
