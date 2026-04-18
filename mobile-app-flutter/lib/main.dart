import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/config/app_config.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/config/env_config.dart';
import 'package:plagit/routes/app_router.dart';
import 'package:plagit/core/services/auth_expired_handler.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/providers/admin_providers.dart';
import 'package:plagit/providers/community_provider.dart';
import 'package:plagit/providers/recent_searches_provider.dart';
import 'package:plagit/repositories/auth_repository.dart';
import 'package:plagit/repositories/candidate_repository.dart';
import 'package:plagit/repositories/business_repository.dart';
import 'package:plagit/repositories/admin_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  EnvConfig.initialize(Environment.localReal);
  AuthExpiredHandler.instance.initialize(AppRouter.navigatorKey);
  runApp(const PlagitApp());
}

class PlagitApp extends StatelessWidget {
  const PlagitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = AuthRepository();
    final candidateRepo = CandidateRepository();
    final businessRepo = BusinessRepository();
    final adminRepo = AdminRepository();
    return MultiProvider(
      providers: [
        // -- Candidate providers --
        ChangeNotifierProvider(
            create: (_) => CandidateAuthProvider(repo: candidateRepo, authRepo: authRepo)),
        ChangeNotifierProvider(
            create: (_) => CandidateHomeProvider(repo: candidateRepo)),
        ChangeNotifierProvider(
            create: (_) => CandidateJobsProvider(repo: candidateRepo)),
        ChangeNotifierProvider(
            create: (_) => CandidateApplicationsProvider(repo: candidateRepo)),
        ChangeNotifierProvider(
            create: (_) => CandidateMessagesProvider(repo: candidateRepo)),
        ChangeNotifierProvider(
            create: (_) => CandidateInterviewsProvider(repo: candidateRepo)),
        ChangeNotifierProvider(
            create: (_) => CandidateNotificationsProvider(repo: candidateRepo)),
        // -- Business providers --
        ChangeNotifierProvider(
            create: (_) => BusinessAuthProvider(repo: businessRepo, authRepo: authRepo)),
        ChangeNotifierProvider(
            create: (_) => BusinessHomeProvider(repo: businessRepo)),
        ChangeNotifierProvider(
            create: (_) => BusinessJobsProvider(repo: businessRepo)),
        ChangeNotifierProvider(
            create: (_) => BusinessApplicantsProvider(repo: businessRepo)),
        ChangeNotifierProvider(
            create: (_) => BusinessMessagesProvider(repo: businessRepo)),
        ChangeNotifierProvider(
            create: (_) => BusinessInterviewsProvider(repo: businessRepo)),
        ChangeNotifierProvider(
            create: (_) => BusinessQuickPlugProvider(repo: businessRepo)),
        ChangeNotifierProvider(
            create: (_) => BusinessNotificationsProvider(repo: businessRepo)),
        // -- Admin providers --
        ChangeNotifierProvider(
            create: (_) => AdminAuthProvider(repo: adminRepo, authRepo: authRepo)),
        ChangeNotifierProvider(
            create: (_) => AdminDashboardProvider(repo: adminRepo)),
        ChangeNotifierProvider(
            create: (_) => AdminNotificationsProvider(repo: adminRepo)),
        ChangeNotifierProvider(
            create: (_) => AdminActionsProvider(repo: adminRepo)),
        // Admin list providers
        ChangeNotifierProvider(create: (_) => AdminCandidatesListProvider(repo: adminRepo)),
        ChangeNotifierProvider(create: (_) => AdminBusinessesListProvider(repo: adminRepo)),
        ChangeNotifierProvider(create: (_) => AdminJobsListProvider(repo: adminRepo)),
        ChangeNotifierProvider(create: (_) => AdminApplicationsListProvider(repo: adminRepo)),
        ChangeNotifierProvider(create: (_) => AdminInterviewsListProvider(repo: adminRepo)),
        ChangeNotifierProvider(create: (_) => AdminVerificationsListProvider(repo: adminRepo)),
        ChangeNotifierProvider(create: (_) => AdminReportsListProvider(repo: adminRepo)),
        ChangeNotifierProvider(create: (_) => AdminSupportListProvider(repo: adminRepo)),
        ChangeNotifierProvider(
            create: (_) => CandidateQuickPlugProvider(repo: candidateRepo)),
        // -- Shared providers (used by all 3 sides) --
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => RecentSearchesProvider()),
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,

        // ── Localization ──
        // Device locale drives the app language automatically on iOS + Android.
        // Production-visible locales: EN / IT / AR.
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: const [
          Locale('en'),
          Locale('it'),
          Locale('ar'),
        ],
        localeResolutionCallback: (deviceLocale, supported) {
          if (deviceLocale == null) return const Locale('en');
          // Exact match (language + country)
          for (final s in supported) {
            if (s.languageCode == deviceLocale.languageCode &&
                s.countryCode == deviceLocale.countryCode) return s;
          }
          // Language-only match (e.g. it-CH → it)
          for (final s in supported) {
            if (s.languageCode == deviceLocale.languageCode) return s;
          }
          // Fallback
          return const Locale('en');
        },
      ),
    );
  }
}
