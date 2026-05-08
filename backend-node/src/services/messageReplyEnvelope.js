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
      'users.name as sender_name',
      'users.user_type as sender_type',
    )
    .first();
  if (!parent) return null;
  return {
    id: parent.id,
    sender_type: parent.sender_type || null,
    sender_name: parent.sender_name || null,
    attachment_type: parent.attachment_type,
    body_preview: _bodyPreviewFor(parent),
    audio_duration_ms: parent.audio_duration_ms || null,
  };
}

/** Compact one-liner for the quote header. Type-aware so an
 * entity-share parent reads as "💼 Job" / "📋 Profile" /
 * "📅 Interview" instead of an empty body. */
function _bodyPreviewFor(parent) {
  if (parent.attachment_type === 'audio') return '🎤 Voice message';
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
