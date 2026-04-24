const { bus } = require('./eventBus');
const db = require('../../config/db');

/**
 * In-memory presence registry.
 *
 * Each SSE connection increments the counter for its user; disconnects
 * decrement it. A user is considered "online" as long as at least one
 * connection is open. First-connect and last-disconnect transitions emit
 * a `presence.update` event to every conversation counterpart of the
 * user — so chat headers can flip the green dot live without polling.
 *
 * This is intentionally single-process. A multi-node deployment would
 * swap this for Redis pub/sub + SADD/SREM — but we're on one Node now.
 */
const counts = new Map(); // userId -> number of active SSE connections

async function findCounterpartUserIds(userId) {
  // Every user id that shares a conversation with `userId`, through either
  // the business or candidate side.
  try {
    const rows = await db.raw(
      `SELECT DISTINCT u.id
         FROM users u
        WHERE u.id IN (
            SELECT b.user_id
              FROM businesses b
             WHERE b.id IN (
               SELECT c.business_id
                 FROM conversations c
                WHERE c.candidate_id IN (
                  SELECT cn.id FROM candidates cn WHERE cn.user_id = ?
                )
             )
          )
           OR u.id IN (
            SELECT cn.user_id
              FROM candidates cn
             WHERE cn.id IN (
               SELECT c.candidate_id
                 FROM conversations c
                WHERE c.business_id IN (
                  SELECT b.id FROM businesses b WHERE b.user_id = ?
                )
             )
          )`,
      [userId, userId]
    );
    return (rows.rows || rows || []).map((r) => r.id).filter(Boolean);
  } catch (_e) {
    return [];
  }
}

async function emitPresenceChange(userId, isOnline) {
  const counterparts = await findCounterpartUserIds(userId);
  const audience = ['role:admin', ...counterparts.map((id) => `user:${id}`)];
  bus.publish('presence.update', { user_id: userId, is_online: isOnline }, audience);
}

async function connect(userId) {
  if (!userId) return;
  const prev = counts.get(userId) || 0;
  counts.set(userId, prev + 1);
  if (prev === 0) {
    // 0 → 1 transition: user just came online.
    await emitPresenceChange(userId, true);
  }
}

async function disconnect(userId) {
  if (!userId) return;
  const prev = counts.get(userId) || 0;
  if (prev <= 1) {
    counts.delete(userId);
    await emitPresenceChange(userId, false);
  } else {
    counts.set(userId, prev - 1);
  }
}

function isOnline(userId) {
  return (counts.get(userId) || 0) > 0;
}

module.exports = { connect, disconnect, isOnline };
