'use strict';

/**
 * Call Reliability Phase 1 — Cloudflare TURN provider.
 *
 * The Cloudflare API is mocked: these must never make a real network call, and
 * they must fail loudly if the credential-minting contract drifts. Cloudflare
 * does not use the coturn shared-secret scheme, so the two auth models are
 * tested separately and must not bleed into each other.
 */

const test = require('node:test');
const assert = require('node:assert/strict');

const cf = require('../../src/services/turn/cloudflare');
const {
  resolveIceConfig,
  resolveProvider,
  resolveTtlSeconds,
  DEFAULT_CLOUDFLARE_TTL_SECONDS,
  MAX_CLOUDFLARE_TTL_SECONDS,
  MIN_TTL_SECONDS,
  DEFAULT_STUN,
} = require('../../src/services/iceServers');

const KEY_ID = 'test-key-id';
const TOKEN = 'cf-api-token-must-never-leak';
const NOW = 1_700_000_000_000;

const CF_ENV = {
  TURN_PROVIDER: 'cloudflare',
  CLOUDFLARE_TURN_KEY_ID: KEY_ID,
  CLOUDFLARE_TURN_API_TOKEN: TOKEN,
};

// Cloudflare answers with a single object, not a list, and includes its own
// STUN alongside UDP / TCP / TLS TURN transports.
const CF_BODY = {
  iceServers: {
    urls: [
      'stun:stun.cloudflare.com:3478',
      'turn:turn.cloudflare.com:3478?transport=udp',
      'turn:turn.cloudflare.com:3478?transport=tcp',
      'turns:turn.cloudflare.com:5349?transport=tcp',
      'turns:turn.cloudflare.com:443?transport=tcp',
    ],
    username: 'cf-ephemeral-username',
    credential: 'cf-ephemeral-credential',
  },
};

const silentLogger = { warn() {}, info() {} };

function okFetch(body, capture) {
  return async (url, init) => {
    if (capture) Object.assign(capture, { url, init });
    return { ok: true, status: 200, json: async () => body };
  };
}

test('provider selection is explicit and defaults to coturn', () => {
  assert.equal(resolveProvider({}), 'coturn');
  assert.equal(resolveProvider({ TURN_PROVIDER: 'cloudflare' }), 'cloudflare');
  assert.equal(resolveProvider({ TURN_PROVIDER: 'CloudFlare ' }), 'cloudflare');
  assert.equal(resolveProvider({ TURN_PROVIDER: 'coturn' }), 'coturn');
  assert.equal(resolveProvider({ TURN_PROVIDER: 'anything-else' }), 'coturn');
});

test('the request hits the documented endpoint with the token in the header', async () => {
  const seen = {};
  await cf.fetchIceServers({
    env: CF_ENV,
    ttlSeconds: 86400,
    fetchImpl: okFetch(CF_BODY, seen),
    logger: silentLogger,
  });

  assert.equal(
    seen.url,
    `${cf.API_BASE}/${KEY_ID}/credentials/generate-ice-servers`,
  );
  assert.equal(seen.init.method, 'POST');
  assert.equal(seen.init.headers.Authorization, `Bearer ${TOKEN}`);
  assert.deepEqual(JSON.parse(seen.init.body), { ttl: 86400 });
});

test('success mapping: object becomes a list, transports and credential kept verbatim', async () => {
  const cfg = await resolveIceConfig({
    userId: 'u-1',
    env: CF_ENV,
    now: NOW,
    fetchImpl: okFetch(CF_BODY),
    logger: silentLogger,
  });

  assert.equal(cfg.turnEnabled, true);
  assert.equal(cfg.credentialMode, 'cloudflare');
  assert.ok(Array.isArray(cfg.iceServers));
  assert.equal(cfg.iceServers.length, 1);

  const s = cfg.iceServers[0];
  // Every transport Cloudflare offered survives — including TLS on 443, which
  // is the only way out of restrictive hotel and venue wifi.
  assert.deepEqual(s.urls, CF_BODY.iceServers.urls);
  assert.ok(s.urls.some((u) => u.startsWith('turns:')));
  assert.ok(s.urls.some((u) => u.includes(':443')));
  // Cloudflare's credential is scoped to those urls: rewriting it breaks auth.
  assert.equal(s.username, 'cf-ephemeral-username');
  assert.equal(s.credential, 'cf-ephemeral-credential');
});

test('an array-shaped response is accepted too', () => {
  const out = cf.normalizeIceServers({
    iceServers: [
      { urls: 'turn:a.example:3478', username: 'u', credential: 'c' },
      { urls: ['stun:b.example:3478'] },
    ],
  });
  assert.equal(out.length, 2);
  assert.deepEqual(out[0].urls, ['turn:a.example:3478']);
  assert.equal(out[1].username, undefined, 'STUN needs no credential');
});

test('a half-populated credential is dropped rather than sent', () => {
  const out = cf.normalizeIceServers({
    iceServers: { urls: ['turn:a.example:3478'], username: 'u' },
  });
  assert.equal(out.length, 1);
  assert.equal(out[0].username, undefined);
  assert.equal(out[0].credential, undefined);
});

test('timeout falls back to STUN-only', async () => {
  const abort = async () => {
    const e = new Error('aborted');
    e.name = 'AbortError';
    throw e;
  };
  const cfg = await resolveIceConfig({
    userId: 'u-1',
    env: CF_ENV,
    now: NOW,
    fetchImpl: abort,
    logger: silentLogger,
  });
  assert.equal(cfg.turnEnabled, false);
  assert.deepEqual(cfg.iceServers, [{ urls: [DEFAULT_STUN] }]);
});

test('a non-2xx response falls back to STUN-only', async () => {
  const cfg = await resolveIceConfig({
    userId: 'u-1',
    env: CF_ENV,
    now: NOW,
    fetchImpl: async () => ({ ok: false, status: 401, json: async () => ({}) }),
    logger: silentLogger,
  });
  assert.equal(cfg.turnEnabled, false);
});

test('malformed responses fall back to STUN-only', async () => {
  for (const body of [
    {},
    { iceServers: null },
    { iceServers: {} },
    { iceServers: { urls: [] } },
    { iceServers: { urls: ['https://not-ice'] } },
    { iceServers: { urls: ['stun:only.example:3478'] } }, // no TURN at all
  ]) {
    const cfg = await resolveIceConfig({
      userId: 'u-1',
      env: CF_ENV,
      now: NOW,
      fetchImpl: okFetch(body),
      logger: silentLogger,
    });
    assert.equal(cfg.turnEnabled, false, JSON.stringify(body));
  }
});

test('a thrown/invalid json body falls back rather than crashing', async () => {
  const cfg = await resolveIceConfig({
    userId: 'u-1',
    env: CF_ENV,
    now: NOW,
    fetchImpl: async () => ({
      ok: true,
      status: 200,
      json: async () => {
        throw new Error('not json');
      },
    }),
    logger: silentLogger,
  });
  assert.equal(cfg.turnEnabled, false);
});

test('missing key id or API token never reaches the network', async () => {
  for (const env of [
    { TURN_PROVIDER: 'cloudflare' },
    { TURN_PROVIDER: 'cloudflare', CLOUDFLARE_TURN_KEY_ID: KEY_ID },
    { TURN_PROVIDER: 'cloudflare', CLOUDFLARE_TURN_API_TOKEN: TOKEN },
  ]) {
    let called = false;
    const cfg = await resolveIceConfig({
      userId: 'u-1',
      env,
      now: NOW,
      fetchImpl: async () => {
        called = true;
        return { ok: true, status: 200, json: async () => CF_BODY };
      },
      logger: silentLogger,
    });
    assert.equal(called, false, 'no request without complete credentials');
    assert.equal(cfg.turnEnabled, false);
  }
});

test('the API token never appears in anything the client receives', async () => {
  const cfg = await resolveIceConfig({
    userId: 'u-1',
    env: CF_ENV,
    now: NOW,
    fetchImpl: okFetch(CF_BODY),
    logger: silentLogger,
  });
  assert.ok(!JSON.stringify(cfg).includes(TOKEN));
  assert.ok(!JSON.stringify(cfg).includes(KEY_ID));
});

test('the coturn shared secret is never used in cloudflare mode', async () => {
  const SECRET = 'coturn-secret-should-be-ignored';
  const cfg = await resolveIceConfig({
    userId: 'u-1',
    env: { ...CF_ENV, TURN_STATIC_AUTH_SECRET: SECRET },
    now: NOW,
    fetchImpl: okFetch(CF_BODY),
    logger: silentLogger,
  });
  assert.equal(cfg.credentialMode, 'cloudflare');
  assert.equal(cfg.iceServers[0].username, 'cf-ephemeral-username');
  assert.ok(!JSON.stringify(cfg).includes(SECRET));
});

test('cloudflare TTL defaults long enough to outlive a call', async () => {
  const seen = {};
  await resolveIceConfig({
    userId: 'u-1',
    env: CF_ENV,
    now: NOW,
    fetchImpl: okFetch(CF_BODY, seen),
    logger: silentLogger,
  });
  const requested = JSON.parse(seen.init.body).ttl;
  assert.equal(requested, DEFAULT_CLOUDFLARE_TTL_SECONDS);
  assert.ok(
    requested >= 4 * 60 * 60,
    'must comfortably exceed the longest realistic Plagit call',
  );
});

test('cloudflare TTL is configurable and clamped to its own bounds', () => {
  const opts = {
    fallback: DEFAULT_CLOUDFLARE_TTL_SECONDS,
    max: MAX_CLOUDFLARE_TTL_SECONDS,
  };
  assert.equal(resolveTtlSeconds('7200', opts), 7200);
  assert.equal(resolveTtlSeconds('1', opts), MIN_TTL_SECONDS);
  assert.equal(resolveTtlSeconds('99999999', opts), MAX_CLOUDFLARE_TTL_SECONDS);
  assert.equal(resolveTtlSeconds('nonsense', opts), DEFAULT_CLOUDFLARE_TTL_SECONDS);
});

test('expiry is reported and sits in the future', async () => {
  const cfg = await resolveIceConfig({
    userId: 'u-1',
    env: { ...CF_ENV, TURN_TTL_SECONDS: '7200' },
    now: NOW,
    fetchImpl: okFetch(CF_BODY),
    logger: silentLogger,
  });
  assert.equal(cfg.ttlSeconds, 7200);
  assert.equal(cfg.expiresAt, Math.floor(NOW / 1000) + 7200);
});

test('cloudflare mode still honours the relay QA switch', async () => {
  const { resolveTransportPolicy } = require('../../src/services/iceServers');
  const env = { ...CF_ENV, ICE_RELAY_QA_USER_IDS: 'qa-1' };
  assert.equal(resolveTransportPolicy({ userId: 'qa-1', env }), 'relay');
  assert.equal(resolveTransportPolicy({ userId: 'u-2', env }), 'all');
});

test('coturn mode is untouched by the cloudflare code path', async () => {
  const cfg = await resolveIceConfig({
    userId: 'u-1',
    env: {
      TURN_URLS: 'turn:self.example:3478',
      TURN_STATIC_AUTH_SECRET: 'a-secret',
    },
    now: NOW,
    fetchImpl: async () => {
      throw new Error('cloudflare must not be called in coturn mode');
    },
    logger: silentLogger,
  });
  assert.equal(cfg.credentialMode, 'ephemeral');
});
