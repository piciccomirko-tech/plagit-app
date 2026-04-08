const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminApplicationsController');
router.use(authenticate, requireAdmin);
router.get('/', c.list);
router.patch('/:id/status', c.updateStatus);
module.exports = router;
