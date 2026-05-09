/**
 * Soft-delete support for chat messages — Sprint 4C.
 *
 * Two distinct deletion modes, both additive + reversible:
 *
 *   1. Delete for me (per-user soft hide)
 *      Adds the `message_hides` table. One row per (message, user)
 *      means that user does not see that message in their thread.
 *      Other participants + admin still see the message normally.
 *      UNIQUE(message_id, user_id) makes the operation idempotent.
 *
 *   2. Delete for everyone (tombstone)
 *      Adds `messages.deleted_for_everyone_at` (timestamptz, NULL).
 *      Non-NULL means the sender removed the message inside the
 *      15-minute window enforced at the controller layer. The
 *      message row itself stays — the body is just nullified at
 *      list-time and the bubble renders a "This message was
 *      deleted" placeholder. Admin sees the original payload for
 *      audit (controller decides — schema is permissive).
 *
 * Reactions tied to a tombstoned message are dropped explicitly by
 * the controller when the tombstone is set (mirror of WhatsApp UX).
 * The schema-level FK on message_reactions.message_id ON DELETE
 * CASCADE doesn't fire here — the messages row stays.
 *
 * Idempotent + reversible. Down() drops the table and the column.
 */
exports.up = async function (knex) {
  // 1) deleted_for_everyone_at column (tombstone marker)
  const has = (col) => knex.schema.hasColumn('messages', col);
  if (!(await has('deleted_for_everyone_at'))) {
    await knex.schema.alterTable('messages', (t) => {
      t.timestamp('deleted_for_everyone_at', { useTz: true }).nullable();
    });
  }

  // 2) message_hides table (per-user soft hide)
  const hidesExists = await knex.schema.hasTable('message_hides');
  if (!hidesExists) {
    await knex.schema.createTable('message_hides', (t) => {
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
  }
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('message_hides');
  if (await knex.schema.hasColumn('messages', 'deleted_for_everyone_at')) {
    await knex.schema.alterTable('messages', (t) => {
      t.dropColumn('deleted_for_everyone_at');
    });
  }
};
