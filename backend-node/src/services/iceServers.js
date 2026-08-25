'use strict';

/**
 * ICE (STUN/TURN) configuration service — Call Reliability Phase 1.
 *
 * The Flutter client has shipped the full TURN integration for a while
 * (fetch + prewarm + `iceTransportPolicy` + a getStats() RELAY-vs-DIRECT
 * probe); the backend half was never implemented, so `GET /calls/ice-servers`
 * 404'd, the client swallowed it and every call fell back to STUN-only. That
 * silently breaks calls behind symmetric NAT and carrier CGNAT, which is the
 * single most common "it rings but nobody hears anything" report.
 *
 * This module is deliberately pure: no db, no express, no logging. Everything
 * comes from `env` and `now`, which is what makes the credential/TTL/fallback
 * behaviour testable without a server or a provider account.
 *
 * SECURITY
 *   • The shared secret NEVER leaves this process. Only the derived,
 *     short-lived username/credential pair is sent to the device.
 *   • Nothing here logs. Callers must not log the returned credentials
 *     either — see the controller.
 */

const crypto = require('crypto');

const DEFAULT_STUN = 'stun:stun.l.google.com:19302';
const DEFAULT_TTL_SECONDS = 600;
const MIN_TTL_SECONDS = 60;
const MAX_TTL_SECONDS = 3600;

/** Comma-separated env list → trimmed, non-empty entries. */
function parseList(raw) {
  if (typeof raw !== 'string') return [];
  return raw
    .split(',')
    .map((s) => s.trim())
    .filter((s) => s.length > 0);
}

const isTurnUrl = (u) => /^turns?:/i.test(u);
const isStunUrl = (u) => /^stuns?:/i.test(u);

/**
 * Clamp the credential lifetime. Too short and a slow ringing→accept window
 * hands the device an already-expired credential; too long and a leaked one
 * stays useful. Anything unparseable falls back to the default rather than
 * producing a NaN expiry.
 */
function resolveTtlSeconds(raw) {
  const n = Number.parseInt(raw, 10);
  if (!Number.isFinite(n)) return DEFAULT_TTL_SECONDS;
  return Math.min(MAX_TTL_SECONDS, Math.max(MIN_TTL_SECONDS, n));
}

/**
 * coturn REST-API credential (draft-uberti-behave-turn-rest-00), which every
 * major managed provider also accepts:
 *
 *   username   = "<unix-expiry>:<userId>"
 *   credential = base64( HMAC-SHA1( sharedSecret, username ) )
 *
 * The TURN server recomputes the HMAC from the same secret, so no per-user
 * account provisioning is needed and the pair dies on its own.
 */
function makeEphemeralCredential({ secret, userId, ttlSeconds, now }) {
  const expiresAt = Math.floor(now / 1000) + ttlSeconds;
  const username = `${expiresAt}:${userId}`;
  const credential = crypto
    .createHmac('sha1', secret)
    .update(username)
    .digest('base64');
  return { username, credential, expiresAt };
}

/**
 * Build the ICE server list for one user.
 *
 * Returns STUN-only — never throws, never errors — when TURN is unconfigured
 * or misconfigured. An honest degraded call beats a 500 that kills calling
 * outright, and `turnEnabled` lets the caller log the degradation.
 */
function buildIceConfig({ userId, env = process.env, now = Date.now() } = {}) {
  const configuredStun = parseList(env.STUN_URLS).filter(isStunUrl);
  const iceServers = [
    { urls: configuredStun.length > 0 ? configuredStun : [DEFAULT_STUN] },
  ];

  // Malformed entries are dropped rather than passed through: flutter_webrtc
  // rejects the whole config if any url is unparseable, so one typo in an env
  // var would take down every call.
  const turnUrls = parseList(env.TURN_URLS).filter(isTurnUrl);
  const secret = String(env.TURN_STATIC_AUTH_SECRET || '').trim();
  const staticUsername = String(env.TURN_USERNAME || '').trim();
  const staticCredential = String(env.TURN_CREDENTIAL || '').trim();
  const ttlSeconds = resolveTtlSeconds(env.TURN_TTL_SECONDS);

  if (turnUrls.length > 0 && secret && userId) {
    const c = makeEphemeralCredential({ secret, userId, ttlSeconds, now });
    iceServers.push({
      urls: turnUrls,
      username: c.username,
      credential: c.credential,
    });
    return {
      iceServers,
      turnEnabled: true,
      credentialMode: 'ephemeral',
      ttlSeconds,
      expiresAt: c.expiresAt,
    };
  }

  // Escape hatch for managed providers that mint their own pair out-of-band.
  // Long-lived, so it is the second choice, not the first.
  if (turnUrls.length > 0 && staticUsername && staticCredential) {
    iceServers.push({
      urls: turnUrls,
      username: staticUsername,
      credential: staticCredential,
    });
    return {
      iceServers,
      turnEnabled: true,
      credentialMode: 'static',
      ttlSeconds: null,
      expiresAt: null,
    };
  }

  return {
    iceServers,
    turnEnabled: false,
    credentialMode: 'none',
    ttlSeconds: null,
    expiresAt: null,
  };
}

/**
 * `relay` forces every candidate through TURN — no host, no srflx. It is the
 * only way to PROVE the relay works, and a terrible production default (it
 * relays traffic that would have gone peer-to-peer). So it is opt-in per user
 * id, or behind an explicit all-users switch for a staging environment.
 */
function resolveTransportPolicy({ userId, env = process.env } = {}) {
  const qaUserIds = parseList(env.ICE_RELAY_QA_USER_IDS);
  if (userId && qaUserIds.includes(String(userId))) return 'relay';
  if (String(env.ICE_FORCE_RELAY_ALL || '').trim() === '1') return 'relay';
  return 'all';
}

module.exports = {
  buildIceConfig,
  resolveTransportPolicy,
  makeEphemeralCredential,
  resolveTtlSeconds,
  DEFAULT_STUN,
  DEFAULT_TTL_SECONDS,
  MIN_TTL_SECONDS,
  MAX_TTL_SECONDS,
};
