const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminInterviewsController');
router.use(authenticate, requireAdmin);
router.get('/', c.list);
router.post('/schedule', c.schedule);
router.patch('/:id/status', c.updateStatus);
module.exports = router;
