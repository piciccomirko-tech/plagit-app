const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminReportsController');
router.use(authenticate, requireAdmin);
router.get('/', c.list);
router.patch('/:id/status', c.updateStatus);
router.patch('/:id/assign', c.assignAdmin);
module.exports = router;
