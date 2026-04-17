import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Go Premium — rebuilt in Community-screen design language.
class CandidateSubscriptionView extends StatefulWidget {
  const CandidateSubscriptionView({super.key});

  @override
  State<CandidateSubscriptionView> createState() => _State();
}

class _State extends State<CandidateSubscriptionView> {
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<CandidateAuthProvider>().subscription;
    final isPremium = sub.plan.isPremium;

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
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const SizedBox(width: 36, height: 36, child: BackChevron(size: 22, color: AppColors.charcoal)),
                  ),
                  const Spacer(),
                  const Text('Go Premium', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                  const Spacer(),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            Expanded(
              child: isPremium ? _activePlan(sub) : _paywall(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activePlan(dynamic sub) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.amber.withValues(alpha: 0.2), AppColors.amber.withValues(alpha: 0.05)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.workspace_premium, size: 24, color: AppColors.amber),
              ),
              const SizedBox(height: 16),
              Text('${sub.plan.displayName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
              const SizedBox(height: 6),
              Text(
                sub.renewalDate != null ? 'Renews on ${sub.renewalDate}' : 'Your premium plan is active',
                style: const TextStyle(fontSize: 13, color: AppColors.secondary),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('Manage Subscription', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _paywall() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        children: [
          // Hero
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.amber.withValues(alpha: 0.2), AppColors.amber.withValues(alpha: 0.05)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium, size: 24, color: AppColors.amber),
          ),
          const SizedBox(height: 16),
          const Text('Unlock your full potential', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.charcoal), textAlign: TextAlign.center),
          const SizedBox(height: 6),
          const Text('Premium tools for hospitality professionals', style: TextStyle(fontSize: 13, color: AppColors.secondary), textAlign: TextAlign.center),

          const SizedBox(height: 28),

          // Benefits card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
            ),
            child: Column(
              children: [
                _benefit(Icons.rocket_launch, AppColors.teal, 'Boost My Profile', 'Get seen by more employers'),
                const SizedBox(height: 16),
                _benefit(Icons.bolt, AppColors.purple, 'Quick Apply', 'Apply to jobs instantly'),
                const SizedBox(height: 16),
                _benefit(Icons.notifications_active, AppColors.amber, 'Priority Notifications', 'Never miss an opportunity'),
                const SizedBox(height: 16),
                _benefit(Icons.tune, const Color(0xFF3B82F6), 'Advanced Filters', 'Find exactly what you need'),
                const SizedBox(height: 16),
                _benefit(Icons.visibility, AppColors.teal, 'Increased Visibility', 'Appear higher in searches'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Plan cards
          Row(
            children: [
              Expanded(child: _planCard(0, 'Monthly', '\u00A39.99', '/month', null)),
              const SizedBox(width: 12),
              Expanded(child: _planCard(1, 'Annual', '\u00A389.99', '/year', 'Save 25%')),
            ],
          ),

          const SizedBox(height: 28),

          // CTA
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Free trial started!'), backgroundColor: AppColors.teal, behavior: SnackBarBehavior.floating));
              context.pop();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.teal, AppColors.darkTeal]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: Text('Start Free Trial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.pop(),
            child: const Text('Maybe later', style: TextStyle(fontSize: 13, color: AppColors.tertiary)),
          ),
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, Color color, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _planCard(int index, String title, String price, String period, String? badge) {
    final active = _selected == index;
    return GestureDetector(
      onTap: () => setState(() => _selected = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: active ? AppColors.teal : AppColors.border, width: active ? 2 : 1),
            ),
            child: Column(
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                const SizedBox(height: 6),
                Text(price, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                Text(period, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(8)),
                child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}
