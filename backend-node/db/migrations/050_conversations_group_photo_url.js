/**
 * Group Photo — extends `conversations` with an optional `group_photo_url`
 * so the Stage C.2A.2 client can set a per-group avatar that lives ONLY
 * on the conversation (never overwrites any user.photo_url).
 *
 * Schema additions (additive, idempotent):
 *
 *   conversations
 *     • group_photo_url  text (nullable) — HTTPS URL issued by our
 *                        storage adapter (storage.isOwnedUrl gate
 *                        enforced at the controller layer). Null on
 *                        every existing row → renderer keeps painting
 *                        the color-hash GroupAvatar fallback.
 *
 * Why only HTTPS owned URLs (no inline data URI):
 *   The client uploads via the existing `POST /v1/uploads/image`
 *   endpoint first, then PATCHes the resulting URL into this column.
 *   Keeps the row small (a single TEXT URL, not a 600+KB base64 blob),
 *   keeps the upload pipeline single-purpose, and avoids the
 *   image-flicker class of bugs that motivated the user-photo refactor.
 *
 * Permission model lives in the controller (group_creator-only for
 * UPDATE / clear); the migration itself stays schema-only.
 *
 * Backwards compat:
 *   • Pre-migration rows: column doesn't exist, the runtime guard
 *     `schemaFeatureFlags.isGroupPhotoColumnPresent()` keeps the read
 *     code path safe through the deploy window.
 *   • Post-migration old clients: column exists but null → identical
 *     visual to today's color-hash fallback. No client breakage.
 *
 * Idempotent: `hasColumn` probe before alter, safe to re-run on a
 * partially-applied dev DB.
 */

exports.up = async function (knex) {
  const hasGroupPhotoUrl = await knex.schema.hasColumn(
    'conversations',
    'group_photo_url',
  );
  if (!hasGroupPhotoUrl) {
    await knex.schema.alterTable('conversations', (t) => {
      t.text('group_photo_url').nullable();
    });
  }
};

exports.down = async function (knex) {
  if (await knex.schema.hasColumn('conversations', 'group_photo_url')) {
    await knex.schema.alterTable('conversations', (t) => {
      t.dropColumn('group_photo_url');
    });
  }
};
