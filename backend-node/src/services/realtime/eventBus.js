const EventEmitter = require('events');

/**
 * Realtime event bus — in-process pub/sub for SSE delivery.
 *
 * An event is: { type, payload, audience, timestamp }.
 *
 * Audience is an array of tokens. Supported formats:
 *   - 'user:<userId>'  → deliver to that specific user's connections
 *   - 'role:admin'     → deliver to every connected admin
 *
 * The per-connection SSE handler subscribes to the 'event' channel and
 * filters by matching its own user identity against the event audience.
 */
class RealtimeBus extends EventEmitter {
  constructor() {
    super();
    this.setMaxListeners(0); // no warning; we scale with connection count
  }

  /**
   * Emit a realtime event.
   * @param {string} type — e.g. 'application.status_changed'
   * @param {object} payload — arbitrary domain data
   * @param {string[]} audience — tokens: 'user:<id>', 'role:admin'
   */
  publish(type, payload, audience) {
    const event = {
      type,
      payload: payload || {},
      audience: Array.isArray(audience) ? audience : [],
      timestamp: new Date().toISOString(),
    };
    if (type === 'message.new') {
      const convId = (payload && payload.conversation_id) || null;
      const senderUserId = (payload && payload.sender_user_id) || null;
      const recipientUserId = (payload && payload.recipient_user_id) || null;
      const listenerCount = this.listenerCount('event');
      console.log(`[SSE EMIT] bus.publish type=${type} convId=${convId} senderUserId=${senderUserId} recipientUserId=${recipientUserId} audience=${JSON.stringify(event.audience)} listeners=${listenerCount}`);
    }
    this.emit('event', event);
    return event;
  }
}

const bus = new RealtimeBus();

/**
 * True if the given user matches the audience tokens of an event.
 * @param {{id: string, role: string}} user
 * @param {string[]} audience
 */
function audienceMatches(user, audience) {
  if (!user || !Array.isArray(audience) || audience.length === 0) return false;
  for (const token of audience) {
    if (token === `user:${user.id}`) return true;
    if (token === 'role:admin' && user.role === 'admin') return true;
  }
  return false;
}

module.exports = { bus, audienceMatches };
