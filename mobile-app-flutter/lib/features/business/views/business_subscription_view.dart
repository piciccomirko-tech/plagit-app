import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Business Subscription / Paywall screen — 3 tiers: Basic, Pro, Premium.
/// Mirrors BusinessSubscriptionView.swift with mock data.
class BusinessSubscriptionView extends StatefulWidget {
  const BusinessSubscriptionView({super.key});

  @override
  State<BusinessSubscriptionView> createState() =>
      _BusinessSubscriptionViewState();
}

enum _Tier { basic, pro, premium }

class _TierConfig {
  final String name;
  final String desc;
  final String monthlyPrice;
  final String annualPrice;
  final String saving;
  final List<String> features;
  final Color color;
  final bool isPopular;
  final String? topLabel;

  const _TierConfig({
    required this.name,
    required this.desc,
    required this.monthlyPrice,
    required this.annualPrice,
    required this.saving,
    required this.features,
    required this.color,
    required this.isPopular,
    this.topLabel,
  });
}

class _BusinessSubscriptionViewState extends State<BusinessSubscriptionView> {
  _Tier _selectedTier = _Tier.pro;
  bool _isAnnual = true;
  bool _purchasing = false;

  final Map<_Tier, _TierConfig> _configs = {
    _Tier.basic: const _TierConfig(
      name: 'Basic',
      desc: 'Essential hiring tools',
      monthlyPrice: '\$19',
      annualPrice: '\$190',
      saving: 'Save \$38/year',
      features: [
        'Limited job posts',
        'Limited candidate contacts',
        'Basic filters',
        'Improved visibility',
      ],
      color: AppColors.teal,
      isPopular: false,
    ),
    _Tier.pro: const _TierConfig(
      name: 'Pro',
      desc: 'For growing businesses',
      monthlyPrice: '\$29',
      annualPrice: '\$290',
      saving: 'Save \$58/year',
      features: [
        'Unlimited job posts',
        'Unlimited candidate contacts',
        'Advanced filters',
        'Analytics dashboard',
        'Improved visibility',
      ],
      color: AppColors.indigo,
      isPopular: true,
      topLabel: 'Most Popular',
    ),
    _Tier.premium: const _TierConfig(
      name: 'Premium',
      desc: 'Maximum visibility & features',
      monthlyPrice: '\$49',
      annualPrice: '\$490',
      saving: 'Save \$98/year',
      features: [
        'Everything in Pro',
        'Featured listings',
        'Top placement in search',
        'Premium badge',
        'Highlighted company profile',
        'Advanced insights',
      ],
      color: AppColors.amber,
      isPopular: false,
      topLabel: 'Best for Maximum Visibility',
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _topBar(),
              const SizedBox(height: AppSpacing.xl),
              _heroSection(),
              const SizedBox(height: AppSpacing.xxl),
              _billingToggle(),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Text(
                    'Choose the plan that fits your hiring needs. Upgrade or downgrade anytime.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.secondary)),
              ),
              const SizedBox(height: AppSpacing.lg),
              _tierCards(),
              const SizedBox(height: AppSpacing.xxl),
              _restoreLink(),
              const SizedBox(height: AppSpacing.lg),
              _termsNote(),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(
                width: 36,
                height: 36,
                child:
                    Icon(Icons.close, size: 16, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _heroSection() {
    return Column(
      children: [
        const Icon(Icons.business, size: 36, color: AppColors.indigo),
        const SizedBox(height: AppSpacing.md),
        const Text('Upgrade Your Hiring',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal)),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Text(
              'Post jobs, discover candidates, and grow your team with premium tools.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: AppColors.secondary, height: 1.5)),
        ),
      ],
    );
  }

  Widget _billingToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                _toggleBtn('Monthly', !_isAnnual, () {
                  setState(() => _isAnnual = false);
                }),
                _toggleBtn('Yearly', _isAnnual, () {
                  setState(() => _isAnnual = true);
                }),
              ],
            ),
          ),
          if (_isAnnual) ...[
            const SizedBox(height: AppSpacing.xs),
            const Text('Save more with annual billing',
                style: TextStyle(fontSize: 11, color: AppColors.online)),
          ],
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.indigo : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.secondary)),
        ),
      ),
    );
  }

  Widget _tierCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: _Tier.values.map((tier) {
          final cfg = _configs[tier]!;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: _tierCard(tier, cfg),
          );
        }).toList(),
      ),
    );
  }

  Widget _tierCard(_Tier tier, _TierConfig cfg) {
    final isSelected = _selectedTier == tier;
    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: Container(
        padding: EdgeInsets.all(cfg.isPopular ? AppSpacing.xl : AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected || cfg.isPopular
                ? cfg.color
                : AppColors.divider,
            width: isSelected ? 2.5 : cfg.isPopular ? 1.5 : 1,
          ),
          boxShadow: cfg.isPopular
              ? [
                  BoxShadow(
                      color: cfg.color.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top label
            if (cfg.topLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: cfg.color,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (cfg.isPopular)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.local_fire_department,
                            size: 10, color: Colors.white),
                      ),
                    Text(cfg.topLabel!,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),

            // Name + price row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cfg.name,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal)),
                      const SizedBox(height: 2),
                      Text(cfg.desc,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.secondary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_isAnnual ? cfg.annualPrice : cfg.monthlyPrice,
                        style: TextStyle(
                            fontSize: cfg.isPopular ? 28 : 16,
                            fontWeight: FontWeight.w600,
                            color: cfg.isPopular
                                ? cfg.color
                                : AppColors.charcoal)),
                    Text(_isAnnual ? '/year' : '/month',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.tertiary)),
                    if (_isAnnual)
                      Text(cfg.saving,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.online)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Features
            ...cfg.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          size: 12, color: AppColors.online),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(f,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.charcoal)),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: AppSpacing.md),

            // CTA
            GestureDetector(
              onTap: _purchasing
                  ? null
                  : () {
                      setState(() => _selectedTier = tier);
                      // Purchase placeholder
                    },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: cfg.isPopular
                      ? cfg.color
                      : cfg.color.withValues(alpha: 0.1),
                  gradient: cfg.isPopular
                      ? LinearGradient(colors: [
                          cfg.color,
                          cfg.color.withValues(alpha: 0.8)
                        ])
                      : null,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                alignment: Alignment.center,
                child: _purchasing && _selectedTier == tier
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        tier == _Tier.basic
                            ? 'Choose Basic'
                            : tier == _Tier.pro
                                ? 'Choose Pro'
                                : 'Choose Premium',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color:
                                cfg.isPopular ? Colors.white : cfg.color)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _restoreLink() {
    return GestureDetector(
      onTap: () {
        // Restore placeholder
      },
      child: const Text('Restore Purchases',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.indigo)),
    );
  }

  Widget _termsNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Text(
          'Subscriptions auto-renew unless cancelled at least 24 hours before the current period ends. Manage in Settings.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, color: AppColors.tertiary)),
    );
  }
}
