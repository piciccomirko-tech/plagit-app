import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/widgets/plagit_logo.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class RoleSelectView extends StatelessWidget {
  const RoleSelectView({super.key});

  static const _orange = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const PlagitLogo(size: 60, borderRadius: 16),
            const SizedBox(height: 20),
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select how you want to use Plagit today',
              style: TextStyle(fontSize: 14, color: Color(0xFF9EA0AD)),
            ),
            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _RoleCard(
                    initials: 'TC',
                    color: AppColors.teal,
                    title: AppLocalizations.of(context).continueAsCandidate,
                    subtitle: AppLocalizations.of(context).findJobsAndApply,
                    onTap: () => context.go('/candidate/home'),
                  ),
                  const SizedBox(height: 12),
                  _RoleCard(
                    initials: 'TB',
                    color: AppColors.purple,
                    title: AppLocalizations.of(context).continueAsBusiness,
                    subtitle: AppLocalizations.of(context).manageJobsAndHiring,
                    onTap: () => context.go('/business/home'),
                  ),
                  const SizedBox(height: 12),
                  _RoleCard(
                    initials: 'AU',
                    color: AppColors.navy,
                    title: AppLocalizations.of(context).adminPortal,
                    subtitle: AppLocalizations.of(context).managePlatform,
                    onTap: () => context.go('/admin/dashboard'),
                  ),
                  const SizedBox(height: 12),
                  _RoleCard(
                    icon: Icons.grid_view_rounded,
                    color: _orange,
                    title: AppLocalizations.of(context).browseServices,
                    subtitle: AppLocalizations.of(context).findHospitalityCompanies,
                    onTap: () => context.go('/services/home'),
                  ),
                ],
              ),
            ),

            const Spacer(),

            GestureDetector(
              onTap: () => context.go('/entry'),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String? initials;
  final IconData? icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    this.initials,
    this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: icon != null
                    ? Icon(icon, color: Colors.white, size: 22)
                    : Text(
                        initials ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.teal, size: 28),
          ],
        ),
      ),
    );
  }
}
