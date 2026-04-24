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
 *
 * Events that DO NOT trigger pushes (UX-only, not push-worthy):
 *   • chat.typing
 *   • presence.update
 *   • message.delivered / message.read
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
