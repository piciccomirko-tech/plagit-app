exports.up = function (knex) {
  return knex.schema.createTable('password_reset_tokens', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
    t.string('token_hash').notNullable();
    t.string('code', 6).notNullable(); // 6-digit code for mobile entry
    t.timestamp('expires_at').notNullable();
    t.boolean('used').defaultTo(false);
    t.timestamps(true, true);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('password_reset_tokens');
};
