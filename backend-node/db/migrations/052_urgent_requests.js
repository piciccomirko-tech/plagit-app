/**
 * Availability Live — Phase AL.5.1 schema foundation.
 *
 * Creates the `urgent_requests` table — businesses' time-windowed
 * "Need staff today" posts. Distinct from `jobs` (long-term
 * recruiting): urgent_requests have hour-level start/end times,
 * a fast lifecycle (open → filled/expired in hours, not weeks),
 * and a tap-to-respond UX that hands off to chat instead of an
 * `applications` row.
 *
 * Columns:
 *   • id                       UUID primary key
 *   • business_id              FK → businesses.id, CASCADE on
 *                              business delete (no orphan posts)
 *   • role                     varchar(100) — "Bartender",
 *                              "Waiter", "Kitchen Porter", etc.
 *                              Free-text for now; locale-aware
 *                              matching deferred to a future sprint.
 *                              Matched case-insensitively against
 *                              candidates.role / primary_role in
 *                              AL.5.3.
 *   • location                 text — free-text fallback when no
 *                              geo (e.g. "Milan, near central").
 *                              Defaults pulled from business row on
 *                              create (AL.5.2 controller).
 *   • latitude / longitude     float — optional, copied from
 *                              businesses.{latitude, longitude}
 *                              (mig 005) at create time. Powers
 *                              haversine matching on the candidate
 *                              side when both sides have coords.
 *   • starts_at                timestamptz NOT NULL — when the
 *                              shift begins. Server validates
 *                              starts_at >= NOW() at create time
 *                              (small clock-skew tolerance applied
 *                              in the AL.5.2 controller).
 *   • ends_at                  timestamptz NULL — when the shift
 *                              ends. NULL means "open-ended that
 *                              day"; AL.5.3 caps NULL-ends_at
 *                              requests visibility window at 24h
 *                              after starts_at.
 *   • notes                    text NULL — "Friendly venue, no
 *                              experience needed". Capped to 500
 *                              chars at the controller level.
 *   • status                   enum [open|filled|expired|cancelled]
 *                              default 'open'. AL.5.1 only writes
 *                              'open' on create; later phases flip
 *                              to filled / cancelled, and a future
 *                              cron (or lazy check on read) marks
 *                              'expired' once expires_at passes.
 *   • expires_at               timestamptz NOT NULL — server-
 *                              computed at INSERT as `(ends_at OR
 *                              starts_at) + 4h grace`. Hard cutoff
 *                              for visibility on the candidate
 *                              side: `WHERE expires_at > NOW()`.
 *                              4h grace covers shift overrun and
 *                              tardy candidate replies without
 *                              keeping stale posts live overnight.
 *   • filled_by_candidate_id   UUID NULL — FK to candidates.id,
 *                              SET NULL on candidate delete.
 *                              Populated by AL.6 when a candidate
 *                              accepts via chat handoff. AL.5.1
 *                              defines the column but no
 *                              controller writes to it yet (column
 *                              exists from day one so the AL.6
 *                              wiring doesn't need a follow-up
 *                              migration during a deploy window).
 *   • created_at / updated_at  Knex timestamps(true, true).
 *
 * Indexes:
 *   • (status, expires_at)
 *     Hot path on candidate-side GET: "find open + non-expired
 *     urgent requests." Composite avoids a full table scan in
 *     fallback mode where no role/geo filter narrows the set.
 *   • (business_id, status)
 *     Hot path on business-side GET: "my open urgent requests."
 *     Sorted listing for the dashboard section.
 *
 * Status enum vs string:
 *   Knex `.enum()` produces a check constraint on Postgres, which
 *   matches the existing `jobs.status` / `applications.status`
 *   pattern (mig 001). Reversible on rollback without an explicit
 *   type-drop. App-level validation in AL.5.2 doubles as a guard
 *   against typos.
 *
 * Backwards compat: this is a brand-new table. Pre-mig deploys
 * simply 503 from any endpoint that calls
 * `isUrgentRequestsTablePresent()` (added in the same commit).
 *
 * Idempotent: `hasTable` probe guards the createTable so the
 * file is safe to re-run on a partially-applied dev DB. Mirrors
 * the pattern of recent migrations (049 / 050 / 051).
 *
 * Out of AL.5.1 scope (intentionally NOT added):
 *   • urgent_responses table — chat handoff IS the response
 *     (AL.5.6), no audit-trail row needed for MVP.
 *   • role taxonomy / locale-aware matching — see R12 in plan.
 *   • PostGIS / geo index — haversine in JS is fine at this
 *     scale; revisit at 10k+ urgent_requests rows.
 *   • Quota / credit columns — Premium gate (if any) lives on
 *     the controller, not the row.
 */

exports.up = async function (knex) {
  const exists = await knex.schema.hasTable('urgent_requests');
  if (!exists) {
    await knex.schema.createTable('urgent_requests', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('business_id').notNullable()
        .references('id').inTable('businesses').onDelete('CASCADE');
      t.string('role', 100).notNullable();
      t.text('location');
      t.float('latitude');
      t.float('longitude');
      t.timestamp('starts_at', { useTz: true }).notNullable();
      t.timestamp('ends_at', { useTz: true });
      t.text('notes');
      t.enum('status', ['open', 'filled', 'expired', 'cancelled'])
        .notNullable().defaultTo('open');
      t.timestamp('expires_at', { useTz: true }).notNullable();
      t.uuid('filled_by_candidate_id')
        .references('id').inTable('candidates').onDelete('SET NULL');
      t.timestamps(true, true);
    });
    // Composite indexes — see header for rationale.
    await knex.schema.alterTable('urgent_requests', (t) => {
      t.index(['status', 'expires_at'], 'idx_urgent_requests_status_expires');
      t.index(['business_id', 'status'], 'idx_urgent_requests_business_status');
    });
  }
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('urgent_requests');
};
