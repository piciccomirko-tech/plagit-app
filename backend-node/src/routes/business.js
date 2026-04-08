const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const c = require('../controllers/businessController');

router.use(authenticate);

// Profile & Dashboard
router.get('/profile', c.profile);
router.put('/profile', c.updateProfile);
router.post('/photo', c.uploadPhoto);
router.get('/home', c.home);

// Jobs
router.get('/jobs', c.listJobs);
router.post('/jobs', c.createJob);
router.get('/jobs/:id', c.getJob);
router.patch('/jobs/:id', c.updateJob);
router.get('/jobs/:id/applicants', c.listApplicants);

// Applicants
router.patch('/applicants/:id/status', c.updateApplicantStatus);

// Interviews
router.get('/interviews', c.listInterviews);
router.post('/interviews', c.scheduleInterview);
router.patch('/interviews/:id/status', c.updateInterviewStatus);

// Messages
router.get('/conversations', c.listConversations);
router.post('/conversations/start', c.startConversation);
router.delete('/conversations/:id', c.archiveConversation);
router.get('/conversations/:id/messages', c.listMessages);
router.post('/conversations/:id/messages', c.sendMessage);

// Candidates
router.get('/candidates/nearby', c.nearbyCandidates);
router.get('/candidates/:id', c.getCandidateProfile);

// Matches
router.get('/matches/:jobId', c.listJobMatches);
router.patch('/matches/:id/status', c.updateMatchStatus);
router.post('/feedback', c.submitMatchFeedback);

// Dashboard extras
router.get('/recent-applicants', c.recentApplicants);

// Notifications
router.get('/notifications', c.listNotifications);
router.patch('/notifications/read-all', c.markAllNotificationsRead);
router.patch('/notifications/:id/read', c.markNotificationRead);

module.exports = router;
