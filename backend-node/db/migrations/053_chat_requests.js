/**
 * Stage AL.6.1 — Chat Request Gate / Mutual Chat Consent.
 *
 * Creates the `chat_requests` table. Before a normal Candidate ↔
 * Business conversation can open, the recipient must explicitly
 * Accept the request. Existing trusted contexts (shortlist →
 * applicant → urgent_request handoff) bypass the gate; they keep
 * calling the existing `startConversation` paths.
 *
 * Status lifecycle:
 *   pending  → accepted   (recipient Accept; conversation created/reused)
 *   pending  → denied     (recipient Deny; no conversation)
 *   pending  → cancelled  (requester Cancel; no conversation)
 *   pending  → expired    (lazy filter on read; `expires_at < NOW()`)
 *   Terminal states are immutable.
 *
 * Columns:
 *   • id                      UUID PK
 *   • candidate_id / business_id
 *                             FKs for fast pair lookups + admin joins
 *                             (mig 001 candidates / businesses tables)
 *   • requester_user_id       FK users.id — the initiator
 *   • requester_role          enum [candidate, business] — who tapped
 *                             "Message". Admin never reaches the gate.
 *   • recipient_user_id       FK users.id — the gatekeeper
 *   • recipient_role          enum [candidate, business]
 *   • status                  enum [pending, accepted, denied,
 *                             cancelled, expired] default 'pending'
 *   • conversation_id         FK conversations.id NULLABLE — populated
 *                             on accept (find-or-create). SET NULL on
 *                             conversation delete so the chat_request
 *                             row stays as audit evidence.
 *   • message                 text NULLABLE — optional opener
 *                             (cap enforced at controller, not DB)
 *   • responded_at            timestamptz NULLABLE — set on
 *                             accept/deny/cancel
 *   • expires_at              timestamptz NOT NULL — created_at + 7d
 *                             (controller computes server-side)
 *   • timestamps              Knex created_at / updated_at
 *
 * Indexes:
 *   • (recipient_user_id, status)   "my incoming"
 *   • (requester_user_id, status)   "my outgoing"
 *   • (candidate_id, business_id, status)
 *                                   pair lookups + cooldown checks
 *   • expires_at                    future cron / lazy scan
 *   • PARTIAL UNIQUE on
 *     (candidate_id, business_id) WHERE status='pending'
 *                                   enforces "one pending per pair"
 *                                   regardless of requester role —
 *                                   if both sides try to request
 *                                   simultaneously, one wins, the
 *                                   second sees 409. Many terminal-
 *                                   state historical rows OK.
 *
 * Notifications: AL.6.1 ships SCHEMA + ENDPOINTS ONLY (no notification
 * fanout per Mirko's decision #3 silent deny + decision #7 admin
 * audit deferred). AL.6.2 will add the catalog entries + fanout in
 * a separate commit.
 *
 * Idempotent: `hasTable` probe guards createTable so the file is
 * safe to re-run on a partially-applied dev DB. Mirrors mig 052
 * (urgent_requests) chrome exactly.
 */

exports.up = async function (knex) {
  const exists = await knex.schema.hasTable('chat_requests');
  if (!exists) {
    await knex.schema.createTable('chat_requests', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('candidate_id').notNullable()
        .references('id').inTable('candidates').onDelete('CASCADE');
      t.uuid('business_id').notNullable()
        .references('id').inTable('businesses').onDelete('CASCADE');
      t.uuid('requester_user_id').notNullable()
        .references('id').inTable('users').onDelete('CASCADE');
      t.enum('requester_role', ['candidate', 'business']).notNullable();
      t.uuid('recipient_user_id').notNullable()
        .references('id').inTable('users').onDelete('CASCADE');
      t.enum('recipient_role', ['candidate', 'business']).notNullable();
      t.enum('status', [
        'pending', 'accepted', 'denied', 'cancelled', 'expired',
      ]).notNullable().defaultTo('pending');
      t.uuid('conversation_id')
        .references('id').inTable('conversations').onDelete('SET NULL');
      t.text('message');
      t.timestamp('responded_at', { useTz: true });
      t.timestamp('expires_at', { useTz: true }).notNullable();
      t.timestamps(true, true);
    });

    await knex.schema.alterTable('chat_requests', (t) => {
      t.index(['recipient_user_id', 'status'], 'idx_chat_requests_recipient_status');
      t.index(['requester_user_id', 'status'], 'idx_chat_requests_requester_status');
      t.index(['candidate_id', 'business_id', 'status'], 'idx_chat_requests_pair_status');
      t.index('expires_at', 'idx_chat_requests_expires');
    });

    // Partial unique index — only ONE pending row per (candidate,
    // business) pair, regardless of requester role. Many terminal-
    // state rows accumulate as audit history without conflict.
    // Knex doesn't ship a partial-unique helper, so raw SQL.
    await knex.raw(
      `CREATE UNIQUE INDEX uniq_chat_requests_pair_pending
       ON chat_requests (candidate_id, business_id)
       WHERE status = 'pending'`,
    );
  }
};

exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('chat_requests');
};
