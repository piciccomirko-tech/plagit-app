const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const c = require('../controllers/subscriptionController');

router.use(authenticate);

router.post('/verify', c.verifyReceipt);
router.get('/status', c.getStatus);
router.post('/restore', c.restorePurchase);

module.exports = router;
