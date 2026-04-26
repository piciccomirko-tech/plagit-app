/**
 * Add a `cv_visible_to_businesses` privacy flag to `candidates`.
 *
 * Until now `cv_url` was either set or null with no granular consent —
 * a candidate uploading a CV implicitly opted in. The Business Quick
 * Plug mini profile now exposes a "View CV" row, so we need an explicit
 * gate the candidate can toggle without deleting the file. Defaults to
 * TRUE so existing rows keep working; candidates can opt out from their
 * privacy settings.
 *
 * The `quickplugDeck` controller filters `cv_url` out when this flag is
 * false, so the Flutter side only ever sees a non-null cv_url for
 * candidates who consented.
 */
exports.up = async function (knex) {
  const has = await knex.schema.hasColumn(
    'candidates',
    'cv_visible_to_businesses',
  );
  if (has) return;
  await knex.schema.alterTable('candidates', (t) => {
    t.boolean('cv_visible_to_businesses').notNullable().defaultTo(true);
  });
};

exports.down = async function (knex) {
  const has = await knex.schema.hasColumn(
    'candidates',
    'cv_visible_to_businesses',
  );
  if (!has) return;
  await knex.schema.alterTable('candidates', (t) => {
    t.dropColumn('cv_visible_to_businesses');
  });
};
