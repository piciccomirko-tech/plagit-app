import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

class CandidateSubscriptionView extends StatefulWidget {
  const CandidateSubscriptionView({super.key});

  @override
  State<CandidateSubscriptionView> createState() => _CandidateSubscriptionViewState();
}

class _CandidateSubscriptionViewState extends State<CandidateSubscriptionView> {
  int _selectedPlan = 1; // 0 = monthly, 1 = annual
  final bool _isPremium = MockData.candidate['plan'] == 'premium';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: const Text('Go Premium', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
        centerTitle: true,
      ),
      body: _isPremium ? _buildManageSubscription() : _buildPaywall(),
    );
  }

  // ── Already premium ──
  Widget _buildManageSubscription() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, size: 60, color: AppColors.gold),
            const SizedBox(height: 16),
            const Text('Premium Active', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
            const SizedBox(height: 8),
            const Text('Your plan renews on May 8, 2026', style: TextStyle(fontSize: 14, color: AppColors.secondary)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Manage Subscription', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.teal)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Paywall ──
  Widget _buildPaywall() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Crown icon
          const Icon(Icons.workspace_premium, size: 60, color: AppColors.gold),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Unlock your full potential',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.charcoal),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Premium tools for hospitality professionals',
            style: TextStyle(fontSize: 14, color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Benefits list
          _BenefitRow(icon: Icons.star, iconColor: AppColors.gold, text: 'Boost My Profile \u2014 get seen by more employers'),
          _BenefitRow(icon: Icons.bolt, iconColor: AppColors.purple, text: 'Quick Apply \u2014 apply to jobs instantly'),
          _BenefitRow(icon: Icons.notifications_active, iconColor: AppColors.amber, text: 'Priority Notifications \u2014 never miss an opportunity'),
          _BenefitRow(icon: Icons.tune, iconColor: Colors.blue, text: 'Advanced Filters \u2014 find exactly what you need'),
          _BenefitRow(icon: Icons.visibility, iconColor: AppColors.teal, text: 'Increased Visibility \u2014 appear higher in employer searches'),

          const SizedBox(height: 32),

          // Pricing cards
          Row(
            children: [
              Expanded(child: _buildPlanCard(
                index: 0,
                title: 'Monthly',
                price: '\u00A39.99/month',
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildPlanCard(
                index: 1,
                title: 'Annual',
                price: '\u00A389.99/year',
                badge: 'Save 25%',
              )),
            ],
          ),

          const SizedBox(height: 32),

          // Start Free Trial button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Free trial started!'),
                    backgroundColor: AppColors.teal,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                context.pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Start Free Trial', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),

          const SizedBox(height: 12),

          // Maybe later
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Maybe later', style: TextStyle(fontSize: 14, color: AppColors.secondary)),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required int index,
    required String title,
    required String price,
    String? badge,
  }) {
    final selected = _selectedPlan == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.teal : AppColors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                const SizedBox(height: 6),
                Text(price, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;

  const _BenefitRow({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppColors.charcoal))),
        ],
      ),
    );
  }
}
