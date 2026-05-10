/**
 * Album Messages — extends `messages` with grouped multi-photo
 * attachment metadata.
 *
 * Same idempotent + additive shape as 031 (audio), 035 (image),
 * 036 (document), 037 (location). Stores an ordered array of
 * HTTPS R2/S3 URLs (max 6 enforced at controller level) so a
 * multi-photo selection lands as ONE `messages` row instead of
 * N separate rows.
 *
 * Why a single jsonb column instead of a child table:
 *   • Keeps reactions / stars / hides / forward / report / reply
 *     naturally agnostic — they all key off `messages.id` which
 *     stays a single row regardless of how many photos are inside.
 *   • Avoids an extra LEFT JOIN per listMessages call.
 *   • Order is preserved by the JSON array, so no `position`
 *     column is needed.
 *
 * Idempotent: every step is gated by `hasColumn` so the file is
 * safe to re-run on a partially-applied dev DB. Down() removes
 * only the column we add — no destructive ops on existing data.
 *
 * Backwards compat: `album_image_urls` is nullable. Every row
 * inserted before this migration leaves it NULL, and the chat
 * controllers only read the column when `attachment_type='album'`.
 */

exports.up = async function (knex) {
  const has = (col) => knex.schema.hasColumn('messages', col);

  if (!(await has('album_image_urls'))) {
    await knex.schema.alterTable('messages', (t) => {
      // jsonb array of HTTPS URLs (R2/S3-issued). Cap of 6 is
      // enforced in candidateController/businessController.sendMessage
      // — DB layer stays permissive so future caps can change without
      // a schema migration.
      t.jsonb('album_image_urls').nullable();
    });
  }
};

exports.down = async function (knex) {
  if (await knex.schema.hasColumn('messages', 'album_image_urls')) {
    await knex.schema.alterTable('messages', (t) => {
      t.dropColumn('album_image_urls');
    });
  }
};
