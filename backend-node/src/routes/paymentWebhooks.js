/**
 * Payment provider webhooks — mounted at /v1/webhooks.
 *
 * NO `authenticate` middleware: these are server-to-server calls from the
 * stores (Apple now; Stripe/Google later), authenticated by the signed
 * payload the provider module verifies, not by a user JWT.
 */
const router = require('express').Router();
const c = require('../controllers/paymentWebhookController');

// Apple App Store Server Notifications V2
router.post('/apple', c.appleWebhook);

module.exports = router;
