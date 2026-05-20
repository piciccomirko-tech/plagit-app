/**
 * Group Chats — extends `conversations` with a type discriminator +
 * group-only display fields, and introduces a membership table so
 * conversations can carry 2..N participants.
 *
 * Schema additions (additive, idempotent):
 *
 *   conversations
 *     • type                 enum-as-string ('1v1' | 'group'), default '1v1'
 *     • name                 text (nullable) — group display name, null on 1:1
 *     • avatar_hue           float (nullable) — color-hash avatar fallback
 *     • created_by_user_id   uuid FK → users.id (nullable) — group creator
 *
 *   conversation_members (NEW)
 *     • id                   uuid PK
 *     • conversation_id      uuid FK → conversations.id (CASCADE)
 *     • user_id              uuid FK → users.id (CASCADE)
 *     • role                 'admin' | 'member', default 'member'
 *     • joined_at            timestamp, default now()
 *     • last_read_at         timestamp (nullable) — per-user read cursor
 *                            (replaces messages.is_read for groups; 1:1 keeps
 *                             its existing single-boolean semantics)
 *     • left_at              timestamp (nullable) — soft-delete for "I left"
 *     • UNIQUE(conversation_id, user_id)
 *     • INDEX(user_id) — for "list my conversations" queries
 *
 * Why per-user `last_read_at` instead of a `message_read_receipts`
 * sidecar table:
 *   • One row per (user, conversation) regardless of message count —
 *     write volume is O(read events), not O(messages × members).
 *   • Unread count is a single COUNT(*) of messages with
 *     created_at > member.last_read_at, no JOIN explosion.
 *   • Per-message receipt UI ("seen by Elena, Nobu, …") can be added
 *     later via a real receipt table without changing this schema.
 *
 * Backwards compat: every 1:1 conversation existing today keeps its
 * candidate_id/business_id pair AND defaults to type='1v1'. Group
 * conversations leave candidate_id/business_id NULL — the controller
 * code branches on `type` to decide which membership model to use.
 *
 * Idempotent: every column add / table create is guarded by a
 * hasColumn / hasTable probe so the file is safe to re-run on a
 * partially-applied dev DB.
 */

exports.up = async function (knex) {
  const hasConvCol = (col) => knex.schema.hasColumn('conversations', col);

  if (!(await hasConvCol('type'))) {
    await knex.schema.alterTable('conversations', (t) => {
      // `string` over `enu` to keep the migration reversible without
      // an explicit type-drop on Postgres + matches the
      // `attachment_type` pattern used elsewhere in this codebase.
      t.string('type', 16).notNullable().defaultTo('1v1');
    });
  }

  if (!(await hasConvCol('name'))) {
    await knex.schema.alterTable('conversations', (t) => {
      t.text('name').nullable();
    });
  }

  if (!(await hasConvCol('avatar_hue'))) {
    await knex.schema.alterTable('conversations', (t) => {
      t.float('avatar_hue').nullable();
    });
  }

  if (!(await hasConvCol('created_by_user_id'))) {
    await knex.schema.alterTable('conversations', (t) => {
      t.uuid('created_by_user_id')
        .nullable()
        .references('id')
        .inTable('users')
        .onDelete('SET NULL');
    });
  }

  if (!(await knex.schema.hasTable('conversation_members'))) {
    await knex.schema.createTable('conversation_members', (t) => {
      t.uuid('id').primary().defaultTo(knex.raw('gen_random_uuid()'));
      t.uuid('conversation_id')
        .notNullable()
        .references('id')
        .inTable('conversations')
        .onDelete('CASCADE');
      t.uuid('user_id')
        .notNullable()
        .references('id')
        .inTable('users')
        .onDelete('CASCADE');
      t.string('role', 16).notNullable().defaultTo('member');
      t.timestamp('joined_at').notNullable().defaultTo(knex.fn.now());
      t.timestamp('last_read_at').nullable();
      t.timestamp('left_at').nullable();

      // One row per (conversation, user) so a re-add after leave
      // is an UPDATE (left_at = NULL) instead of a duplicate row.
      t.unique(['conversation_id', 'user_id']);
      // Speeds up "list conversations where I'm a member" — the
      // dominant read pattern for the Messages list on both sides.
      t.index(['user_id']);
    });
  }
};

exports.down = async function (knex) {
  // Drop the FK-bearing table first so the column drops below are
  // safe even if Postgres tried to enforce remaining references.
  if (await knex.schema.hasTable('conversation_members')) {
    await knex.schema.dropTable('conversation_members');
  }
  for (const col of [
    'created_by_user_id',
    'avatar_hue',
    'name',
    'type',
  ]) {
    if (await knex.schema.hasColumn('conversations', col)) {
      await knex.schema.alterTable('conversations', (t) => {
        t.dropColumn(col);
      });
    }
  }
};
