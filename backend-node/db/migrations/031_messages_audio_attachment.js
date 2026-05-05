/**
 * Voice Messages MVP — extends `messages` with attachment metadata.
 *
 * Pure metadata: actual audio bytes live on the storage adapter
 * (LocalDiskAdapter today, S3Adapter later — see src/storage/README.md).
 *
 * Idempotent: each `addColumn` is gated by `hasColumn` so the file is
 * safe to re-run if a partial apply happened on a dev DB. Down() removes
 * only columns we added — no destructive ops on existing fields.
 */
exports.up = async function (knex) {
  const has = (col) => knex.schema.hasColumn('messages', col);

  if (!(await has('attachment_type'))) {
    await knex.schema.alterTable('messages', (t) => {
      // 'text' | 'audio' (future: 'image', 'video', 'multi')
      t.string('attachment_type', 20).notNullable().defaultTo('text');
    });
  }
  if (!(await has('audio_url'))) {
    await knex.schema.alterTable('messages', (t) => {
      // Relative path served by express.static for local driver,
      // absolute https:// for S3 driver. Nullable for text rows.
      t.text('audio_url').nullable();
    });
  }
  if (!(await has('audio_duration_ms'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.integer('audio_duration_ms').nullable();
    });
  }
  if (!(await has('audio_size_bytes'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.integer('audio_size_bytes').nullable();
    });
  }
  if (!(await has('audio_mime_type'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.string('audio_mime_type', 50).nullable();
    });
  }
};

exports.down = async function (knex) {
  const has = (col) => knex.schema.hasColumn('messages', col);
  for (const col of [
    'audio_mime_type',
    'audio_size_bytes',
    'audio_duration_ms',
    'audio_url',
    'attachment_type',
  ]) {
    if (await has(col)) {
      await knex.schema.alterTable('messages', (t) => {
        t.dropColumn(col);
      });
    }
  }
};
