/**
 * Migration 014: business profile public-facing fields.
 *
 * Adds two nullable columns to `businesses`:
 *   - about   (text)   — company bio / description shown on public profile.
 *   - website (string) — optional website URL surfaced on public profile.
 *
 * Defensive hasColumn check keeps the migration idempotent so it is safe
 * to re-run on environments that partially got the columns already.
 */
exports.up = async function (knex) {
  const hasAbout = await knex.schema.hasColumn('businesses', 'about');
  if (!hasAbout) {
    await knex.schema.alterTable('businesses', (t) => {
      t.text('about');
    });
  }

  const hasWebsite = await knex.schema.hasColumn('businesses', 'website');
  if (!hasWebsite) {
    await knex.schema.alterTable('businesses', (t) => {
      t.string('website');
    });
  }
};

exports.down = async function (knex) {
  const hasWebsite = await knex.schema.hasColumn('businesses', 'website');
  if (hasWebsite) {
    await knex.schema.alterTable('businesses', (t) => {
      t.dropColumn('website');
    });
  }

  const hasAbout = await knex.schema.hasColumn('businesses', 'about');
  if (hasAbout) {
    await knex.schema.alterTable('businesses', (t) => {
      t.dropColumn('about');
    });
  }
};
