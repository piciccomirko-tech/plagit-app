/**
 * User follows table for community feed "Following" tab.
 */
exports.up = function (knex) {
  return knex.schema.createTable('user_follows', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('follower_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    t.uuid('followed_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
    t.timestamps(true, true);
    t.unique(['follower_id', 'followed_id']);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('user_follows');
};
