'use strict';

/**
 * Call Reliability Phase 1 — endpoint behaviour.
 *
 * The database module is stubbed in the require cache before the controller
 * is loaded, so these run with no Postgres and no provider account: what is
 * under test is the contract the shipped Flutter client depends on, and the
 * refusal to leak anything through the diagnostic beacon.
 */

const test = require('node:test');
const assert = require('node:assert/strict');
const path = require('node:path');
const Module = require('node:module');

// --- stub `../config/db` before the controller pulls it in -----------------
const DB_PATH = path.join(__dirname, '..', '..', 'src', 'config', 'db.js');
let stubbedCall = null;
function dbStub(table) {
  assert.equal(table, 'calls');
  return {
    where() {
      return this;
    },
    async first() {
      return stubbedCall;
    },
  };
}
require.cache[DB_PATH] = new Module(DB_PATH, null);
require.cache[DB_PATH].filename = DB_PATH;
require.cache[DB_PATH].loaded = true;
require.cache[DB_PATH].exports = dbStub;

const ctrl = require('../../src/controllers/callIceController');

// --- minimal express doubles ---------------------------------------------
function makeRes() {
  const res = { statusCode: 200, body: undefined, ended: false };
  res.status = (c) => ((res.statusCode = c), res);
  res.json = (b) => ((res.body = b), res);
  res.end = () => ((res.ended = true), res);
  return res;
}

const withEnv = async (patch, fn) => {
  const saved = {};
  for (const k of Object.keys(patch)) {
    saved[k] = process.env[k];
    if (patch[k] === undefined) delete process.env[k];
    else process.env[k] = patch[k];
  }
  try {
    await fn();
  } finally {
    for (const k of Object.keys(patch)) {
      if (saved[k] === undefined) delete process.env[k];
      else process.env[k] = saved[k];
    }
  }
};

const CLEAN_TURN_ENV = {
  TURN_URLS: undefined,
  TURN_STATIC_AUTH_SECRET: undefined,
  TURN_USERNAME: undefined,
  TURN_CREDENTIAL: undefined,
  ICE_RELAY_QA_USER_IDS: undefined,
  ICE_FORCE_RELAY_ALL: undefined,
  STUN_URLS: undefined,
};

test('GET ice-servers returns the shape CallRepository.iceServers() parses', async () => {
  await withEnv(
    {
      ...CLEAN_TURN_ENV,
      TURN_URLS: 'turn:turn.example.net:3478?transport=udp',
      TURN_STATIC_AUTH_SECRET: 'shhh-test-only',
    },
    async () => {
      const res = makeRes();
      await ctrl.getIceServers({ user: { id: 'u-1' } }, res);

      assert.equal(res.body.success, true);
      const d = res.body.data;
      assert.ok(Array.isArray(d.iceServers), 'data.iceServers must be a list');
      assert.ok(d.iceServers.length >= 2, 'STUN + TURN');
      assert.equal(typeof d.iceTransportPolicy, 'string');
      assert.equal(d.turnEnabled, true);

      // Every entry must carry a `urls` the engine can read.
      for (const s of d.iceServers) {
        assert.ok(s.urls, 'each ICE server needs urls');
      }
    },
  );
});

test('GET ice-servers never returns the shared secret', async () => {
  const SECRET = 'super-secret-value-xyz';
  await withEnv(
    {
      ...CLEAN_TURN_ENV,
      TURN_URLS: 'turn:turn.example.net:3478',
      TURN_STATIC_AUTH_SECRET: SECRET,
    },
    async () => {
      const res = makeRes();
      await ctrl.getIceServers({ user: { id: 'u-1' } }, res);
      assert.ok(!JSON.stringify(res.body).includes(SECRET));
    },
  );
});

test('GET ice-servers degrades to STUN-only rather than failing', async () => {
  await withEnv(CLEAN_TURN_ENV, async () => {
    const res = makeRes();
    await ctrl.getIceServers({ user: { id: 'u-1' } }, res);
    assert.equal(res.body.success, true);
    assert.equal(res.body.data.turnEnabled, false);
    assert.equal(res.body.data.iceServers.length, 1);
    assert.equal(res.body.data.iceTransportPolicy, 'all');
  });
});

test('relay-only policy is served to an authorised QA user only', async () => {
  await withEnv(
    { ...CLEAN_TURN_ENV, ICE_RELAY_QA_USER_IDS: 'qa-user' },
    async () => {
      const qa = makeRes();
      await ctrl.getIceServers({ user: { id: 'qa-user' } }, qa);
      assert.equal(qa.body.data.iceTransportPolicy, 'relay');

      const normal = makeRes();
      await ctrl.getIceServers({ user: { id: 'someone-else' } }, normal);
      assert.equal(normal.body.data.iceTransportPolicy, 'all');
    },
  );
});

test('QA beacon accepts a participant and answers 204', async () => {
  stubbedCall = { id: 'call-1', caller_id: 'u-1', callee_id: 'u-2' };
  const res = makeRes();
  await ctrl.qaBeacon(
    {
      user: { id: 'u-2' },
      params: { id: 'call-1' },
      body: { role: 'callee', type: 'audio', path: 'RELAY' },
    },
    res,
  );
  assert.equal(res.statusCode, 204);
  assert.equal(res.ended, true);
});

test('QA beacon drops a non-participant without leaking call existence', async () => {
  stubbedCall = { id: 'call-1', caller_id: 'u-1', callee_id: 'u-2' };
  const res = makeRes();
  await ctrl.qaBeacon(
    { user: { id: 'intruder' }, params: { id: 'call-1' }, body: {} },
    res,
  );
  assert.equal(res.statusCode, 204, 'same answer as the happy path');
});

test('QA beacon answers 204 for an unknown call', async () => {
  stubbedCall = undefined;
  const res = makeRes();
  await ctrl.qaBeacon(
    { user: { id: 'u-1' }, params: { id: 'nope' }, body: {} },
    res,
  );
  assert.equal(res.statusCode, 204);
});

test('QA beacon does not throw on a hostile body', async () => {
  stubbedCall = { id: 'call-1', caller_id: 'u-1', callee_id: 'u-2' };
  for (const body of [undefined, null, 'x', { role: { $ne: 1 } }]) {
    const res = makeRes();
    await ctrl.qaBeacon(
      { user: { id: 'u-1' }, params: { id: 'call-1' }, body },
      res,
    );
    assert.equal(res.statusCode, 204);
  }
});
