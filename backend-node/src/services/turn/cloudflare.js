'use strict';

/**
 * Cloudflare Calls TURN provider — Call Reliability Phase 1.
 *
 * Cloudflare does NOT use the coturn REST shared-secret scheme. There is no
 * secret we can HMAC locally: the backend holds a TURN key id plus an API
 * token and asks Cloudflare to mint a short-lived ICE credential per request.
 * Mixing the two authentication models would produce credentials the TURN
 * server rejects, so the two providers stay in separate modules and are
 * selected explicitly by `TURN_PROVIDER`.
 *
 * SECURITY
 *   • `CLOUDFLARE_TURN_API_TOKEN` is server-only and never appears in a
 *     response, a log line or an error surfaced to the device.
 *   • The credential Cloudflare returns is passed through VERBATIM. Rewriting
 *     it — or the urls it is scoped to — would invalidate it.
 */

const API_BASE = 'https://rtc.live.cloudflare.com/v1/turn/keys';
const DEFAULT_TIMEOUT_MS = 4000;

/**
 * Cloudflare answers with a single `iceServers` OBJECT, while flutter_webrtc
 * (and our endpoint contract) expects a LIST. Accept either shape so a future
 * response change does not break calling, and drop anything that does not
 * carry usable urls.
 */
function normalizeIceServers(payload) {
  const raw = payload && payload.iceServers;
  const list = Array.isArray(raw) ? raw : raw ? [raw] : [];
  const out = [];
  for (const entry of list) {
    if (!entry || typeof entry !== 'object') continue;
    const urls = []
      .concat(entry.urls || entry.url || [])
      .filter((u) => typeof u === 'string' && /^(stun|turn)s?:/i.test(u));
    if (urls.length === 0) continue;
    const server = { urls };
    // Only attach credentials when BOTH halves are present: a half-populated
    // TURN entry makes the engine fail authentication instead of skipping it.
    if (typeof entry.username === 'string' && entry.username.length > 0 &&
        typeof entry.credential === 'string' && entry.credential.length > 0) {
      server.username = entry.username;
      server.credential = entry.credential;
    }
    out.push(server);
  }
  return out;
}

const isTurn = (u) => /^turns?:/i.test(u);
const isTls = (u) => /^turns:/i.test(u);

/**
 * Request short-lived ICE servers from Cloudflare.
 *
 * Returns `null` on ANY failure — missing config, timeout, non-2xx, malformed
 * body — so the caller can fall back to STUN-only. It never throws and never
 * lets a Cloudflare error message reach the device: a diagnostic must not be
 * able to take calling down, and provider errors can carry account detail.
 */
async function fetchIceServers({
  env = process.env,
  ttlSeconds,
  fetchImpl = globalThis.fetch,
  timeoutMs = DEFAULT_TIMEOUT_MS,
  logger = console,
} = {}) {
  const keyId = String(env.CLOUDFLARE_TURN_KEY_ID || '').trim();
  const token = String(env.CLOUDFLARE_TURN_API_TOKEN || '').trim();
  if (!keyId || !token) {
    logger.warn(
      '[calls][ice] TURN_PROVIDER=cloudflare but key id / API token missing',
    );
    return null;
  }
  if (typeof fetchImpl !== 'function') {
    logger.warn('[calls][ice] no fetch implementation available');
    return null;
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    const res = await fetchImpl(
      `${API_BASE}/${encodeURIComponent(keyId)}/credentials/generate-ice-servers`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ ttl: ttlSeconds }),
        signal: controller.signal,
      },
    );

    if (!res || res.ok !== true) {
      // Status only — the body can name the account and is never logged.
      logger.warn(
        `[calls][ice] cloudflare credential request failed (status=${
          res && res.status ? res.status : 'none'
        })`,
      );
      return null;
    }

    const payload = await res.json();
    const iceServers = normalizeIceServers(payload);
    if (iceServers.length === 0) {
      logger.warn('[calls][ice] cloudflare returned no usable ICE servers');
      return null;
    }

    const urls = iceServers.flatMap((s) => s.urls);
    if (!urls.some(isTurn)) {
      logger.warn('[calls][ice] cloudflare response carried no TURN url');
      return null;
    }
    if (!urls.some(isTls)) {
      // Not fatal, but worth knowing: without a turns: transport, restrictive
      // hotel and venue wifi that only lets 443 out will still fail.
      logger.warn('[calls][ice] cloudflare response has no TLS (turns:) url');
    }

    return { iceServers, ttlSeconds };
  } catch (err) {
    const reason = err && err.name === 'AbortError' ? 'timeout' : 'error';
    // Deliberately not `err.message` — provider errors can carry account
    // identifiers, and this line goes to a shared log.
    logger.warn(`[calls][ice] cloudflare credential request ${reason}`);
    return null;
  } finally {
    clearTimeout(timer);
  }
}

module.exports = { fetchIceServers, normalizeIceServers, API_BASE };
