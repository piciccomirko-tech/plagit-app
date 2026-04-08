import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/providers/business_providers.dart';

/// Business Subscription / Paywall screen — 3 pricing tiers.
class BusinessSubscriptionView extends StatefulWidget {
  const BusinessSubscriptionView({super.key});

  @override
  State<BusinessSubscriptionView> createState() =>
      _BusinessSubscriptionViewState();
}

class _BusinessSubscriptionViewState extends State<BusinessSubscriptionView> {
  int _selectedPlan = 2; // default to premium annual

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<BusinessAuthProvider>().subscription;
    final isPremium = sub.plan.isPremium;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Business Premium',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
      ),
      body: isPremium ? _buildManageSubscription(sub) : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Hero ──
            const Icon(
              Icons.workspace_premium,
              size: 60,
              color: AppColors.gold,
            ),
            const SizedBox(height: 16),
            const Text(
              'Hire faster with premium tools',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock powerful recruiting features',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.secondary),
            ),
            const SizedBox(height: 32),

            // ── Benefits List ──
            _benefitRow(Icons.bolt, AppColors.purple, 'Quick Plug \u2014 swipe to discover candidates'),
            _benefitRow(Icons.star, AppColors.amber, 'Featured Jobs \u2014 appear at top of search'),
            _benefitRow(Icons.bar_chart, AppColors.teal, 'Applicant Insights \u2014 see views and rankings'),
            _benefitRow(Icons.tune, const Color(0xFF3B82F6), 'Advanced Filters \u2014 find exact match'),
            _benefitRow(Icons.all_inclusive, AppColors.green, 'Unlimited Jobs \u2014 post as many as needed'),
            _benefitRow(Icons.visibility, AppColors.teal, 'Priority Visibility \u2014 your jobs shown first'),

            const SizedBox(height: 32),

            // ── Pricing Cards ──
            _pricingCard(
              index: 0,
              name: 'Basic',
              price: '\u00A329.99/month',
              badge: null,
              badgeColor: Colors.transparent,
            ),
            const SizedBox(height: 12),
            _pricingCard(
              index: 1,
              name: 'Pro',
              price: '\u00A359.99/month',
              badge: 'Most Popular',
              badgeColor: AppColors.amber,
            ),
            const SizedBox(height: 12),
            _pricingCard(
              index: 2,
              name: 'Premium',
              price: '\u00A3499/year',
              subPrice: '(~\u00A341.58/month)',
              badge: 'Save 30%',
              badgeColor: AppColors.green,
            ),

            const SizedBox(height: 32),

            // ── Start Free Trial ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Free trial started!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Start Free Trial',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Maybe Later ──
            TextButton(
              onPressed: () => context.pop(),
              child: const Text(
                'Maybe later',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Already premium ──
  Widget _buildManageSubscription(dynamic sub) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, size: 60, color: AppColors.gold),
            const SizedBox(height: 16),
            Text(
              '${sub.plan.displayName} Plan Active',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.charcoal),
            ),
            const SizedBox(height: 8),
            Text(
              sub.renewalDate != null
                  ? 'Your plan renews on ${sub.renewalDate}'
                  : 'Your premium plan is active',
              style: const TextStyle(fontSize: 14, color: AppColors.secondary),
            ),
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

  // ── Benefit Row ──
  Widget _benefitRow(IconData icon, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pricing Card ──
  Widget _pricingCard({
    required int index,
    required String name,
    required String price,
    String? subPrice,
    required String? badge,
    required Color badgeColor,
  }) {
    final isSelected = _selectedPlan == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.teal : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.secondary,
                  ),
                ),
                if (subPrice != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subPrice,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Badge
          if (badge != null)
            Positioned(
              top: -8,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
