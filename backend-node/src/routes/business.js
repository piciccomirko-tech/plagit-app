const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const c = require('../controllers/businessController');
const boost = require('../controllers/businessBoostController');
const catalog = require('../controllers/productCatalogController');
const wallet = require('../controllers/businessWalletController');

router.use(authenticate);

// Product catalog (Step 4 — read-only, always on)
router.get('/job-products', catalog.listJobProducts);

// Wallet read (Step 6B — read-only, always on, scoped to logged-in business)
router.get('/wallet', wallet.getMyWallet);

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
router.post('/jobs/:id/duplicate', c.duplicateJob);
router.get('/jobs/:id/applicants', c.listApplicants);

// Boost activation (Step 3 — flag-gated by BOOST_ACTIVATION_ENABLED)
router.post('/jobs/:id/use-credit-boost', boost.useCreditBoost);
router.get('/jobs/:id/boost-status', boost.boostStatus);

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
router.post('/conversations/:id/messages/ack-delivered', c.ackMessagesDelivered);
router.post('/conversations/:id/typing', c.sendTyping);
// Reactions — one per user per message; POST upserts, DELETE removes.
router.post('/messages/:messageId/reactions', c.addMessageReaction);
router.delete('/messages/:messageId/reactions', c.removeMessageReaction);

// Candidates
router.get('/candidates/nearby', c.nearbyCandidates);
router.get('/candidates/:id', c.getCandidateProfile);

// Matches
router.get('/matches/:jobId', c.listJobMatches);
router.patch('/matches/:id/status', c.updateMatchStatus);
router.post('/feedback', c.submitMatchFeedback);

// Dashboard extras
router.get('/recent-applicants', c.recentApplicants);

// QuickPlug (Tinder-style swipe deck)
router.get('/quickplug/deck', c.quickplugDeck);
router.post('/quickplug/swipe', c.quickplugSwipe);

// Subscription
router.get('/subscription', c.subscription);

// Notifications
router.get('/notifications', c.listNotifications);
router.patch('/notifications/read-all', c.markAllNotificationsRead);
router.patch('/notifications/:id/read', c.markNotificationRead);
router.delete('/notifications/:id', c.deleteNotification);
router.delete('/notifications', c.deleteAllNotifications);

module.exports = router;
