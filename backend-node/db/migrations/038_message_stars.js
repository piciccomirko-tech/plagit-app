/**
 * Per-user message stars — Sprint 4A.
 *
 * Mirror of `message_reactions` but without the emoji column. Each
 * row is one user marking one message as "starred". UNIQUE on
 * (message_id, user_id) means each user can star a message only
 * once — re-tapping the Star action is idempotent (controller does
 * INSERT ... ON CONFLICT DO NOTHING).
 *
 * Stars are private: only the user who created the row sees it. The
 * peer / admin do NOT learn about your stars.
 *
 * Cascades:
 *   - message_id ON DELETE CASCADE — drop stars when the message
 *     row is hard-deleted (admin only). For soft-delete (Sprint 4C
 *     `deleted_for_everyone_at`), the star row stays attached to the
 *     tombstone. The bubble renders a placeholder either way.
 *   - user_id ON DELETE CASCADE — drop stars when an account is
 *     wiped out for GDPR / cleanup.
 *
 * Idempotent + reversible.
 */
exports.up = async function (knex) {
  const exists = await knex.schema.hasTable('message_stars');
  if (exists) return;

  await knex.schema.createTable('message_stars', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('message_id')
      .notNullable()
      .references('id')
      .inTable('messages')
      .onDelete('CASCADE');
    t.uuid('user_id')
      .notNullable()
      .references('id')
      .inTable('users')
      .onDelete('CASCADE');
    t.timestamp('created_at', { useTz: true })
      .notNullable()
      .defaultTo(knex.fn.now());
    t.unique(['message_id', 'user_id']);
  });
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('message_stars');
};
