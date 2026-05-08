/**
 * Phase 3D — Reply / quote support for chat messages.
 *
 * Adds a self-referential FK so a message can point at the message
 * it is replying to. Nullable: existing messages and any future
 * non-reply messages leave it NULL.
 *
 * `ON DELETE SET NULL`: if the original message gets removed (admin
 * delete, future hard-delete path), the reply remains in the thread
 * with its quote header gone — safer than a CASCADE that would
 * silently delete the reply chain.
 */
exports.up = async (knex) => {
  await knex.schema.alterTable('messages', (t) => {
    t.uuid('reply_to_message_id')
      .nullable()
      .references('id')
      .inTable('messages')
      .onDelete('SET NULL');
    t.index('reply_to_message_id', 'messages_reply_to_message_id_idx');
  });
};

exports.down = async (knex) => {
  await knex.schema.alterTable('messages', (t) => {
    t.dropIndex(['reply_to_message_id'], 'messages_reply_to_message_id_idx');
    t.dropForeign(['reply_to_message_id']);
    t.dropColumn('reply_to_message_id');
  });
};
