exports.up = async function (knex) {
  const exists = await knex.schema.hasTable('device_tokens');
  if (exists) return;
  await knex.schema.createTable('device_tokens', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('user_id').notNullable()
      .references('id').inTable('users').onDelete('CASCADE');
    t.text('token').notNullable().unique();
    t.enum('platform', ['ios', 'android', 'web']).notNullable();
    t.string('app_version');
    t.timestamp('last_seen_at').defaultTo(knex.fn.now());
    t.timestamps(true, true);
    t.index(['user_id']);
  });
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('device_tokens');
};
