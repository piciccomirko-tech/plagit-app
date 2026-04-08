import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/providers/candidate_providers.dart';

class CandidateQuickPlugView extends StatelessWidget {
  const CandidateQuickPlugView({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<CandidateAuthProvider>().subscription;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            const Center(
              child: Icon(Icons.bolt, size: 40, color: AppColors.purple),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Quick Plug',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                'Premium tools for faster hiring',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Card 1: Boost My Profile
            _QuickPlugCard(
              iconBg: AppColors.teal,
              icon: Icons.rocket_launch,
              title: 'Boost My Profile',
              subtitle: 'Get seen by more employers today',
              trailing: sub.canBoostProfile ? _ActivePill() : _UnlockPill(),
              onTap: () => sub.canBoostProfile
                  ? _showActiveSnack(context)
                  : _showPremiumSnack(context),
            ),
            const SizedBox(height: 12),

            // Card 2: Quick Apply
            _QuickPlugCard(
              iconBg: AppColors.purple,
              icon: Icons.bolt,
              title: 'Quick Apply',
              subtitle: 'Apply to matching jobs instantly',
              trailing: sub.canQuickApply ? _ActivePill() : _LockTrailing(),
              onTap: () => sub.canQuickApply
                  ? _showActiveSnack(context)
                  : _showPremiumSnack(context),
            ),
            const SizedBox(height: 12),

            // Card 3: Priority Notifications
            _QuickPlugCard(
              iconBg: AppColors.amber,
              icon: Icons.notifications,
              title: 'Priority Notifications',
              subtitle: 'Be first to know about new jobs',
              trailing: sub.hasPriorityNotifications ? _ActivePill() : _LockTrailing(),
              onTap: () => sub.hasPriorityNotifications
                  ? _showActiveSnack(context)
                  : _showPremiumSnack(context),
            ),
            const SizedBox(height: 12),

            // Card 4: Advanced Filters
            _QuickPlugCard(
              iconBg: const Color(0xFF3B82F6),
              icon: Icons.tune,
              title: 'Advanced Filters',
              subtitle: 'Filter by salary, distance, contract type',
              trailing: sub.hasAdvancedFilters ? _ActivePill() : _LockTrailing(),
              onTap: () => sub.hasAdvancedFilters
                  ? _showActiveSnack(context)
                  : _showPremiumSnack(context),
            ),
            const SizedBox(height: 12),

            // Card 5: Go Premium
            _QuickPlugCard(
              iconBg: AppColors.gold,
              icon: Icons.workspace_premium,
              title: 'Go Premium',
              subtitle: sub.plan.isPremium
                  ? 'All features unlocked'
                  : 'Unlock all features \u00b7 \u00a39.99/month',
              trailing: sub.plan.isPremium ? _PremiumActivePill() : _UpgradeButton(),
              onTap: () => sub.plan.isPremium
                  ? _showActiveSnack(context)
                  : context.push('/candidate/subscription'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showPremiumSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Premium feature \u2014 upgrade to unlock'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _showActiveSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature is active!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ── Reusable card ──
class _QuickPlugCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  const _QuickPlugCard({
    required this.iconBg,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
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
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 2),
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
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ── "Active" teal pill ──
class _ActivePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Text(
            'Active',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 20, color: AppColors.tertiary),
      ],
    );
  }
}

// ── "Premium Active" green pill ──
class _PremiumActivePill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '\u2713 Premium Active',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

// ── "Unlock" amber pill ──
class _UnlockPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.amber.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Text(
            'Unlock',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.amber,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 20, color: AppColors.tertiary),
      ],
    );
  }
}

// ── Lock icon + chevron ──
class _LockTrailing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock, size: 16, color: AppColors.tertiary),
        SizedBox(width: 4),
        Icon(Icons.chevron_right, size: 20, color: AppColors.tertiary),
      ],
    );
  }
}

// ── "Upgrade Now" small teal button ──
class _UpgradeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Upgrade Now',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
