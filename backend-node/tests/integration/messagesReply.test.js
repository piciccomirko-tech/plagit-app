/**
 * Integration tests for Phase 3D — chat reply / quote support.
 *
 * Skipped automatically unless MESSAGES_REPLY_TESTS=1, mirroring
 * the opt-in pattern used by the rest of tests/integration.
 *
 * Covers:
 *   1. Candidate sends a text reply to a Business message — row
 *      stores `reply_to_message_id`.
 *   2. Cross-conversation reply target → 400.
 *   3. listMessages exposes a compact `reply_to` preview (id,
 *      sender_type, attachment_type, body_preview).
 *
 * Each test creates its own messages and deletes them after, so
 * the live thread stays clean.
 */

'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');

const RUN = process.env.MESSAGES_REPLY_TESTS === '1';

if (!RUN) {
  test('messages reply tests skipped (set MESSAGES_REPLY_TESTS=1)', () => {
    assert.ok(true);
  });
} else {
  const db = require('../../src/config/db');
  const candidateController = require('../../src/controllers/candidateController');
  const businessController = require('../../src/controllers/businessController');

  // Real Elena ↔ Nobu conversation (verified in prior session).
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

  /** Inserts a baseline parent text message authored by Nobu. */
  async function insertParent(body) {
    const [row] = await db('messages').insert({
      conversation_id: CONV_ID,
      sender_id: NOBU_USER_ID,
      body,
      attachment_type: 'text',
    }).returning('*');
    return row;
  }

  test('candidate text reply persists reply_to_message_id', async () => {
    const parent = await insertParent('PHASE_3D_TEST_PARENT');
    try {
      const req = mockReq({
        user: { id: ELENA_USER_ID },
        params: { id: CONV_ID },
        body: {
          body: 'PHASE_3D_TEST_REPLY',
          reply_to_message_id: parent.id,
        },
      });
      const { res, err } = await call(candidateController.sendMessage, req);
      assert.equal(err, null, 'no error expected');
      assert.equal(res.status, 200, 'expected 200 OK');
      assert.ok(res.body && res.body.data, 'envelope shape');
      const saved = res.body.data;
      assert.equal(saved.reply_to_message_id, parent.id);

      // Verify DB row directly too
      const dbRow = await db('messages').where({ id: saved.id }).first();
      assert.equal(dbRow.reply_to_message_id, parent.id);

      // Cleanup created reply
      await db('messages').where({ id: saved.id }).del();
    } finally {
      await db('messages').where({ id: parent.id }).del();
    }
  });

  test('cross-conversation reply target rejected', async () => {
    // Use a UUID that exists but lives in a different conversation
    // (or simply a random UUID not in this conv). A random UUID
    // also misses the same-conversation guard; use that.
    const fakeId = '00000000-0000-0000-0000-000000000000';
    const req = mockReq({
      user: { id: ELENA_USER_ID },
      params: { id: CONV_ID },
      body: {
        body: 'should be rejected',
        reply_to_message_id: fakeId,
      },
    });
    const { res, err } = await call(candidateController.sendMessage, req);
    assert.ok(err, 'expected an AppError');
    assert.equal(err.status, 400);
    assert.equal(res.body, null, 'no body should be sent');
  });

  test('listMessages exposes compact reply_to preview', async () => {
    const parent = await insertParent('PHASE_3D_LIST_PARENT');
    let replyId = null;
    try {
      // Insert a candidate-side reply directly so we don't have to
      // re-trigger the SSE path twice.
      const [reply] = await db('messages').insert({
        conversation_id: CONV_ID,
        sender_id: ELENA_USER_ID,
        body: 'PHASE_3D_LIST_REPLY',
        attachment_type: 'text',
        reply_to_message_id: parent.id,
      }).returning('*');
      replyId = reply.id;

      const req = mockReq({
        user: { id: ELENA_USER_ID },
        params: { id: CONV_ID },
        query: { limit: '500' },
      });
      const { res, err } = await call(candidateController.listMessages, req);
      assert.equal(err, null);
      assert.equal(res.status, 200);
      const items = res.body.data;
      const replyRow = items.find((m) => m.id === reply.id);
      assert.ok(replyRow, 'reply row must be in the list');
      assert.ok(replyRow.reply_to, 'reply_to must be populated');
      assert.equal(replyRow.reply_to.id, parent.id);
      assert.equal(replyRow.reply_to.attachment_type, 'text');
      assert.ok(replyRow.reply_to.body_preview.includes('PHASE_3D_LIST_PARENT'));
    } finally {
      if (replyId) await db('messages').where({ id: replyId }).del();
      await db('messages').where({ id: parent.id }).del();
    }
  });

  test('business sendMessage validates reply_to_message_id same-conv', async () => {
    const fakeId = '00000000-0000-0000-0000-000000000000';
    const req = mockReq({
      user: { id: NOBU_USER_ID },
      params: { id: CONV_ID },
      body: {
        body: 'should be rejected biz',
        reply_to_message_id: fakeId,
      },
    });
    const { res, err } = await call(businessController.sendMessage, req);
    assert.ok(err);
    assert.equal(err.status, 400);
  });
}
