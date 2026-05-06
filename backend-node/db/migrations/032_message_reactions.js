/**
 * Phase 2 — Reactions persistence.
 *
 * Per-user, per-message reaction state. One row = one user's current
 * reaction on one message. The UNIQUE (message_id, user_id) constraint
 * encodes the product rule "one reaction per user per message" at the
 * schema level — no app-side dedupe needed.
 *
 * Idempotent: every step is gated by `hasTable` / `hasColumn` so the
 * file is safe to re-run on a partially-applied dev DB.
 */
exports.up = async function (knex) {
  const exists = await knex.schema.hasTable('message_reactions');
  if (!exists) {
    await knex.schema.createTable('message_reactions', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      // Message this reaction targets. Cascade so reactions disappear
      // alongside the message they were attached to.
      t.uuid('message_id')
        .references('id')
        .inTable('messages')
        .onDelete('CASCADE')
        .notNullable();
      // User who owns this reaction. Cascade keeps the table clean if
      // an account is hard-deleted.
      t.uuid('user_id')
        .references('id')
        .inTable('users')
        .onDelete('CASCADE')
        .notNullable();
      // Emoji as a Unicode string — same canonical form the Flutter
      // controller uses (`\u{1F44D}`, `\u{2764}\u{FE0F}`, etc.). We
      // intentionally don't normalise here because the client may want
      // to render variation-selector-suffixed emoji distinctly later.
      t.text('emoji').notNullable();
      t.timestamps(true, true); // created_at + updated_at, default now()
      // Product rule: one reaction per user per message. Toggle and
      // replace flows both work via INSERT … ON CONFLICT … DO UPDATE.
      t.unique(['message_id', 'user_id']);
    });
    // Hot path: listMessages joins reactions by message_id. The unique
    // index above already covers (message_id, user_id) — but Postgres
    // can use the unique index for message_id-only lookups, so we
    // skip a redundant index.
  }
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('message_reactions');
};
