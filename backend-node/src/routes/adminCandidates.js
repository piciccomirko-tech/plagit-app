const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminCandidatesController');
router.use(authenticate, requireAdmin);
router.get('/', c.list);
router.get('/:id', c.get);
router.patch('/:id/verification', c.updateVerification);
module.exports = router;
