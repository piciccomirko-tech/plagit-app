// Phase 3.2 — push token registration foundation.
//
// Mounted at `/v1/push` by routes/index.js. Two endpoints:
//   POST /v1/push/register-token   — idempotent upsert
//   POST /v1/push/unregister-token — soft-revoke (sets revoked_at)
//
// Both authenticated. Token-owner identity is read from the JWT,
// never the body, so a caller can only register a token for their
// own account and can only unregister tokens they own.
//
// The legacy /v1/devices/* endpoints (mig 016 era) stay in place
// untouched — they use hard DELETE on unregister. P3.3 will migrate
// the Flutter client to /push/* and the legacy endpoints can retire
// in a follow-up cleanup once the 44 existing tokens have rotated.

const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const c = require('../controllers/pushController');

router.use(authenticate);

router.post('/register-token', c.registerToken);
router.post('/unregister-token', c.unregisterToken);

module.exports = router;
