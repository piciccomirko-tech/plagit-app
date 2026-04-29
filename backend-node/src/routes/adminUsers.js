const router = require('express').Router();
const { authenticate, requireAdmin, requireRole } = require('../middleware/auth');
const c = require('../controllers/adminUsersController');

router.use(authenticate, requireAdmin);

router.get('/', c.listUsers);
router.get('/:id', c.getUser);
router.put('/:id', c.updateUser);
router.patch('/:id/verify', c.setVerified);
router.delete('/:id', c.deleteUser);
router.post('/:id/message', c.sendMessage);

// Security-sensitive: account-control actions are restricted to roles
// that own the support workflow. support_admin handles day-to-day
// password help and suspensions; super_admin retains full reach.
router.patch(
  '/:id/status',
  requireRole('super_admin', 'support_admin'),
  c.updateStatus,
);
router.post(
  '/:id/send-reset-link',
  requireRole('super_admin', 'support_admin'),
  c.sendResetLink,
);
router.post(
  '/:id/force-password-change',
  requireRole('super_admin', 'support_admin'),
  c.forcePasswordChange,
);

module.exports = router;
