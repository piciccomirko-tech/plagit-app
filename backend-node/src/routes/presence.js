const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const db = require('../config/db');
const presence = require('../services/realtime/presence');
const { ok } = require('../utils/response');
const AppError = require('../utils/AppError');

router.use(authenticate);

/**
 * GET /v1/presence/conversation/:convId
 *
 * Returns the peer (counterpart) of the authenticated user in a given
 * conversation and whether that peer currently has an active SSE
 * connection. The peer is determined from the caller's role — if the
 * caller is the business side, peer is the candidate user; and vice
 * versa. 404 if the caller doesn't participate in the conversation.
 *
 * Response: { peer_user_id, is_online }
 */
router.get('/conversation/:convId', async (req, res, next) => {
  try {
    const conv = await db('conversations').where({ id: req.params.convId }).first();
    if (!conv) throw AppError.notFound('Conversation not found.');

    const biz = conv.business_id
      ? await db('businesses').where({ id: conv.business_id }).select('user_id').first()
      : null;
    const cand = conv.candidate_id
      ? await db('candidates').where({ id: conv.candidate_id }).select('user_id').first()
      : null;

    let peerUserId = null;
    if (biz && biz.user_id === req.user.id) {
      peerUserId = cand ? cand.user_id : null;
    } else if (cand && cand.user_id === req.user.id) {
      peerUserId = biz ? biz.user_id : null;
    } else {
      throw AppError.notFound('Conversation not found.');
    }

    ok(res, {
      peer_user_id: peerUserId,
      is_online: peerUserId ? presence.isOnline(peerUserId) : false,
    });
  } catch (err) { next(err); }
});

module.exports = router;
