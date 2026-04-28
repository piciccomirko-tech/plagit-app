/**
 * Step 1.3 — `job_boosts` history & audit.
 *
 * Every boost application — whether granted by an admin, paid via
 * credits, comped, or simulated in test mode — gets a row here. The
 * `jobs` table holds the *current* boost state (denormalized for fast
 * ranking queries); this table holds the *full timeline* for audit,
 * analytics, and admin debugging.
 *
 * One job can have many rows over time, but business logic enforces
 * that at most one row is in `status='active'` per job at any moment.
 * That invariant is checked in the service layer + cron, not via DB
 * partial-unique index, because Phase 2 may add overlapping bundles.
 *
 * `payment_id` and `credit_tx_id` are mutually exclusive — one of them
 * is set depending on `source`. Both are nullable so admin/comped/test
 * grants don't need a financial trace row.
 *
 * `notes` is free-form and used by admin grants to record the reason
 * (e.g. "compensation for outage 2026-04-25", "beta test seed").
 */

exports.up = async function (knex) {
  const hasTable = await knex.schema.hasTable('job_boosts');
  if (!hasTable) {
    await knex.schema.createTable('job_boosts', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));

      t.uuid('job_id').notNullable();
      t.uuid('business_id').notNullable();
      t.string('product_code', 50).notNullable(); // logical FK to job_products.code

      // Snapshot of the boost shape at grant time, so retroactive product
      // edits don't rewrite history.
      t.string('boost_type', 20).notNullable();
      t.integer('boost_priority').notNullable().defaultTo(0);

      t.timestamp('starts_at', { useTz: true }).notNullable().defaultTo(knex.fn.now());
      t.timestamp('ends_at', { useTz: true }).notNullable();

      // Lifecycle: active | expired | revoked
      t.string('status', 20).notNullable().defaultTo('active');

      // Attribution: 'admin' | 'credit' | 'comped' | 'test'
      // (Phase 2 adds 'stripe' | 'apple' | 'google'.)
      t.string('source', 20).notNullable();

      // Optional financial trace.
      t.uuid('payment_id');
      t.uuid('credit_tx_id');

      // Admin context.
      t.uuid('admin_user_id');
      t.text('notes');

      // For audit when revoked.
      t.timestamp('revoked_at', { useTz: true });
      t.text('revoke_reason');

      t.timestamps(true, true);
    });

    await knex.raw(
      `CREATE INDEX IF NOT EXISTS job_boosts_job_id_status_idx
         ON job_boosts (job_id, status)`
    );
    await knex.raw(
      `CREATE INDEX IF NOT EXISTS job_boosts_business_id_status_idx
         ON job_boosts (business_id, status)`
    );
    await knex.raw(
      `CREATE INDEX IF NOT EXISTS job_boosts_status_ends_at_idx
         ON job_boosts (status, ends_at)`
    );
  }
};

exports.down = async function (knex) {
  await knex.raw('DROP INDEX IF EXISTS job_boosts_status_ends_at_idx');
  await knex.raw('DROP INDEX IF EXISTS job_boosts_business_id_status_idx');
  await knex.raw('DROP INDEX IF EXISTS job_boosts_job_id_status_idx');
  await knex.schema.dropTableIfExists('job_boosts');
};
