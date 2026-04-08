import 'package:flutter/material.dart';
import 'package:plagit/config/app_config.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/routes/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlagitApp());
}

class PlagitApp extends StatelessWidget {
  const PlagitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
