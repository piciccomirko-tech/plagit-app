const router = require('express').Router();

// Public
router.use('/auth', require('./auth'));

// Realtime (SSE)
router.use('/events', require('./events'));
router.use('/presence', require('./presence'));

// Push notifications (APNS / FCM)
router.use('/devices', require('./devices'));

// Media uploads (voice messages today, future image/video)
router.use('/uploads', require('./uploads'));

// Candidate
router.use('/candidate', require('./candidate'));

// Business
router.use('/business', require('./business'));

// Group conversations (mig 049) — role-agnostic, members-only.
router.use('/groups', require('./group'));

// Social Feed (shared by candidate + business)
router.use('/feed', require('./feed'));

// Voice + Video calls (WebRTC P2P MVP — Step A: REST only, no SSE yet)
router.use('/calls', require('./calls'));

// Subscriptions
router.use('/subscription', require('./subscription'));

// Admin
router.use('/admin/dashboard', require('./adminDashboard'));
router.use('/admin/users', require('./adminUsers'));
router.use('/admin/businesses', require('./adminBusinesses'));
router.use('/admin/candidates', require('./adminCandidates'));
router.use('/admin/jobs', require('./adminJobs'));
router.use('/admin/applications', require('./adminApplications'));
router.use('/admin/interviews', require('./adminInterviews'));
router.use('/admin/messages', require('./adminMessages'));
router.use('/admin/notifications', require('./adminNotifications'));
router.use('/admin/reports', require('./adminReports'));
router.use('/admin/subscriptions', require('./adminSubscriptions'));
router.use('/admin/community', require('./adminCommunity'));
router.use('/admin/featured', require('./adminFeatured'));
router.use('/admin/matches', require('./adminMatches'));
router.use('/admin/logs', require('./adminLogs'));
router.use('/admin/settings', require('./adminSettings'));
// Stage AL.5.9 — Admin read-only urgent requests visibility.
router.use('/admin/urgent-requests', require('./adminUrgentRequests'));

module.exports = router;
