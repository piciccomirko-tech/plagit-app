/**
 * Provider payment webhooks (server-to-server, NO user JWT).
 *
 * Apple App Store Server Notifications V2 → POST { signedPayload }. The
 * provider module verifies the signature, maps the notification to an
 * entitlement and upserts it. We always ACK 200 so a malformed/spoofed
 * payload can't make Apple retry-storm us; real verification/mapping failures
 * are logged. (Stripe/Google webhooks land here in their own steps.)
 *
 * Never log the signedPayload contents or any signing material.
 */
const { ok } = require('../utils/response');
const apple = require('../services/providers/apple');

async function appleWebhook(req, res) {
  try {
    const signedPayload = req.body && req.body.signedPayload;
    const result = await apple.handleNotification({ signedPayload });
    // eslint-disable-next-line no-console
    console.log('[webhook:apple]', JSON.stringify(result));
  } catch (err) {
    // eslint-disable-next-line no-console
    console.warn('[webhook:apple] not processed (non-fatal):', err.message);
  }
  return ok(res, { received: true });
}

module.exports = { appleWebhook };
