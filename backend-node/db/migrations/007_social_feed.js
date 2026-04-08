/**
 * Social Feed tables: feed_posts, post_likes, post_comments
 */
exports.up = function (knex) {
  return knex.schema
    .createTable('feed_posts', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.text('body').notNullable();
      t.text('image_url');          // base64 data URI or null
      t.string('location');
      t.string('tag');              // open_to_work, hiring, looking_for_staff, available_for_shifts
      t.string('role_category');    // chef, waiter, bartender, manager, reception, kitchen_porter
      t.float('latitude');
      t.float('longitude');
      t.integer('like_count').defaultTo(0);
      t.integer('comment_count').defaultTo(0);
      t.enum('status', ['active', 'hidden', 'deleted']).defaultTo('active');
      t.timestamps(true, true);
    })
    .createTable('post_likes', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('post_id').notNullable().references('id').inTable('feed_posts').onDelete('CASCADE');
      t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.timestamps(true, true);
      t.unique(['post_id', 'user_id']);
    })
    .createTable('post_comments', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('post_id').notNullable().references('id').inTable('feed_posts').onDelete('CASCADE');
      t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.text('body').notNullable();
      t.timestamps(true, true);
    });
};

exports.down = function (knex) {
  return knex.schema
    .dropTableIfExists('post_comments')
    .dropTableIfExists('post_likes')
    .dropTableIfExists('feed_posts');
};
