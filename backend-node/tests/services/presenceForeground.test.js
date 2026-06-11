/**
 * Unit test: presence foreground-state freshness (CallKit suppression).
 *
 * `setAppState` / `isForeground` decide whether callController.initiate
 * SKIPS the VoIP push (callee foreground → in-app UI) or SENDS it
 * (background/locked/terminated/unknown/stale → CallKit rings). The TTL
 * guarantees a stale report self-expires to the safe default (send push).
 *
 * Pure in-memory — no DB query runs — but presence.js requires the knex
 * instance on load, so the suite closes the pool at teardown to let the
 * process exit cleanly.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const presence = require('../../src/services/realtime/presence');

test('isForeground: unknown user → false (safe default = send push)', () => {
  assert.equal(presence.isForeground('user-never-reported'), false);
});

test('isForeground: true immediately after a foreground=true report', () => {
  presence.setAppState('user-fg', true);
  assert.equal(presence.isForeground('user-fg'), true);
});

test('isForeground: false after a foreground=false (background) report', () => {
  presence.setAppState('user-bg', true);
  presence.setAppState('user-bg', false);
  assert.equal(presence.isForeground('user-bg'), false);
});

test('isForeground: empty userId is a no-op and stays false', () => {
  presence.setAppState('', true);
  assert.equal(presence.isForeground(''), false);
});

test('isForeground: state self-expires after the TTL (stale → false)', (t) => {
  t.mock.timers.enable({ apis: ['Date'] });

  presence.setAppState('user-stale', true);
  assert.equal(presence.isForeground('user-stale'), true, 'fresh within TTL');

  // Advance just past the freshness window.
  t.mock.timers.tick(presence.FOREGROUND_TTL_MS + 1);
  assert.equal(
    presence.isForeground('user-stale'),
    false,
    'stale beyond TTL falls back to not-foreground → push would be sent',
  );

  t.mock.timers.reset();
});

test('teardown: close db pool so the process exits', async () => {
  await require('../../src/config/db').destroy();
});
