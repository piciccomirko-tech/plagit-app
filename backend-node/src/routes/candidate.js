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

// Stage AL.2 — Availability Live: structured availability state
// + preferred_area_radius_km. Candidate-only (controller-side
// role gate). See db/migrations/051_candidate_availability_state.js
// for the column contract.
router.patch('/availability', c.updateAvailability);

// Phase 4 — public business profile lookup (used by chat
// EntityShareBubble navigation when a candidate taps a shared
// business profile card).
router.get('/businesses/:id', c.getBusinessProfile);

// Jobs
router.get('/jobs/nearby', c.nearbyJobs);
router.get('/jobs/featured', c.featuredJobs);
router.get('/jobs', c.listJobs);
router.get('/jobs/:id', c.getJob);
router.post('/jobs/:id/apply', c.applyToJob);

// Quick Jobs — Tinder-style swipe deck (mirror of Business Quick Plug)
router.get('/quickjobs/deck', c.quickjobsDeck);
router.post('/quickjobs/swipe', c.quickjobsSwipe);

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
// Phase 4 — Job picker scope guard. Candidate-side picker shows
// only jobs from the business at the other end of THIS thread.
router.get('/conversations/:id/business-jobs', c.listBusinessJobsForConversation);
router.get('/conversations/:id/business-interviews', c.listInterviewsForConversation);
router.post('/conversations/:id/messages', c.sendMessage);
router.post('/conversations/:id/messages/ack-delivered', c.ackMessagesDelivered);
router.post('/conversations/:id/typing', c.sendTyping);
// Reactions — one per user per message; POST upserts, DELETE removes.
router.post('/messages/:messageId/reactions', c.addMessageReaction);
router.delete('/messages/:messageId/reactions', c.removeMessageReaction);

// Stars — per-user bookmark; POST is idempotent, DELETE removes own.
router.post('/messages/:messageId/star', c.starMessage);
router.delete('/messages/:messageId/star', c.unstarMessage);

// Delete actions — POST .../hide soft-hides for the caller only;
// DELETE .../  tombstones for everyone (sender + 15-min window).
router.post('/messages/:messageId/hide', c.hideMessageForMe);
router.delete('/messages/:messageId', c.deleteMessageForEveryone);

// Report a message — Sprint 4E4. Persists into the platform-level
// `reports` table with type='message' and notifies admins.
router.post('/messages/:messageId/report', c.reportMessage);

// Notifications
router.get('/notifications', c.listCandidateNotifications);
router.get('/notifications/count', c.candidateUnreadCount);
router.patch('/notifications/:id/read', c.markCandidateNotifRead);
router.patch('/notifications/read-all', c.markAllCandidateNotifsRead);
router.delete('/notifications/:id', c.deleteCandidateNotif);
router.delete('/notifications', c.deleteAllCandidateNotifs);

// Matches
router.get('/matches', c.listMatches);
router.patch('/matches/:id/status', c.updateMatchStatus);
router.post('/feedback', c.submitMatchFeedback);

// Community
router.get('/community', c.listCommunityPosts);

// Stage AL.5.3 — Candidate-side matching for "Staff Needed Today"
// urgent requests. Read-only; role-gated to candidate JWTs;
// schema-flag-gated on both `urgent_requests` table (mig 052) and
// the AL.1 candidate availability columns (mig 051).
router.get('/urgent-requests', c.listUrgentRequestsForCandidate);

module.exports = router;
