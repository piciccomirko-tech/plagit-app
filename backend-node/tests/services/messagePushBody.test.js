/**
 * Unit tests for subscriber._internal.messagePushBody — the push-body
 * fallback for media chat messages.
 *
 * Contract: text messages (and media with a caption) keep their body
 * verbatim. Media messages with an EMPTY body — which is by design for
 * voice/photo/video/document attachments — fall back to a fixed label
 * derived from attachment_type so the lock-screen push is never blank:
 *   audio → "Voice message", image → "Photo", video → "Video",
 *   document → "Document", anything else → "New message".
 *
 * Pure: messagePushBody only reads the message object — no bus, no DB,
 * no FCM provider — so NO real push is ever dispatched by this suite.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const { _internal } = require('../../src/services/push/subscriber');
const { messagePushBody } = _internal;

test('text message keeps its body verbatim', () => {
  assert.equal(messagePushBody({ body: 'ciao', attachment_type: null }), 'ciao');
});

test('media message WITH caption keeps the caption', () => {
  assert.equal(messagePushBody({ body: 'guarda qui', attachment_type: 'image' }), 'guarda qui');
});

test('voice message (audio) falls back to "Voice message"', () => {
  assert.equal(messagePushBody({ body: '', attachment_type: 'audio' }), 'Voice message');
});

test('photo (image) falls back to "Photo"', () => {
  assert.equal(messagePushBody({ body: '', attachment_type: 'image' }), 'Photo');
});

test('video falls back to "Video"', () => {
  assert.equal(messagePushBody({ body: '', attachment_type: 'video' }), 'Video');
});

test('document falls back to "Document"', () => {
  assert.equal(messagePushBody({ body: '', attachment_type: 'document' }), 'Document');
});

test('unknown attachment type falls back to "New message"', () => {
  assert.equal(messagePushBody({ body: '', attachment_type: 'location' }), 'New message');
  assert.equal(messagePushBody({ body: '', attachment_type: 'album' }), 'New message');
});

test('missing/empty message degrades to "New message", never throws', () => {
  assert.equal(messagePushBody(undefined), 'New message');
  assert.equal(messagePushBody({}), 'New message');
  assert.equal(messagePushBody({ body: '   ', attachment_type: null }), 'New message');
});
