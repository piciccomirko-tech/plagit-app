const db = require('../config/db');
const { ok } = require('../utils/response');
const { isChatRequestsTablePresent } = require('../services/schemaFeatureFlags');

/**
 * Stage AL.6.5 — Admin chat_requests visibility (read-only).
 *
 * Mirrors the chrome of `adminUrgentRequestsController.list` (AL.5.9)
 * with two intentional deviations:
 *   • limit-only (no page/offset) — per AL.6.5 decision #3, the audit
 *     view is a tight rolling window not a paginated browse
 *   • optional `candidate_id` / `business_id` exact-id filters in
 *     addition to `status` — surface for admin pivot when chasing a
 *     specific account incident
 *
 * Joins:
 *   • candidates       → candidate.name + avatar_hue + verified
 *   • businesses       → business.name + verified seal
 *   • users (cand/biz) → requester/recipient display names (raw user
 *                        name; profile-side dup is acceptable)
 *
 * Read-only — no admin moderation in AL.6.5 (decision #1). The
 * candidate + business own the chat_request lifecycle (AL.6.1 POST
 * create, AL.6.1 PATCH accept/deny/cancel). Admin observability only.
 *
 * Schema-flag-gated on the `chat_requests` table (mig 053) so a
 * pre-mig deploy returns 503, not 500 — matches the candidate /
 * business call-side contract from AL.6.1.
 */
async function list(req, res, next) {
  try {
    if (!(await isChatRequestsTablePresent())) {
      return res.status(503).json({
        success: false,
        error: 'Chat requests are temporarily unavailable.',
        code: 'CHAT_REQUESTS_NOT_READY',
      });
    }
    const { status, candidate_id, business_id, limit = 50 } = req.query;
    const limitN = Math.max(1, Math.min(parseInt(limit, 10) || 50, 100));

    let base = db('chat_requests')
      .leftJoin('candidates', 'chat_requests.candidate_id', 'candidates.id')
      .leftJoin('businesses', 'chat_requests.business_id', 'businesses.id')
      .leftJoin('users as cand_user', 'chat_requests.requester_user_id', 'cand_user.id')
      .leftJoin('users as biz_user',  'chat_requests.recipient_user_id', 'biz_user.id');

    if (status) {
      base = base.where('chat_requests.status', status);
    }
    if (candidate_id) {
      base = base.where('chat_requests.candidate_id', candidate_id);
    }
    if (business_id) {
      base = base.where('chat_requests.business_id', business_id);
    }

    const rows = await base
      .select(
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
        'candidates.avatar_hue as candidate_avatar_hue',
        'candidates.verification_status as candidate_verification_status',
        'businesses.name as business_name',
        'businesses.is_verified as business_is_verified',
        'cand_user.name as requester_display_name',
        'biz_user.name as recipient_display_name',
      )
      .orderBy('chat_requests.created_at', 'desc')
      .limit(limitN);

    ok(res, rows);
  } catch (e) { next(e); }
}

module.exports = { list };
