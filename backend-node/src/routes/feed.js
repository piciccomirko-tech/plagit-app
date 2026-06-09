const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const c = require('../controllers/feedController');

// PUBLIC — feed media proxy (registered BEFORE authenticate) so <img src> and
// the video player can fetch media without an auth header. mediaId is an
// unguessable uuid (or <postId>-img/-vid for legacy); read-only, IDOR-guarded.
router.get('/media/:mediaId', c.getFeedMedia);

router.use(authenticate);

router.get('/notifications', c.listFeedNotifications);
router.get('/notifications/count', c.unreadNotifCount);
router.patch('/notifications/read-all', c.markAllNotifsRead);
router.patch('/notifications/:id/read', c.markNotifRead);
router.get('/following', c.listFollowing);
router.get('/', c.listPosts);
router.post('/', c.createPost);
router.post('/:id/like', c.toggleLike);
router.post('/:id/repost', c.toggleRepost);
router.get('/:id/comments', c.listComments);
router.post('/:id/comments', c.addComment);
router.delete('/:id', c.deletePost);
router.post('/:id/save', c.savePost);
router.delete('/:id/save', c.unsavePost);
router.post('/:id/view', c.recordView);
router.post('/follow/:userId', c.followUser);
router.delete('/follow/:userId', c.unfollowUser);

module.exports = router;
