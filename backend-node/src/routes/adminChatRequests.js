// Stage AL.6.5 — Admin read-only chat_requests visibility.
//
// Mounted at `/v1/admin/chat-requests` by routes/index.js. Auth
// chain mirrors every other admin route: `authenticate` parses the
// JWT, `requireAdmin` rejects non-admin callers with 403.
//
// AL.6.5 ships read-only (decision #1) — no PATCH cancel, no DELETE,
// no force accept/deny, no moderation. The candidate + business
// own the chat_request lifecycle (AL.6.1 POST/PATCH). Future
// moderation polish can attach to this same route file.
//
// Mirror of `adminUrgentRequests.js` (AL.5.9).

const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminChatRequestsController');

router.use(authenticate, requireAdmin);
router.get('/', c.list);

module.exports = router;
