// Schema feature-flag — runtime probes for columns/tables that are
// added by migrations the deploy pipeline may apply AFTER the new
// code rolls out (typical on Railway: image redeploys before the
// `knex migrate:latest` step finishes). Without this guard, every
// listMessages SELECT that names `album_image_urls` would 500 on a
// pre-migration DB and break the inbox.
//
// Cache strategy:
//   • once we observe the column exists → cache TRUE forever
//     (migrations are additive in this codebase, columns aren't
//     dropped at runtime)
//   • when we observe it doesn't exist → cache FALSE with a 30s
//     re-probe TTL so the backend self-heals as soon as
//     `migrate:latest` finishes — no manual restart needed
//
// The probe is a single `information_schema` lookup (~1 ms) and only
// runs at first use + every 30s while the answer stays FALSE, so the
// runtime overhead is negligible.

const db = require('../config/db');

const _cache = {
  album_image_urls: { present: null, lastCheckedAt: 0 },
  video_columns: { present: null, lastCheckedAt: 0 },
  video_album_columns: { present: null, lastCheckedAt: 0 },
  forwarded_columns: { present: null, lastCheckedAt: 0 },
  call_log_metadata: { present: null, lastCheckedAt: 0 },
  group_chat: { present: null, lastCheckedAt: 0 },
  group_photo_url: { present: null, lastCheckedAt: 0 },
  candidate_availability: { present: null, lastCheckedAt: 0 },
  urgent_requests: { present: null, lastCheckedAt: 0 },
};

const _RECHECK_INTERVAL_MS = 30 * 1000;

async function _probe(column) {
  try {
    return await db.schema.hasColumn('messages', column);
  } catch (_e) {
    return false;
  }
}

async function isAlbumColumnPresent() {
  const entry = _cache.album_image_urls;
  if (entry.present === true) return true; // sticky on success
  const now = Date.now();
  if (entry.present === false && (now - entry.lastCheckedAt) < _RECHECK_INTERVAL_MS) {
    return false;
  }
  const result = await _probe('album_image_urls');
  entry.present = result;
  entry.lastCheckedAt = now;
  if (result) {
    // ignore: avoid_print — single line at the moment we transition
    // from "missing" to "present" lets the operator see in Railway
    // logs that the schema is now ready (no re-deploy required).
    // eslint-disable-next-line no-console
    console.log('[schemaFeatureFlags] messages.album_image_urls is now PRESENT');
  }
  return result;
}

/// Multi-column probe for video message metadata. Migration 047 adds
/// all columns together, but the runtime gate stays strict so SELECT /
/// INSERT paths never name a half-applied schema.
async function isVideoColumnsPresent() {
  const entry = _cache.video_columns;
  if (entry.present === true) return true; // sticky on success
  const now = Date.now();
  if (entry.present === false && (now - entry.lastCheckedAt) < _RECHECK_INTERVAL_MS) {
    return false;
  }
  const checks = await Promise.all([
    _probe('video_url'),
    _probe('video_size_bytes'),
    _probe('video_mime_type'),
    _probe('video_duration_ms'),
    _probe('video_width'),
    _probe('video_height'),
  ]);
  const result = checks.every(Boolean);
  entry.present = result;
  entry.lastCheckedAt = now;
  if (result) {
    // eslint-disable-next-line no-console
    console.log('[schemaFeatureFlags] messages.video_* columns are now PRESENT');
  }
  return result;
}

/// Probe for the video-album columns added by migration 048 (multi-
/// video album bubble). Same sticky-on-true + 30s re-probe pattern.
/// Strict gate — only TRUE when BOTH `album_video_urls` and
/// `album_video_metadata` are present, so the listMessages SELECT and
/// the sendMessage INSERT either both name the new columns or neither
/// does. Either-alone is impossible in practice (mig 048 adds them
/// atomically), but the strict gate keeps controllers from tracking
/// two flags.
async function isVideoAlbumColumnsPresent() {
  const entry = _cache.video_album_columns;
  if (entry.present === true) return true; // sticky on success
  const now = Date.now();
  if (entry.present === false && (now - entry.lastCheckedAt) < _RECHECK_INTERVAL_MS) {
    return false;
  }
  const [hasUrls, hasMeta] = await Promise.all([
    _probe('album_video_urls'),
    _probe('album_video_metadata'),
  ]);
  const result = hasUrls && hasMeta;
  entry.present = result;
  entry.lastCheckedAt = now;
  if (result) {
    // eslint-disable-next-line no-console
    console.log('[schemaFeatureFlags] messages.album_video_urls + album_video_metadata are now PRESENT');
  }
  return result;
}

/// Probe for the group-chat schema introduced by migration 049:
/// the type/name discriminator columns on `conversations` plus the
/// `conversation_members` table. Same sticky-on-true + 30s reprobe
/// pattern. Strict gate — only TRUE when ALL three are present, so
/// controller code branching on group support never half-applies.
async function isGroupChatColumnsPresent() {
  const entry = _cache.group_chat;
  if (entry.present === true) return true; // sticky on success
  const now = Date.now();
  if (entry.present === false && (now - entry.lastCheckedAt) < _RECHECK_INTERVAL_MS) {
    return false;
  }
  try {
    const [hasType, hasName, hasMembersTable] = await Promise.all([
      db.schema.hasColumn('conversations', 'type'),
      db.schema.hasColumn('conversations', 'name'),
      db.schema.hasTable('conversation_members'),
    ]);
    const result = hasType && hasName && hasMembersTable;
    entry.present = result;
    entry.lastCheckedAt = now;
    if (result) {
      // eslint-disable-next-line no-console
      console.log('[schemaFeatureFlags] conversations.{type,name} + conversation_members are now PRESENT');
    }
    return result;
  } catch (_) {
    entry.present = false;
    entry.lastCheckedAt = now;
    return false;
  }
}

/// Pair-probe for the forward sprint columns. We treat them as ONE
/// readiness signal — only return TRUE when BOTH `forwarded_from_message_id`
/// and `is_forwarded` are present. Either-alone is impossible in
/// practice (migration 041 adds both atomically), but the strict gate
/// keeps the controller code from having to track two separate flags.
async function isForwardedColumnsPresent() {
  const entry = _cache.forwarded_columns;
  if (entry.present === true) return true; // sticky on success
  const now = Date.now();
  if (entry.present === false && (now - entry.lastCheckedAt) < _RECHECK_INTERVAL_MS) {
    return false;
  }
  const [hasFk, hasFlag] = await Promise.all([
    _probe('forwarded_from_message_id'),
    _probe('is_forwarded'),
  ]);
  const result = hasFk && hasFlag;
  entry.present = result;
  entry.lastCheckedAt = now;
  if (result) {
    // eslint-disable-next-line no-console
    console.log('[schemaFeatureFlags] messages.forwarded_from_message_id + is_forwarded are now PRESENT');
  }
  return result;
}

/// Probe for the `messages.call_log_metadata` column added by
/// migration 046 (Calls Step 3A). Same sticky-on-true + 30s re-probe
/// pattern as the other flags. Used by the call controller to gate
/// the missed-call message insert during the Railway deploy →
/// migrate window so a pre-migration backend doesn't 500 on the
/// JSONB write.
async function isCallLogColumnPresent() {
  const entry = _cache.call_log_metadata;
  if (entry.present === true) return true; // sticky on success
  const now = Date.now();
  if (entry.present === false && (now - entry.lastCheckedAt) < _RECHECK_INTERVAL_MS) {
    return false;
  }
  const result = await _probe('call_log_metadata');
  entry.present = result;
  entry.lastCheckedAt = now;
  if (result) {
    // eslint-disable-next-line no-console
    console.log('[schemaFeatureFlags] messages.call_log_metadata is now PRESENT');
  }
  return result;
}

/// Probe for `conversations.group_photo_url` added by migration 050
/// (Stage C.2A.2). Independent of [isGroupChatColumnsPresent] so the
/// group chat feature itself continues to work through the Railway
/// deploy → migrate window — only the optional photo read/write is
/// gated. Same sticky-on-true + 30s re-probe pattern as the other
/// schema flags.
async function isGroupPhotoColumnPresent() {
  const entry = _cache.group_photo_url;
  if (entry.present === true) return true; // sticky on success
  const now = Date.now();
  if (entry.present === false && (now - entry.lastCheckedAt) < _RECHECK_INTERVAL_MS) {
    return false;
  }
  try {
    const result = await db.schema.hasColumn('conversations', 'group_photo_url');
    entry.present = result;
    entry.lastCheckedAt = now;
    if (result) {
      // eslint-disable-next-line no-console
      console.log('[schemaFeatureFlags] conversations.group_photo_url is now PRESENT');
    }
    return result;
  } catch (_) {
    entry.present = false;
    entry.lastCheckedAt = now;
    return false;
  }
}

/// Probe for the Availability Live columns added by migration 051
/// (Stage AL.1). Strict gate — only TRUE when ALL four new columns
/// are present, so the AL.2 controller never half-writes during the
/// Railway deploy -> migrate window. Same sticky-on-true + 30s
/// re-probe pattern as the other schema flags.
async function isCandidateAvailabilityColumnsPresent() {
  const entry = _cache.candidate_availability;
  if (entry.present === true) return true; // sticky on success
  const now = Date.now();
  if (entry.present === false && (now - entry.lastCheckedAt) < _RECHECK_INTERVAL_MS) {
    return false;
  }
  try {
    const [hasState, hasUntil, hasRadius, hasActive] = await Promise.all([
      db.schema.hasColumn('candidates', 'availability_state'),
      db.schema.hasColumn('candidates', 'availability_until'),
      db.schema.hasColumn('candidates', 'preferred_area_radius_km'),
      db.schema.hasColumn('candidates', 'last_active_at'),
    ]);
    const result = hasState && hasUntil && hasRadius && hasActive;
    entry.present = result;
    entry.lastCheckedAt = now;
    if (result) {
      // eslint-disable-next-line no-console
      console.log('[schemaFeatureFlags] candidates availability columns are now PRESENT');
    }
    return result;
  } catch (_) {
    entry.present = false;
    entry.lastCheckedAt = now;
    return false;
  }
}

/// Probe for the `urgent_requests` table added by migration 052
/// (Stage AL.5.1). Single-table presence check — no per-column
/// probe needed since the table is created atomically. Same
/// sticky-on-true + 30s re-probe pattern as the other flags.
async function isUrgentRequestsTablePresent() {
  const entry = _cache.urgent_requests;
  if (entry.present === true) return true;
  const now = Date.now();
  if (entry.present === false && (now - entry.lastCheckedAt) < _RECHECK_INTERVAL_MS) {
    return false;
  }
  try {
    const result = await db.schema.hasTable('urgent_requests');
    entry.present = result;
    entry.lastCheckedAt = now;
    if (result) {
      // eslint-disable-next-line no-console
      console.log('[schemaFeatureFlags] urgent_requests table is now PRESENT');
    }
    return result;
  } catch (_) {
    entry.present = false;
    entry.lastCheckedAt = now;
    return false;
  }
}

module.exports = {
  isAlbumColumnPresent,
  isVideoColumnsPresent,
  isVideoAlbumColumnsPresent,
  isForwardedColumnsPresent,
  isCallLogColumnPresent,
  isGroupChatColumnsPresent,
  isGroupPhotoColumnPresent,
  isCandidateAvailabilityColumnsPresent,
  isUrgentRequestsTablePresent,
};
