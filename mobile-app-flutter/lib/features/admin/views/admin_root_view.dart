import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/super_admin_home_view.dart';
import 'package:plagit/features/auth/views/admin_login_view.dart';

/// AdminRootView — switches between login and admin area based on auth state.
/// In this placeholder version, we simulate "authenticated = true" by default.
class AdminRootView extends StatefulWidget {
  const AdminRootView({super.key});

  @override
  State<AdminRootView> createState() => _AdminRootViewState();
}

class _AdminRootViewState extends State<AdminRootView> {
  bool _isRestoring = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _isRestoring = false;
        _isAuthenticated = true; // mock: auto-authenticated
      });
    }
  }

  void _logout() {
    setState(() => _isAuthenticated = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestoring) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.teal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.work_outline, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2),
            ],
          ),
        ),
      );
    }

    if (_isAuthenticated) {
      return SuperAdminHomeView(onLogout: _logout);
    }

    return const AdminLoginView();
  }
}
