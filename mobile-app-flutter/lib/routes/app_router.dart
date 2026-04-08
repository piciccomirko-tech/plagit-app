import 'package:go_router/go_router.dart';
import 'package:plagit/features/auth/views/splash_view.dart';
import 'package:plagit/features/auth/views/entry_view.dart';
import 'package:plagit/features/auth/views/candidate_login_view.dart';
import 'package:plagit/features/auth/views/candidate_signup_view.dart';
import 'package:plagit/features/auth/views/business_login_view.dart';
import 'package:plagit/features/auth/views/business_signup_view.dart';
import 'package:plagit/features/candidate/views/candidate_home_view.dart';
import 'package:plagit/features/candidate/views/candidate_job_detail_view.dart';
import 'package:plagit/features/candidate/views/candidate_chat_view.dart';
import 'package:plagit/features/business/views/business_home_view.dart';
import 'package:plagit/features/business/views/business_post_job_view.dart';
import 'package:plagit/features/business/views/business_job_detail_view.dart';
import 'package:plagit/features/business/views/business_chat_view.dart';
import 'package:plagit/features/business/views/business_schedule_interview_view.dart';
import 'package:plagit/features/business/views/business_candidate_profile_view.dart';
import 'package:plagit/features/services/views/service_entry_view.dart';

class AppRouter {
  AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash: session check → auto-route
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashView(),
      ),

      // Entry: role selection
      GoRoute(
        path: '/entry',
        builder: (context, state) => const EntryView(),
      ),

      // Candidate auth
      GoRoute(
        path: '/candidate/login',
        builder: (context, state) => const CandidateLoginView(),
      ),
      GoRoute(
        path: '/candidate/signup',
        builder: (context, state) => const CandidateSignupView(),
      ),

      // Business auth
      GoRoute(
        path: '/business/login',
        builder: (context, state) => const BusinessLoginView(),
      ),
      GoRoute(
        path: '/business/signup',
        builder: (context, state) => const BusinessSignupView(),
      ),

      // Candidate main area
      GoRoute(
        path: '/candidate/home',
        builder: (context, state) => const CandidateHomeView(),
      ),
      GoRoute(
        path: '/candidate/job/:id',
        builder: (context, state) => CandidateJobDetailView(
          jobId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/candidate/chat/:id',
        builder: (context, state) => CandidateChatView(
          conversationId: state.pathParameters['id']!,
        ),
      ),

      // Services
      GoRoute(
        path: '/services',
        builder: (context, state) => const ServiceEntryView(),
      ),

      // Business main area
      GoRoute(
        path: '/business/home',
        builder: (context, state) => const BusinessHomeView(),
      ),
      GoRoute(
        path: '/business/post-job',
        builder: (context, state) => const BusinessPostJobView(),
      ),
      GoRoute(
        path: '/business/job/:id',
        builder: (context, state) => BusinessJobDetailView(
          jobId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/business/chat/:id',
        builder: (context, state) => BusinessChatView(
          conversationId: state.pathParameters['id']!,
        ),
      ),
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
      GoRoute(
        path: '/business/candidate/:id',
        builder: (context, state) => BusinessCandidateProfileView(
          candidateId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
}
