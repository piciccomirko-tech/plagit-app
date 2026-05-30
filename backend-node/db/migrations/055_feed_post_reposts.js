/**
 * Migration 055: Social Feed reposts.
 *
 * `feed_post_reposts` — one row per (post_id, user_id) repost. The composite
 * unique index makes reposts idempotent at the DB level (a user can repost a
 * given post at most once), so the toggle endpoint stays simple.
 *
 * Also adds a denormalized `repost_count` on `feed_posts` (mirrors
 * like_count / save_count) so the feed list returns the count without a
 * per-row aggregate.
 *
 * Both FKs cascade on delete: removing a user (account deletion) or a post
 * (author deletes it) wipes the repost rows cleanly.
 *
 * Scope: Repost = engagement counter + per-viewer flag (like a like). It does
 * NOT inject the post into anyone's feed (no reshare/duplication) — that is a
 * separate future sprint.
 */
exports.up = async function (knex) {
  const hasTable = await knex.schema.hasTable('feed_post_reposts');
  if (!hasTable) {
    await knex.schema.createTable('feed_post_reposts', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('post_id')
        .notNullable()
        .references('id')
        .inTable('feed_posts')
        .onDelete('CASCADE');
      t.uuid('user_id')
        .notNullable()
        .references('id')
        .inTable('users')
        .onDelete('CASCADE');
      t.timestamp('created_at').defaultTo(knex.fn.now());
      t.unique(['post_id', 'user_id']);
      t.index(['post_id']);
      t.index(['user_id']);
    });
  }

  const hasCol = await knex.schema.hasColumn('feed_posts', 'repost_count');
  if (!hasCol) {
    await knex.schema.alterTable('feed_posts', (t) => {
      t.integer('repost_count').notNullable().defaultTo(0);
    });
  }
};

exports.down = async function (knex) {
  const hasCol = await knex.schema.hasColumn('feed_posts', 'repost_count');
  if (hasCol) {
    await knex.schema.alterTable('feed_posts', (t) => {
      t.dropColumn('repost_count');
    });
  }
  const hasTable = await knex.schema.hasTable('feed_post_reposts');
  if (hasTable) await knex.schema.dropTable('feed_post_reposts');
};
