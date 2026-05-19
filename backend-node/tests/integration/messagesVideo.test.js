/**
 * Integration tests for chat video-message backend support.
 *
 * Skipped unless MESSAGES_VIDEO_TESTS=1 because they use the local
 * development DB, mirroring the existing messagesReply opt-in tests.
 */

'use strict';

const { test, after } = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.MESSAGES_VIDEO_TESTS === '1';

if (!RUN) {
  test('messages video tests skipped (set MESSAGES_VIDEO_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const db = require('../../src/config/db');
  const candidateController = require('../../src/controllers/candidateController');
  const businessController = require('../../src/controllers/businessController');

  after(async () => {
    await db.destroy();
  });

  const ELENA_USER_ID = '782c0cd7-d7be-4446-b142-0f2dc295035e';
  const NOBU_USER_ID = '192c4bb8-cde5-410f-9628-f2277d8e042f';
  const CONV_ID = '4e696bbf-8f00-4550-a485-2ff2f805ad87';

  function mockReq({ user, body = {}, params = {}, query = {} } = {}) {
    return { user, body, params, query, get: () => null };
  }

  function mockRes() {
    const state = { status: 200, body: null };
    return {
      _state: state,
      status(c) { state.status = c; return this; },
      json(b) { state.body = b; return this; },
    };
  }

  function call(fn, req) {
    const res = mockRes();
    let nextErr = null;
    return fn(req, res, (e) => { nextErr = e; })
      .then(() => ({ res: res._state, err: nextErr }));
  }

  function videoPayload(url = 'http://localhost:3000/uploads/video/test-video.mp4') {
    return {
      attachment_type: 'video',
      video_url: url,
      video_size_bytes: 123456,
      video_mime_type: 'video/mp4',
      video_duration_ms: 15000,
      video_width: 1080,
      video_height: 1920,
    };
  }

  test('candidate video send persists and listMessages returns metadata', async () => {
    let msgId = null;
    try {
      const req = mockReq({
        user: { id: ELENA_USER_ID },
        params: { id: CONV_ID },
        body: videoPayload(),
      });
      const { res, err } = await call(candidateController.sendMessage, req);
      assert.equal(err, null);
      assert.equal(res.status, 200);
      const saved = res.body.data;
      msgId = saved.id;
      assert.equal(saved.attachment_type, 'video');
      assert.equal(saved.video_url, videoPayload().video_url);
      assert.equal(saved.video_mime_type, 'video/mp4');

      const listed = await call(candidateController.listMessages, mockReq({
        user: { id: ELENA_USER_ID },
        params: { id: CONV_ID },
        query: { limit: '500' },
      }));
      assert.equal(listed.err, null);
      const row = listed.res.body.data.find((m) => m.id === msgId);
      assert.ok(row);
      assert.equal(row.attachment_type, 'video');
      assert.equal(row.video_url, videoPayload().video_url);
      assert.equal(row.video_duration_ms, 15000);
    } finally {
      if (msgId) await db('messages').where({ id: msgId }).del();
    }
  });

  test('candidate video send rejects non-owned URL', async () => {
    const req = mockReq({
      user: { id: ELENA_USER_ID },
      params: { id: CONV_ID },
      body: videoPayload('https://example.com/not-owned.mp4'),
    });
    const { err } = await call(candidateController.sendMessage, req);
    assert.ok(err);
    assert.equal(err.status, 400);
  });

  test('business video send rejects unsupported MIME', async () => {
    const req = mockReq({
      user: { id: NOBU_USER_ID },
      params: { id: CONV_ID },
      body: {
        ...videoPayload(),
        video_mime_type: 'video/avi',
      },
    });
    const { err } = await call(businessController.sendMessage, req);
    assert.ok(err);
    assert.equal(err.status, 400);
  });

  test('business video send persists and candidate listMessages returns metadata', async () => {
    let msgId = null;
    try {
      const req = mockReq({
        user: { id: NOBU_USER_ID },
        params: { id: CONV_ID },
        body: videoPayload('http://localhost:3000/uploads/video/business-video.mov'),
      });
      req.body.video_mime_type = 'video/quicktime';
      const { res, err } = await call(businessController.sendMessage, req);
      assert.equal(err, null);
      assert.equal(res.status, 200);
      const saved = res.body.data;
      msgId = saved.id;
      assert.equal(saved.attachment_type, 'video');
      assert.equal(saved.video_mime_type, 'video/quicktime');

      const listed = await call(candidateController.listMessages, mockReq({
        user: { id: ELENA_USER_ID },
        params: { id: CONV_ID },
        query: { limit: '500' },
      }));
      assert.equal(listed.err, null);
      const row = listed.res.body.data.find((m) => m.id === msgId);
      assert.ok(row);
      assert.equal(row.attachment_type, 'video');
      assert.equal(row.video_url, req.body.video_url);
      assert.equal(row.video_mime_type, 'video/quicktime');
    } finally {
      if (msgId) await db('messages').where({ id: msgId }).del();
    }
  });
}
