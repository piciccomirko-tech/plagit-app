const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminJobsController');
const boost = require('../controllers/adminBoostController');
router.use(authenticate, requireAdmin);
router.get('/', c.list);
router.get('/:id', c.get);
router.patch('/:id/status', c.updateStatus);
router.patch('/:id/featured', c.setFeatured);
router.delete('/:id', c.remove);

// Boost activation (Step 3 — flag-gated by BOOST_ACTIVATION_ENABLED)
router.post('/:id/grant-boost', boost.grantBoost);
router.delete('/:id/boost', boost.revokeBoost);

module.exports = router;
