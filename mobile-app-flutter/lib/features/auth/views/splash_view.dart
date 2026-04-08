import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/repositories/auth_repository.dart';
import 'package:plagit/widgets/plagit_logo.dart';

/// Splash screen — attempts session restore, then routes accordingly.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      final authRepo = AuthRepository();
      final session = await authRepo.restoreSession();
      if (!mounted) return;

      if (session != null) {
        debugPrint('[Splash] Restored session → ${session.role}');
        switch (session.role) {
          case 'candidate':
            context.go('/candidate/home');
          case 'business':
            context.go('/business/home');
          case 'admin':
            context.go('/admin/dashboard');
          default:
            context.go('/entry');
        }
        return;
      }
    } catch (e) {
      debugPrint('[Splash] Session restore failed: $e');
    }

    if (mounted) context.go('/entry');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PlagitLogo(size: 120, borderRadius: 28),
            const SizedBox(height: 20),
            const Text(
              'PLAGIT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
