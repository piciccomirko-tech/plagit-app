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
      const body = payload.message?.body || '';
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
      if (!evt || !PUSH_TYPES.has(evt.type)) return;
      const targets = uniqueUserIds(evt.audience);
      if (targets.length === 0) return;
      const payload = await buildPayload(evt.type, evt.payload || {});
      if (!payload) return;

      // `message.new` echoes to the sender too (so SSE can refresh lists);
      // suppress the push for the sender to avoid self-notifications.
      const senderId =
        evt.type === 'message.new' ? evt.payload?.sender_user_id : null;

      await Promise.all(
        targets
          .filter((uid) => uid !== senderId)
          .map((uid) => sendToUser(uid, payload))
      );
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error('[push:subscriber] failed:', err.message);
    }
  });
  // eslint-disable-next-line no-console
  console.log('[push:subscriber] started');
}

module.exports = { start };
