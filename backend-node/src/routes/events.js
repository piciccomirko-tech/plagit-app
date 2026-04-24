const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const { bus, audienceMatches } = require('../services/realtime/eventBus');

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

  // Initial hello so clients know the stream is live
  res.write(
    `event: ready\ndata: ${JSON.stringify({ userId: req.user.id, role: req.user.role, ts: new Date().toISOString() })}\n\n`
  );

  const onEvent = (event) => {
    if (!audienceMatches(req.user, event.audience)) return;
    const line = `event: ${event.type}\ndata: ${JSON.stringify(event)}\n\n`;
    try { res.write(line); } catch (_) { /* socket closed race */ }
  };

  bus.on('event', onEvent);

  const heartbeat = setInterval(() => {
    try { res.write(`: keep-alive ${Date.now()}\n\n`); } catch (_) { /* ignore */ }
  }, 25000);

  const cleanup = () => {
    clearInterval(heartbeat);
    bus.off('event', onEvent);
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
