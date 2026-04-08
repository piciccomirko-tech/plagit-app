import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Service provider subscription paywall -- 3 tiers: Basic, Pro, Premium.
/// Mirrors ServiceSubscriptionView.swift.
class ServiceSubscriptionView extends StatefulWidget {
  const ServiceSubscriptionView({super.key});

  @override
  State<ServiceSubscriptionView> createState() => _ServiceSubscriptionViewState();
}

enum _Tier { basic, pro, premium }

class _TierInfo {
  final String name;
  final String price;
  final String annualPrice;
  final List<(IconData, String)> features;
  final Color color;
  final bool isPopular;

  const _TierInfo({
    required this.name,
    required this.price,
    required this.annualPrice,
    required this.features,
    required this.color,
    this.isPopular = false,
  });
}

final Map<_Tier, _TierInfo> _tierData = {
  _Tier.basic: const _TierInfo(
    name: 'Basic',
    price: '\$9.99/mo',
    annualPrice: '\$99.99/yr',
    features: [
      (Icons.verified, 'Verified Badge'),
      (Icons.trending_up, 'Improved Visibility'),
      (Icons.article, 'Up to 10 Posts'),
      (Icons.people, '20 Contacts/Month'),
    ],
    color: AppColors.teal,
  ),
  _Tier.pro: const _TierInfo(
    name: 'Pro',
    price: '\$19.99/mo',
    annualPrice: '\$199.99/yr',
    features: [
      (Icons.auto_awesome, 'Featured Placement'),
      (Icons.bar_chart, 'Advanced Analytics'),
      (Icons.article_outlined, 'Up to 50 Posts'),
      (Icons.people_alt, '100 Contacts/Month'),
      (Icons.star, 'Priority Listing'),
    ],
    color: AppColors.amber,
    isPopular: true,
  ),
  _Tier.premium: const _TierInfo(
    name: 'Premium',
    price: '\$39.99/mo',
    annualPrice: '\$399.99/yr',
    features: [
      (Icons.workspace_premium, 'Premium Badge'),
      (Icons.arrow_circle_up, 'Top Placement'),
      (Icons.bolt, 'Feed Boost'),
      (Icons.bar_chart_outlined, 'Full Analytics'),
      (Icons.all_inclusive, 'Unlimited Posts'),
      (Icons.all_inclusive, 'Unlimited Contacts'),
    ],
    color: AppColors.indigo,
  ),
};

class _ServiceSubscriptionViewState extends State<ServiceSubscriptionView> {
  _Tier _selectedTier = _Tier.pro;
  bool _isAnnual = true;

  @override
  Widget build(BuildContext context) {
    final selected = _tierData[_selectedTier]!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal)),
                    ),
                    const Spacer(),
                    const Text('Service Plans', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                    const Spacer(),
                    const SizedBox(width: 36, height: 36),
                  ],
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Grow Your Service Business',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Get discovered by more clients with a premium listing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Annual toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Monthly', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _isAnnual ? AppColors.tertiary : AppColors.charcoal)),
                  const SizedBox(width: AppSpacing.md),
                  Switch(
                    value: _isAnnual,
                    activeColor: AppColors.amber,
                    onChanged: (v) => setState(() => _isAnnual = v),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text('Annual', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _isAnnual ? AppColors.charcoal : AppColors.tertiary)),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.online.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: const Text('Save 17%', style: TextStyle(fontSize: 11, color: AppColors.online)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Tier cards
              ..._Tier.values.map((tier) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _tierCard(tier),
              )),

              // Subscribe button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [selected.color, selected.color.withValues(alpha: 0.8)]),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Subscribe to ${selected.name}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Restore purchases
              GestureDetector(
                onTap: () {},
                child: const Text('Restore Purchases', style: TextStyle(fontSize: 13, color: AppColors.tertiary)),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tierCard(_Tier tier) {
    final info = _tierData[tier]!;
    final isSelected = _selectedTier == tier;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: GestureDetector(
        onTap: () => setState(() => _selectedTier = tier),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isSelected ? info.color : AppColors.border.withValues(alpha: 0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: info.color.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(info.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                            if (info.isPopular) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: info.color, borderRadius: BorderRadius.circular(AppRadius.full)),
                                child: const Text('Most Popular', style: TextStyle(fontSize: 11, color: Colors.white)),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isAnnual ? info.annualPrice : info.price,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: info.color),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    size: 24,
                    color: isSelected ? info.color : AppColors.border,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ...info.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(f.$1, size: 14, color: info.color),
                    const SizedBox(width: AppSpacing.sm),
                    Text(f.$2, style: const TextStyle(fontSize: 13, color: AppColors.charcoal)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
