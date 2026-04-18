import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Business Insights / Analytics screen.
/// Mirrors BusinessInsightsView.swift.
class BusinessInsightsView extends StatelessWidget {
  const BusinessInsightsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: BackChevron(size: 22, color: AppColors.charcoal),
                    ),
                  ),
                  const Spacer(),
                  const Text('Insights',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal)),
                  const Spacer(),
                  const SizedBox(width: 36, height: 36),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    top: AppSpacing.xs, bottom: AppSpacing.xxxl),
                child: Column(
                  children: [
                    _insightCard(
                      title: 'Profile Views',
                      number: '48',
                      change: '+12 this week',
                      icon: Icons.visibility_outlined,
                      color: AppColors.indigo,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _insightCard(
                      title: 'Job Performance',
                      number: '3',
                      change: 'Active jobs',
                      icon: Icons.work_rounded,
                      color: AppColors.teal,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _insightCard(
                      title: 'Applicant Activity',
                      number: '12',
                      change: 'New this week',
                      icon: Icons.people_outline,
                      color: AppColors.amber,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _insightCard(
                      title: 'Interview Rate',
                      number: '67%',
                      change: 'Of shortlisted candidates',
                      icon: Icons.calendar_today_outlined,
                      color: AppColors.online,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _insightCard(
                      title: 'Avg Response Time',
                      number: '2.4h',
                      change: 'Faster than 80% of businesses',
                      icon: Icons.access_time,
                      color: AppColors.teal,
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // ── Top Performing Job card ──
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Top Performing Job',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.charcoal)),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        HSLColor.fromAHSL(1, 198, 0.45, 0.90)
                                            .toColor(),
                                        HSLColor.fromAHSL(1, 198, 0.55, 0.75)
                                            .toColor(),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text('NR',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('Senior Chef',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.charcoal)),
                                      const SizedBox(height: 2),
                                      Text(
                                          '12 applicants \u00b7 48 views \u00b7 3 interviews',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.secondary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightCard({
    required String title,
    required String number,
    required String change,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.secondary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(number,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal)),
                  Text(change,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.teal)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
