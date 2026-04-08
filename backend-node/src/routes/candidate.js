const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const c = require('../controllers/candidateController');

// All candidate routes require authentication but NOT admin role
router.use(authenticate);

// Profile & Dashboard
router.get('/profile', c.profile);
router.put('/profile', c.updateProfile);
router.post('/photo', c.uploadPhoto);
router.post('/cv', c.uploadCV);
router.post('/cv/parse', c.parseCV);
router.get('/home', c.home);

// Jobs
router.get('/jobs/nearby', c.nearbyJobs);
router.get('/jobs/featured', c.featuredJobs);
router.get('/jobs', c.listJobs);
router.get('/jobs/:id', c.getJob);
router.post('/jobs/:id/apply', c.applyToJob);

// Applications
router.get('/applications', c.listApplications);
router.get('/applications/:id', c.getApplication);
router.patch('/applications/:id/withdraw', c.withdrawApplication);

// Interviews
router.get('/interviews', c.listInterviews);
router.get('/interviews/:id', c.getInterview);
router.patch('/interviews/:id/respond', c.respondToInterview);

// Messages
router.get('/conversations', c.listConversations);
router.delete('/conversations/:id', c.archiveConversation);
router.get('/conversations/:id/messages', c.listMessages);
router.post('/conversations/:id/messages', c.sendMessage);

// Notifications
router.get('/notifications', c.listCandidateNotifications);
router.get('/notifications/count', c.candidateUnreadCount);
router.patch('/notifications/:id/read', c.markCandidateNotifRead);
router.patch('/notifications/read-all', c.markAllCandidateNotifsRead);

// Matches
router.get('/matches', c.listMatches);
router.patch('/matches/:id/status', c.updateMatchStatus);
router.post('/feedback', c.submitMatchFeedback);

// Community
router.get('/community', c.listCommunityPosts);

module.exports = router;
