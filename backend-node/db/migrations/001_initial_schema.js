exports.up = function (knex) {
  return knex.schema

    // ─── Users (candidates, businesses, admins) ───
    .createTable('users', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.string('name').notNullable();
      t.string('initials', 4);
      t.string('email').notNullable().unique();
      t.string('password_hash').notNullable();
      t.string('phone');
      t.enum('user_type', ['candidate', 'business', 'admin']).notNullable();
      t.string('location');
      t.string('role');
      t.enum('status', ['active', 'suspended', 'banned']).defaultTo('active');
      t.boolean('is_verified').defaultTo(false);
      t.integer('profile_strength').defaultTo(0);
      t.integer('flag_count').defaultTo(0);
      t.float('avatar_hue').defaultTo(0.5);
      t.string('plan');
      t.timestamps(true, true);
    })

    // ─── Businesses ───
    .createTable('businesses', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      t.string('name').notNullable();
      t.string('initials', 4);
      t.string('venue_type');
      t.string('location');
      t.string('contact');
      t.string('email');
      t.enum('status', ['active', 'suspended', 'banned']).defaultTo('active');
      t.boolean('is_verified').defaultTo(false);
      t.boolean('is_featured').defaultTo(false);
      t.string('plan');
      t.enum('plan_status', ['active', 'trial', 'expired', 'cancelled']).defaultTo('active');
      t.date('renewal_date');
      t.integer('response_rate').defaultTo(0);
      t.integer('flag_count').defaultTo(0);
      t.float('avatar_hue').defaultTo(0.5);
      t.timestamps(true, true);
    })

    // ─── Candidates ───
    .createTable('candidates', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('user_id').references('id').inTable('users').onDelete('CASCADE');
      t.string('name').notNullable();
      t.string('initials', 4);
      t.string('role');
      t.string('location');
      t.string('experience');
      t.string('languages');
      t.enum('verification_status', ['verified', 'pending_review', 'suspended', 'new']).defaultTo('new');
      t.float('avatar_hue').defaultTo(0.5);
      t.timestamps(true, true);
    })

    // ─── Jobs ───
    .createTable('jobs', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('business_id').references('id').inTable('businesses').onDelete('CASCADE');
      t.string('title').notNullable();
      t.string('location');
      t.string('employment_type');
      t.string('salary');
      t.string('category');
      t.enum('status', ['active', 'paused', 'closed', 'draft', 'pending_review', 'flagged', 'suspended']).defaultTo('draft');
      t.boolean('is_featured').defaultTo(false);
      t.date('expiry_date');
      t.integer('views').defaultTo(0);
      t.integer('flag_count').defaultTo(0);
      t.float('avatar_hue').defaultTo(0.5);
      t.timestamps(true, true);
    })

    // ─── Applications ───
    .createTable('applications', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('candidate_id').references('id').inTable('candidates').onDelete('CASCADE');
      t.uuid('job_id').references('id').inTable('jobs').onDelete('CASCADE');
      t.enum('status', ['applied', 'under_review', 'shortlisted', 'interview', 'offer', 'rejected', 'withdrawn', 'flagged']).defaultTo('applied');
      t.boolean('has_interview').defaultTo(false);
      t.boolean('has_offer').defaultTo(false);
      t.integer('flag_count').defaultTo(0);
      t.integer('days_since_update').defaultTo(0);
      t.timestamps(true, true);
    })

    // ─── Interviews ───
    .createTable('interviews', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('application_id').references('id').inTable('applications').onDelete('CASCADE');
      t.uuid('candidate_id').references('id').inTable('candidates');
      t.uuid('job_id').references('id').inTable('jobs');
      t.timestamp('scheduled_at');
      t.string('timezone');
      t.enum('interview_type', ['video_call', 'phone', 'in_person']).defaultTo('video_call');
      t.enum('status', ['pending', 'confirmed', 'rescheduled', 'cancelled', 'completed', 'flagged']).defaultTo('pending');
      t.string('location');
      t.string('meeting_link');
      t.integer('reschedule_count').defaultTo(0);
      t.integer('flag_count').defaultTo(0);
      t.timestamps(true, true);
    })

    // ─── Messages / Conversations ───
    .createTable('conversations', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('candidate_id').references('id').inTable('candidates');
      t.uuid('business_id').references('id').inTable('businesses');
      t.uuid('job_id').references('id').inTable('jobs');
      t.text('last_message');
      t.enum('status', ['normal', 'flagged', 'under_review', 'archived', 'restricted']).defaultTo('normal');
      t.integer('flag_count').defaultTo(0);
      t.enum('support_state', ['none', 'open', 'escalated', 'resolved']).defaultTo('none');
      t.boolean('is_interview_related').defaultTo(false);
      t.integer('no_reply_days').defaultTo(0);
      t.timestamps(true, true);
    })

    // ─── Notifications ───
    .createTable('notifications', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('recipient_id').references('id').inTable('users');
      t.enum('notification_type', ['push', 'email', 'in_app', 'sms']).notNullable();
      t.string('title').notNullable();
      t.string('linked_entity');
      t.string('destination_route');
      t.enum('delivery_state', ['pending', 'sent', 'delivered', 'failed']).defaultTo('pending');
      t.boolean('is_read').defaultTo(false);
      t.timestamp('sent_at');
      t.integer('retry_count').defaultTo(0);
      t.timestamps(true, true);
    })

    // ─── Reports ───
    .createTable('reports', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.string('title').notNullable();
      t.string('reported_entity');
      t.string('reported_initials', 4);
      t.enum('type', ['user', 'business', 'job', 'message', 'community']).notNullable();
      t.string('reason');
      t.enum('severity', ['low', 'medium', 'high', 'urgent']).defaultTo('medium');
      t.enum('status', ['open', 'under_review', 'resolved', 'dismissed']).defaultTo('open');
      t.string('reporter');
      t.string('assigned_admin');
      t.integer('previous_reports').defaultTo(0);
      t.integer('flag_count').defaultTo(0);
      t.text('summary');
      t.float('avatar_hue').defaultTo(0.5);
      t.timestamps(true, true);
    })

    // ─── Subscriptions ───
    .createTable('subscriptions', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('business_id').references('id').inTable('businesses').onDelete('CASCADE');
      t.enum('plan', ['basic', 'premium', 'enterprise']).defaultTo('basic');
      t.enum('status', ['active', 'trial', 'expiring', 'failed', 'cancelled', 'grace', 'comp']).defaultTo('trial');
      t.enum('billing_cycle', ['monthly', 'annual']).defaultTo('monthly');
      t.date('renewal_date');
      t.string('amount');
      t.date('trial_end');
      t.boolean('auto_renew').defaultTo(true);
      t.integer('invoice_count').defaultTo(0);
      t.enum('payment_state', ['paid', 'failed', 'pending', 'refunded', 'complimentary']).defaultTo('pending');
      t.float('avatar_hue').defaultTo(0.5);
      t.timestamps(true, true);
    })

    // ─── Community Posts ───
    .createTable('community_posts', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.string('title').notNullable();
      t.string('category');
      t.string('author');
      t.string('author_initials', 4);
      t.enum('status', ['published', 'draft', 'scheduled', 'archived']).defaultTo('draft');
      t.boolean('is_pinned').defaultTo(false);
      t.boolean('is_featured_on_home').defaultTo(false);
      t.string('linked_employer');
      t.string('linked_job');
      t.date('published_date');
      t.integer('views').defaultTo(0);
      t.integer('saves').defaultTo(0);
      t.string('read_time');
      t.text('summary');
      t.float('avatar_hue').defaultTo(0.5);
      t.timestamps(true, true);
    })

    // ─── Featured Content ───
    .createTable('featured_content', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.string('title').notNullable();
      t.string('type');
      t.string('linked_entity');
      t.string('placement');
      t.enum('status', ['active', 'scheduled', 'expired', 'draft']).defaultTo('draft');
      t.boolean('is_pinned').defaultTo(false);
      t.integer('priority').defaultTo(0);
      t.date('start_date');
      t.date('end_date');
      t.integer('clicks').defaultTo(0);
      t.integer('views').defaultTo(0);
      t.float('avatar_hue').defaultTo(0.5);
      t.timestamps(true, true);
    })

    // ─── Admin Logs ───
    .createTable('admin_logs', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.string('action').notNullable();
      t.string('target');
      t.string('category');
      t.string('admin_user');
      t.string('old_value');
      t.string('new_value');
      t.enum('result', ['success', 'failed']).defaultTo('success');
      t.timestamps(true, true);
    })

    // ─── Admin Settings ───
    .createTable('admin_settings', (t) => {
      t.string('key').primary();
      t.text('value');
      t.timestamps(true, true);
    });
};

exports.down = function (knex) {
  return knex.schema
    .dropTableIfExists('admin_settings')
    .dropTableIfExists('admin_logs')
    .dropTableIfExists('featured_content')
    .dropTableIfExists('community_posts')
    .dropTableIfExists('subscriptions')
    .dropTableIfExists('reports')
    .dropTableIfExists('notifications')
    .dropTableIfExists('conversations')
    .dropTableIfExists('interviews')
    .dropTableIfExists('applications')
    .dropTableIfExists('jobs')
    .dropTableIfExists('candidates')
    .dropTableIfExists('businesses')
    .dropTableIfExists('users');
};
