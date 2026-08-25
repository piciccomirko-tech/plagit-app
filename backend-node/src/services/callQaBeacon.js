'use strict';

/**
 * QA beacon sanitiser — Call Reliability Phase 1.
 *
 * The client already ships a diagnostic beacon when ICE reaches `connected`,
 * carrying the nominated candidate-pair verdict from getStats(). It is the
 * only way to see, from TestFlight builds that emit no readable device logs,
 * whether a real call took the TURN relay or a direct path.
 *
 * Everything crossing this boundary is client-supplied, so nothing is echoed
 * or stored verbatim: each field is mapped onto a closed vocabulary and
 * anything unrecognised becomes null. That also guarantees the beacon can
 * never be used to smuggle an IP address into the logs — WebRTC candidate
 * TYPES ('host' / 'srflx' / 'prflx' / 'relay') carry no addressing at all,
 * and a raw candidate string would simply not match the vocabulary.
 */

const PATHS = new Set(['RELAY', 'DIRECT']);
const ROLES = new Set(['caller', 'callee']);
const TYPES = new Set(['audio', 'video']);
const CANDIDATE_TYPES = new Set(['host', 'srflx', 'prflx', 'relay']);

/** Map onto a closed vocabulary, case-insensitively; else null. */
function pick(value, allowed, { upper = false } = {}) {
  if (typeof value !== 'string') return null;
  const v = upper ? value.trim().toUpperCase() : value.trim().toLowerCase();
  return allowed.has(v) ? v : null;
}

/** Non-negative integer milliseconds, capped so a bogus value can't skew logs. */
function pickDurationMs(value) {
  const n = Number.parseInt(value, 10);
  if (!Number.isFinite(n) || n < 0 || n > 10 * 60 * 1000) return null;
  return n;
}

function sanitizeQaBeacon(body) {
  const b = body && typeof body === 'object' ? body : {};
  return {
    role: pick(b.role, ROLES),
    type: pick(b.type, TYPES),
    path: pick(b.path, PATHS, { upper: true }),
    localCandidate: pick(b.local_candidate ?? b.localCandidate, CANDIDATE_TYPES),
    remoteCandidate: pick(
      b.remote_candidate ?? b.remoteCandidate,
      CANDIDATE_TYPES,
    ),
    engineToIceMs: pickDurationMs(b.engine_to_ice_ms ?? b.engineToIceMs),
  };
}

module.exports = { sanitizeQaBeacon, PATHS, ROLES, TYPES, CANDIDATE_TYPES };
