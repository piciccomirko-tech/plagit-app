'use strict';

/**
 * Call Reliability Phase 1 — ICE config generation.
 *
 * Pure unit tests: no database, no provider account, no network. They run in
 * every suite because the failure they guard against (TURN silently absent,
 * or a leaked shared secret) is invisible until a real call fails in the
 * field.
 */

const test = require('node:test');
const assert = require('node:assert/strict');
const crypto = require('crypto');

const {
  buildIceConfig,
  resolveTransportPolicy,
  resolveTtlSeconds,
  DEFAULT_STUN,
  DEFAULT_TTL_SECONDS,
  MIN_TTL_SECONDS,
  MAX_TTL_SECONDS,
} = require('../../src/services/iceServers');
const { sanitizeQaBeacon } = require('../../src/services/callQaBeacon');

const SECRET = 'test-shared-secret-not-a-real-one';
const NOW = 1_700_000_000_000; // fixed clock → deterministic expiry
const USER = 'user-abc';

const turnEnv = (over = {}) => ({
  TURN_URLS:
    'turn:turn.example.net:3478?transport=udp,' +
    'turn:turn.example.net:3478?transport=tcp,' +
    'turns:turn.example.net:443?transport=tcp',
  TURN_STATIC_AUTH_SECRET: SECRET,
  ...over,
});

const turnEntry = (cfg) =>
  cfg.iceServers.find((s) =>
    []
      .concat(s.urls)
      .some((u) => /^turns?:/i.test(u)),
  );

test('TURN config generation — all three transports reach the client', () => {
  const cfg = buildIceConfig({ userId: USER, env: turnEnv(), now: NOW });
  assert.equal(cfg.turnEnabled, true);
  assert.equal(cfg.credentialMode, 'ephemeral');

  const turn = turnEntry(cfg);
  assert.ok(turn, 'a TURN entry must be present');
  assert.deepEqual(turn.urls, [
    'turn:turn.example.net:3478?transport=udp',
    'turn:turn.example.net:3478?transport=tcp',
    'turns:turn.example.net:443?transport=tcp',
  ]);

  // STUN is always first so the engine can still try the cheap path.
  assert.deepEqual(cfg.iceServers[0].urls, [DEFAULT_STUN]);
});

test('credential is a real coturn REST HMAC, independently reproducible', () => {
  const cfg = buildIceConfig({ userId: USER, env: turnEnv(), now: NOW });
  const turn = turnEntry(cfg);

  const expectedExpiry = Math.floor(NOW / 1000) + DEFAULT_TTL_SECONDS;
  assert.equal(turn.username, `${expectedExpiry}:${USER}`);

  const expected = crypto
    .createHmac('sha1', SECRET)
    .update(turn.username)
    .digest('base64');
  assert.equal(turn.credential, expected);
});

test('TTL is clamped, and a bogus value falls back instead of NaN', () => {
  assert.equal(resolveTtlSeconds(undefined), DEFAULT_TTL_SECONDS);
  assert.equal(resolveTtlSeconds('not-a-number'), DEFAULT_TTL_SECONDS);
  assert.equal(resolveTtlSeconds('1'), MIN_TTL_SECONDS);
  assert.equal(resolveTtlSeconds('999999'), MAX_TTL_SECONDS);
  assert.equal(resolveTtlSeconds('900'), 900);

  const cfg = buildIceConfig({
    userId: USER,
    env: turnEnv({ TURN_TTL_SECONDS: '900' }),
    now: NOW,
  });
  assert.equal(cfg.ttlSeconds, 900);
  assert.equal(cfg.expiresAt, Math.floor(NOW / 1000) + 900);
});

test('expiry is in the future and short-lived', () => {
  const cfg = buildIceConfig({ userId: USER, env: turnEnv(), now: NOW });
  const nowSec = Math.floor(NOW / 1000);
  assert.ok(cfg.expiresAt > nowSec, 'credential must not be born expired');
  assert.ok(
    cfg.expiresAt - nowSec <= MAX_TTL_SECONDS,
    'credential must not be long-lived',
  );
});

test('missing configuration degrades to STUN-only, never throws', () => {
  for (const env of [
    {},
    { TURN_URLS: '' },
    { TURN_URLS: turnEnv().TURN_URLS }, // urls but no secret
    { TURN_STATIC_AUTH_SECRET: SECRET }, // secret but no urls
  ]) {
    const cfg = buildIceConfig({ userId: USER, env, now: NOW });
    assert.equal(cfg.turnEnabled, false);
    assert.equal(cfg.credentialMode, 'none');
    assert.equal(cfg.iceServers.length, 1);
    assert.deepEqual(cfg.iceServers[0].urls, [DEFAULT_STUN]);
  }
});

test('a user id is required before any credential is minted', () => {
  const cfg = buildIceConfig({ userId: undefined, env: turnEnv(), now: NOW });
  assert.equal(cfg.turnEnabled, false, 'no anonymous TURN credentials');
});

test('malformed urls are dropped, not forwarded to the engine', () => {
  const cfg = buildIceConfig({
    userId: USER,
    env: turnEnv({
      TURN_URLS: 'https://not-a-turn-url, ,turn:good.example.net:3478',
      STUN_URLS: 'http://nope.example.net,stun:good.example.net:3478',
    }),
    now: NOW,
  });
  assert.deepEqual(cfg.iceServers[0].urls, ['stun:good.example.net:3478']);
  assert.deepEqual(turnEntry(cfg).urls, ['turn:good.example.net:3478']);
});

test('an entirely malformed TURN list degrades to STUN-only', () => {
  const cfg = buildIceConfig({
    userId: USER,
    env: turnEnv({ TURN_URLS: 'https://a,ftp://b' }),
    now: NOW,
  });
  assert.equal(cfg.turnEnabled, false);
});

test('the shared secret never appears anywhere in the response', () => {
  const cfg = buildIceConfig({ userId: USER, env: turnEnv(), now: NOW });
  const serialized = JSON.stringify(cfg);
  assert.ok(
    !serialized.includes(SECRET),
    'the shared secret must never leave the server',
  );
  // Nor its raw HMAC bytes in any other encoding.
  const hex = crypto.createHmac('sha1', SECRET).update('x').digest('hex');
  assert.ok(!serialized.includes(hex));
});

test('a managed provider static pair is accepted as the second choice', () => {
  const cfg = buildIceConfig({
    userId: USER,
    env: {
      TURN_URLS: 'turn:managed.example.net:3478',
      TURN_USERNAME: 'provider-user',
      TURN_CREDENTIAL: 'provider-pass',
    },
    now: NOW,
  });
  assert.equal(cfg.turnEnabled, true);
  assert.equal(cfg.credentialMode, 'static');
  assert.equal(turnEntry(cfg).username, 'provider-user');
});

test('ephemeral wins over static when both are configured', () => {
  const cfg = buildIceConfig({
    userId: USER,
    env: turnEnv({ TURN_USERNAME: 'u', TURN_CREDENTIAL: 'p' }),
    now: NOW,
  });
  assert.equal(cfg.credentialMode, 'ephemeral');
});

test('relay policy is opt-in — production default is "all"', () => {
  assert.equal(resolveTransportPolicy({ userId: USER, env: {} }), 'all');
  assert.equal(
    resolveTransportPolicy({ userId: USER, env: turnEnv() }),
    'all',
    'configuring TURN must not silently force every call through the relay',
  );
});

test('relay policy is granted only to authorised QA user ids', () => {
  const env = { ICE_RELAY_QA_USER_IDS: 'qa-1, qa-2' };
  assert.equal(resolveTransportPolicy({ userId: 'qa-1', env }), 'relay');
  assert.equal(resolveTransportPolicy({ userId: 'qa-2', env }), 'relay');
  assert.equal(resolveTransportPolicy({ userId: 'qa-3', env }), 'all');
  assert.equal(resolveTransportPolicy({ userId: undefined, env }), 'all');
});

test('the all-users relay switch is explicit and exact', () => {
  assert.equal(
    resolveTransportPolicy({ userId: USER, env: { ICE_FORCE_RELAY_ALL: '1' } }),
    'relay',
  );
  for (const v of ['0', 'true', 'yes', '', ' ']) {
    assert.equal(
      resolveTransportPolicy({ userId: USER, env: { ICE_FORCE_RELAY_ALL: v } }),
      'all',
      `"${v}" must not enable relay-only`,
    );
  }
});

test('QA beacon accepts the exact payload the client sends', () => {
  const clean = sanitizeQaBeacon({
    role: 'callee',
    type: 'audio',
    path: 'RELAY',
    local_candidate: 'relay',
    remote_candidate: 'srflx',
    engine_to_ice_ms: 1840,
  });
  assert.deepEqual(clean, {
    role: 'callee',
    type: 'audio',
    path: 'RELAY',
    localCandidate: 'relay',
    remoteCandidate: 'srflx',
    engineToIceMs: 1840,
  });
});

test('QA beacon maps anything outside the vocabulary to null', () => {
  const clean = sanitizeQaBeacon({
    role: 'attacker',
    type: 'screen_share',
    path: 'MAYBE',
    local_candidate: 'candidate:1 1 UDP 2122 192.168.1.7 51000 typ host',
    remote_candidate: { nested: true },
    engine_to_ice_ms: -5,
  });
  assert.deepEqual(clean, {
    role: null,
    type: null,
    path: null,
    localCandidate: null,
    remoteCandidate: null,
    engineToIceMs: null,
  });
});

test('QA beacon survives a missing or hostile body', () => {
  for (const body of [undefined, null, 'string', 42, []]) {
    const clean = sanitizeQaBeacon(body);
    assert.equal(clean.path, null);
    assert.equal(clean.engineToIceMs, null);
  }
});

test('QA beacon normalises case and rejects absurd durations', () => {
  assert.equal(sanitizeQaBeacon({ path: 'relay' }).path, 'RELAY');
  assert.equal(sanitizeQaBeacon({ role: 'CALLER' }).role, 'caller');
  assert.equal(sanitizeQaBeacon({ engine_to_ice_ms: 99_999_999 }).engineToIceMs, null);
});

test('the shape production actually has today yields working TURN', () => {
  // Production already carries TURN_URLS / TURN_USERNAME / TURN_CREDENTIAL for
  // a managed relay, and no TURN_PROVIDER and no shared secret. That must
  // resolve to a usable TURN config the moment the endpoint ships — the whole
  // point of this work is that those variables were configured but nothing
  // ever served them.
  const cfg = buildIceConfig({
    userId: USER,
    env: {
      TURN_URLS: [
        'turn:global.relay.example:80',
        'turn:global.relay.example:80?transport=tcp',
        'turn:global.relay.example:443',
        'turns:global.relay.example:443?transport=tcp',
      ].join(','),
      TURN_USERNAME: 'provider-issued-user',
      TURN_CREDENTIAL: 'provider-issued-pass',
    },
    now: NOW,
  });

  assert.equal(cfg.turnEnabled, true, 'existing managed TURN must be served');
  assert.equal(cfg.credentialMode, 'static');

  const urls = turnEntry(cfg).urls;
  assert.equal(urls.length, 4, 'every configured transport survives');
  assert.ok(urls.some((u) => u.startsWith('turns:')), 'TLS must be offered');
  assert.ok(
    urls.some((u) => u.includes(':443')),
    'port 443 is the only way out of restrictive venue wifi',
  );
  assert.ok(
    urls.some((u) => !/transport=tcp/.test(u)),
    'a UDP-capable entry must remain — it is the best relay path',
  );
});

test('switching provider without its credentials must not silently kill TURN', async () => {
  // Setting TURN_PROVIDER=cloudflare on an environment configured for a
  // different managed relay would drop a WORKING relay to STUN-only. This
  // asserts the failure is total and obvious rather than partial.
  const { resolveIceConfig } = require('../../src/services/iceServers');
  const cfg = await resolveIceConfig({
    userId: USER,
    env: {
      TURN_PROVIDER: 'cloudflare',
      TURN_URLS: 'turn:global.relay.example:443',
      TURN_USERNAME: 'provider-issued-user',
      TURN_CREDENTIAL: 'provider-issued-pass',
    },
    now: NOW,
    fetchImpl: async () => ({ ok: false, status: 401, json: async () => ({}) }),
    logger: { warn() {}, info() {} },
  });
  assert.equal(cfg.turnEnabled, false);
  assert.equal(
    JSON.stringify(cfg).includes('provider-issued-user'),
    false,
    'the other provider\'s credentials are not reused under cloudflare mode',
  );
});
