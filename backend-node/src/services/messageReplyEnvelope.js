// Builds the compact `reply_to` snapshot the chat clients render in
// the bubble quote. The same shape is produced by listMessages via
// LEFT JOIN — this helper is for the single-row paths (POST send
// response, realtime SSE emit) where we need the envelope without
// re-running a full thread query.
//
// Returns `null` when:
//   - replyToId is null/undefined (not a reply)
//   - the parent row is missing (FK ON DELETE SET NULL race)

const db = require('../config/db');

async function buildReplyEnvelope(replyToId) {
  if (!replyToId) return null;
  const parent = await db('messages')
    .leftJoin('users', 'messages.sender_id', 'users.id')
    .where('messages.id', replyToId)
    .select(
      'messages.id',
      'messages.body',
      'messages.attachment_type',
      'messages.audio_duration_ms',
      'messages.shared_entity_type',
      'messages.shared_entity_id',
      'messages.album_image_urls',
      'messages.deleted_for_everyone_at',
      'users.name as sender_name',
      'users.user_type as sender_type',
    )
    .first();
  if (!parent) return null;
  // Sprint 4C — when the parent has been tombstoned, surface the same
  // "This message was deleted" placeholder the listMessages enrichment
  // produces, and force the attachment_type so the bubble can branch
  // its render without inspecting the raw timestamp.
  const isTombstoned = parent.deleted_for_everyone_at != null;
  return {
    id: parent.id,
    sender_type: parent.sender_type || null,
    sender_name: parent.sender_name || null,
    attachment_type: isTombstoned ? 'deleted' : parent.attachment_type,
    body_preview: isTombstoned ? 'This message was deleted' : _bodyPreviewFor(parent),
    audio_duration_ms: isTombstoned ? null : (parent.audio_duration_ms || null),
  };
}

/** Compact one-liner for the quote header. Type-aware so an
 * entity-share parent reads as "💼 Job" / "📋 Profile" /
 * "📅 Interview" instead of an empty body. */
function _bodyPreviewFor(parent) {
  if (parent.attachment_type === 'audio') return '🎤 Voice message';
  if (parent.attachment_type === 'image') return '🖼 Photo';
  if (parent.attachment_type === 'document') return '📄 Document';
  if (parent.attachment_type === 'location') return '📍 Location';
  if (parent.attachment_type === 'album') {
    // album_image_urls is a jsonb array of HTTPS R2/S3 URLs (cap 6,
    // enforced at write time by the controllers). pg may surface it
    // pre-parsed (Array) or as a JSON string depending on the driver
    // path — handle both so quoting a freshly-sent album doesn't crash.
    let urls = parent.album_image_urls;
    if (typeof urls === 'string') {
      try { urls = JSON.parse(urls); } catch (_) { urls = null; }
    }
    const len = Array.isArray(urls) ? urls.length : 0;
    return `📷 Album · ${len} photo${len === 1 ? '' : 's'}`;
  }
  if (parent.attachment_type === 'entity_share') {
    switch (parent.shared_entity_type) {
      case 'profile_candidate':
      case 'profile_business':
        return '📋 Profile';
      case 'job':
        return '💼 Job';
      case 'interview':
        return '📅 Interview';
      default:
        return '📎 Shared item';
    }
  }
  return (parent.body || '').slice(0, 200);
}

module.exports = { buildReplyEnvelope };
