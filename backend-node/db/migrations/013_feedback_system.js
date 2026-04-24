/**
 * Migration 013: verified mutual feedback system (MVP Phase 1).
 *
 * Two tables:
 *   - feedback_opportunities: the review window opened by a trigger event
 *     (MVP trigger = interview.status -> 'completed'). Holds both sides of
 *     the reciprocal review and drives blind-window / expiry logic.
 *   - feedbacks: the actual review written by one party about the other.
 *     One row per direction per opportunity.
 *
 * Design notes:
 *   - `opportunity_type` and `source_kind` are varchar (not enum) on
 *     purpose: they will grow (shift_completed, hire_completed,
 *     collaboration_completed) and PG enum ALTERs are painful.
 *   - `status`, `direction`, `*_role` are enum because the value sets are
 *     closed for the MVP and any future additions there are unlikely.
 *   - feedback_opportunities holds `feedback_b2c_id` / `feedback_c2b_id`
 *     as soft references (no FK). The hard FK goes the other direction,
 *     from feedbacks.opportunity_id -> feedback_opportunities.id CASCADE,
 *     which avoids the circular dependency at table-creation time and
 *     still gives us cascading deletes.
 *   - `overall_rating` is constrained 1..5 via CHECK.
 *   - All steps are idempotent (hasTable guards + IF NOT EXISTS indexes)
 *     so the migration can be safely re-run on partially migrated envs.
 */

exports.up = async function (knex) {
  // ── feedback_opportunities ──────────────────────────────────────────────
  const hasOpportunities = await knex.schema.hasTable('feedback_opportunities');
  if (!hasOpportunities) {
    await knex.schema.createTable('feedback_opportunities', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));

      // trigger event descriptor
      t.string('opportunity_type', 50).notNullable();
      t.string('source_kind', 50).notNullable();
      t.uuid('source_id').notNullable();

      // relational context
      t.uuid('application_id').references('id').inTable('applications').onDelete('CASCADE');
      t.uuid('job_id').references('id').inTable('jobs').onDelete('SET NULL');
      t.uuid('candidate_id').references('id').inTable('candidates').onDelete('CASCADE');
      t.uuid('business_id').references('id').inTable('businesses').onDelete('CASCADE');

      // lifecycle
      t.enum('status', ['open', 'partial', 'published', 'expired', 'closed']).defaultTo('open');
      t.timestamp('opened_at').defaultTo(knex.fn.now());
      t.timestamp('review_deadline').notNullable();

      // soft refs to feedbacks (populated on submit)
      t.uuid('feedback_b2c_id');
      t.uuid('feedback_c2b_id');

      t.timestamps(true, true);

      t.unique(['source_kind', 'source_id'], {
        indexName: 'uq_feedback_opportunities_source',
      });
    });
  }

  // ── feedbacks ───────────────────────────────────────────────────────────
  const hasFeedbacks = await knex.schema.hasTable('feedbacks');
  if (!hasFeedbacks) {
    await knex.schema.createTable('feedbacks', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));

      t.uuid('opportunity_id')
        .notNullable()
        .references('id')
        .inTable('feedback_opportunities')
        .onDelete('CASCADE');

      t.enum('direction', ['business_to_candidate', 'candidate_to_business']).notNullable();

      t.uuid('author_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.enum('author_role', ['business', 'candidate']).notNullable();

      t.uuid('subject_id').notNullable().references('id').inTable('users').onDelete('CASCADE');
      t.enum('subject_role', ['business', 'candidate']).notNullable();

      // ratings
      t.integer('overall_rating').notNullable();
      t.jsonb('category_ratings');
      t.specificType('tags', 'text[]').defaultTo('{}');
      t.text('comment');

      // lifecycle
      t.enum('status', ['draft', 'submitted', 'published', 'removed', 'flagged']).defaultTo('draft');
      t.timestamp('editable_until');
      t.timestamp('submitted_at');
      t.timestamp('published_at');
      t.timestamp('last_edited_at');

      // moderation + anti-abuse
      t.jsonb('moderation');
      t.specificType('flags', 'jsonb[]').defaultTo('{}');
      t.boolean('auto_flagged').defaultTo(false);
      t.specificType('auto_flag_reasons', 'text[]').defaultTo('{}');

      t.timestamps(true, true);

      t.unique(['opportunity_id', 'direction'], {
        indexName: 'uq_feedbacks_opportunity_direction',
      });
    });

    // overall_rating bounds — enforce at DB level
    await knex.raw(
      `ALTER TABLE feedbacks
         ADD CONSTRAINT chk_feedbacks_overall_rating
         CHECK (overall_rating BETWEEN 1 AND 5)`
    );
  }

  // ── indexes ─────────────────────────────────────────────────────────────
  // feedback_opportunities
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_feedback_opportunities_status
       ON feedback_opportunities (status)`
  );
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_feedback_opportunities_deadline
       ON feedback_opportunities (review_deadline)`
  );
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_feedback_opportunities_application
       ON feedback_opportunities (application_id)`
  );
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_feedback_opportunities_candidate
       ON feedback_opportunities (candidate_id)`
  );
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_feedback_opportunities_business
       ON feedback_opportunities (business_id)`
  );

  // feedbacks
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_feedbacks_opportunity
       ON feedbacks (opportunity_id)`
  );
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_feedbacks_author
       ON feedbacks (author_id)`
  );
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_feedbacks_subject_status
       ON feedbacks (subject_id, status)`
  );
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_feedbacks_status
       ON feedbacks (status)`
  );
};

exports.down = async function (knex) {
  await knex.raw(`DROP INDEX IF EXISTS idx_feedbacks_status`);
  await knex.raw(`DROP INDEX IF EXISTS idx_feedbacks_subject_status`);
  await knex.raw(`DROP INDEX IF EXISTS idx_feedbacks_author`);
  await knex.raw(`DROP INDEX IF EXISTS idx_feedbacks_opportunity`);
  await knex.raw(`DROP INDEX IF EXISTS idx_feedback_opportunities_business`);
  await knex.raw(`DROP INDEX IF EXISTS idx_feedback_opportunities_candidate`);
  await knex.raw(`DROP INDEX IF EXISTS idx_feedback_opportunities_application`);
  await knex.raw(`DROP INDEX IF EXISTS idx_feedback_opportunities_deadline`);
  await knex.raw(`DROP INDEX IF EXISTS idx_feedback_opportunities_status`);

  await knex.schema.dropTableIfExists('feedbacks');
  await knex.schema.dropTableIfExists('feedback_opportunities');
};
