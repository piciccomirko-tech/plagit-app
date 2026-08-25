'use strict';

/**
 * Call reliability endpoints — Call Reliability Phase 1.
 *
 *   GET  /v1/calls/ice-servers   STUN + TURN config for the WebRTC engine
 *   POST /v1/calls/:id/qa        RELAY-vs-DIRECT diagnostic beacon
 *
 * Both were already implemented on the Flutter side and had no server half.
 * Neither touches the signalling path: `iceServers` is consumed by the
 * RTCPeerConnection constructor, so offer/answer/ICE routing is untouched.
 */

const db = require('../config/db');
const { ok, noContent } = require('../utils/response');
const {
  resolveIceConfig,
  resolveProvider,
  resolveTransportPolicy,
} = require('../services/iceServers');
const { sanitizeQaBeacon } = require('../services/callQaBeacon');

/**
 * GET /v1/calls/ice-servers
 *
 * Shape is fixed by the shipped client (`CallRepository.iceServers()`):
 * `data.iceServers` is the flutter_webrtc list, `data.iceTransportPolicy` is
 * honoured only when it equals 'relay'. `turnEnabled` / `ttlSeconds` are
 * additive diagnostics the client ignores.
 *
 * Never 5xx: a device that cannot read this config falls back to STUN-only
 * and still places calls. Failing the request would degrade calling further,
 * not protect it.
 */
async function getIceServers(req, res) {
  const userId = req.user && req.user.id;
  const config = await resolveIceConfig({ userId });
  const iceTransportPolicy = resolveTransportPolicy({ userId });

  // Diagnostics only — deliberately no username, no credential, no secret.
  if (!config.turnEnabled) {
    console.warn(
      `[calls][ice] TURN unavailable (provider=${resolveProvider()}) — ` +
        'serving STUN-only. Calls behind symmetric NAT / CGNAT will fail.',
    );
  } else if (iceTransportPolicy === 'relay') {
    console.info('[calls][ice] relay-only policy served (QA)');
  }

  return ok(res, {
    iceServers: config.iceServers,
    iceTransportPolicy,
    turnEnabled: config.turnEnabled,
    ttlSeconds: config.ttlSeconds,
  });
}

/**
 * POST /v1/calls/:id/qa
 *
 * Fire-and-forget on the client, so this stays cheap and always answers 204:
 * a diagnostic must never surface as an error on a live call. The payload is
 * mapped onto a closed vocabulary before it reaches the log.
 */
async function qaBeacon(req, res) {
  const userId = req.user && req.user.id;
  const callId = req.params.id;

  const call = await db('calls')
    .where({ id: callId })
    .first('id', 'caller_id', 'callee_id', 'type');

  // Unknown call, or a user who was never on it: accept and drop. Returning
  // 403/404 would only teach a caller which call ids exist.
  if (!call || (call.caller_id !== userId && call.callee_id !== userId)) {
    return noContent(res);
  }

  const b = sanitizeQaBeacon(req.body);
  console.info(
    `[calls][qa] call=${callId} role=${b.role ?? '-'} type=${b.type ?? '-'} ` +
      `path=${b.path ?? '-'} local=${b.localCandidate ?? '-'} ` +
      `remote=${b.remoteCandidate ?? '-'} setup_ms=${b.engineToIceMs ?? '-'}`,
  );

  return noContent(res);
}

module.exports = { getIceServers, qaBeacon };
