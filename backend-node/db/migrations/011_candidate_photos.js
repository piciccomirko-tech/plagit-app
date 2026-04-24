/**
 * Migration 011: candidate photos (legacy placeholder).
 *
 * The original migration was applied on dev/staging databases before this
 * repo was initialised. Its side effects are already present on those
 * databases, and its row is already recorded in knex_migrations.
 *
 * We keep this file as an idempotent no-op stub so `knex migrate:latest`
 * does not report the migration directory as corrupt. On a fresh database
 * this stub creates the same table the original migration produced.
 */

exports.up = async function (knex) {
  const hasTable = await knex.schema.hasTable('candidate_photos');
  if (!hasTable) {
    await knex.schema.createTable('candidate_photos', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('candidate_id').notNullable();
      t.text('photo_url').notNullable();
      t.integer('sort_order').defaultTo(0);
      t.timestamps(true, true);
    });
  }
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('candidate_photos');
};
