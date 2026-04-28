/**
 * Step 3 — Activation flow schema additions.
 *
 * Two changes, both additive and idempotent:
 *
 *  1. `job_products.credits_cost` — how many wallet credits a Phase-1
 *     business pays to redeem this product. Stored on the catalog (not
 *     hardcoded in code) so prices/admins can change costs from the
 *     seed/admin UI without a code deploy. Default 1: any product not
 *     explicitly priced costs a single credit, which is a safe floor.
 *
 *  2. `job_boosts` — partial UNIQUE index on (job_id) WHERE status='active'.
 *     Hard guarantee that at most one ACTIVE boost per job exists at a
 *     time, regardless of how the service layer is invoked (concurrent
 *     admin + business activations on the same job race to the index
 *     and the loser gets a Postgres constraint error, which the service
 *     converts to 409 BOOST_ALREADY_ACTIVE). Originally migration 025
 *     deliberately deferred this for "future bundle overlap"; per
 *     Mirko's Step 3 decision we now lock the rule for Phase 1.
 */

exports.up = async function (knex) {
  // 1. credits_cost on job_products
  const hasCreditsCost = await knex.schema.hasColumn('job_products', 'credits_cost');
  if (!hasCreditsCost) {
    await knex.schema.alterTable('job_products', (t) => {
      // INTEGER NOT NULL DEFAULT 1.
      // Existing rows backfill to 1; seed 008 then overrides with the
      // approved table (urgent_24h=1, urgent_3d=2, …).
      t.integer('credits_cost').notNullable().defaultTo(1);
    });
  }

  // 2. Partial UNIQUE index — at most one active boost per job.
  //    `IF NOT EXISTS` keeps the migration idempotent if it ever runs
  //    twice on the same DB (e.g. local re-runs after rollback testing).
  await knex.raw(
    `CREATE UNIQUE INDEX IF NOT EXISTS job_boosts_one_active_per_job_idx
       ON job_boosts (job_id) WHERE status = 'active'`
  );
};

exports.down = async function (knex) {
  await knex.raw('DROP INDEX IF EXISTS job_boosts_one_active_per_job_idx');

  const hasCreditsCost = await knex.schema.hasColumn('job_products', 'credits_cost');
  if (hasCreditsCost) {
    await knex.schema.alterTable('job_products', (t) => {
      t.dropColumn('credits_cost');
    });
  }
};
