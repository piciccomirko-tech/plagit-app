import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plagit/config/app_config.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/config/env_config.dart';
import 'package:plagit/routes/app_router.dart';
import 'package:plagit/core/services/auth_expired_handler.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/repositories/auth_repository.dart';
import 'package:plagit/repositories/candidate_repository.dart';
import 'package:plagit/repositories/business_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  EnvConfig.initialize(Environment.production);
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
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
