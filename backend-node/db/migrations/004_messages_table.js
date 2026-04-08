exports.up = function (knex) {
  return knex.schema.createTable('messages', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('conversation_id').references('id').inTable('conversations').onDelete('CASCADE').notNullable();
    t.uuid('sender_id').references('id').inTable('users').notNullable();
    t.text('body').notNullable();
    t.boolean('is_read').defaultTo(false);
    t.timestamps(true, true);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('messages');
};
