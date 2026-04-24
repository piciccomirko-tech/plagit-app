import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/providers/admin_providers.dart';

const Color _adminIndigo = Color(0xFF6676F0);

/// Premium bottom sheet for the admin header avatar.
/// Shows identity (initials, role, email) + Settings + Sign Out.
///
/// [onLogout] is optional; when provided it is called after the sheet closes
/// (used by [SuperAdminHomeView] which controls its own auth state).
/// When null, the sheet calls [AdminAuthProvider.logout] directly and routes
/// back to /admin/login.
Future<void> showAdminAccountSheet(
  BuildContext context, {
  VoidCallback? onLogout,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _AdminAccountSheet(onLogout: onLogout),
  );
}

class _AdminAccountSheet extends StatelessWidget {
  final VoidCallback? onLogout;
  const _AdminAccountSheet({this.onLogout});

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'AU';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length.clamp(0, 2)).toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthProvider>();
    final name = auth.userName;
    final email = auth.userEmail.isEmpty ? '—' : auth.userEmail;
    final roleLabel = auth.isSuperAdmin ? 'Super Admin' : 'Admin';
    final initials = _initials(name.isEmpty ? 'Admin User' : name);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_adminIndigo, AppColors.teal],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name.isEmpty ? 'Admin User' : name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _adminIndigo.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  roleLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _adminIndigo,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 18),
              const Divider(height: 1, color: AppColors.divider),
              _item(
                context,
                icon: Icons.dashboard_outlined,
                label: 'Admin Dashboard',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/admin/dashboard');
                },
              ),
              const Divider(height: 1, color: AppColors.divider, indent: 56),
              _item(
                context,
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/admin/settings');
                },
              ),
              const Divider(height: 1, color: AppColors.divider, indent: 56),
              _item(
                context,
                icon: Icons.history,
                label: 'Activity Log',
                onTap: () {
                  Navigator.of(context).pop();
                  context.push('/admin/audit');
                },
              ),
              const Divider(height: 1, color: AppColors.divider, indent: 56),
              _item(
                context,
                icon: Icons.logout,
                label: 'Sign Out',
                destructive: true,
                onTap: () async {
                  Navigator.of(context).pop();
                  if (onLogout != null) {
                    onLogout!();
                    return;
                  }
                  await context.read<AdminAuthProvider>().logout();
                  if (context.mounted) context.go('/admin/login');
                },
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final color = destructive ? AppColors.red : AppColors.charcoal;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            if (!destructive)
              const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
          ],
        ),
      ),
    );
  }
}
