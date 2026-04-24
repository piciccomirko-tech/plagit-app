/**
 * Migration 010: multi-role system.
 *
 * Adds primary/additional role columns to candidates, businesses, and jobs,
 * and backfills the new primary fields from whichever legacy column holds a
 * real role value — NOT necessarily the column with a similar name.
 *
 * Backfill sources:
 *   candidates.primary_role     <- candidates.role          (role -> role)
 *   businesses.main_role_needed <- businesses.required_role (role -> role)
 *   jobs.main_role_needed       <- jobs.title               (title -> role)
 *
 * Why `jobs.title` and NOT `jobs.category`:
 *   jobs.category today stores VENUE TYPE (e.g. 'Fine Dining', 'Luxury
 *   Hotel', 'Nightclub'), not the hiring role. jobs.title is where the
 *   actual role lives per row (e.g. 'Senior Chef', 'Bar Manager',
 *   'Sommelier'). Backfilling from category would poison the matching
 *   layer with venue-type values.
 *
 * Title values are trimmed and capped at 100 chars (defensive — the column
 * is VARCHAR(100)); empty/null titles leave main_role_needed NULL so the
 * owner can re-enter the role on next edit.
 *
 * Legacy columns (role, required_role, category) are intentionally kept
 * for 2 releases to support dual-read / dual-write in the API. A later
 * migration will drop them.
 *
 * All steps are idempotent (guarded by hasColumn / IF NOT EXISTS) so the
 * migration can safely be re-run on partially migrated environments.
 */

exports.up = async function (knex) {
  // ── candidates ──────────────────────────────────────────────────────────
  const hasCandPrimary = await knex.schema.hasColumn('candidates', 'primary_role');
  if (!hasCandPrimary) {
    await knex.schema.alterTable('candidates', (t) => {
      t.string('primary_role', 100);
      t.specificType('additional_roles', 'text[]').defaultTo('{}');
    });
    await knex.raw(
      `UPDATE candidates
         SET primary_role = role
       WHERE role IS NOT NULL
         AND primary_role IS NULL`
    );
  }

  // ── businesses ──────────────────────────────────────────────────────────
  const hasBizMain = await knex.schema.hasColumn('businesses', 'main_role_needed');
  if (!hasBizMain) {
    await knex.schema.alterTable('businesses', (t) => {
      t.string('main_role_needed', 100);
      t.specificType('additional_roles_needed', 'text[]').defaultTo('{}');
    });
    await knex.raw(
      `UPDATE businesses
         SET main_role_needed = required_role
       WHERE required_role IS NOT NULL
         AND main_role_needed IS NULL`
    );
  }

  // ── jobs ────────────────────────────────────────────────────────────────
  const hasJobMain = await knex.schema.hasColumn('jobs', 'main_role_needed');
  if (!hasJobMain) {
    await knex.schema.alterTable('jobs', (t) => {
      t.string('main_role_needed', 100);
      t.specificType('additional_roles_needed', 'text[]').defaultTo('{}');
    });
    await knex.raw(
      `UPDATE jobs
         SET main_role_needed = LEFT(TRIM(title), 100)
       WHERE title IS NOT NULL
         AND TRIM(title) <> ''
         AND main_role_needed IS NULL`
    );
  }

  // ── GIN indexes for array overlap / ANY lookups ─────────────────────────
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_candidates_additional_roles
       ON candidates USING GIN (additional_roles)`
  );
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_businesses_additional_roles_needed
       ON businesses USING GIN (additional_roles_needed)`
  );
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_jobs_additional_roles_needed
       ON jobs USING GIN (additional_roles_needed)`
  );

  // ── btree indexes on single-value columns for equality matching ─────────
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_candidates_primary_role
       ON candidates (primary_role)`
  );
  await knex.raw(
    `CREATE INDEX IF NOT EXISTS idx_jobs_main_role_needed
       ON jobs (main_role_needed)`
  );
};

exports.down = async function (knex) {
  await knex.raw(`DROP INDEX IF EXISTS idx_candidates_primary_role`);
  await knex.raw(`DROP INDEX IF EXISTS idx_jobs_main_role_needed`);
  await knex.raw(`DROP INDEX IF EXISTS idx_candidates_additional_roles`);
  await knex.raw(`DROP INDEX IF EXISTS idx_businesses_additional_roles_needed`);
  await knex.raw(`DROP INDEX IF EXISTS idx_jobs_additional_roles_needed`);

  const hasJobMain = await knex.schema.hasColumn('jobs', 'main_role_needed');
  if (hasJobMain) {
    await knex.schema.alterTable('jobs', (t) => {
      t.dropColumn('main_role_needed');
      t.dropColumn('additional_roles_needed');
    });
  }

  const hasBizMain = await knex.schema.hasColumn('businesses', 'main_role_needed');
  if (hasBizMain) {
    await knex.schema.alterTable('businesses', (t) => {
      t.dropColumn('main_role_needed');
      t.dropColumn('additional_roles_needed');
    });
  }

  const hasCandPrimary = await knex.schema.hasColumn('candidates', 'primary_role');
  if (hasCandPrimary) {
    await knex.schema.alterTable('candidates', (t) => {
      t.dropColumn('primary_role');
      t.dropColumn('additional_roles');
    });
  }
};
