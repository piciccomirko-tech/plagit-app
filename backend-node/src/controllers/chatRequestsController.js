/**
 * Stage AL.6.1 — Chat Request Gate / Mutual Chat Consent backend.
 *
 * Three endpoints exposed under two route prefixes
 * (/v1/candidate/chat-requests and /v1/business/chat-requests),
 * but the logic is symmetric — the same controller dispatches
 * based on `req.user.role`. Admin clients NEVER reach this
 * controller; admin observability is AL.6.5 territory.
 *
 *   • POST   create        — requester sends a new request to the
 *                            other side. Bypasses gate when a
 *                            conversation already exists.
 *   • GET    list          — caller sees own incoming / outgoing
 *                            requests. Lazy-filters expired
 *                            pending rows.
 *   • PATCH  respond       — recipient Accept/Deny, requester
 *                            Cancel. Accept creates/reuses the
 *                            1:1 conversation in a transaction.
 *
 * Status lifecycle: pending → accepted | denied | cancelled |
 * expired. Terminal states are immutable (idempotent retries
 * return the existing row's state without write).
 *
 * Rules (AL.6.1 decisions):
 *   • Partial unique on `(candidate_id, business_id) WHERE
 *     status='pending'` (mig 053) — DB enforces "one pending per
 *     pair" regardless of requester role.
 *   • Denied cooldown: 7 days for the SAME requester (different
 *     direction is unaffected — Alice→Bob denied doesn't block
 *     Bob→Alice).
 *   • Expiry: 7 days from creation; lazy filter on read.
 *   • No notifications, no SSE, no push in AL.6.1.
 *   • No admin notifyAllAdmins in AL.6.1.
 *   • AL.5.6 urgent_request handoff bypasses this entirely
 *     (separate transaction; doesn't touch chat_requests).
 */

const db = require('../config/db');
const { ok, paginated } = require('../utils/response');
const AppError = require('../utils/AppError');
const { isChatRequestsTablePresent } = require('../services/schemaFeatureFlags');

const _EXPIRY_DAYS = 7;
const _COOLDOWN_DAYS = 7;
const _MAX_MESSAGE_LENGTH = 500;
const _DEFAULT_LIMIT = 20;
const _MAX_LIMIT = 100;

const _PROFILE_JOINS = [
  'chat_requests.id',
  'chat_requests.candidate_id',
  'chat_requests.business_id',
  'chat_requests.requester_user_id',
  'chat_requests.requester_role',
  'chat_requests.recipient_user_id',
  'chat_requests.recipient_role',
  'chat_requests.status',
  'chat_requests.conversation_id',
  'chat_requests.message',
  'chat_requests.responded_at',
  'chat_requests.expires_at',
  'chat_requests.created_at',
  'chat_requests.updated_at',
  'candidates.name as candidate_name',
  'candidates.role as candidate_role',
  'candidates.nationality as candidate_nationality',
  'candidates.verification_status as candidate_verification_status',
  'candidates.avatar_hue as candidate_avatar_hue',
  'cand_user.photo_url as candidate_photo_url',
  'businesses.name as business_name',
  'businesses.location as business_location',
  'businesses.is_verified as business_verified',
  'businesses.avatar_hue as business_avatar_hue',
  'biz_user.photo_url as business_photo_url',
];

function _baseQuery() {
  return db('chat_requests')
    .leftJoin('candidates', 'chat_requests.candidate_id', 'candidates.id')
    .leftJoin('businesses', 'chat_requests.business_id', 'businesses.id')
    .leftJoin('users as cand_user', 'candidates.user_id', 'cand_user.id')
    .leftJoin('users as biz_user', 'businesses.user_id', 'biz_user.id');
}

function _shapeRow(row) {
  if (!row) return null;
  return {
    id: row.id,
    candidate_id: row.candidate_id,
    business_id: row.business_id,
    requester_user_id: row.requester_user_id,
    requester_role: row.requester_role,
    recipient_user_id: row.recipient_user_id,
    recipient_role: row.recipient_role,
    status: row.status,
    conversation_id: row.conversation_id,
    message: row.message,
    responded_at: row.responded_at,
    expires_at: row.expires_at,
    created_at: row.created_at,
    updated_at: row.updated_at,
    candidate: {
      id: row.candidate_id,
      name: row.candidate_name || '',
      role: row.candidate_role || '',
      nationality: row.candidate_nationality,
      verified: row.candidate_verification_status === 'verified',
      avatar_hue: row.candidate_avatar_hue ?? 0.5,
      photo_url: row.candidate_photo_url,
    },
    business: {
      id: row.business_id,
      name: row.business_name || '',
      location: row.business_location,
      verified: row.business_verified === true,
      avatar_hue: row.business_avatar_hue ?? 0.5,
      photo_url: row.business_photo_url,
    },
  };
}

async function _ensureReady() {
  if (!(await isChatRequestsTablePresent())) {
    throw AppError.unavailable(
      'Chat requests are temporarily unavailable. Please try again in a moment.',
      'CHAT_REQUESTS_NOT_READY',
    );
  }
}

function _ensureRole(req) {
  const role = req.user.role;
  if (role !== 'candidate' && role !== 'business') {
    throw AppError.forbidden('Only candidates and businesses can manage chat requests.');
  }
  return role;
}

// ---------------------------------------------------------------------------
// POST — create new chat request
// ---------------------------------------------------------------------------
async function createChatRequest(req, res, next) {
  try {
    await _ensureReady();
    const requesterRole = _ensureRole(req);
    const body = req.body || {};

    // Resolve the requester's profile row + target id depending on
    // direction. Body shape:
    //   • candidate caller → { business_id }
    //   • business  caller → { candidate_id }
    let candidateId; let businessId;
    let requesterUserId = req.user.id; let recipientRole; let recipientUserId;

    if (requesterRole === 'candidate') {
      const targetBizId = typeof body.business_id === 'string' ? body.business_id.trim() : '';
      if (!targetBizId) {
        throw AppError.badRequest('business_id is required.');
      }
      const cand = await db('candidates').where({ user_id: req.user.id }).select('id').first();
      if (!cand) throw AppError.notFound('Candidate profile not found.');
      const biz = await db('businesses').where({ id: targetBizId }).select('id', 'user_id').first();
      if (!biz) {
        throw AppError.notFound('Business not found.', 'BUSINESS_NOT_FOUND');
      }
      candidateId = cand.id;
      businessId = biz.id;
      recipientUserId = biz.user_id;
      recipientRole = 'business';
    } else {
      const targetCandId = typeof body.candidate_id === 'string' ? body.candidate_id.trim() : '';
      if (!targetCandId) {
        throw AppError.badRequest('candidate_id is required.');
      }
      const biz = await db('businesses').where({ user_id: req.user.id }).select('id').first();
      if (!biz) throw AppError.notFound('Business profile not found.');
      const cand = await db('candidates').where({ id: targetCandId }).select('id', 'user_id').first();
      if (!cand) {
        throw AppError.notFound('Candidate not found.', 'CANDIDATE_NOT_FOUND');
      }
      candidateId = cand.id;
      businessId = biz.id;
      recipientUserId = cand.user_id;
      recipientRole = 'candidate';
    }

    // Optional opener message — capped to keep notification bodies sane.
    let message = null;
    if (body.message !== undefined && body.message !== null) {
      if (typeof body.message !== 'string') {
        throw AppError.badRequest('message must be a string or null.');
      }
      const trimmed = body.message.trim();
      if (trimmed.length > _MAX_MESSAGE_LENGTH) {
        throw AppError.badRequest(`message must be at most ${_MAX_MESSAGE_LENGTH} characters.`);
      }
      message = trimmed || null;
    }

    // Bypass shortcut #1: a non-archived conversation already exists
    // for this pair (created by AL.5.6 urgent handoff, business
    // shortlist flow, applicant flow, etc.). Skip the gate — return
    // a synthetic "accepted" response so the caller opens chat
    // directly without inserting a chat_request row.
    const existingConv = await db('conversations')
      .where({ candidate_id: candidateId, business_id: businessId })
      .whereNot('status', 'archived')
      .first();
    if (existingConv) {
      return res.status(200).json({
        success: true,
        data: {
          id: null,
          status: 'accepted',
          conversation_id: existingConv.id,
          bypassed: true,
          bypass_reason: 'conversation_exists',
          candidate_id: candidateId,
          business_id: businessId,
        },
      });
    }

    // Bypass shortcut #2: an accepted chat_request with a valid
    // conversation_id already exists for this pair (avoids creating
    // a redundant pending row when the previous accept is intact).
    const existingAccepted = await db('chat_requests')
      .where({ candidate_id: candidateId, business_id: businessId, status: 'accepted' })
      .whereNotNull('conversation_id')
      .orderBy('responded_at', 'desc')
      .first();
    if (existingAccepted) {
      return res.status(200).json({
        success: true,
        data: {
          id: existingAccepted.id,
          status: 'accepted',
          conversation_id: existingAccepted.conversation_id,
          bypassed: true,
          bypass_reason: 'already_accepted',
          candidate_id: candidateId,
          business_id: businessId,
        },
      });
    }

    // Duplicate-pending guard. Partial unique index also enforces
    // this at DB level — we pre-check here to surface a friendly
    // 409 instead of a constraint violation error.
    const existingPending = await db('chat_requests')
      .where({ candidate_id: candidateId, business_id: businessId, status: 'pending' })
      .first();
    if (existingPending) {
      throw AppError.conflict(
        'A pending chat request already exists for this pair.',
        'CHAT_REQUEST_ALREADY_PENDING',
      );
    }

    // Denied-cooldown guard. Only blocks the SAME requester
    // (different direction is unaffected).
    const cooldownCutoffMs = Date.now() - (_COOLDOWN_DAYS * 24 * 60 * 60 * 1000);
    const cooldownRow = await db('chat_requests')
      .where({
        candidate_id: candidateId,
        business_id: businessId,
        requester_user_id: requesterUserId,
        status: 'denied',
      })
      .where('responded_at', '>', new Date(cooldownCutoffMs).toISOString())
      .orderBy('responded_at', 'desc')
      .first();
    if (cooldownRow) {
      const retryAtMs = new Date(cooldownRow.responded_at).getTime()
        + (_COOLDOWN_DAYS * 24 * 60 * 60 * 1000);
      return res.status(429).json({
        success: false,
        error: 'You already requested this contact recently. Please try again later.',
        code: 'CHAT_REQUEST_COOLDOWN',
        retry_at: new Date(retryAtMs).toISOString(),
      });
    }

    const expiresAt = new Date(Date.now() + _EXPIRY_DAYS * 24 * 60 * 60 * 1000);

    let inserted;
    try {
      [inserted] = await db('chat_requests').insert({
        candidate_id: candidateId,
        business_id: businessId,
        requester_user_id: requesterUserId,
        requester_role: requesterRole,
        recipient_user_id: recipientUserId,
        recipient_role: recipientRole,
        status: 'pending',
        message,
        expires_at: expiresAt.toISOString(),
      }).returning('*');
    } catch (e) {
      // Catch the partial-unique-index violation in case a
      // concurrent insert beat us to it (unlikely but defensive).
      const msg = String(e?.message || '');
      if (msg.includes('uniq_chat_requests_pair_pending') || msg.includes('duplicate key')) {
        throw AppError.conflict(
          'A pending chat request already exists for this pair.',
          'CHAT_REQUEST_ALREADY_PENDING',
        );
      }
      throw e;
    }

    const enriched = await _baseQuery()
      .where('chat_requests.id', inserted.id)
      .select(..._PROFILE_JOINS)
      .first();

    return res.status(201).json({
      success: true,
      data: _shapeRow(enriched),
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// GET — list own chat requests (caller is either side)
// ---------------------------------------------------------------------------
async function listChatRequests(req, res, next) {
  try {
    await _ensureReady();
    _ensureRole(req);

    const direction = ['incoming', 'outgoing', 'all'].includes(req.query.direction)
      ? req.query.direction : 'all';
    const statusFilterRaw = req.query.status;
    const limit = Math.max(1, Math.min(parseInt(req.query.limit, 10) || _DEFAULT_LIMIT, _MAX_LIMIT));

    let q = _baseQuery();
    if (direction === 'incoming') {
      q = q.where('chat_requests.recipient_user_id', req.user.id);
    } else if (direction === 'outgoing') {
      q = q.where('chat_requests.requester_user_id', req.user.id);
    } else {
      q = q.where((b) => b
        .where('chat_requests.recipient_user_id', req.user.id)
        .orWhere('chat_requests.requester_user_id', req.user.id));
    }

    if (statusFilterRaw && ['pending', 'accepted', 'denied', 'cancelled', 'expired']
        .includes(statusFilterRaw)) {
      q = q.where('chat_requests.status', statusFilterRaw);
      // Lazy expired filter: when caller asks for pending, also drop
      // rows whose expires_at has passed (no DB write — they remain
      // 'pending' on disk until a future cleanup).
      if (statusFilterRaw === 'pending') {
        q = q.where('chat_requests.expires_at', '>', db.fn.now());
      }
    } else {
      // Default: hide expired pending rows from the list (clean UX).
      q = q.where((b) => b
        .whereNot('chat_requests.status', 'pending')
        .orWhere('chat_requests.expires_at', '>', db.fn.now()));
    }

    const rows = await q
      .orderBy('chat_requests.created_at', 'desc')
      .limit(limit)
      .select(..._PROFILE_JOINS);

    paginated(res, rows.map(_shapeRow), {
      page: 1,
      limit,
      total: rows.length,
    });
  } catch (err) { next(err); }
}

// ---------------------------------------------------------------------------
// PATCH — accept / deny (recipient) or cancel (requester)
// ---------------------------------------------------------------------------
async function respondToChatRequest(req, res, next) {
  try {
    await _ensureReady();
    _ensureRole(req);

    const body = req.body || {};
    const action = body.action;
    if (!['accept', 'deny', 'cancel'].includes(action)) {
      throw AppError.badRequest("action must be one of: 'accept', 'deny', 'cancel'.");
    }

    const result = await db.transaction(async (trx) => {
      const row = await trx('chat_requests').where({ id: req.params.id }).forUpdate().first();
      if (!row) {
        throw AppError.notFound('Chat request not found.', 'CHAT_REQUEST_NOT_FOUND');
      }

      // Authorization — caller must be the relevant party.
      if (action === 'cancel') {
        if (row.requester_user_id !== req.user.id) {
          // Don't leak existence — return 404.
          throw AppError.notFound('Chat request not found.', 'CHAT_REQUEST_NOT_FOUND');
        }
      } else {
        if (row.recipient_user_id !== req.user.id) {
          throw AppError.notFound('Chat request not found.', 'CHAT_REQUEST_NOT_FOUND');
        }
      }

      // Idempotent retry — same caller redoing the same terminal
      // action returns 200 with the existing state.
      if (action === 'accept' && row.status === 'accepted'
          && row.conversation_id) {
        return { row, idempotent: true };
      }
      if (action === 'deny' && row.status === 'denied') {
        return { row, idempotent: true };
      }
      if (action === 'cancel' && row.status === 'cancelled') {
        return { row, idempotent: true };
      }

      // Terminal-state collision (different action attempted on a
      // non-pending row).
      if (row.status !== 'pending') {
        const code = {
          accepted: 'CHAT_REQUEST_ALREADY_ACCEPTED',
          denied: 'CHAT_REQUEST_ALREADY_DENIED',
          cancelled: 'CHAT_REQUEST_ALREADY_CANCELLED',
          expired: 'CHAT_REQUEST_EXPIRED',
        }[row.status] || 'CHAT_REQUEST_TERMINAL';
        throw AppError.conflict(
          `Chat request is no longer pending (status=${row.status}).`,
          code,
        );
      }

      // Expired pending (lazy detection).
      if (new Date(row.expires_at).getTime() <= Date.now()) {
        // Mark expired in-place for cleaner future reads (single
        // write, still race-safe via the FOR UPDATE lock above).
        await trx('chat_requests').where({ id: row.id }).update({
          status: 'expired',
          updated_at: trx.fn.now(),
        });
        throw new AppError(
          'Chat request has expired.',
          410,
          'CHAT_REQUEST_EXPIRED',
        );
      }

      let updates = { updated_at: trx.fn.now(), responded_at: trx.fn.now() };
      let convId = null;

      if (action === 'accept') {
        // Find-or-create the 1:1 conversation. Mirrors the
        // businessController.startConversation + AL.5.6
        // acceptUrgentRequest pattern: whereNot status='archived',
        // reuse if found, else INSERT with default status='normal'.
        const existing = await trx('conversations')
          .where({ candidate_id: row.candidate_id, business_id: row.business_id })
          .whereNot('status', 'archived')
          .first();
        if (existing) {
          convId = existing.id;
        } else {
          const [created] = await trx('conversations').insert({
            candidate_id: row.candidate_id,
            business_id: row.business_id,
          }).returning('*');
          convId = created.id;
        }
        updates = { ...updates, status: 'accepted', conversation_id: convId };
      } else if (action === 'deny') {
        updates = { ...updates, status: 'denied' };
      } else {
        updates = { ...updates, status: 'cancelled' };
      }

      // Optimistic-lock-style guard: re-assert pending in the WHERE
      // (defensive — FOR UPDATE above already serializes us).
      const [updated] = await trx('chat_requests')
        .where({ id: row.id, status: 'pending' })
        .update(updates)
        .returning('*');
      if (!updated) {
        throw AppError.conflict(
          'Chat request was modified concurrently. Please refresh.',
          'CHAT_REQUEST_CONCURRENT_UPDATE',
        );
      }
      return { row: updated, idempotent: false };
    });

    const enriched = await _baseQuery()
      .where('chat_requests.id', result.row.id)
      .select(..._PROFILE_JOINS)
      .first();

    ok(res, _shapeRow(enriched));
  } catch (err) { next(err); }
}

module.exports = {
  createChatRequest,
  listChatRequests,
  respondToChatRequest,
};
