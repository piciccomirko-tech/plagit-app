const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const g = require('../controllers/groupController');

// Group conversation endpoints (mig 049). Role-agnostic: any
// authenticated user can call these — membership is the only gate
// (enforced inside each handler via `_resolveMemberConversation`).
router.use(authenticate);

// Create a new group conversation.
router.post('/', g.createGroup);

// Member roster + management.
router.get('/:id/members', g.listGroupMembers);
router.post('/:id/members', g.addGroupMember);
router.delete('/:id/members/:userId', g.removeGroupMember);

// Rename / avatar_hue patch (creator-only).
router.patch('/:id', g.updateGroup);

// Group photo set/clear (creator-only). Body: { group_photo_url: string | null }
router.put('/:id/photo', g.updateGroupPhoto);

// Mark conversation read up to now (per-user cursor on
// conversation_members.last_read_at).
router.post('/:id/read', g.markGroupRead);

module.exports = router;
