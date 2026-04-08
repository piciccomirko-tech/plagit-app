const router = require('express').Router();
const { authenticate, requireAdmin } = require('../middleware/auth');
const c = require('../controllers/adminUsersController');

router.use(authenticate, requireAdmin);

router.get('/', c.listUsers);
router.get('/:id', c.getUser);
router.put('/:id', c.updateUser);
router.patch('/:id/status', c.updateStatus);
router.patch('/:id/verify', c.setVerified);
router.delete('/:id', c.deleteUser);
router.post('/:id/message', c.sendMessage);

module.exports = router;
