/**
 * WebRTC signaling foundation — backing table for SDP offer / answer
 * exchange and ICE candidate trickling (Step E1).
 *
 * The signaling channel is *ephemeral by nature*: an offer/answer is
 * useful only during the ~1-3s handshake window, and ICE candidates
 * stop mattering once the peer connection is established. Storing
 * these in a dedicated table (rather than as JSONB columns on
 * `calls`) keeps the `calls` table lean for read-heavy paths
 * (chat history, call_log_bubble in Step G) and lets ICE arrive as
 * one row per batch instead of growing an unbounded JSONB array.
 *
 * Schema:
 *
 *   • id (uuid pk) — gen_random_uuid() default.
 *
 *   • call_id — FK to `calls` with ON DELETE CASCADE. When a call is
 *     hard-deleted (admin purge, conversation drop) the signaling
 *     trail goes with it automatically. No orphans.
 *
 *   • sender_user_id — FK to `users.id`. SET NULL on user delete so
 *     a closed account doesn't nuke the row (matches `calls.caller_id`
 *     policy from migration 043).
 *
 *   • kind — discriminator. varchar(10) (not enum) so we can add
 *     `renegotiate` / `restart` later without an ALTER TYPE dance,
 *     same precedent as `messages.attachment_type`.
 *
 *   • payload — JSONB. Shape varies by kind:
 *
 *       kind='offer'  → { sdp: string, sdpType: 'offer' }
 *       kind='answer' → { sdp: string, sdpType: 'answer' }
 *       kind='ice'    → { candidates: [{ candidate, sdpMid, sdpMLineIndex }, …] }
 *
 *     JSONB chosen over per-field columns so future WebRTC fields
 *     (DTLS fingerprints, fmtp params, datachannel descriptors) can
 *     land without a migration. The application layer is the source
 *     of truth for the shape contract.
 *
 *   • created_at — used both for sort ("replay signaling history in
 *     order") and for the opportunistic TTL cleanup that runs inline
 *     on every signal POST.
 *
 * Indexes:
 *
 *   • call_signals_call_id_idx — hot path: fetch all signals for a
 *     given call in chronological order (replay on reconnect, deferred
 *     to E2).
 *
 *   • call_signals_call_id_kind_idx — pattern: "does an offer already
 *     exist for this call?" (used by the offer/answer handlers to
 *     enforce the state machine: no double-offer, no answer-before-
 *     offer).
 *
 *   • call_signals_created_at_idx — supports the TTL cleanup DELETE.
 *
 * Backwards compat: zero. This is the first migration that touches
 * call_signals — no readers exist yet, so no schemaFeatureFlags probe
 * is needed for the deploy → migrate window. Add an
 * `isCallSignalsTablePresent()` flag in E2 when the Flutter side
 * starts reading.
 */

exports.up = async function (knex) {
  const exists = await knex.schema.hasTable('call_signals');
  if (!exists) {
    await knex.schema.createTable('call_signals', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));

      t.uuid('call_id').notNullable()
        .references('id').inTable('calls').onDelete('CASCADE');

      t.uuid('sender_user_id')
        .references('id').inTable('users').onDelete('SET NULL');

      t.string('kind', 10).notNullable();
      t.jsonb('payload').notNullable();

      t.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
    });

    // Indexes named explicitly so they can be added/dropped
    // independently in future migrations without ambiguity.
    await knex.schema.alterTable('call_signals', (t) => {
      t.index('call_id',           'call_signals_call_id_idx');
      t.index(['call_id', 'kind'], 'call_signals_call_id_kind_idx');
      t.index('created_at',        'call_signals_created_at_idx');
    });
  }
};

exports.down = async function (knex) {
  // dropTableIfExists is enough — Postgres drops the FKs and indexes
  // automatically. Defensive guard so a partially-rolled-back dev DB
  // can re-run this without error.
  await knex.schema.dropTableIfExists('call_signals');
};
