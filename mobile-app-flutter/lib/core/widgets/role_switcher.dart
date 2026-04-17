import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class RoleSwitcher extends StatelessWidget {
  final String currentRole;

  const RoleSwitcher({super.key, required this.currentRole});

  static const _orange = Color(0xFFF97316);

  IconData _iconForRole(String role) {
    switch (role) {
      case 'candidate':
        return Icons.person;
      case 'business':
        return Icons.business;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'services':
        return Icons.grid_view;
      default:
        return Icons.swap_horiz;
    }
  }

  Color _colorForRole(String role) {
    switch (role) {
      case 'candidate':
        return AppColors.teal;
      case 'business':
        return AppColors.purple;
      case 'admin':
        return AppColors.navy;
      case 'services':
        return _orange;
      default:
        return AppColors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: FloatingActionButton.small(
        backgroundColor: Colors.white,
        elevation: 4,
        onPressed: () => _showRoleSheet(context),
        child: Icon(_iconForRole(currentRole), color: _colorForRole(currentRole), size: 22),
      ),
    );
  }

  void _showRoleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final l = AppLocalizations.of(ctx);
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.switchRoleTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _RoleRow(
                icon: Icons.person,
                color: AppColors.teal,
                label: l.candidate,
                isCurrent: currentRole == 'candidate',
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/candidate/home');
                },
              ),
              _RoleRow(
                icon: Icons.business,
                color: AppColors.purple,
                label: l.businessLabel,
                isCurrent: currentRole == 'business',
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/business/home');
                },
              ),
              _RoleRow(
                icon: Icons.shield,
                color: AppColors.navy,
                label: l.admin,
                isCurrent: currentRole == 'admin',
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/admin/dashboard');
                },
              ),
              _RoleRow(
                icon: Icons.grid_view,
                color: _orange,
                label: l.browseServices,
                isCurrent: currentRole == 'services',
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/services/home');
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l.cancel,
                  style: const TextStyle(color: AppColors.secondary, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RoleRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final bool isCurrent;
  final VoidCallback onTap;

  const _RoleRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            if (isCurrent)
              const Icon(Icons.check, color: AppColors.teal, size: 20),
          ],
        ),
      ),
    );
  }
}
