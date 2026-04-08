const router = require('express').Router();
const { authenticate, requireRole } = require('../middleware/auth');
const c = require('../controllers/adminSettingsController');
router.use(authenticate, requireRole('super_admin'));
router.get('/', c.getAll);
router.put('/', c.update);
module.exports = router;
