exports.up = function (knex) {
  return knex.schema
    .alterTable('users', (t) => {
      t.enum('admin_role', ['super_admin', 'moderation_admin', 'support_admin', 'finance_admin'])
        .nullable()
        .after('user_type');
    })
    .createTable('refresh_tokens', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      t.text('token').notNullable().unique();
      t.timestamp('expires_at').notNullable();
      t.timestamps(true, true);
    });
};

exports.down = function (knex) {
  return knex.schema
    .dropTableIfExists('refresh_tokens')
    .alterTable('users', (t) => {
      t.dropColumn('admin_role');
    });
};
