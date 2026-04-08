import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/token_storage.dart';
import 'package:plagit/widgets/plagit_logo.dart';

/// Splash screen — checks for existing session and auto-routes.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    try {
      final token = await TokenStorage.getAccessToken();
      final role = await TokenStorage.getUserRole();
      debugPrint('[SPLASH] token=${token != null ? "YES" : "null"} role=$role');

      if (!mounted) return;

      if (token != null && role != null) {
        debugPrint('[SPLASH] Restoring session -> /$role/home');
        context.go('/$role/home');
        return;
      }
    } catch (e) {
      debugPrint('[SPLASH] Session check error: $e');
    }

    debugPrint('[SPLASH] No session -> /entry');
    if (mounted) context.go('/entry');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teal,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PlagitLogo(size: 100, borderRadius: 24),
            const SizedBox(height: 16),
            const Text(
              'Plagit',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
