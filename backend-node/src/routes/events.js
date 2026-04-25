const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const { bus, audienceMatches } = require('../services/realtime/eventBus');
const presence = require('../services/realtime/presence');

/**
 * GET /v1/events/stream — Server-Sent Events stream.
 *
 * Opens a long-lived text/event-stream. Each realtime event whose audience
 * matches the authenticated user is written as a single SSE message.
 *
 * Heartbeat comment (": keep-alive") every 25s so intermediaries don't
 * close the connection for idleness.
 */
router.get('/stream', authenticate, (req, res) => {
  res.status(200).set({
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache, no-transform',
    Connection: 'keep-alive',
    'X-Accel-Buffering': 'no', // disable proxy buffering (nginx)
  });
  res.flushHeaders();

  console.log(`[SSE EMIT] stream OPEN userId=${req.user.id} role=${req.user.role}`);

  // Initial hello so clients know the stream is live
  res.write(
    `event: ready\ndata: ${JSON.stringify({ userId: req.user.id, role: req.user.role, ts: new Date().toISOString() })}\n\n`
  );

  // Register this connection with the presence registry. A 0→1 transition
  // will emit presence.update to every conversation counterpart so their
  // chat header flips to "Online" live.
  presence.connect(req.user.id).catch(() => { /* non-fatal */ });

  const onEvent = (event) => {
    const matches = audienceMatches(req.user, event.audience);
    if (event.type === 'message.new') {
      console.log(`[SSE EMIT] route → user=${req.user.id} role=${req.user.role} type=${event.type} convId=${event.payload && event.payload.conversation_id} match=${matches} audience=${JSON.stringify(event.audience)}`);
    }
    if (!matches) return;
    const line = `event: ${event.type}\ndata: ${JSON.stringify(event)}\n\n`;
    try {
      res.write(line);
      if (event.type === 'message.new') {
        console.log(`[SSE EMIT] route ✓ WROTE to user=${req.user.id} type=${event.type} convId=${event.payload && event.payload.conversation_id}`);
      }
    } catch (err) {
      console.log(`[SSE EMIT] route ✗ WRITE FAILED user=${req.user.id} type=${event.type} err=${err && err.message}`);
    }
  };

  bus.on('event', onEvent);

  const heartbeat = setInterval(() => {
    try { res.write(`: keep-alive ${Date.now()}\n\n`); } catch (_) { /* ignore */ }
  }, 25000);

  const cleanup = () => {
    console.log(`[SSE EMIT] stream CLOSE userId=${req.user.id} role=${req.user.role}`);
    clearInterval(heartbeat);
    bus.off('event', onEvent);
    presence.disconnect(req.user.id).catch(() => { /* non-fatal */ });
    try { res.end(); } catch (_) { /* ignore */ }
  };

  req.on('close', cleanup);
  req.on('aborted', cleanup);
});

/**
 * POST /v1/events/ping — Dev-only: emit a test event addressed to self.
 * Useful for smoke-testing the SSE stream without triggering a real domain event.
 * Body: { message?: string }
 */
router.post('/ping', authenticate, (req, res) => {
  const event = bus.publish(
    'ping',
    { message: (req.body && req.body.message) || 'pong', from: req.user.id },
    [`user:${req.user.id}`]
  );
  res.status(200).json({ success: true, data: event });
});

module.exports = router;
