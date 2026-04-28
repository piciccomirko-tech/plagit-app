/**
 * Step 1.1 — Boost columns on `jobs`.
 *
 * Additive only. Every column is nullable or has a safe default so that
 * existing rows (and any code path that ignores boost) keep working
 * unchanged. The boost engine treats `boost_status='none'` as "no boost",
 * which is the implicit state of every legacy job after this migration.
 *
 * Columns:
 *   boost_type         current product family applied to the job
 *                      ('urgent' | 'top' | 'featured' | NULL)
 *   boost_priority     numeric weight feeding the ranking formula (0..100)
 *   boost_starts_at    when the active boost window opened
 *   boost_ends_at      when the active boost window closes (cron expires it)
 *   boost_status       lifecycle: 'none' | 'active' | 'expired' | 'revoked'
 *   boost_source       attribution: 'admin' | 'credit' | 'comped' | 'test'
 *                      (Phase 2 will add 'stripe' | 'apple' | 'google'
 *                       without a migration — column is plain varchar.)
 *   visibility_score   precomputed score (matchScore baseline + boost weight)
 *                      refreshed by cron, used to keep list queries fast.
 *   boost_product_id   logical FK to job_products.code (no DB constraint —
 *                      products may be retired without nuking history).
 *
 * Indexes:
 *   (boost_status, boost_ends_at) — drives the cron expiry sweep
 *   (boost_status, boost_priority DESC) — drives list ranking queries
 *
 * NOTE: legacy `is_urgent` (added in migration 009) is intentionally LEFT
 * IN PLACE. It still works for old rows and for the legacy free toggle.
 * The new boost engine does NOT read `is_urgent` — it reads `boost_type`.
 * Removing the legacy free path is a Flutter UI concern, not a DB one.
 */

exports.up = async function (knex) {
  const hasBoostType = await knex.schema.hasColumn('jobs', 'boost_type');
  if (!hasBoostType) {
    await knex.schema.alterTable('jobs', (t) => {
      t.string('boost_type', 20);
      t.integer('boost_priority').notNullable().defaultTo(0);
      t.timestamp('boost_starts_at', { useTz: true });
      t.timestamp('boost_ends_at', { useTz: true });
      t.string('boost_status', 20).notNullable().defaultTo('none');
      t.string('boost_source', 20);
      t.integer('visibility_score').notNullable().defaultTo(0);
      t.string('boost_product_id', 50);
    });
  }

  // Indexes are created separately so the migration is rerunnable even if
  // an earlier partial run already added the columns.
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS jobs_boost_status_ends_at_idx
       ON jobs (boost_status, boost_ends_at)`
  );
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS jobs_boost_status_priority_idx
       ON jobs (boost_status, boost_priority DESC)`
  );
};

exports.down = async function (knex) {
  await knex.raw('DROP INDEX IF EXISTS jobs_boost_status_priority_idx');
  await knex.raw('DROP INDEX IF EXISTS jobs_boost_status_ends_at_idx');

  const hasBoostType = await knex.schema.hasColumn('jobs', 'boost_type');
  if (hasBoostType) {
    await knex.schema.alterTable('jobs', (t) => {
      t.dropColumn('boost_product_id');
      t.dropColumn('visibility_score');
      t.dropColumn('boost_source');
      t.dropColumn('boost_status');
      t.dropColumn('boost_ends_at');
      t.dropColumn('boost_starts_at');
      t.dropColumn('boost_priority');
      t.dropColumn('boost_type');
    });
  }
};
