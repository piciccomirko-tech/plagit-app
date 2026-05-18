/**
 * Migration 046: add `call_log_metadata` JSONB column to `messages`.
 *
 * Used by the Calls Step 3A sprint to persist a single chat row each
 * time a ringing call is cancelled by the caller (status transitions
 * `ringing → missed`). The row's `attachment_type` is set to
 * `'call_log'` and this JSONB blob carries the per-call context the
 * Flutter `CallLogBubble` needs to render the missed-call card:
 *
 *   {
 *     callId:          uuid,
 *     callType:        'audio' | 'video',
 *     callStatus:      'missed' | 'declined' | ...,
 *     callerId:        uuid,
 *     calleeId:        uuid,
 *     conversationId:  uuid,
 *     createdAt:       ISO-8601,
 *     endedAt:         ISO-8601 | null,
 *   }
 *
 * Strictly additive — column is nullable so old rows and old code
 * paths keep working. The runtime probe `isCallLogColumnPresent()`
 * (services/schemaFeatureFlags.js) lets the controller skip writes
 * cleanly during the deploy → migrate window on Railway.
 *
 * Pattern mirrors migration 040 (album_image_urls) exactly:
 * idempotent up + down, no data backfill needed.
 */

exports.up = async function (knex) {
  const hasCol = await knex.schema.hasColumn('messages', 'call_log_metadata');
  if (!hasCol) {
    await knex.schema.alterTable('messages', (t) => {
      t.jsonb('call_log_metadata').nullable();
    });
  }
};

exports.down = async function (knex) {
  const hasCol = await knex.schema.hasColumn('messages', 'call_log_metadata');
  if (hasCol) {
    await knex.schema.alterTable('messages', (t) => {
      t.dropColumn('call_log_metadata');
    });
  }
};
