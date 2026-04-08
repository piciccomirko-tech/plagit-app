import 'package:go_router/go_router.dart';

// Auth
import 'package:plagit/features/auth/views/splash_view.dart';
import 'package:plagit/features/auth/views/entry_view.dart';
import 'package:plagit/features/auth/views/candidate_login_view.dart';
import 'package:plagit/features/auth/views/candidate_signup_view.dart';
import 'package:plagit/features/auth/views/business_login_view.dart';
import 'package:plagit/features/auth/views/business_signup_view.dart';
import 'package:plagit/features/auth/views/admin_login_view.dart';
import 'package:plagit/features/auth/views/admin_change_password_view.dart';

// Candidate
import 'package:plagit/features/candidate/views/candidate_home_view.dart';
import 'package:plagit/features/candidate/views/candidate_job_detail_view.dart';
import 'package:plagit/features/candidate/views/candidate_chat_view.dart';
import 'package:plagit/features/candidate/views/candidate_interviews_view.dart';
import 'package:plagit/features/candidate/views/candidate_interview_detail_view.dart';
import 'package:plagit/features/candidate/views/candidate_matches_view.dart';
import 'package:plagit/features/candidate/views/candidate_nearby_view.dart';
import 'package:plagit/features/candidate/views/candidate_profile_setup_view.dart';
import 'package:plagit/features/candidate/views/candidate_quick_plug_view.dart';
import 'package:plagit/features/candidate/views/candidate_subscription_view.dart';
import 'package:plagit/features/candidate/views/candidate_application_detail_view.dart';
import 'package:plagit/features/candidate/views/company_discovery_view.dart';
import 'package:plagit/features/candidate/views/cv_review_view.dart';
import 'package:plagit/features/candidate/views/match_feedback_view.dart';

// Business
import 'package:plagit/features/business/views/business_home_view.dart';
import 'package:plagit/features/business/views/business_post_job_view.dart';
import 'package:plagit/features/business/views/business_job_detail_view.dart';
import 'package:plagit/features/business/views/business_chat_view.dart';
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

// Services
import 'package:plagit/features/services/views/service_entry_view.dart';
import 'package:plagit/features/services/views/service_discovery_view.dart';
import 'package:plagit/features/services/views/service_feed_view.dart';
import 'package:plagit/features/services/views/service_company_profile_view.dart';
import 'package:plagit/features/services/views/service_provider_signup_view.dart' show ServiceProviderSignUpView;
import 'package:plagit/features/services/views/service_subscription_view.dart';

// Feed
import 'package:plagit/features/feed/views/community_view.dart';
import 'package:plagit/features/feed/views/feed_activity_view.dart';
import 'package:plagit/features/feed/views/saved_posts_view.dart';

// Admin
import 'package:plagit/features/admin/views/admin_root_view.dart';
import 'package:plagit/features/admin/views/super_admin_home_view.dart';

// Shared
import 'package:plagit/widgets/activity_view.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // ── Splash ──
      GoRoute(path: '/', builder: (context, state) => const SplashView()),

      // ── Entry: role selection ──
      GoRoute(path: '/entry', builder: (context, state) => const EntryView()),

      // ── Candidate auth ──
      GoRoute(path: '/candidate/login', builder: (context, state) => const CandidateLoginView()),
      GoRoute(path: '/candidate/signup', builder: (context, state) => const CandidateSignupView()),

      // ── Business auth ──
      GoRoute(path: '/business/login', builder: (context, state) => const BusinessLoginView()),
      GoRoute(path: '/business/signup', builder: (context, state) => const BusinessSignupView()),

      // ── Admin auth ──
      GoRoute(path: '/admin/login', builder: (context, state) => AdminLoginView(onLoginSuccess: () => const AdminRootView())),
      GoRoute(path: '/admin/change-password', builder: (context, state) => const AdminChangePasswordView()),

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
      GoRoute(path: '/candidate/profile-setup', builder: (context, state) => const CandidateProfileSetupView()),
      GoRoute(path: '/candidate/quick-plug', builder: (context, state) => const CandidateQuickPlugView()),
      GoRoute(path: '/candidate/subscription', builder: (context, state) => const CandidateSubscriptionView()),
      GoRoute(path: '/candidate/application/:id', builder: (context, state) => CandidateApplicationDetailView(applicationId: state.pathParameters['id']!)),
      GoRoute(path: '/candidate/companies', builder: (context, state) => const CompanyDiscoveryView()),
      GoRoute(path: '/candidate/cv-review', builder: (context, state) => const CvReviewView()),
      GoRoute(path: '/candidate/match-feedback/:id', builder: (context, state) => MatchFeedbackView(matchId: state.pathParameters['id']!)),
      GoRoute(path: '/candidate/notifications', builder: (context, state) => const ActivityView(isBusiness: false)),

      // ══════════════════════════════════════════
      // ── Business main area ──
      // ══════════════════════════════════════════
      GoRoute(path: '/business/home', builder: (context, state) => const BusinessHomeView()),
      GoRoute(path: '/business/post-job', builder: (context, state) => const BusinessPostJobView()),
      GoRoute(path: '/business/job/:id', builder: (context, state) => BusinessJobDetailView(jobId: state.pathParameters['id']!)),
      GoRoute(path: '/business/chat/:id', builder: (context, state) => BusinessChatView(conversationId: state.pathParameters['id']!)),
      GoRoute(
        path: '/business/schedule-interview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return BusinessScheduleInterviewView(
            candidateId: extra?['candidateId']?.toString(),
            jobId: extra?['jobId']?.toString(),
          );
        },
      ),
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
      // ── Services ──
      // ══════════════════════════════════════════
      GoRoute(path: '/services', builder: (context, state) => const ServiceEntryView()),
      GoRoute(path: '/services/discovery', builder: (context, state) => const ServiceDiscoveryView()),
      GoRoute(path: '/services/feed', builder: (context, state) => const ServiceFeedView()),
      GoRoute(path: '/services/company/:id', builder: (context, state) => const ServiceCompanyProfileView()),
      GoRoute(path: '/services/signup', builder: (context, state) => const ServiceProviderSignUpView()),
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
      GoRoute(path: '/admin/dashboard', builder: (context, state) => SuperAdminHomeView(onLogout: () {})),
    ],
  );
}
