// Stage AL.5.9 — Admin read-only urgent_requests visibility.
//
// Mounted at `/v1/admin/urgent-requests` by routes/index.js. Auth
// chain mirrors every other admin route: `authenticate` parses the
// JWT, `requireAdmin` rejects non-admin callers with 403.
//
// AL.5.9 ships read-only (decision #1) — no PATCH cancel, no DELETE,
// no moderation. The business owns the urgent_request lifecycle
// (AL.5.2 PATCH self-cancel, AL.5.6 candidate accept). Future
// moderation polish can attach to this same route file.

const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminUrgentRequestsController');

router.use(authenticate, requireAdmin);
router.get('/', c.list);

module.exports = router;
