const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const AppError = require('../utils/AppError');
const { bus } = require('../services/realtime/eventBus');
const {
  isGroupChatColumnsPresent,
  isGroupPhotoColumnPresent,
} = require('../services/schemaFeatureFlags');
const storage = require('../storage');
// Phase 5C — admin platform-events fan-out. Same helper that
// authController already uses (Phase 5A/5B), exported from
// businessController. Imported lazily-deconstructed here so the
// dependency stays obvious to grep + a future extraction into a
// shared service is a single search/replace away.
const { notifyAllAdmins } = require('./businessController');

// ---------------------------------------------------------------------------
// Group conversations (mig 049)
// ---------------------------------------------------------------------------
//
// All endpoints here are role-agnostic — they live under `/v1/groups` and
// only require an authenticated user. The role split (candidate vs business
// vs admin) is irrelevant for group operations: membership is the only
// gate. 1:1 conversations stay on the existing per-role endpoints; this
// module never touches them.
//
// MVP scope (per the approved plan):
//   • Create a group (name + 2..50 members, contacts-only validation)
//   • List members (member-only access)
//   • Add a member (creator-only)
//   • Remove a member — self leave OR creator kick
//   • Rename group (creator-only)
//   • Mark conversation read up to now (every member, own row)
//
// Per-user read state lives on `conversation_members.last_read_at` —
// NO `message_read_receipts` table for the MVP, per the plan.

// ───────────────────────────────────────────────────────────────────
// Validation constants
// ───────────────────────────────────────────────────────────────────
const _NAME_MAX_LEN = 60;
const _MAX_MEMBERS = 50; // including the creator
const _MAX_ADD_BATCH = 20;

// ───────────────────────────────────────────────────────────────────
// Helpers
// ───────────────────────────────────────────────────────────────────

/// Returns the set of `users.id` values the requester already has a
/// 1:1 conversation with — used as the "contacts" gate for group
/// creation per the MVP rule "no global search, only people you can
/// already message".
async function _resolveMyContactUserIds(userId) {
  const user = await db('users').where({ id: userId }).first();
  if (!user) return [];

  if (user.user_type === 'candidate') {
    const cand = await db('candidates').where({ user_id: userId }).first();
    if (!cand) return [];
    const rows = await db('conversations')
      .leftJoin('businesses', 'conversations.business_id', 'businesses.id')
      .leftJoin('users', 'businesses.user_id', 'users.id')
      .where('conversations.candidate_id', cand.id)
      .whereNot('conversations.status', 'archived')
      .whereNotNull('businesses.user_id')
      .select('businesses.user_id as user_id');
    return rows.map((r) => r.user_id);
  }

  if (user.user_type === 'business') {
    const biz = await db('businesses').where({ user_id: userId }).first();
    if (!biz) return [];
    const rows = await db('conversations')
      .leftJoin('candidates', 'conversations.candidate_id', 'candidates.id')
      .leftJoin('users', 'candidates.user_id', 'users.id')
      .where('conversations.business_id', biz.id)
      .whereNot('conversations.status', 'archived')
      .whereNotNull('candidates.user_id')
      .select('candidates.user_id as user_id');
    return rows.map((r) => r.user_id);
  }

  // Admin or unknown — no contact gate, but admins shouldn't be
  // creating chat groups via this endpoint anyway.
  return [];
}

/// Stable HSL hue (0..360) seeded from a string. Used as the
/// `conversations.avatar_hue` fallback so the same group name always
/// renders the same color-hash badge on the client.
function _hashHue(s) {
  let hash = 0;
  for (let i = 0; i < s.length; i++) {
    hash = ((hash << 5) - hash) + s.charCodeAt(i);
    hash |= 0;
  }
  return Math.abs(hash) % 360;
}

/// Loads the active membership row (left_at IS NULL) for [userId] in
/// [convId]. Returns null when not a member or already left.
async function _myMembership(convId, userId) {
  return db('conversation_members')
    .where({ conversation_id: convId, user_id: userId })
    .whereNull('left_at')
    .first();
}

/// Returns the conversation row only if it's a group AND [userId]
/// is an active member. Throws 404 otherwise — same opaque message
/// for "doesn't exist" and "you're not a member" so we don't leak
/// the existence of groups the caller isn't in.
async function _resolveMemberConversation(convId, userId) {
  const conv = await db('conversations').where({ id: convId }).first();
  if (!conv || conv.type !== 'group') {
    throw AppError.notFound('Conversation not found.');
  }
  const me = await _myMembership(convId, userId);
  if (!me) {
    throw AppError.notFound('Conversation not found.');
  }
  return { conv, me };
}

/// Sender-side audience for SSE broadcasts: every active member of
/// the group EXCEPT the sender, plus the role:admin firehose.
async function _audienceForGroup(convId, senderUserId) {
  const rows = await db('conversation_members')
    .where({ conversation_id: convId })
    .whereNull('left_at')
    .select('user_id');
  const audience = ['role:admin', `user:${senderUserId}`];
  for (const r of rows) {
    if (r.user_id !== senderUserId) audience.push(`user:${r.user_id}`);
  }
  return audience;
}

/// Fetches the display fields (name, photo_url) for a batch of
/// `users.id` values. One query, joins the role tables so candidate
/// names come from `candidates.name` and business names come from
/// `businesses.name` — matches the 1:1 chat list behaviour.
async function _fetchMemberProfiles(userIds) {
  if (userIds.length === 0) return new Map();
  const rows = await db('users')
    .leftJoin('candidates', 'candidates.user_id', 'users.id')
    .leftJoin('businesses', 'businesses.user_id', 'users.id')
    .whereIn('users.id', userIds)
    .select(
      'users.id as user_id',
      'users.name as user_name',
      'users.user_type',
      'users.photo_url as user_photo_url',
      'candidates.name as candidate_name',
      'candidates.initials as candidate_initials',
      'businesses.name as business_name',
      'businesses.initials as business_initials',
    );
  const map = new Map();
  for (const r of rows) {
    const displayName =
      r.candidate_name || r.business_name || r.user_name || 'User';
    const initials =
      r.candidate_initials ||
      r.business_initials ||
      (displayName.slice(0, 2) || 'U').toUpperCase();
    map.set(r.user_id, {
      user_id: r.user_id,
      user_type: r.user_type,
      display_name: displayName,
      initials,
      photo_url: r.user_photo_url || null,
    });
  }
  return map;
}

// ───────────────────────────────────────────────────────────────────
// Endpoints
// ───────────────────────────────────────────────────────────────────

// POST /v1/groups — create a new group conversation.
//
// Body:
//   • name             string (1..60 chars, trimmed)
//   • member_user_ids  string[] — users.id values to invite. The
//                      creator is auto-added and MUST NOT appear in
//                      this list. Every entry must be a 1:1 contact
//                      of the requester (MVP rule).
async function createGroup(req, res, next) {
  try {
    if (!(await isGroupChatColumnsPresent())) {
      throw AppError.unavailable(
        'Group chats are temporarily unavailable. Please try again in a moment.',
        'GROUP_NOT_READY',
      );
    }

    const userId = req.user.id;
    const { name, member_user_ids, group_photo_url } = req.body;

    if (typeof name !== 'string' || name.trim().length === 0) {
      throw AppError.badRequest('name is required.');
    }
    const cleanName = name.trim().slice(0, _NAME_MAX_LEN);

    // Optional group photo at create time — Stage C.2A.2. The client
    // is expected to have uploaded the image via POST /v1/uploads/image
    // FIRST and pass the resulting HTTPS URL here, so the row stays
    // small (TEXT URL, never a base64 blob). Only URLs issued by our
    // storage adapter are accepted — an arbitrary HTTPS pointing at a
    // third-party host is rejected so a malicious caller can't pin a
    // remote image into a group record.
    //
    // The column itself is gated behind isGroupPhotoColumnPresent so
    // a backend booted before the migration finished just drops the
    // field silently — group creation continues to succeed without a
    // photo, identical to pre-C.2A.2 behaviour.
    let cleanPhotoUrl = null;
    if (group_photo_url !== undefined && group_photo_url !== null) {
      if (typeof group_photo_url !== 'string' ||
          !storage.isOwnedUrl(group_photo_url)) {
        throw AppError.badRequest(
          'group_photo_url must be an HTTPS URL issued by our upload endpoint.',
        );
      }
      cleanPhotoUrl = group_photo_url;
    }

    if (!Array.isArray(member_user_ids)) {
      throw AppError.badRequest('member_user_ids must be an array.');
    }
    const cleanMemberIds = [
      ...new Set(member_user_ids.filter((id) => typeof id === 'string' && id && id !== userId)),
    ];
    if (cleanMemberIds.length === 0) {
      throw AppError.badRequest('member_user_ids must contain at least 1 other user.');
    }
    if (cleanMemberIds.length + 1 > _MAX_MEMBERS) {
      throw AppError.badRequest(`A group cannot have more than ${_MAX_MEMBERS} members.`);
    }

    // Contacts-only gate (MVP) — every invited user must already
    // be in a 1:1 conversation with the requester.
    const contactIds = await _resolveMyContactUserIds(userId);
    const contactSet = new Set(contactIds);
    for (const memberId of cleanMemberIds) {
      if (!contactSet.has(memberId)) {
        throw AppError.badRequest(
          'You can only invite users you already have a conversation with.',
        );
      }
    }

    const hue = _hashHue(cleanName);

    // Only attempt to write group_photo_url when the column actually
    // exists — keeps zero-downtime through the migrate window.
    const photoColumnReady = await isGroupPhotoColumnPresent();
    const insertPayload = {
      type: 'group',
      name: cleanName,
      avatar_hue: hue,
      created_by_user_id: userId,
      status: 'normal',
      last_message: '',
    };
    if (photoColumnReady && cleanPhotoUrl !== null) {
      insertPayload.group_photo_url = cleanPhotoUrl;
    }

    const newConvId = await db.transaction(async (trx) => {
      const [conv] = await trx('conversations')
        .insert(insertPayload)
        .returning('*');

      const rows = [
        {
          conversation_id: conv.id,
          user_id: userId,
          role: 'admin',
          last_read_at: trx.fn.now(),
        },
        ...cleanMemberIds.map((u) => ({
          conversation_id: conv.id,
          user_id: u,
          role: 'member',
        })),
      ];
      await trx('conversation_members').insert(rows);

      return conv.id;
    });

    const audience = ['role:admin', `user:${userId}`];
    for (const mid of cleanMemberIds) audience.push(`user:${mid}`);

    // eslint-disable-next-line no-console
    console.log(
      `[GROUP CREATE] convId=${newConvId} creator=${userId} memberCount=${cleanMemberIds.length + 1} name="${cleanName}"`,
    );
    bus.publish(
      'conversation.new',
      {
        conversation_id: newConvId,
        type: 'group',
        name: cleanName,
        avatar_hue: hue,
        created_by_user_id: userId,
        // Carry photo URL on the broadcast so other clients can
        // paint the new row's avatar immediately without an extra
        // GET. Missing key when column not yet present.
        ...(photoColumnReady && cleanPhotoUrl !== null
          ? { group_photo_url: cleanPhotoUrl }
          : {}),
      },
      audience,
    );

    // Phase 5C — fan a "new group created" row to every admin user
    // so the admin platform-events feed surfaces the creation in
    // real time (admin SSE audience is also part of the broadcast
    // above, but the row gives an inspectable history). Same
    // fire-and-forget IIFE safety as Phase 5A/5B: any failure is
    // logged but MUST NOT roll back the conversation insert (which
    // already committed) and MUST NOT block the response. We use
    // `'group_created'` as the destination_route (distinct from
    // the messages-surface `'group'` route in the Phase 1 catalog)
    // so this admin platform event never collides with the
    // peer-side group-lifecycle events that other phases may wire
    // through the bell exclusion list.
    (async () => {
      try {
        const actor = await db('users')
          .where({ id: userId })
          .select('name')
          .first();
        await notifyAllAdmins(
          `New group created: ${cleanName}`,
          'in_app',
          newConvId,
          'group_created',
          [
            actor?.name ? `By ${actor.name}` : null,
            `${cleanMemberIds.length + 1} members`,
          ].filter(Boolean).join(' · '),
        );
      } catch (e) {
        // eslint-disable-next-line no-console
        console.warn('[createGroup] notifyAllAdmins failed:', e.message);
      }
    })();

    const conv = await db('conversations').where({ id: newConvId }).first();
    const profiles = await _fetchMemberProfiles([userId, ...cleanMemberIds]);
    ok(res, {
      ...conv,
      members: [userId, ...cleanMemberIds].map(
        (u) => profiles.get(u) || { user_id: u, display_name: 'User', initials: 'U', photo_url: null },
      ),
    });
  } catch (err) {
    next(err);
  }
}

// GET /v1/groups/:id/members — list active members of a group.
// Member-only access.
async function listGroupMembers(req, res, next) {
  try {
    if (!(await isGroupChatColumnsPresent())) {
      throw AppError.unavailable(
        'Group chats are temporarily unavailable.',
        'GROUP_NOT_READY',
      );
    }
    const userId = req.user.id;
    const convId = req.params.id;

    await _resolveMemberConversation(convId, userId);

    const memberRows = await db('conversation_members')
      .where({ conversation_id: convId })
      .whereNull('left_at')
      .select('user_id', 'role', 'joined_at');

    const profiles = await _fetchMemberProfiles(memberRows.map((m) => m.user_id));

    const enriched = memberRows.map((m) => ({
      ...(profiles.get(m.user_id) || {
        user_id: m.user_id,
        display_name: 'User',
        initials: 'U',
        photo_url: null,
        user_type: null,
      }),
      role: m.role,
      joined_at: m.joined_at,
    }));

    paginated(res, enriched, { page: 1, limit: enriched.length, total: enriched.length });
  } catch (err) {
    next(err);
  }
}

// POST /v1/groups/:id/members — add member(s) to the group.
// Creator-only in the MVP.
//
// Body: { member_user_ids: string[] } — same contact-gate as create.
async function addGroupMember(req, res, next) {
  try {
    if (!(await isGroupChatColumnsPresent())) {
      throw AppError.unavailable(
        'Group chats are temporarily unavailable.',
        'GROUP_NOT_READY',
      );
    }
    const userId = req.user.id;
    const convId = req.params.id;
    const { member_user_ids } = req.body;

    const { conv } = await _resolveMemberConversation(convId, userId);
    if (conv.created_by_user_id !== userId) {
      throw AppError.forbidden('Only the group creator can add members.');
    }

    if (!Array.isArray(member_user_ids) || member_user_ids.length === 0) {
      throw AppError.badRequest('member_user_ids must contain at least 1 user.');
    }
    if (member_user_ids.length > _MAX_ADD_BATCH) {
      throw AppError.badRequest(`Cannot add more than ${_MAX_ADD_BATCH} members at once.`);
    }

    const cleanIds = [
      ...new Set(member_user_ids.filter((id) => typeof id === 'string' && id && id !== userId)),
    ];

    // Validate contact gate
    const contactIds = await _resolveMyContactUserIds(userId);
    const contactSet = new Set(contactIds);
    for (const mid of cleanIds) {
      if (!contactSet.has(mid)) {
        throw AppError.badRequest(
          'You can only invite users you already have a conversation with.',
        );
      }
    }

    // Refuse if it would exceed the cap
    const activeCount = await db('conversation_members')
      .where({ conversation_id: convId })
      .whereNull('left_at')
      .count('* as c').first().then((r) => +r.c);
    if (activeCount + cleanIds.length > _MAX_MEMBERS) {
      throw AppError.badRequest(`A group cannot have more than ${_MAX_MEMBERS} members.`);
    }

    // Upsert pattern: if a row exists with left_at set, re-activate it.
    await db.transaction(async (trx) => {
      for (const mid of cleanIds) {
        const existing = await trx('conversation_members')
          .where({ conversation_id: convId, user_id: mid })
          .first();
        if (existing) {
          if (existing.left_at != null) {
            await trx('conversation_members')
              .where({ id: existing.id })
              .update({ left_at: null, joined_at: trx.fn.now() });
          }
          // Already-active row → idempotent no-op.
        } else {
          await trx('conversation_members').insert({
            conversation_id: convId,
            user_id: mid,
            role: 'member',
          });
        }
      }
    });

    // Broadcast to everyone in the group so the new members appear
    // on every client's roster immediately.
    const audience = await _audienceForGroup(convId, userId);
    bus.publish(
      'conversation.member_added',
      {
        conversation_id: convId,
        added_user_ids: cleanIds,
        actor_user_id: userId,
      },
      audience,
    );

    const memberRows = await db('conversation_members')
      .where({ conversation_id: convId })
      .whereNull('left_at')
      .select('user_id', 'role', 'joined_at');
    const profiles = await _fetchMemberProfiles(memberRows.map((m) => m.user_id));
    const enriched = memberRows.map((m) => ({
      ...(profiles.get(m.user_id) || {
        user_id: m.user_id,
        display_name: 'User',
        initials: 'U',
        photo_url: null,
        user_type: null,
      }),
      role: m.role,
      joined_at: m.joined_at,
    }));

    ok(res, { members: enriched });
  } catch (err) {
    next(err);
  }
}

// DELETE /v1/groups/:id/members/:userId — remove a member.
//
// Permission rules (MVP):
//   • Self can always leave (userId in path === req.user.id).
//   • Creator can kick anyone except themselves.
//   • Nobody else can remove others (member kicking another member
//     returns 403).
//   • Creator leaving: allowed; the group keeps running, no
//     ownership transfer in MVP (`created_by_user_id` stays).
async function removeGroupMember(req, res, next) {
  try {
    if (!(await isGroupChatColumnsPresent())) {
      throw AppError.unavailable(
        'Group chats are temporarily unavailable.',
        'GROUP_NOT_READY',
      );
    }
    const userId = req.user.id;
    const convId = req.params.id;
    const targetUserId = req.params.userId;

    const { conv } = await _resolveMemberConversation(convId, userId);

    const isSelfLeave = targetUserId === userId;
    const isCreatorKick = conv.created_by_user_id === userId && !isSelfLeave;

    if (!isSelfLeave && !isCreatorKick) {
      throw AppError.forbidden('Only the group creator can remove other members.');
    }

    const targetMembership = await _myMembership(convId, targetUserId);
    if (!targetMembership) {
      // Idempotent — already gone.
      ok(res, { success: true });
      return;
    }

    await db('conversation_members')
      .where({ id: targetMembership.id })
      .update({ left_at: db.fn.now() });

    const audience = await _audienceForGroup(convId, userId);
    bus.publish(
      isSelfLeave ? 'conversation.member_left' : 'conversation.member_removed',
      {
        conversation_id: convId,
        target_user_id: targetUserId,
        actor_user_id: userId,
      },
      audience,
    );

    ok(res, { success: true });
  } catch (err) {
    next(err);
  }
}

// PATCH /v1/groups/:id — rename (and/or tweak avatar_hue).
// Creator-only in MVP. Body: { name?: string, avatar_hue?: number }
async function updateGroup(req, res, next) {
  try {
    if (!(await isGroupChatColumnsPresent())) {
      throw AppError.unavailable(
        'Group chats are temporarily unavailable.',
        'GROUP_NOT_READY',
      );
    }
    const userId = req.user.id;
    const convId = req.params.id;
    const { name, avatar_hue } = req.body || {};

    const { conv } = await _resolveMemberConversation(convId, userId);
    if (conv.created_by_user_id !== userId) {
      throw AppError.forbidden('Only the group creator can update the group.');
    }

    const patch = {};
    if (name !== undefined) {
      if (typeof name !== 'string' || name.trim().length === 0) {
        throw AppError.badRequest('name must be a non-empty string.');
      }
      patch.name = name.trim().slice(0, _NAME_MAX_LEN);
    }
    if (avatar_hue !== undefined) {
      const n = Number(avatar_hue);
      if (!Number.isFinite(n) || n < 0 || n >= 360) {
        throw AppError.badRequest('avatar_hue must be in [0, 360).');
      }
      patch.avatar_hue = n;
    }
    if (Object.keys(patch).length === 0) {
      throw AppError.badRequest('No fields to update.');
    }
    // Keep the SSE payload JSON-serializable. `db.fn.now()` is a
    // knex raw query helper, not a real value — passing it into
    // bus.publish() blows up `JSON.stringify` with a circular
    // Timeout/TimersList reference. We bump `updated_at` in the
    // UPDATE via a separate object and broadcast only the plain
    // fields the patch carries.
    await db('conversations')
      .where({ id: convId })
      .update({ ...patch, updated_at: db.fn.now() });

    const audience = await _audienceForGroup(convId, userId);
    bus.publish(
      'conversation.updated',
      {
        conversation_id: convId,
        patch,
        actor_user_id: userId,
      },
      audience,
    );

    const updated = await db('conversations').where({ id: convId }).first();
    ok(res, updated);
  } catch (err) {
    next(err);
  }
}

// PUT /v1/groups/:id/photo — set or clear the group photo.
//
// Creator-only in the MVP (same gate as `updateGroup`). Body:
//   { group_photo_url: string | null }
//
// Rules:
//   • A non-null value must be a string AND pass `storage.isOwnedUrl`
//     — i.e. an HTTPS URL issued by our upload pipeline. Arbitrary
//     external URLs are rejected so callers can't pin third-party
//     images into a group record.
//   • `null` (or absent — we treat omission as "no change requested",
//     so the explicit null is required) clears the photo and the
//     client falls back to the color-hash GroupAvatar.
//   • Gated behind `isGroupPhotoColumnPresent` so the route returns
//     503 during the migrate window instead of writing into a column
//     that doesn't exist yet.
//
// Future: when admin promotion exists, swap the creator gate for a
// membership-role check (role === 'admin'). For now creator IS the
// only admin so the simpler gate is equivalent.
async function updateGroupPhoto(req, res, next) {
  try {
    if (!(await isGroupChatColumnsPresent())) {
      throw AppError.unavailable(
        'Group chats are temporarily unavailable.',
        'GROUP_NOT_READY',
      );
    }
    if (!(await isGroupPhotoColumnPresent())) {
      throw AppError.unavailable(
        'Group photos are temporarily unavailable.',
        'GROUP_PHOTO_NOT_READY',
      );
    }
    const userId = req.user.id;
    const convId = req.params.id;
    const body = req.body || {};
    if (!Object.prototype.hasOwnProperty.call(body, 'group_photo_url')) {
      throw AppError.badRequest(
        'group_photo_url is required (string for set, null for clear).',
      );
    }
    const raw = body.group_photo_url;

    const { conv } = await _resolveMemberConversation(convId, userId);
    if (conv.created_by_user_id !== userId) {
      throw AppError.forbidden(
        'Only the group creator can change the group photo.',
      );
    }

    let nextValue;
    if (raw === null || raw === '') {
      nextValue = null;
    } else if (typeof raw === 'string' && storage.isOwnedUrl(raw)) {
      nextValue = raw;
    } else {
      throw AppError.badRequest(
        'group_photo_url must be an HTTPS URL issued by our upload endpoint, or null.',
      );
    }

    await db('conversations')
      .where({ id: convId })
      .update({ group_photo_url: nextValue, updated_at: db.fn.now() });

    // Broadcast to the full group audience so every member's
    // Messages list + open chat header repaint immediately.
    const audience = await _audienceForGroup(convId, userId);
    bus.publish(
      'conversation.updated',
      {
        conversation_id: convId,
        patch: { group_photo_url: nextValue },
        actor_user_id: userId,
      },
      audience,
    );

    const updated = await db('conversations').where({ id: convId }).first();
    ok(res, updated);
  } catch (err) {
    next(err);
  }
}

// POST /v1/groups/:id/read — mark this conversation as read up to
// now for the caller. Used by the chat view when the user opens
// the thread; subsequent message.new events bump the unread count
// again only for messages with created_at > new last_read_at.
async function markGroupRead(req, res, next) {
  try {
    if (!(await isGroupChatColumnsPresent())) {
      throw AppError.unavailable(
        'Group chats are temporarily unavailable.',
        'GROUP_NOT_READY',
      );
    }
    const userId = req.user.id;
    const convId = req.params.id;

    const { me } = await _resolveMemberConversation(convId, userId);

    await db('conversation_members')
      .where({ id: me.id })
      .update({ last_read_at: db.fn.now() });

    ok(res, { success: true });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  createGroup,
  listGroupMembers,
  addGroupMember,
  removeGroupMember,
  updateGroup,
  updateGroupPhoto,
  markGroupRead,
};
