/**
 * Voice + Video calls — backing table for the WebRTC P2P MVP.
 *
 * Step A scope: backend foundation only. The signaling/SSE wiring,
 * Flutter CallRepository, and WebRTC UI are intentionally NOT in this
 * step. This file just adds the `calls` table so the four REST
 * endpoints (initiate, accept, decline, end) have a place to persist
 * call state.
 *
 * Shape mirrors the additive + idempotent style of 031/035-040/041 —
 * every CREATE is guarded so the file is safe to re-run on a partially
 * applied dev DB, and `down()` removes only what we add.
 *
 * Schema rationale:
 *
 *   • id (uuid pk) — gen_random_uuid() default so the API can echo it
 *     back in the initiate response without an extra round trip.
 *
 *   • conversation_id — FK to `conversations` with ON DELETE CASCADE.
 *     Calls only make sense inside a conversation, and if the convo is
 *     hard-deleted (admin / GDPR purge) the call history goes with it.
 *
 *   • caller_id / callee_id — FK to `users.id` (NOT candidates.id /
 *     businesses.id). Calls are user↔user; tying them to role
 *     profiles would create ambiguity if we ever let an account hold
 *     more than one role. ON DELETE SET NULL so a closed account
 *     doesn't nuke the history.
 *
 *   • type — 'audio' | 'video'. varchar(10) instead of t.enum so we
 *     can add 'screen_share' later without an ALTER TYPE dance (same
 *     reason `messages.attachment_type` uses varchar — see migration
 *     031).
 *
 *   • status — state machine. Allowed values enforced in the
 *     controller (see callController.STATE_MACHINE). Storing the
 *     transitions in app code, not the DB, lets us tweak rules
 *     without a schema migration.
 *       ringing  → initial state, set by initiate
 *       accepted → callee picked up
 *       declined → callee explicitly rejected
 *       missed   → caller cancelled before accept (or auto-timeout)
 *       ended    → either side hung up after accept
 *       failed   → technical failure (TURN/STUN/ICE)
 *
 *   • started_at / accepted_at / ended_at — timeline anchors. All
 *     nullable except started_at (initiate fills it). The controller
 *     stamps accepted_at on transition → accepted and ended_at on
 *     transition → any terminal state.
 *
 *   • duration_s — denormalised once the call ends. Computed as
 *     ended_at − accepted_at (zero if the call never connected).
 *     Stored explicitly so the chat list / call-log bubble can render
 *     "2:14" without recomputing on every read.
 *
 *   • created_at / updated_at — managed by t.timestamps(true, true).
 *
 * Indexes:
 *   • conversation_id — call history lookup per chat (hot path: the
 *     in-chat call_log_bubble fetches "last N calls in this convo").
 *   • caller_id, callee_id — "my call history" lookups from settings.
 *   • status — admin dashboards / metrics ("failed call rate today").
 *   • created_at — pagination / chronological sort.
 *
 * Backwards compat: there are no Sprint-1 readers yet (this is the
 * first migration that introduces the table) so no schemaFeatureFlags
 * probe is required for the deploy → migrate window. Once a runtime
 * reader exists (Step B+), add a `isCallsTablePresent()` probe like
 * `isAlbumColumnPresent` so the request handlers can degrade
 * gracefully during the next deploy.
 */

exports.up = async function (knex) {
  const exists = await knex.schema.hasTable('calls');
  if (!exists) {
    await knex.schema.createTable('calls', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));

      t.uuid('conversation_id').notNullable()
        .references('id').inTable('conversations').onDelete('CASCADE');

      t.uuid('caller_id').notNullable()
        .references('id').inTable('users').onDelete('SET NULL');
      t.uuid('callee_id').notNullable()
        .references('id').inTable('users').onDelete('SET NULL');

      t.string('type', 10).notNullable().defaultTo('audio');
      t.string('status', 20).notNullable().defaultTo('ringing');

      t.timestamp('started_at').notNullable().defaultTo(knex.fn.now());
      t.timestamp('accepted_at').nullable();
      t.timestamp('ended_at').nullable();
      t.integer('duration_s').notNullable().defaultTo(0);

      t.timestamps(true, true);
    });

    // Indexes — created outside createTable so we can name them
    // explicitly and re-run idempotently later if a column is added.
    await knex.schema.alterTable('calls', (t) => {
      t.index('conversation_id', 'calls_conversation_id_idx');
      t.index('caller_id',       'calls_caller_id_idx');
      t.index('callee_id',       'calls_callee_id_idx');
      t.index('status',          'calls_status_idx');
      t.index('created_at',      'calls_created_at_idx');
    });
  }
};

exports.down = async function (knex) {
  // dropTableIfExists is enough — Postgres drops the FKs and indexes
  // automatically when the table goes. Keep this defensive so rerun
  // on a partially-rolled-back dev DB is a no-op.
  await knex.schema.dropTableIfExists('calls');
};
