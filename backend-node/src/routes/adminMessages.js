const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminMessagesController');
router.use(authenticate, requireAdmin);
router.get('/', c.list);
router.patch('/:id/status', c.updateStatus);
router.delete('/:id', c.remove);
module.exports = router;
