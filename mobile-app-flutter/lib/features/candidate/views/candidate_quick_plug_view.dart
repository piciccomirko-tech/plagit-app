import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Candidate Quick Plug — rebuilt in Community-screen design language.
class CandidateQuickPlugView extends StatelessWidget {
  const CandidateQuickPlugView({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<CandidateAuthProvider>().subscription;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const SizedBox(width: 36),
                  const Spacer(),
                  const Text('Quick Plug', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                  const Spacer(),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.purple.withValues(alpha: 0.08), shape: BoxShape.circle),
                    child: const Icon(Icons.bolt, size: 18, color: AppColors.purple),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                children: [
                  // ── Hero ──
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.purple.withValues(alpha: 0.15), AppColors.purple.withValues(alpha: 0.05)]),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.bolt, size: 22, color: AppColors.purple),
                        ),
                        const SizedBox(height: 14),
                        const Text('Premium Speed Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                        const SizedBox(height: 4),
                        const Text('Get hired faster with premium features', style: TextStyle(fontSize: 13, color: AppColors.secondary)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Feature cards ──
                  _featureCard(
                    context,
                    icon: Icons.rocket_launch,
                    color: AppColors.teal,
                    title: 'Boost My Profile',
                    subtitle: 'Get seen by more employers today',
                    active: sub.canBoostProfile,
                    onTap: () => sub.canBoostProfile ? _activeSnack(context) : _premiumSnack(context),
                  ),
                  const SizedBox(height: 12),
                  _featureCard(
                    context,
                    icon: Icons.bolt,
                    color: AppColors.purple,
                    title: 'Quick Apply',
                    subtitle: 'Apply to matching jobs instantly',
                    active: sub.canQuickApply,
                    onTap: () => sub.canQuickApply ? _activeSnack(context) : _premiumSnack(context),
                  ),
                  const SizedBox(height: 12),
                  _featureCard(
                    context,
                    icon: Icons.notifications_active,
                    color: AppColors.amber,
                    title: 'Priority Notifications',
                    subtitle: 'Be first to know about new jobs',
                    active: sub.hasPriorityNotifications,
                    onTap: () => sub.hasPriorityNotifications ? _activeSnack(context) : _premiumSnack(context),
                  ),
                  const SizedBox(height: 12),
                  _featureCard(
                    context,
                    icon: Icons.tune,
                    color: const Color(0xFF3B82F6),
                    title: 'Advanced Filters',
                    subtitle: 'Filter by salary, distance, contract',
                    active: sub.hasAdvancedFilters,
                    onTap: () => sub.hasAdvancedFilters ? _activeSnack(context) : _premiumSnack(context),
                  ),

                  const SizedBox(height: 20),

                  // ── Upgrade CTA ──
                  if (!sub.plan.isPremium)
                    GestureDetector(
                      onTap: () => context.push('/candidate/subscription'),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.teal.withValues(alpha: 0.06), AppColors.purple.withValues(alpha: 0.04)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.teal.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppColors.amber.withValues(alpha: 0.2), AppColors.amber.withValues(alpha: 0.05)]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.workspace_premium, size: 20, color: AppColors.amber),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Go Premium', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                                  SizedBox(height: 2),
                                  Text('Unlock all features \u00B7 \u00A39.99/month', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [AppColors.teal, AppColors.darkTeal]),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Upgrade', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [AppColors.amber.withValues(alpha: 0.2), AppColors.amber.withValues(alpha: 0.05)]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.workspace_premium, size: 20, color: AppColors.amber),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Premium Active', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                                SizedBox(height: 2),
                                Text('All features are unlocked', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.green.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(100)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, size: 12, color: AppColors.green),
                                SizedBox(width: 4),
                                Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.green)),
                              ],
                            ),
                          ),
                        ],
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

  Widget _featureCard(BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (active)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(100)),
                child: const Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.teal)),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: AppColors.tertiary),
                  const SizedBox(width: 4),
                  const ForwardChevron(size: 18, color: AppColors.tertiary),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static void _premiumSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium feature \u2014 upgrade to unlock'), behavior: SnackBarBehavior.floating),
    );
  }

  static void _activeSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature is active!'), behavior: SnackBarBehavior.floating),
    );
  }
}
