/**
 * Mutual-interest matching infrastructure.
 *
 * Two new tables, both idempotent under repeated migration.
 *
 * 1. `quickplug_shortlists` — durable record of which candidates a
 *    business has expressed interest in via Quick Plug. We use this
 *    as a persistent intent flag so the apply-side flow can detect a
 *    pre-existing shortlist and trigger a mutual match without
 *    relying on notification rows as state.
 *
 *    Unique key (business_id, candidate_id) — repeated shortlisting
 *    is a no-op, not an error.
 *
 * 2. `mutual_matches` — created when BOTH sides have shown interest:
 *    business shortlisted the candidate AND the candidate applied to
 *    one of that business's jobs. Stays separate from the existing
 *    algorithm-driven `matches` table so the two never get conflated
 *    in queries or admin views.
 *
 *    Unique key (business_id, candidate_id, job_id) — exactly one
 *    mutual match per business / candidate / job triple, regardless
 *    of which side fired first.
 *
 *    Source columns track which surface produced each side of the
 *    interest, for analytics / admin attribution.
 */

exports.up = async function (knex) {
  const hasShortlists = await knex.schema.hasTable('quickplug_shortlists');
  if (!hasShortlists) {
    await knex.schema.createTable('quickplug_shortlists', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('business_id').notNullable();
      t.uuid('candidate_id').notNullable();
      t.string('source', 32).notNullable().defaultTo('quickplug');
      t.timestamps(true, true);
      t.unique(['business_id', 'candidate_id']);
      t.index(['candidate_id']);
    });
  }

  const hasMutual = await knex.schema.hasTable('mutual_matches');
  if (!hasMutual) {
    await knex.schema.createTable('mutual_matches', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('business_id').notNullable();
      t.uuid('candidate_id').notNullable();
      t.uuid('job_id').notNullable();
      t.string('source_business', 32).notNullable().defaultTo('quickplug');
      t.string('source_candidate', 32).notNullable().defaultTo('application');
      t.string('status', 16).notNullable().defaultTo('active');
      t.timestamps(true, true);
      t.unique(['business_id', 'candidate_id', 'job_id']);
      t.index(['business_id']);
      t.index(['candidate_id']);
    });
  }
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('mutual_matches');
  await knex.schema.dropTableIfExists('quickplug_shortlists');
};
