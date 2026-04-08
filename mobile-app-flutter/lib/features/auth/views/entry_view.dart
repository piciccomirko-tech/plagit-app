import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/widgets/plagit_logo.dart';

/// Role selection screen — entry point for the app.
class EntryView extends StatelessWidget {
  const EntryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // ── Logo + title block ──
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.teal.withValues(alpha: 0.16),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const PlagitLogo(size: 84, borderRadius: 20, withShadow: true),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Plagit',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'One app for hospitality\nprofessionals and businesses',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.secondary, height: 1.4),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Role cards ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _RoleCard(
                    icon: Icons.person,
                    color: AppColors.teal,
                    title: 'Find Work',
                    subtitle: 'Discover jobs and apply faster',
                    onTap: () => context.go('/candidate/login'),
                  ),
                  const SizedBox(height: 12),
                  _RoleCard(
                    icon: Icons.business,
                    color: AppColors.purple,
                    title: 'Hire Staff',
                    subtitle: 'Post jobs and hire faster',
                    onTap: () => context.go('/business/login'),
                  ),
                  const SizedBox(height: 12),
                  _RoleCard(
                    icon: Icons.grid_view_rounded,
                    color: AppColors.amber,
                    title: 'Looking for Companies',
                    subtitle: 'Discover hospitality services near you',
                    onTap: () => context.go('/services'),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Footer ──
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/sign-in'),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(fontSize: 13, color: AppColors.secondary),
                        ),
                        Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.teal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'By continuing you agree to our Terms and Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single role-selection card with icon badge, title, subtitle, and arrow.
class _RoleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon badge
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow circle
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward, size: 18, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
