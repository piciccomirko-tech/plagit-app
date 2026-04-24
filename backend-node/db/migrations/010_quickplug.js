/**
 * Migration 010: quickplug (legacy placeholder).
 *
 * The original migration was applied on dev/staging databases before this
 * repo was initialised. Its side effects (quickplug_swipes /
 * quickplug_matches tables) are already present on those databases, and
 * its row is already recorded in knex_migrations, so re-running it would
 * fail.
 *
 * We keep this file as an idempotent no-op stub so `knex migrate:latest`
 * does not report the migration directory as corrupt. On a fresh database
 * this stub creates the same tables the original migration produced.
 */

exports.up = async function (knex) {
  const hasSwipes = await knex.schema.hasTable('quickplug_swipes');
  if (!hasSwipes) {
    await knex.schema.createTable('quickplug_swipes', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('candidate_id').notNullable();
      t.uuid('job_id').notNullable();
      t.string('direction', 10).notNullable();
      t.timestamps(true, true);
      t.unique(['candidate_id', 'job_id']);
    });
  }

  const hasMatches = await knex.schema.hasTable('quickplug_matches');
  if (!hasMatches) {
    await knex.schema.createTable('quickplug_matches', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('candidate_id').notNullable();
      t.uuid('job_id').notNullable();
      t.timestamps(true, true);
      t.unique(['candidate_id', 'job_id']);
    });
  }
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('quickplug_matches');
  await knex.schema.dropTableIfExists('quickplug_swipes');
};
