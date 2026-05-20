/**
 * Video Album Messages — extends `messages` with grouped multi-video
 * attachment metadata.
 *
 * Same idempotent + additive shape as 040 (photo album), 047 (single
 * video). Stores an ordered array of HTTPS R2/S3 URLs (max 6 enforced
 * at controller level) so a multi-video selection lands as ONE
 * `messages` row instead of N separate rows — mirror of the photo
 * album decision.
 *
 * Why a sidecar `album_video_metadata` jsonb instead of N scalar
 * columns:
 *   • Per-tile duration / width / height varies across the array, so
 *     a single scalar column can't represent the set.
 *   • Keeping the metadata next to the URL array lets the listMessages
 *     serializer return one tidy payload without a JOIN to a side
 *     table.
 *   • Future-proofs adding more per-tile fields (e.g. poster URL,
 *     codec hint) without another migration.
 *
 * Why a single jsonb column instead of a child table:
 *   • Keeps reactions / stars / hides / forward / report / reply
 *     naturally agnostic — they all key off `messages.id` which
 *     stays a single row regardless of how many videos are inside.
 *   • Avoids an extra LEFT JOIN per listMessages call.
 *   • Order is preserved by the JSON array, so no `position`
 *     column is needed.
 *
 * Idempotent: every step is gated by `hasColumn` so the file is
 * safe to re-run on a partially-applied dev DB. Down() removes
 * only the columns we add — no destructive ops on existing data.
 *
 * Backwards compat: both columns are nullable. Every row inserted
 * before this migration leaves them NULL, and the chat controllers
 * only read the columns when `attachment_type='video_album'`.
 */

exports.up = async function (knex) {
  const has = (col) => knex.schema.hasColumn('messages', col);

  if (!(await has('album_video_urls'))) {
    await knex.schema.alterTable('messages', (t) => {
      // jsonb array of HTTPS URLs (R2/S3-issued or relative /uploads/video/...
      // for the local storage driver). Cap of 6 is enforced in
      // candidateController/businessController.sendMessage — DB layer
      // stays permissive so future caps can change without a schema
      // migration.
      t.jsonb('album_video_urls').nullable();
    });
  }

  if (!(await has('album_video_metadata'))) {
    await knex.schema.alterTable('messages', (t) => {
      // jsonb array, one entry per URL in `album_video_urls`. Each
      // entry is an object like:
      //   { duration_ms?: int, width?: int, height?: int,
      //     size_bytes?: int, mime_type?: string }
      // All fields are best-effort: the sender extracts them at pick
      // time, but if the device can't decode the file we ship the
      // upload without metadata and the receiver bubble hides the
      // duration label.
      t.jsonb('album_video_metadata').nullable();
    });
  }
};

exports.down = async function (knex) {
  const has = (col) => knex.schema.hasColumn('messages', col);
  for (const col of ['album_video_metadata', 'album_video_urls']) {
    if (await has(col)) {
      await knex.schema.alterTable('messages', (t) => {
        t.dropColumn(col);
      });
    }
  }
};
