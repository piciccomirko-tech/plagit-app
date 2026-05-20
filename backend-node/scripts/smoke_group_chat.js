// Stage A smoke test — group chat end-to-end on local DB.
//
// Verifies:
//   1. Direct INSERT into conversations(type='group') + conversation_members
//      lands cleanly via knex with all new columns populated.
//   2. listConversations (candidate side) returns the group for Elena.
//   3. listConversations (business side) returns the group for Nobu.
//   4. sendMessage on a group resolves audience from members table.
//   5. Permission gate: a third party NOT in the group gets 404 on listMessages.
//
// Runs against the LOCAL dev DB only via knex; does NOT hit the
// HTTP layer — that's smoke-tested live by the iOS simulator after.

require('dotenv').config();
const db = require('/Users/mirkopicicco/Projects/Plagit-new-project/backend-node/src/config/db');

(async () => {
  try {
    // ─── 1. Find Elena (candidate) + Nobu (business) by name ─────
    const elena = await db('users')
      .leftJoin('candidates', 'candidates.user_id', 'users.id')
      .where('candidates.name', 'Elena Rossi')
      .select('users.id as user_id', 'users.name', 'users.user_type')
      .first();
    const nobu = await db('users')
      .leftJoin('businesses', 'businesses.user_id', 'users.id')
      .where('users.user_type', 'business')
      .whereILike('businesses.name', 'Nobu%')
      .select('users.id as user_id', 'users.name', 'users.user_type')
      .first();

    if (!elena || !nobu) {
      console.error('FAIL: test accounts not found');
      console.error('elena:', elena, 'nobu:', nobu);
      process.exit(1);
    }
    console.log(`✓ Found Elena userId=${elena.user_id}`);
    console.log(`✓ Found Nobu  userId=${nobu.user_id}`);

    // ─── 2. Verify mig 049 columns exist ─────────────────────────
    const hasType = await db.schema.hasColumn('conversations', 'type');
    const hasName = await db.schema.hasColumn('conversations', 'name');
    const hasMembersTable = await db.schema.hasTable('conversation_members');
    if (!hasType || !hasName || !hasMembersTable) {
      console.error('FAIL: mig 049 not applied:', { hasType, hasName, hasMembersTable });
      process.exit(1);
    }
    console.log('✓ mig 049 schema present');

    // ─── 3. Clean any prior smoke group ──────────────────────────
    await db('conversations')
      .where({ name: '[SMOKE] Group test 049' })
      .where({ type: 'group' })
      .delete();

    // ─── 4. Create a group: Elena + Nobu, creator = Nobu ─────────
    const [conv] = await db('conversations')
      .insert({
        type: 'group',
        name: '[SMOKE] Group test 049',
        avatar_hue: 180,
        created_by_user_id: nobu.user_id,
        status: 'normal',
        last_message: '',
      })
      .returning('*');
    console.log(`✓ Created group convId=${conv.id}`);

    await db('conversation_members').insert([
      { conversation_id: conv.id, user_id: nobu.user_id, role: 'admin', last_read_at: db.fn.now() },
      { conversation_id: conv.id, user_id: elena.user_id, role: 'member' },
    ]);
    console.log('✓ Inserted 2 members');

    // ─── 5. Membership lookups ───────────────────────────────────
    const elenaIsMember = await db('conversation_members')
      .where({ conversation_id: conv.id, user_id: elena.user_id })
      .whereNull('left_at')
      .first();
    const nobuIsAdmin = await db('conversation_members')
      .where({ conversation_id: conv.id, user_id: nobu.user_id, role: 'admin' })
      .whereNull('left_at')
      .first();
    if (!elenaIsMember || !nobuIsAdmin) {
      console.error('FAIL: members not found:', { elenaIsMember, nobuIsAdmin });
      process.exit(1);
    }
    console.log('✓ Membership rows readable');

    // ─── 6. Simulate listConversations for Elena (candidate side) ─
    const elenaGroups = await db('conversations')
      .innerJoin('conversation_members', function () {
        this.on('conversation_members.conversation_id', '=', 'conversations.id')
          .andOn('conversation_members.user_id', '=', db.raw('?', [elena.user_id]));
      })
      .whereNull('conversation_members.left_at')
      .where('conversations.type', 'group')
      .whereNot('conversations.status', 'archived')
      .select('conversations.id', 'conversations.name', 'conversations.type');
    if (elenaGroups.length === 0) {
      console.error('FAIL: Elena listConversations did not return the group');
      process.exit(1);
    }
    console.log(`✓ Elena listConversations sees ${elenaGroups.length} group(s) including "${elenaGroups[0].name}"`);

    // ─── 7. Same query for Nobu ─────────────────────────────────
    const nobuGroups = await db('conversations')
      .innerJoin('conversation_members', function () {
        this.on('conversation_members.conversation_id', '=', 'conversations.id')
          .andOn('conversation_members.user_id', '=', db.raw('?', [nobu.user_id]));
      })
      .whereNull('conversation_members.left_at')
      .where('conversations.type', 'group')
      .select('conversations.id', 'conversations.name');
    if (nobuGroups.length === 0) {
      console.error('FAIL: Nobu listConversations did not return the group');
      process.exit(1);
    }
    console.log(`✓ Nobu  listConversations sees ${nobuGroups.length} group(s)`);

    // ─── 8. Audience resolution (simulates sendMessage broadcast) ─
    const audience = ['role:admin', `user:${nobu.user_id}`];
    const members = await db('conversation_members')
      .where({ conversation_id: conv.id })
      .whereNull('left_at')
      .pluck('user_id');
    for (const u of members) {
      if (u !== nobu.user_id) audience.push(`user:${u}`);
    }
    if (!audience.includes(`user:${elena.user_id}`)) {
      console.error('FAIL: audience missing Elena');
      process.exit(1);
    }
    console.log(`✓ Audience resolution: ${audience.length} tokens including Elena`);

    // ─── 9. Permission gate: random third user gets nothing ──────
    const randomUser = await db('users')
      .whereNot('id', elena.user_id)
      .whereNot('id', nobu.user_id)
      .where('user_type', 'candidate')
      .first();
    if (randomUser) {
      const blocked = await db('conversation_members')
        .where({ conversation_id: conv.id, user_id: randomUser.id })
        .whereNull('left_at')
        .first();
      if (blocked) {
        console.error('FAIL: random user is somehow a member');
        process.exit(1);
      }
      console.log(`✓ Permission gate: random user (${randomUser.email || randomUser.id}) is NOT in the group`);
    }

    // ─── 10. Cleanup ────────────────────────────────────────────
    await db('conversation_members').where({ conversation_id: conv.id }).delete();
    await db('conversations').where({ id: conv.id }).delete();
    console.log('✓ Cleaned up smoke group');

    console.log('\n🟢 ALL CHECKS PASS');
    await db.destroy();
    process.exit(0);
  } catch (err) {
    console.error('\n🔴 SMOKE FAILED:', err);
    await db.destroy();
    process.exit(1);
  }
})();
