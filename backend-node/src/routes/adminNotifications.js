const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminNotificationsController');
router.use(authenticate, requireAdmin);
router.get('/', c.list);
router.patch('/:id/delivery', c.updateDeliveryState);
router.patch('/:id/read', c.markRead);
module.exports = router;
