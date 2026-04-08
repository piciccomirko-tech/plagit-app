import 'package:go_router/go_router.dart';

// Auth
import 'package:plagit/features/auth/views/splash_view.dart';
import 'package:plagit/features/auth/views/entry_view.dart';
import 'package:plagit/features/auth/views/candidate_login_view.dart';
import 'package:plagit/features/auth/views/candidate_register_view.dart';
import 'package:plagit/features/auth/views/forgot_password_view.dart';
import 'package:plagit/features/auth/views/business_login_view.dart';
import 'package:plagit/features/auth/views/business_signup_view.dart';
import 'package:plagit/features/auth/views/admin_login_view.dart';
import 'package:plagit/features/auth/views/admin_change_password_view.dart';

// Onboarding
import 'package:plagit/features/onboarding/views/onboarding_welcome_view.dart';
import 'package:plagit/features/onboarding/views/onboarding_role_view.dart';
import 'package:plagit/features/onboarding/views/onboarding_location_view.dart';
import 'package:plagit/features/onboarding/views/onboarding_experience_view.dart';
import 'package:plagit/features/onboarding/views/onboarding_availability_view.dart';

// Candidate
import 'package:plagit/features/candidate/views/candidate_home_view.dart';
import 'package:plagit/features/candidate/views/candidate_job_detail_view.dart';
import 'package:plagit/features/candidate/views/candidate_chat_view.dart';
import 'package:plagit/features/candidate/views/candidate_interviews_view.dart';
import 'package:plagit/features/candidate/views/candidate_interview_detail_view.dart';
import 'package:plagit/features/candidate/views/candidate_matches_view.dart';
import 'package:plagit/features/candidate/views/candidate_nearby_view.dart';
import 'package:plagit/features/candidate/views/nearby_map_view.dart';
import 'package:plagit/features/candidate/views/saved_jobs_view.dart';
import 'package:plagit/features/candidate/views/candidate_application_detail_view.dart';
import 'package:plagit/features/candidate/views/candidate_subscription_view.dart';
import 'package:plagit/features/candidate/views/notifications_view.dart';
import 'package:plagit/features/candidate/views/profile_edit_view.dart';
import 'package:plagit/features/candidate/views/candidate_quick_plug_view.dart';
import 'package:plagit/features/candidate/views/company_discovery_view.dart';
import 'package:plagit/features/candidate/views/cv_review_view.dart';
import 'package:plagit/features/candidate/views/match_feedback_view.dart';
import 'package:plagit/features/candidate/views/candidate_profile_setup_view.dart';

// Business
import 'package:plagit/features/business/views/business_home_view.dart';
import 'package:plagit/features/business/views/post_job_view.dart';
import 'package:plagit/features/business/views/business_jobs_view.dart';
import 'package:plagit/features/business/views/business_job_detail_view.dart';
import 'package:plagit/features/business/views/business_applicants_view.dart';
import 'package:plagit/features/business/views/business_applicant_detail_view.dart';
import 'package:plagit/features/business/views/business_chat_view.dart';
import 'package:plagit/features/business/views/business_messages_view.dart';
import 'package:plagit/features/business/views/business_interviews_view.dart';
import 'package:plagit/features/business/views/business_schedule_interview_view.dart';
import 'package:plagit/features/business/views/business_candidate_profile_view.dart';
import 'package:plagit/features/business/views/business_insights_view.dart';
import 'package:plagit/features/business/views/business_interview_detail_view.dart';
import 'package:plagit/features/business/views/business_matches_view.dart';
import 'package:plagit/features/business/views/business_nearby_talent_view.dart';
import 'package:plagit/features/business/views/business_quick_plug_view.dart';
import 'package:plagit/features/business/views/business_notifications_view.dart';
import 'package:plagit/features/business/views/business_shortlist_view.dart';
import 'package:plagit/features/business/views/business_subscription_view.dart';
import 'package:plagit/features/auth/views/business_register_view.dart';

// Business Onboarding
import 'package:plagit/features/onboarding/business/onboarding_business_welcome_view.dart';
import 'package:plagit/features/onboarding/business/onboarding_business_type_view.dart';
import 'package:plagit/features/onboarding/business/onboarding_business_details_view.dart';
import 'package:plagit/features/onboarding/business/onboarding_business_location_view.dart';
import 'package:plagit/features/onboarding/business/onboarding_business_profile_view.dart';

// Services
import 'package:plagit/features/services/views/service_entry_view.dart';
import 'package:plagit/features/services/views/service_register_view.dart';
import 'package:plagit/features/services/views/service_onboarding_view.dart';
import 'package:plagit/features/services/views/service_home_view.dart';
import 'package:plagit/features/services/views/service_discover_view.dart';
import 'package:plagit/features/services/views/service_search_view.dart';
import 'package:plagit/features/services/views/service_feed_view.dart';
import 'package:plagit/features/services/views/service_company_profile_view.dart';
import 'package:plagit/features/services/views/service_post_detail_view.dart';
import 'package:plagit/features/services/views/service_promotions_view.dart';
import 'package:plagit/features/services/views/service_promotion_detail_view.dart';
import 'package:plagit/features/services/views/service_nearby_view.dart';
import 'package:plagit/features/services/views/service_map_view.dart';
import 'package:plagit/features/services/views/service_saved_view.dart';
import 'package:plagit/features/services/views/service_messages_view.dart';
import 'package:plagit/features/services/views/service_message_thread_view.dart';
import 'package:plagit/features/services/views/service_notifications_view.dart';
import 'package:plagit/features/services/views/service_subscription_view.dart';

// Feed
import 'package:plagit/features/feed/views/community_view.dart';
import 'package:plagit/features/feed/views/feed_activity_view.dart';
import 'package:plagit/features/feed/views/saved_posts_view.dart';

// Admin
import 'package:plagit/features/admin/views/admin_root_view.dart';
import 'package:plagit/features/admin/views/admin_shell_view.dart';
import 'package:plagit/features/admin/views/admin_dashboard_view.dart';
import 'package:plagit/features/admin/views/admin_candidates_view.dart';
import 'package:plagit/features/admin/views/admin_candidate_detail_view.dart';
import 'package:plagit/features/admin/views/admin_businesses_view.dart';
import 'package:plagit/features/admin/views/admin_business_detail_view.dart';
import 'package:plagit/features/admin/views/admin_jobs_view.dart';
import 'package:plagit/features/admin/views/admin_job_detail_view.dart';
import 'package:plagit/features/admin/views/admin_applications_view.dart';
import 'package:plagit/features/admin/views/admin_application_detail_view.dart';
import 'package:plagit/features/admin/views/admin_interviews_view.dart';
import 'package:plagit/features/admin/views/admin_interview_detail_view.dart';
import 'package:plagit/features/admin/views/admin_verifications_view.dart';
import 'package:plagit/features/admin/views/admin_verification_detail_view.dart';
import 'package:plagit/features/admin/views/admin_moderation_view.dart';
import 'package:plagit/features/admin/views/admin_moderation_detail_view.dart';
import 'package:plagit/features/admin/views/admin_subscriptions_view.dart';
import 'package:plagit/features/admin/views/admin_subscription_detail_view.dart';
import 'package:plagit/features/admin/views/admin_support_view.dart';
import 'package:plagit/features/admin/views/admin_support_detail_view.dart';
import 'package:plagit/features/admin/views/admin_analytics_view.dart';
import 'package:plagit/features/admin/views/admin_audit_view.dart';
import 'package:plagit/features/admin/views/admin_audit_detail_view.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // ── Splash ──
      GoRoute(path: '/', builder: (context, state) => const SplashView()),

      // ── Entry: role selection ──
      GoRoute(path: '/entry', builder: (context, state) => const EntryView()),

      // ══════════════════════════════════════════
      // ── Auth ──
      // ══════════════════════════════════════════
      GoRoute(path: '/candidate/login', builder: (context, state) => const CandidateLoginView()),
      GoRoute(path: '/candidate/register', builder: (context, state) => const CandidateRegisterView()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordView()),
      GoRoute(path: '/business/login', builder: (context, state) => const BusinessLoginView()),
      GoRoute(path: '/business/signup', builder: (context, state) => const BusinessSignupView()),
      GoRoute(path: '/admin/login', builder: (context, state) => const AdminLoginView()),
      GoRoute(path: '/admin/change-password', builder: (context, state) => const AdminChangePasswordView()),

      // ══════════════════════════════════════════
      // ── Onboarding ──
      // ══════════════════════════════════════════
      GoRoute(path: '/onboarding/welcome', builder: (context, state) => const OnboardingWelcomeView()),
      GoRoute(path: '/onboarding/role', builder: (context, state) => const OnboardingRoleView()),
      GoRoute(path: '/onboarding/location', builder: (context, state) => const OnboardingLocationView()),
      GoRoute(path: '/onboarding/experience', builder: (context, state) => const OnboardingExperienceView()),
      GoRoute(path: '/onboarding/availability', builder: (context, state) => const OnboardingAvailabilityView()),

      // ══════════════════════════════════════════
      // ── Candidate main area ──
      // ══════════════════════════════════════════
      GoRoute(path: '/candidate/home', builder: (context, state) => const CandidateHomeView()),
      GoRoute(path: '/candidate/job/:id', builder: (context, state) => CandidateJobDetailView(jobId: state.pathParameters['id']!)),
      GoRoute(path: '/candidate/chat/:id', builder: (context, state) => CandidateChatView(conversationId: state.pathParameters['id']!)),
      GoRoute(path: '/candidate/interviews', builder: (context, state) => const CandidateInterviewsView()),
      GoRoute(path: '/candidate/interview/:id', builder: (context, state) => CandidateInterviewDetailView(interviewId: state.pathParameters['id']!)),
      GoRoute(path: '/candidate/matches', builder: (context, state) => const CandidateMatchesView()),
      GoRoute(path: '/candidate/nearby', builder: (context, state) => const CandidateNearbyView()),
      GoRoute(path: '/candidate/nearby-map', builder: (context, state) => const NearbyMapView()),
      GoRoute(path: '/candidate/saved', builder: (context, state) => const SavedJobsView()),
      GoRoute(path: '/candidate/application/:id', builder: (context, state) => CandidateApplicationDetailView(applicationId: state.pathParameters['id']!)),
      GoRoute(path: '/candidate/subscription', builder: (context, state) => const CandidateSubscriptionView()),
      GoRoute(path: '/candidate/notifications', builder: (context, state) => const NotificationsView()),
      GoRoute(path: '/candidate/profile/edit', builder: (context, state) => const ProfileEditView()),
      GoRoute(path: '/candidate/profile-setup', builder: (context, state) => const CandidateProfileSetupView()),
      GoRoute(path: '/candidate/quick-plug', builder: (context, state) => const CandidateQuickPlugView()),
      GoRoute(path: '/candidate/companies', builder: (context, state) => const CompanyDiscoveryView()),
      GoRoute(path: '/candidate/cv-review', builder: (context, state) => const CvReviewView()),
      GoRoute(path: '/candidate/match-feedback/:id', builder: (context, state) => MatchFeedbackView(matchId: state.pathParameters['id']!)),
      GoRoute(path: '/candidate/messages/:id', builder: (context, state) => CandidateChatView(conversationId: state.pathParameters['id']!)),

      // ══════════════════════════════════════════
      // ── Business auth ──
      // ══════════════════════════════════════════
      GoRoute(path: '/business/register', builder: (context, state) => const BusinessRegisterView()),

      // ── Business onboarding ──
      GoRoute(path: '/business/onboarding/welcome', builder: (context, state) => const OnboardingBusinessWelcomeView()),
      GoRoute(path: '/business/onboarding/type', builder: (context, state) => const OnboardingBusinessTypeView()),
      GoRoute(path: '/business/onboarding/details', builder: (context, state) => const OnboardingBusinessDetailsView()),
      GoRoute(path: '/business/onboarding/location', builder: (context, state) => const OnboardingBusinessLocationView()),
      GoRoute(path: '/business/onboarding/profile', builder: (context, state) => const OnboardingBusinessProfileView()),

      // ══════════════════════════════════════════
      // ── Business main area ──
      // ══════════════════════════════════════════
      GoRoute(path: '/business/home', builder: (context, state) => const BusinessHomeView()),
      GoRoute(path: '/business/post-job', builder: (context, state) => const PostJobView()),
      GoRoute(path: '/business/jobs', builder: (context, state) => const BusinessJobsView()),
      GoRoute(path: '/business/job/:id', builder: (context, state) => BusinessJobDetailView(jobId: state.pathParameters['id']!)),
      GoRoute(path: '/business/applicants', builder: (context, state) => const BusinessApplicantsView()),
      GoRoute(path: '/business/applicant/:id', builder: (context, state) => BusinessApplicantDetailView(applicantId: state.pathParameters['id']!)),
      GoRoute(path: '/business/chat/:id', builder: (context, state) => BusinessChatView(conversationId: state.pathParameters['id']!)),
      GoRoute(path: '/business/messages', builder: (context, state) => const BusinessMessagesView()),
      GoRoute(path: '/business/interviews', builder: (context, state) => const BusinessInterviewsView()),
      GoRoute(path: '/business/schedule-interview', builder: (context, state) => const BusinessScheduleInterviewView()),
      GoRoute(path: '/business/candidate/:id', builder: (context, state) => BusinessCandidateProfileView(candidateId: state.pathParameters['id']!)),
      GoRoute(path: '/business/insights', builder: (context, state) => const BusinessInsightsView()),
      GoRoute(path: '/business/interview/:id', builder: (context, state) => BusinessInterviewDetailView(interviewId: state.pathParameters['id']!)),
      GoRoute(
        path: '/business/matches',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BusinessMatchesView(
            jobId: extra?['jobId']?.toString() ?? '',
            jobTitle: extra?['jobTitle']?.toString() ?? '',
          );
        },
      ),
      GoRoute(path: '/business/nearby-talent', builder: (context, state) => const BusinessNearbyTalentView()),
      GoRoute(path: '/business/quick-plug', builder: (context, state) => const BusinessQuickPlugView()),
      GoRoute(path: '/business/notifications', builder: (context, state) => const BusinessNotificationsView()),
      GoRoute(path: '/business/shortlist', builder: (context, state) => const BusinessShortlistView()),
      GoRoute(path: '/business/subscription', builder: (context, state) => const BusinessSubscriptionView()),

      // ══════════════════════════════════════════
      // ── Services / Looking for Companies ──
      // ══════════════════════════════════════════
      GoRoute(path: '/services', builder: (context, state) => const ServiceEntryView()),
      GoRoute(path: '/services/register', builder: (context, state) => const ServiceRegisterView()),
      GoRoute(path: '/services/onboarding', builder: (context, state) => const ServiceOnboardingView()),
      GoRoute(path: '/services/home', builder: (context, state) => const ServiceHomeView()),
      GoRoute(path: '/services/discover', builder: (context, state) => const ServiceDiscoverView()),
      GoRoute(path: '/services/search', builder: (context, state) => const ServiceSearchView()),
      GoRoute(path: '/services/company/:id', builder: (context, state) => ServiceCompanyProfileView(companyId: state.pathParameters['id'] ?? 'sc1')),
      GoRoute(path: '/services/feed', builder: (context, state) => const ServiceFeedView()),
      GoRoute(path: '/services/posts/:id', builder: (context, state) => ServicePostDetailView(postId: state.pathParameters['id'] ?? 'sp1')),
      GoRoute(path: '/services/promotions', builder: (context, state) => const ServicePromotionsView()),
      GoRoute(path: '/services/promotions/:id', builder: (context, state) => ServicePromotionDetailView(promotionId: state.pathParameters['id'] ?? 'promo1')),
      GoRoute(path: '/services/nearby', builder: (context, state) => const ServiceNearbyView()),
      GoRoute(path: '/services/map', builder: (context, state) => const ServiceMapView()),
      GoRoute(path: '/services/saved', builder: (context, state) => const ServiceSavedView()),
      GoRoute(path: '/services/messages', builder: (context, state) => const ServiceMessagesView()),
      GoRoute(path: '/services/messages/:id', builder: (context, state) => ServiceMessageThreadView(conversationId: state.pathParameters['id'] ?? 'smc1')),
      GoRoute(path: '/services/notifications', builder: (context, state) => const ServiceNotificationsView()),
      GoRoute(path: '/services/subscription', builder: (context, state) => const ServiceSubscriptionView()),

      // ══════════════════════════════════════════
      // ── Feed / Community ──
      // ══════════════════════════════════════════
      GoRoute(path: '/feed', builder: (context, state) => const CommunityView()),
      GoRoute(path: '/feed/activity', builder: (context, state) => const FeedActivityView()),
      GoRoute(path: '/feed/saved', builder: (context, state) => const SavedPostsView()),

      // ══════════════════════════════════════════
      // ── Admin ──
      // ══════════════════════════════════════════
      GoRoute(path: '/admin/home', builder: (context, state) => const AdminRootView()),
      GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminShellView()),
      GoRoute(path: '/admin/candidates', builder: (context, state) => const AdminCandidatesView()),
      GoRoute(path: '/admin/candidates/:id', builder: (context, state) => AdminCandidateDetailView(candidateId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/businesses', builder: (context, state) => const AdminBusinessesView()),
      GoRoute(path: '/admin/businesses/:id', builder: (context, state) => AdminBusinessDetailView(businessId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/jobs', builder: (context, state) => const AdminJobsView()),
      GoRoute(path: '/admin/jobs/:id', builder: (context, state) => AdminJobDetailView(jobId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/applications', builder: (context, state) => const AdminApplicationsView()),
      GoRoute(path: '/admin/applications/:id', builder: (context, state) => AdminApplicationDetailView(applicationId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/interviews', builder: (context, state) => const AdminInterviewsView()),
      GoRoute(path: '/admin/interviews/:id', builder: (context, state) => AdminInterviewDetailView(interviewId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/verifications', builder: (context, state) => const AdminVerificationsView()),
      GoRoute(path: '/admin/verifications/:id', builder: (context, state) => AdminVerificationDetailView(verificationId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/moderation', builder: (context, state) => const AdminModerationView()),
      GoRoute(path: '/admin/moderation/:id', builder: (context, state) => AdminModerationDetailView(reportId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/subscriptions', builder: (context, state) => const AdminSubscriptionsView()),
      GoRoute(path: '/admin/subscriptions/:id', builder: (context, state) => AdminSubscriptionDetailView(subscriptionId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/support', builder: (context, state) => const AdminSupportView()),
      GoRoute(path: '/admin/support/:id', builder: (context, state) => AdminSupportDetailView(issueId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/analytics', builder: (context, state) => const AdminAnalyticsView()),
      GoRoute(path: '/admin/audit', builder: (context, state) => const AdminAuditView()),
      GoRoute(path: '/admin/audit/:id', builder: (context, state) => AdminAuditDetailView(auditId: state.pathParameters['id']!)),
      GoRoute(path: '/admin/notifications', builder: (context, state) => const AdminShellView()),
    ],
  );
}
