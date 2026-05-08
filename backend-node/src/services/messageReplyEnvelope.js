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
      'users.name as sender_name',
      'users.user_type as sender_type',
    )
    .first();
  if (!parent) return null;
  const isVoice = parent.attachment_type === 'audio';
  return {
    id: parent.id,
    sender_type: parent.sender_type || null,
    sender_name: parent.sender_name || null,
    attachment_type: parent.attachment_type,
    body_preview: isVoice
      ? '🎤 Voice message'
      : (parent.body || '').slice(0, 200),
    audio_duration_ms: parent.audio_duration_ms || null,
  };
}

module.exports = { buildReplyEnvelope };
