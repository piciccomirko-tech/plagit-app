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
const lastSeen = new Map(); // userId -> ISO timestamp of last disconnect

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
  bus.publish(
    'presence.update',
    {
      user_id: userId,
      is_online: isOnline,
      last_seen_at: lastSeen.get(userId) || null,
    },
    audience,
  );
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
    // Stamp last-seen at the moment of the 1 → 0 transition so the
    // WhatsApp-style header label can render "last seen at HH:MM".
    lastSeen.set(userId, new Date().toISOString());
    await emitPresenceChange(userId, false);
  } else {
    counts.set(userId, prev - 1);
  }
}

function isOnline(userId) {
  return (counts.get(userId) || 0) > 0;
}

function lastSeenAt(userId) {
  return lastSeen.get(userId) || null;
}

// ── Foreground-state freshness (CallKit suppression) ──────────────────
//
// The VoIP push wakes the callee's device into the CallKit system call
// screen. When the callee's app is already FOREGROUND it shows its own
// in-app IncomingCallView from the SSE `call.ringing` event, so a CallKit
// banner on top is double UI. The mobile app reports its foreground state
// here (POST /v1/presence/app-state) and callController.initiate asks
// `isForeground` to decide whether to SKIP the push.
//
// Deliberately NOT derived from `isOnline` (the SSE connection counter):
// the SSE stream stays connected for a while after the app backgrounds,
// so `isOnline` is true in background too — unsafe as a foreground proxy.
//
// A short TTL makes the state self-expire: if it is stale (app was killed
// or the heartbeat stopped) or unknown, `isForeground` returns false →
// the push IS sent → CallKit rings. Background is therefore never broken;
// the worst case of a missing report is "CallKit shows", not "no call".
const FOREGROUND_TTL_MS = 15000; // 15s freshness window
const foregroundAt = new Map(); // userId -> ms epoch of last foreground=true report

function setAppState(userId, foreground) {
  if (!userId) return;
  if (foreground) {
    foregroundAt.set(userId, Date.now());
  } else {
    foregroundAt.delete(userId);
  }
}

function isForeground(userId) {
  const at = foregroundAt.get(userId);
  if (at === undefined) return false; // no report → safe default (send push)
  if (Date.now() - at > FOREGROUND_TTL_MS) {
    foregroundAt.delete(userId); // prune stale entry
    return false;
  }
  return true;
}

module.exports = {
  connect,
  disconnect,
  isOnline,
  lastSeenAt,
  setAppState,
  isForeground,
  FOREGROUND_TTL_MS,
};
