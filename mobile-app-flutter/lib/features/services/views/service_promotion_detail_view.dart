import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/mock/mock_data.dart';

/// Detail view for a single service promotion.
class ServicePromotionDetailView extends StatelessWidget {
  final String promotionId;
  const ServicePromotionDetailView({super.key, required this.promotionId});

  static const _orange = Color(0xFFF97316);

  Map<String, dynamic>? get _promotion {
    final list = MockData.servicePromotions.cast<Map<String, dynamic>>();
    for (final p in list) {
      if (p['id'] == promotionId) return p;
    }
    return null;
  }

  Map<String, dynamic>? _findCompany(String companyId) {
    final list = MockData.serviceCompanies.cast<Map<String, dynamic>>();
    for (final c in list) {
      if (c['id'] == companyId) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final promo = _promotion;
    if (promo == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _topBar(context),
              const Expanded(
                  child: Center(child: Text('Promotion not found'))),
            ],
          ),
        ),
      );
    }

    final companyId = promo['companyId'] as String;
    final company = _findCompany(companyId);
    final initials = promo['companyInitials'] as String;
    final hue = (initials.hashCode % 360).abs().toDouble();
    final bgColor = HSLColor.fromAHSL(1, hue, 0.15, 0.95).toColor();
    final textColor = HSLColor.fromAHSL(1, hue, 0.6, 0.5).toColor();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.md),

                    // Company header card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 14,
                              offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md)),
                            alignment: Alignment.center,
                            child: Text(initials,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor)),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                          promo['company'] as String,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.charcoal)),
                                    ),
                                    if (company != null &&
                                        company['verified'] == true) ...[
                                      const SizedBox(width: AppSpacing.sm),
                                      const Icon(Icons.verified,
                                          size: 14, color: AppColors.teal),
                                    ],
                                  ],
                                ),
                                if (company != null) ...[
                                  const SizedBox(height: AppSpacing.xs),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: 2),
                                    decoration: BoxDecoration(
                                      color:
                                          AppColors.amber.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.full),
                                    ),
                                    child: Text(
                                        company['category'] as String,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.amber)),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // Title
                    Text(promo['title'] as String,
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.charcoal)),
                    const SizedBox(height: AppSpacing.md),

                    // Description
                    Text(promo['description'] as String,
                        style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.secondary,
                            height: 1.5)),
                    const SizedBox(height: AppSpacing.lg),

                    // Valid until
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 14, color: _orange),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Valid until ${promo['validUntil']}',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _orange)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // Terms
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Terms & Conditions',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondary)),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                              'This promotion is subject to availability and cannot be combined with other offers. '
                              'The provider reserves the right to modify or cancel this promotion at any time. '
                              'Contact the company directly for full terms.',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.tertiary,
                                  height: 1.5)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // Contact Company button
                    GestureDetector(
                      onTap: () =>
                          context.push('/services/messages/$companyId'),
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.teal, Color(0xFF1A9090)]),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.email, size: 16, color: Colors.white),
                            SizedBox(width: AppSpacing.sm),
                            Text('Contact Company',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // View Company Profile button
                    GestureDetector(
                      onTap: () =>
                          context.push('/services/companies/$companyId'),
                      child: Container(
                        width: double.infinity,
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.08),
                          borderRadius:
                              BorderRadius.circular(AppRadius.full),
                          border: Border.all(
                              color: AppColors.teal.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business,
                                size: 16, color: AppColors.teal),
                            SizedBox(width: AppSpacing.sm),
                            Text('View Company Profile',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.teal)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.sm),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(
                width: 36,
                height: 36,
                child: Icon(Icons.chevron_left,
                    size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Promotion Details',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }
}
