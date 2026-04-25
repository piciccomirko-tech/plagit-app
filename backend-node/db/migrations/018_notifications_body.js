/**
 * Add a free-text `body` column to `notifications`.
 *
 * Existing rows have only a `title` (e.g. "New match: Waiter at Nobu"),
 * forcing the admin UI to fall back to "For {recipient_name}" as the
 * subtitle. The job-publish notification needs a real subtitle like
 * "Waiter · Mayfair, London · $25/hr" — this column carries it without
 * polluting the title.
 *
 * Nullable so legacy rows keep working. Flutter `AdminNotification`
 * already reads `json['body']` first and falls back to the recipient
 * name — no client migration needed.
 */
exports.up = async function (knex) {
  const has = await knex.schema.hasColumn('notifications', 'body');
  if (has) return;
  await knex.schema.alterTable('notifications', (t) => {
    t.text('body').nullable();
  });
};

exports.down = async function (knex) {
  const has = await knex.schema.hasColumn('notifications', 'body');
  if (!has) return;
  await knex.schema.alterTable('notifications', (t) => {
    t.dropColumn('body');
  });
};
