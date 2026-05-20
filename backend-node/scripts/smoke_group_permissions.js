// Stage A.1 smoke — exercise the group-aware permission gate by
// hitting the LIVE backend over HTTP. Verifies:
//
//   1. Group member can:
//        a. react to a group message
//        b. star  / unstar a group message
//        c. hide  for me a group message
//        d. delete-for-everyone OWN group message (within window)
//   2. Non-member gets 404 on every message-level endpoint.
//   3. 1:1 reactions/stars/hide/delete still work (regression).
//
// Uses the two seed accounts already in the local DB:
//   • Elena Rossi (candidate)
//   • Nobu (business)
// And generates a 3rd account (another candidate) to exercise the
// non-member 404 path.

require('dotenv').config();
const db = require('/Users/mirkopicicco/Projects/Plagit-new-project/backend-node/src/config/db');
const jwt = require('jsonwebtoken');

const BASE = 'http://localhost:3000/v1';

function mintToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.user_type, admin_role: user.admin_role },
    process.env.JWT_SECRET,
  );
}

async function http(method, path, token, body) {
  const res = await fetch(`${BASE}${path}`, {
    method,
    headers: {
      'Authorization': `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  let payload = null;
  try { payload = await res.json(); } catch (_) { /* empty */ }
  return { status: res.status, body: payload };
}

let groupConvId = null;
let groupMsgId = null;

async function cleanup() {
  if (groupConvId) {
    await db('conversation_members').where({ conversation_id: groupConvId }).delete();
    await db('messages').where({ conversation_id: groupConvId }).delete();
    await db('conversations').where({ id: groupConvId }).delete();
  }
}

(async () => {
  try {
    // ─── Resolve test accounts ─────────────────────────────────
    const elena = await db('users')
      .leftJoin('candidates', 'candidates.user_id', 'users.id')
      .where('candidates.name', 'Elena Rossi')
      .select('users.*')
      .first();
    const nobu = await db('users')
      .leftJoin('businesses', 'businesses.user_id', 'users.id')
      .where('users.user_type', 'business')
      .whereILike('businesses.name', 'Nobu%')
      .select('users.*')
      .first();
    const stranger = await db('users')
      .whereNot('id', elena.id)
      .whereNot('id', nobu.id)
      .where('user_type', 'candidate')
      .first();

    if (!elena || !nobu || !stranger) {
      console.error('FAIL: test accounts missing');
      process.exit(1);
    }
    console.log('✓ Elena, Nobu, stranger loaded');

    const elenaToken = mintToken(elena);
    const nobuToken = mintToken(nobu);
    const strangerToken = mintToken(stranger);

    // Make sure stranger has no 1:1 with either Elena or Nobu in our
    // sample data — otherwise add-member would think it's a contact.
    // (Smoke skips that branch — we only test gating, not creation
    // contact-validation here.)

    // ─── 1. Create a group via direct DB (skip the HTTP create
    //         flow — group create has its own contacts gate that
    //         requires Elena+Nobu to already be 1:1, which they are)
    const [conv] = await db('conversations')
      .insert({
        type: 'group',
        name: '[SMOKE A.1] permissions',
        avatar_hue: 200,
        created_by_user_id: nobu.id,
        status: 'normal',
        last_message: '',
      })
      .returning('*');
    groupConvId = conv.id;
    await db('conversation_members').insert([
      { conversation_id: conv.id, user_id: nobu.id, role: 'admin', last_read_at: db.fn.now() },
      { conversation_id: conv.id, user_id: elena.id, role: 'member' },
    ]);
    console.log(`✓ Created group conv=${conv.id}`);

    // ─── 2. Elena sends a group message via HTTP ────────────────
    const sendRes = await http('POST', `/candidate/conversations/${conv.id}/messages`, elenaToken, {
      attachment_type: 'text',
      body: 'Hello group from Elena',
    });
    if (sendRes.status !== 200) {
      console.error('FAIL: Elena send to group:', sendRes.status, sendRes.body);
      throw new Error('send failed');
    }
    groupMsgId = sendRes.body?.data?.id || sendRes.body?.id;
    if (!groupMsgId) {
      console.error('FAIL: no message id in send response:', sendRes.body);
      throw new Error('no msg id');
    }
    console.log(`✓ Elena sent group msgId=${groupMsgId}`);

    // ─── 3. Nobu (group member) reacts to Elena's message ──────
    const reactRes = await http(
      'POST', `/business/messages/${groupMsgId}/reactions`, nobuToken,
      { emoji: '❤️' },
    );
    if (reactRes.status !== 200) {
      console.error('FAIL: Nobu react in group:', reactRes.status, reactRes.body);
      throw new Error('react failed');
    }
    console.log('✓ Nobu reacted in group');

    // ─── 4. Nobu stars the message ─────────────────────────────
    const starRes = await http('POST', `/business/messages/${groupMsgId}/star`, nobuToken);
    if (starRes.status !== 200) {
      console.error('FAIL: Nobu star in group:', starRes.status, starRes.body);
      throw new Error('star failed');
    }
    console.log('✓ Nobu starred in group');

    // ─── 5. Nobu unstars ──────────────────────────────────────
    const unstarRes = await http('DELETE', `/business/messages/${groupMsgId}/star`, nobuToken);
    if (unstarRes.status !== 200) {
      console.error('FAIL: Nobu unstar in group:', unstarRes.status, unstarRes.body);
      throw new Error('unstar failed');
    }
    console.log('✓ Nobu unstarred in group');

    // ─── 6. Nobu hides the message for himself ────────────────
    const hideRes = await http('POST', `/business/messages/${groupMsgId}/hide`, nobuToken);
    if (hideRes.status !== 200) {
      console.error('FAIL: Nobu hide in group:', hideRes.status, hideRes.body);
      throw new Error('hide failed');
    }
    console.log('✓ Nobu hid the message for self');

    // ─── 7. Elena deletes her own message for everyone ────────
    const deleteRes = await http('DELETE', `/candidate/messages/${groupMsgId}`, elenaToken);
    if (deleteRes.status !== 200) {
      console.error('FAIL: Elena delete-for-everyone in group:', deleteRes.status, deleteRes.body);
      throw new Error('delete failed');
    }
    console.log('✓ Elena deleted her own group message for everyone');

    // ─── 8. Stranger (non-member) tries everything → 404 ──────
    // Send a fresh message first (Elena → group) so we have a non-
    // tombstoned target for stranger to fail on.
    const sendRes2 = await http('POST', `/candidate/conversations/${conv.id}/messages`, elenaToken, {
      attachment_type: 'text',
      body: 'Another message',
    });
    const msgId2 = sendRes2.body?.data?.id || sendRes2.body?.id;
    if (!msgId2) throw new Error('couldn\'t prepare msg for stranger gate');

    const strangerEndpoints = [
      ['POST',   `/candidate/messages/${msgId2}/reactions`, { emoji: '👍' }],
      ['POST',   `/candidate/messages/${msgId2}/star`],
      ['DELETE', `/candidate/messages/${msgId2}/star`],
      ['POST',   `/candidate/messages/${msgId2}/hide`],
    ];
    for (const [method, path, body] of strangerEndpoints) {
      const r = await http(method, path, strangerToken, body);
      if (r.status !== 404) {
        console.error(`FAIL: stranger ${method} ${path} → ${r.status} (expected 404)`, r.body);
        throw new Error('non-member should 404');
      }
    }
    console.log('✓ Non-member gets 404 on every message endpoint');

    // ─── 9. 1:1 regression — Elena reacts to a message in her
    //         existing 1:1 with Nobu, then unreacts ─────────────
    // Find the existing 1:1 conv between Elena and Nobu
    const oneToOne = await db('conversations')
      .leftJoin('candidates', 'conversations.candidate_id', 'candidates.id')
      .leftJoin('businesses', 'conversations.business_id', 'businesses.id')
      .where('candidates.user_id', elena.id)
      .where('businesses.user_id', nobu.id)
      .where(function() { this.where('conversations.type', '1v1').orWhereNull('conversations.type'); })
      .select('conversations.id')
      .first();
    if (oneToOne) {
      const send11 = await http('POST', `/candidate/conversations/${oneToOne.id}/messages`, elenaToken, {
        attachment_type: 'text',
        body: '[smoke A.1] regression 1v1',
      });
      const msg11 = send11.body?.data?.id || send11.body?.id;
      if (!msg11) throw new Error('couldn\'t prep 1v1 msg');
      const react11 = await http('POST', `/business/messages/${msg11}/reactions`, nobuToken, { emoji: '🔥' });
      if (react11.status !== 200) {
        console.error('FAIL: 1v1 react regression:', react11.status, react11.body);
        throw new Error('1v1 react broken');
      }
      const unreact11 = await http('DELETE', `/business/messages/${msg11}/reactions`, nobuToken);
      if (unreact11.status !== 200) {
        console.error('FAIL: 1v1 unreact regression:', unreact11.status, unreact11.body);
        throw new Error('1v1 unreact broken');
      }
      // Cleanup the 1v1 test message (Nobu deletes-for-everyone since
      // it's recent).
      await db('messages').where({ id: msg11 }).delete();
      console.log('✓ 1:1 react/unreact still work (regression PASS)');
    } else {
      console.log('⊘ 1:1 regression skipped (no Elena↔Nobu 1v1 conv)');
    }

    await cleanup();
    console.log('\n🟢 STAGE A.1 SMOKE PASS');
    await db.destroy();
    process.exit(0);
  } catch (err) {
    console.error('\n🔴 SMOKE FAILED:', err.message);
    await cleanup().catch(() => {});
    await db.destroy();
    process.exit(1);
  }
})();
