/**
 * Call lifecycle routes — voice + video MVP (Step A).
 *
 * Mounted at /v1/calls (see src/routes/index.js). All four endpoints
 * require a valid JWT — the controller layer then verifies the user
 * is a participant of the conversation / the callee, where relevant.
 */

const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const c = require('../controllers/callController');
const cs = require('../controllers/callSignalController');

router.use(authenticate);

// Active call lookup (VoIP cold-start hydration) — GET before /:id routes
router.get('/active', c.getActive);

// Cold-start recovery: a callee that answered from a terminated/locked
// device has no SSE, so it fetches the pending offer + counterpart ICE +
// terminal state over REST to negotiate WebRTC (or dismiss CallKit).
router.get('/:id/recovery', c.recovery);

// Caller side
router.post('/initiate', c.initiate);

// Callee side
router.post('/:id/accept',  c.accept);
router.post('/:id/decline', c.decline);

// Either participant
router.post('/:id/end', c.end);

// WebRTC signaling (Step E1) — REST in, SSE fan-out via call.signal.*
router.post('/:id/signal/offer',  cs.submitOffer);
router.post('/:id/signal/answer', cs.submitAnswer);
router.post('/:id/signal/ice',    cs.submitIce);

module.exports = router;
