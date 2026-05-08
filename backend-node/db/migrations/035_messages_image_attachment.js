/**
 * Image Messages — extends `messages` with image-attachment metadata.
 *
 * Mirror of migration 031 (audio). Pure metadata: actual bytes live
 * on the storage adapter (LocalDiskAdapter today, S3Adapter in prod).
 *
 * `attachment_type` is already present from 031 — this migration only
 * adds the image-specific columns. The runtime gates `attachment_type`
 * to one of {'text','audio','entity_share','image'} at the controller
 * layer (no DB enum so the column stays trivially extensible).
 *
 * Idempotent: each `addColumn` is gated by `hasColumn` so the file is
 * safe to re-run on a partially-applied dev DB. Down() removes only
 * columns we added.
 */
exports.up = async function (knex) {
  const has = (col) => knex.schema.hasColumn('messages', col);

  if (!(await has('image_url'))) {
    await knex.schema.alterTable('messages', (t) => {
      // Relative path served by express.static for local driver,
      // absolute https:// for S3 driver. Nullable for non-image rows.
      t.text('image_url').nullable();
    });
  }
  if (!(await has('image_size_bytes'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.integer('image_size_bytes').nullable();
    });
  }
  if (!(await has('image_mime_type'))) {
    await knex.schema.alterTable('messages', (t) => {
      // 'image/jpeg' | 'image/png' | 'image/webp' | 'image/heic'
      t.string('image_mime_type', 50).nullable();
    });
  }
  if (!(await has('image_width'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.integer('image_width').nullable();
    });
  }
  if (!(await has('image_height'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.integer('image_height').nullable();
    });
  }
};

exports.down = async function (knex) {
  await knex.schema.alterTable('messages', (t) => {
    t.dropColumn('image_height');
    t.dropColumn('image_width');
    t.dropColumn('image_mime_type');
    t.dropColumn('image_size_bytes');
    t.dropColumn('image_url');
  });
};
