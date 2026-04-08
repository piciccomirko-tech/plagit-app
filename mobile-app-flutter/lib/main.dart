import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plagit/config/app_config.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/routes/app_router.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/repositories/candidate_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlagitApp());
}

class PlagitApp extends StatelessWidget {
  const PlagitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = CandidateRepository();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => CandidateAuthProvider(repo: repo)),
        ChangeNotifierProvider(
            create: (_) => CandidateHomeProvider(repo: repo)),
        ChangeNotifierProvider(
            create: (_) => CandidateJobsProvider(repo: repo)),
        ChangeNotifierProvider(
            create: (_) => CandidateApplicationsProvider(repo: repo)),
        ChangeNotifierProvider(
            create: (_) => CandidateMessagesProvider(repo: repo)),
        ChangeNotifierProvider(
            create: (_) => CandidateInterviewsProvider(repo: repo)),
        ChangeNotifierProvider(
            create: (_) => CandidateNotificationsProvider(repo: repo)),
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
