const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminLogsController');
router.use(authenticate, requireAdmin);
router.get('/', c.list);
module.exports = router;
