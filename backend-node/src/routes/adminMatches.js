const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminMatchesController');
router.use(authenticate, requireAdmin);
router.get('/', c.listMatches);
router.get('/stats', c.matchStats);
router.get('/feedback', c.listFeedback);
router.get('/notifications', c.matchNotifications);
module.exports = router;
