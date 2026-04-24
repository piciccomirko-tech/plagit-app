const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const c = require('../controllers/deviceController');

router.use(authenticate);

router.post('/register', c.registerDevice);
router.delete('/:token', c.unregisterDevice);

module.exports = router;
