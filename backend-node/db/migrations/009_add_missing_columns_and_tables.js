/**
 * Migration 009: Consolidates all ad-hoc schema changes that were previously
 * run inline in server.js at startup. This makes them proper, versioned
 * migrations that only run once via `knex migrate:latest`.
 */

exports.up = async function (knex) {
  // -- users table additions --
  const hasAppLang = await knex.schema.hasColumn('users', 'app_language_code');
  if (!hasAppLang) {
    await knex.schema.alterTable('users', (t) => {
      t.string('app_language_code', 5).defaultTo('en');
      t.text('spoken_languages');
    });
  }

  const hasSubPlan = await knex.schema.hasColumn('users', 'subscription_plan');
  if (!hasSubPlan) {
    await knex.schema.alterTable('users', (t) => {
      t.string('subscription_plan').defaultTo('free');
      t.string('subscription_status').defaultTo('inactive');
      t.timestamp('subscription_expires');
      t.string('subscription_product_id');
      t.string('original_transaction_id');
    });
  }

  const hasGracePeriod = await knex.schema.hasColumn('users', 'subscription_grace_end');
  if (!hasGracePeriod) {
    await knex.schema.alterTable('users', (t) => {
      t.timestamp('subscription_grace_end');
      t.timestamp('subscription_trial_end');
      t.boolean('subscription_auto_renew').defaultTo(true);
      t.string('subscription_payment_state').defaultTo('none');
    });
  }

  // -- candidates table additions --
  const hasNationality = await knex.schema.hasColumn('candidates', 'nationality');
  if (!hasNationality) {
    await knex.schema.alterTable('candidates', (t) => {
      t.string('nationality');
      t.string('nationality_code', 2);
      t.string('country_code', 2);
    });
  }

  const hasCandJobType = await knex.schema.hasColumn('candidates', 'job_type');
  if (!hasCandJobType) {
    await knex.schema.alterTable('candidates', (t) => {
      t.string('job_type');
      t.text('bio');
      t.string('start_date');
    });
  }

  const hasCandRelocate = await knex.schema.hasColumn('candidates', 'available_to_relocate');
  if (!hasCandRelocate) {
    await knex.schema.alterTable('candidates', (t) => {
      t.boolean('available_to_relocate').defaultTo(false);
    });
  }

  const hasCvUrl = await knex.schema.hasColumn('candidates', 'cv_url');
  if (!hasCvUrl) {
    await knex.schema.alterTable('candidates', (t) => {
      t.text('cv_url');
      t.string('cv_file_name');
    });
  }

  // -- businesses table additions --
  const hasBizCountry = await knex.schema.hasColumn('businesses', 'country');
  if (!hasBizCountry) {
    await knex.schema.alterTable('businesses', (t) => {
      t.string('country');
      t.string('country_code', 2);
      t.string('hiring_region');
    });
  }

  const hasBizLangs = await knex.schema.hasColumn('businesses', 'languages');
  if (!hasBizLangs) {
    await knex.schema.alterTable('businesses', (t) => {
      t.text('languages');
    });
  }

  const hasBizRole = await knex.schema.hasColumn('businesses', 'required_role');
  if (!hasBizRole) {
    await knex.schema.alterTable('businesses', (t) => {
      t.string('required_role');
      t.string('job_type');
      t.boolean('open_to_international').defaultTo(false);
    });
  }

  // -- jobs table additions --
  const hasJobIntl = await knex.schema.hasColumn('jobs', 'open_to_international');
  if (!hasJobIntl) {
    await knex.schema.alterTable('jobs', (t) => {
      t.boolean('open_to_international').defaultTo(false);
    });
  }

  const hasJobDesc = await knex.schema.hasColumn('jobs', 'description');
  if (!hasJobDesc) {
    await knex.schema.alterTable('jobs', (t) => {
      t.text('description');
      t.text('requirements');
      t.boolean('is_urgent').defaultTo(false);
      t.integer('num_hires').defaultTo(1);
      t.date('start_date');
      t.date('end_date');
      t.string('shift_hours');
    });
  }

  // -- feed_posts table + related tables --
  const hasFeed = await knex.schema.hasTable('feed_posts');
  if (!hasFeed) {
    await knex.schema.createTable('feed_posts', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.text('body').notNullable();
      t.text('image_url');
      t.text('video_url');
      t.string('location');
      t.string('tag');
      t.string('role_category');
      t.float('latitude');
      t.float('longitude');
      t.integer('like_count').defaultTo(0);
      t.integer('comment_count').defaultTo(0);
      t.integer('save_count').defaultTo(0);
      t.integer('view_count').defaultTo(0);
      t.enu('status', ['active', 'hidden', 'deleted']).defaultTo('active');
      t.timestamps(true, true);
    });

    await knex.schema.createTable('post_likes', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('post_id').notNullable().references('id').inTable('feed_posts').onDelete('CASCADE');
      t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.timestamps(true, true);
      t.unique(['post_id', 'user_id']);
    });

    await knex.schema.createTable('post_comments', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('post_id').notNullable().references('id').inTable('feed_posts').onDelete('CASCADE');
      t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.text('body').notNullable();
      t.timestamps(true, true);
    });
  } else {
    const hasVideo = await knex.schema.hasColumn('feed_posts', 'video_url');
    if (!hasVideo) {
      await knex.schema.alterTable('feed_posts', (t) => { t.text('video_url'); });
    }
    const cols = await knex.raw("SELECT column_name FROM information_schema.columns WHERE table_name = 'feed_posts'").then(r => r.rows.map(c => c.column_name));
    if (!cols.includes('save_count')) {
      await knex.raw("ALTER TABLE feed_posts ADD COLUMN save_count INTEGER DEFAULT 0");
    }
    if (!cols.includes('view_count')) {
      await knex.raw("ALTER TABLE feed_posts ADD COLUMN view_count INTEGER DEFAULT 0");
    }
  }

  // -- standalone tables --
  const hasFollows = await knex.schema.hasTable('user_follows');
  if (!hasFollows) {
    await knex.schema.createTable('user_follows', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('follower_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.uuid('followed_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.timestamps(true, true);
      t.unique(['follower_id', 'followed_id']);
    });
  }

  const hasMatches = await knex.schema.hasTable('matches');
  if (!hasMatches) {
    await knex.schema.createTable('matches', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('candidate_id').notNullable().references('id').inTable('candidates').onDelete('CASCADE');
      t.uuid('job_id').notNullable().references('id').inTable('jobs').onDelete('CASCADE');
      t.enu('status', ['pending', 'accepted', 'denied']).defaultTo('pending');
      t.timestamps(true, true);
      t.unique(['candidate_id', 'job_id']);
    });
  }

  const hasMatchFeedback = await knex.schema.hasTable('match_feedback');
  if (!hasMatchFeedback) {
    await knex.schema.createTable('match_feedback', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.string('match_id').notNullable();
      t.string('user_type').notNullable();
      t.boolean('was_relevant');
      t.boolean('role_accurate');
      t.boolean('job_type_accurate');
      t.timestamps(true, true);
    });
  }

  const hasPostMedia = await knex.schema.hasTable('post_media');
  if (!hasPostMedia) {
    await knex.schema.createTable('post_media', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('post_id').notNullable().references('id').inTable('feed_posts').onDelete('CASCADE');
      t.string('media_type').notNullable();
      t.text('url').notNullable();
      t.integer('sort_order').defaultTo(0);
      t.timestamps(true, true);
    });
  }

  const hasFeedNotif = await knex.schema.hasTable('feed_notifications');
  if (!hasFeedNotif) {
    await knex.schema.createTable('feed_notifications', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('recipient_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.uuid('actor_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.string('action_type').notNullable();
      t.uuid('post_id');
      t.text('preview');
      t.boolean('is_read').defaultTo(false);
      t.timestamps(true, true);
    });
  }

  const hasPostSaves = await knex.schema.hasTable('post_saves');
  if (!hasPostSaves) {
    await knex.schema.createTable('post_saves', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('post_id').notNullable().references('id').inTable('feed_posts').onDelete('CASCADE');
      t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.timestamps(true, true);
      t.unique(['post_id', 'user_id']);
    });
  }

  const hasPostViews = await knex.schema.hasTable('post_views');
  if (!hasPostViews) {
    await knex.schema.createTable('post_views', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('post_id').notNullable().references('id').inTable('feed_posts').onDelete('CASCADE');
      t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.timestamps(true, true);
      t.unique(['post_id', 'user_id']);
    });
  }

  const hasSubscriptions = await knex.schema.hasTable('subscriptions');
  if (!hasSubscriptions) {
    await knex.schema.createTable('subscriptions', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('user_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.string('plan').notNullable().defaultTo('free');
      t.string('status').notNullable().defaultTo('inactive');
      t.string('payment_state').defaultTo('none');
      t.string('billing_cycle').defaultTo('monthly');
      t.decimal('amount', 10, 2).defaultTo(0);
      t.timestamp('renewal_date');
      t.boolean('auto_renew').defaultTo(true);
      t.integer('trial_days_remaining').defaultTo(0);
      t.timestamp('last_payment_date');
      t.integer('invoice_count').defaultTo(0);
      t.string('product_id');
      t.timestamps(true, true);
    });
  }
};

exports.down = async function () {
  // Intentionally left empty — these columns/tables are now part of the schema.
  // Rolling back would require careful ordering due to foreign keys.
};
