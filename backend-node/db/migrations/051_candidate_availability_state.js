/**
 * Availability Live — Phase AL.1 schema foundation.
 *
 * Adds four nullable columns to `candidates` so the next phases
 * can move the existing free-text `candidates.availability` (mig
 * 001-era) onto a structured, time-windowed model without
 * touching legacy data.
 *
 * New columns (all nullable, all additive):
 *
 *   candidates
 *     • availability_state         text (≤24 chars, app-enforced enum)
 *                                  Values:
 *                                    'now' | 'today' | 'tomorrow'
 *                                    | 'this_weekend' | 'evening_only'
 *                                    | 'full_time' | 'part_time' | NULL
 *                                  NULL = candidate has not opted into
 *                                  the structured availability surface.
 *     • availability_until         timestamp (UTC)
 *                                  Hard expiry for any non-`NULL` state.
 *                                  Business-side filters use
 *                                  `WHERE availability_until > now()`
 *                                  so an outdated `'now'` row naturally
 *                                  disappears from match lists without
 *                                  a cron job. AL.2 controller is
 *                                  responsible for setting this on
 *                                  every state update.
 *     • preferred_area_radius_km   int (default 10)
 *                                  Center = existing candidates.latitude
 *                                  / candidates.longitude (mig 005).
 *                                  Matching uses Haversine in JS for
 *                                  MVP; PostGIS migration is deferred.
 *     • last_active_at             timestamp (UTC, nullable)
 *                                  Heartbeat for the future
 *                                  "fast responder" metric. AL.1 only
 *                                  ADDS the column; no controller
 *                                  writes to it yet (wired in AL.2).
 *
 * Why enum-as-string instead of Postgres enum:
 *   Matches the project convention (mig 049 used `string('type', 16)`
 *   for the conversations type discriminator for the same reason —
 *   strings keep migrations reversible without an explicit type-drop
 *   on Postgres). App code is the source of truth for valid values.
 *
 * Legacy `candidates.availability` (free-text string) is INTENTIONALLY
 * LEFT IN PLACE — it still drives the onboarding step copy in
 * `onboarding_availability_view.dart`. AL.2 / AL.3 will treat the new
 * `availability_state` as the structured surface for the live
 * "Available Now" capability; legacy column stays untouched for
 * backward compat with any existing reader.
 *
 * Backwards compat: every existing candidate row keeps NULL on all
 * four new columns. The MVP filter "available now near you" naturally
 * excludes them (NULL fails any equality check) until they opt in via
 * the AL.3 candidate UI.
 *
 * Idempotent: every column add is guarded by a `hasColumn` probe
 * so the file is safe to re-run on a partially-applied dev DB.
 * Mirrors the pattern of mig 049 (conversations_group_chat) and
 * mig 050 (conversations_group_photo_url).
 */

exports.up = async function (knex) {
  const has = (col) => knex.schema.hasColumn('candidates', col);

  if (!(await has('availability_state'))) {
    await knex.schema.alterTable('candidates', (t) => {
      t.string('availability_state', 24).nullable();
    });
  }
  if (!(await has('availability_until'))) {
    await knex.schema.alterTable('candidates', (t) => {
      t.timestamp('availability_until').nullable();
    });
  }
  if (!(await has('preferred_area_radius_km'))) {
    await knex.schema.alterTable('candidates', (t) => {
      t.integer('preferred_area_radius_km').nullable().defaultTo(10);
    });
  }
  if (!(await has('last_active_at'))) {
    await knex.schema.alterTable('candidates', (t) => {
      t.timestamp('last_active_at').nullable();
    });
  }
};

exports.down = async function (knex) {
  for (const col of [
    'last_active_at',
    'preferred_area_radius_km',
    'availability_until',
    'availability_state',
  ]) {
    if (await knex.schema.hasColumn('candidates', col)) {
      await knex.schema.alterTable('candidates', (t) => {
        t.dropColumn(col);
      });
    }
  }
};
