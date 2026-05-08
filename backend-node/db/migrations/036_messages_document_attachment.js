/**
 * Document Messages — extends `messages` with document-attachment metadata.
 *
 * Mirror of migration 031 (audio) and 035 (image). Pure metadata: actual
 * bytes live on the storage adapter (LocalDiskAdapter today, S3Adapter
 * in prod).
 *
 * `attachment_type` is already present from 031 — this migration only
 * adds the document-specific columns. The runtime gates `attachment_type`
 * to one of {'text','audio','image','entity_share','document'} at the
 * controller layer (no DB enum so the column stays trivially extensible).
 *
 * Idempotent: each `addColumn` is gated by `hasColumn` so the file is
 * safe to re-run on a partially-applied dev DB. Down() removes only
 * columns we added.
 */
exports.up = async function (knex) {
  const has = (col) => knex.schema.hasColumn('messages', col);

  if (!(await has('document_url'))) {
    await knex.schema.alterTable('messages', (t) => {
      // Relative path served by express.static for local driver,
      // absolute https:// for S3 driver. Nullable for non-document rows.
      t.text('document_url').nullable();
    });
  }
  if (!(await has('document_size_bytes'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.integer('document_size_bytes').nullable();
    });
  }
  if (!(await has('document_mime_type'))) {
    await knex.schema.alterTable('messages', (t) => {
      // Up to ~80 chars to fit the longest officially-tracked MIME the
      // allowlist accepts:
      // 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      t.string('document_mime_type', 100).nullable();
    });
  }
  if (!(await has('document_filename'))) {
    await knex.schema.alterTable('messages', (t) => {
      // ORIGINAL filename the sender's OS reported. Surfaced in the
      // bubble + Files share sheet on the receiver. Stored as text
      // since pathological filenames can be very long.
      t.text('document_filename').nullable();
    });
  }
};

exports.down = async function (knex) {
  await knex.schema.alterTable('messages', (t) => {
    t.dropColumn('document_filename');
    t.dropColumn('document_mime_type');
    t.dropColumn('document_size_bytes');
    t.dropColumn('document_url');
  });
};
