const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const { getStats, getRecentActivity, getNeedsAttention } = require('../controllers/adminDashboardController');

router.use(authenticate, requireAdmin);
router.get('/stats', getStats);
router.get('/activity', getRecentActivity);
router.get('/attention', getNeedsAttention);

module.exports = router;
