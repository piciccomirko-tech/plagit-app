/**
 * Idempotent stub for the candidate "save job" feature. The schema was
 * applied to the dev DB during an earlier PLAGIT_MASTER experiment; this
 * file restores the migration record on disk so `knex migrate:latest`
 * stops complaining about a corrupt directory. Re-runs are safe — the
 * `hasTable` guard skips when `job_saves` already exists.
 */
exports.up = async function (knex) {
  const has = await knex.schema.hasTable('job_saves');
  if (has) return;
  await knex.schema.createTable('job_saves', (t) => {
    t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
    t.uuid('candidate_id').notNullable()
      .references('id').inTable('candidates').onDelete('CASCADE');
    t.uuid('job_id').notNullable()
      .references('id').inTable('jobs').onDelete('CASCADE');
    t.timestamp('created_at', { useTz: true }).defaultTo(knex.fn.now());
    t.unique(['candidate_id', 'job_id']);
    t.index('candidate_id');
    t.index('job_id');
  });
};

exports.down = async function (knex) {
  const has = await knex.schema.hasTable('job_saves');
  if (!has) return;
  await knex.schema.dropTable('job_saves');
};
