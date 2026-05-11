/**
 * Forwarded messages — extends `messages` with the two columns that
 * back the WhatsApp-style "Forwarded" label + provenance link.
 *
 * Same idempotent + additive shape as 031 (audio), 035 (image),
 * 036 (document), 037 (location), 040 (album).
 *
 *   • `forwarded_from_message_id` — FK to messages.id, nullable, with
 *     ON DELETE SET NULL. Lets the bubble link back to the original
 *     message when both are still alive in the DB; gracefully drops
 *     to NULL when the source is deleted-for-everyone so the
 *     forwarded copy survives without a dangling reference.
 *
 *   • `is_forwarded` — sticky boolean, NOT NULL, DEFAULT false. Reads
 *     off this flag drive the "Forwarded" pill on the bubble; we
 *     don't piggyback on `forwarded_from_message_id != null` because
 *     the FK can legitimately turn NULL while the bubble must still
 *     show the label (source was deleted, but copy is still
 *     "Forwarded").
 *
 * Why two columns instead of one: the label and the back-link are
 * orthogonal concerns. A forwarded msg whose source was tombstoned
 * keeps `is_forwarded=true, forwarded_from_message_id=NULL`. A
 * legacy non-forwarded msg keeps both at default (false / NULL).
 *
 * Idempotent: every step is gated by `hasColumn` so the file is
 * safe to re-run on a partially-applied dev DB. Down() removes
 * only the two columns we add — no destructive ops on existing data.
 *
 * Backwards compat: both columns default to "not forwarded" so every
 * row inserted before this migration reads as legacy. The Sprint 1
 * defensive guard in `src/services/schemaFeatureFlags.js`
 * (`isForwardedColumnsPresent()`) probes for presence at runtime, so
 * any deploy/migrate ordering produces zero broken inbox window.
 */

exports.up = async function (knex) {
  const has = (col) => knex.schema.hasColumn('messages', col);

  if (!(await has('forwarded_from_message_id'))) {
    await knex.schema.alterTable('messages', (t) => {
      // FK back to the source message. ON DELETE SET NULL is the only
      // sane choice here: if the source is hard-deleted (admin DROP
      // row, not soft delete) we keep the forwarded copy alive but
      // sever the genealogy. is_forwarded stays true so the label
      // survives the broken link.
      t.uuid('forwarded_from_message_id').nullable()
        .references('id').inTable('messages').onDelete('SET NULL');
    });
  }

  if (!(await has('is_forwarded'))) {
    await knex.schema.alterTable('messages', (t) => {
      // NOT NULL + default false so every pre-migration row reads as
      // "not forwarded" automatically. Bubble renderer branches on
      // this flag directly — never inspects the FK presence to make
      // a render decision.
      t.boolean('is_forwarded').notNullable().defaultTo(false);
    });
  }
};

exports.down = async function (knex) {
  // Drop in reverse order — drop the boolean first (no FK to worry
  // about), then the FK column. Each gated by hasColumn so re-run is
  // safe on a partially-rolled-back dev DB.
  if (await knex.schema.hasColumn('messages', 'is_forwarded')) {
    await knex.schema.alterTable('messages', (t) => {
      t.dropColumn('is_forwarded');
    });
  }
  if (await knex.schema.hasColumn('messages', 'forwarded_from_message_id')) {
    await knex.schema.alterTable('messages', (t) => {
      t.dropColumn('forwarded_from_message_id');
    });
  }
};
