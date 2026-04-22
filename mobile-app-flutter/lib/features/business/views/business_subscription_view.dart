import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/business_subscription.dart';
import 'package:plagit/providers/business_providers.dart';

extension _BusinessSubscriptionL10n on AppLocalizations {
  String _local({
    required String en,
    required String it,
    required String ar,
  }) {
    if (localeName.startsWith('it')) return it;
    if (localeName.startsWith('ar')) return ar;
    return en;
  }

  String get businessPremiumTitleLocal => _local(
        en: 'Business Premium',
        it: 'Business Premium',
        ar: 'الأعمال المميزة',
      );

  String get hireFasterWithPremiumLocal => _local(
        en: 'Hire faster with premium tools',
        it: 'Assumi più velocemente con strumenti premium',
        ar: 'وظّف أسرع مع الأدوات المميزة',
      );

  String get unlockPowerfulRecruitingLocal => _local(
        en: 'Unlock powerful recruiting tools for your business',
        it: 'Sblocca strumenti di recruiting avanzati per il tuo business',
        ar: 'افتح أدوات توظيف قوية لعملك',
      );

  String get benefitQuickPlugLocal => _local(
        en: 'Quick Plug — swipe to match top talent',
        it: 'Quick Plug — scorri per trovare i migliori talenti',
        ar: 'Quick Plug — اسحب للتوافق مع أفضل المواهب',
      );

  String get benefitFeaturedJobsLocal => _local(
        en: 'Featured job listings',
        it: 'Annunci in evidenza',
        ar: 'إعلانات وظائف مميزة',
      );

  String get benefitApplicantInsightsLocal => _local(
        en: 'Applicant insights',
        it: 'Insight sui candidati',
        ar: 'رؤى المتقدمين',
      );

  String get benefitUnlimitedJobsLocal => _local(
        en: 'Unlimited job postings',
        it: 'Annunci di lavoro illimitati',
        ar: 'وظائف غير محدودة',
      );

  String get benefitPriorityVisibilityLocal => _local(
        en: 'Priority visibility',
        it: 'Visibilità prioritaria',
        ar: 'أولوية في الظهور',
      );

  String get savePercent30Local => _local(
        en: 'Save 30%',
        it: 'Risparmia il 30%',
        ar: 'وفّر 30٪',
      );

  String get billingComingSoonLocal => _local(
        en: 'Billing coming soon',
        it: 'Fatturazione in arrivo',
        ar: 'الفوترة قريباً',
      );

  String get billingPreviewOnlyLocal => _local(
        en: 'Plan pricing is shown as a preview only right now.',
        it: 'I prezzi dei piani sono mostrati solo come anteprima per ora.',
        ar: 'أسعار الخطط معروضة حالياً كمعاينة فقط.',
      );

  String get billingUnavailableInAppLocal => _local(
        en: 'Business billing is not available in-app yet.',
        it: 'La fatturazione business non è ancora disponibile in-app.',
        ar: 'فواتير الأعمال غير متاحة داخل التطبيق بعد.',
      );

  String planActiveSuffixLocal(String planName) => _local(
        en: '$planName plan active',
        it: 'Piano $planName attivo',
        ar: 'خطة $planName نشطة',
      );

  String planRenewsOnLocal(String renewalDate) => _local(
        en: 'Renews on $renewalDate',
        it: 'Si rinnova il $renewalDate',
        ar: 'يتجدد في $renewalDate',
      );

  String get premiumPlanIsActiveLocal => _local(
        en: 'Your business plan is active',
        it: 'Il tuo piano business è attivo',
        ar: 'خطتك التجارية نشطة',
      );

  String get manageSubscriptionSoonLocal => _local(
        en: 'Subscription management coming soon',
        it: 'Gestione abbonamento in arrivo',
        ar: 'إدارة الاشتراك قريباً',
      );

  String get manageSubscriptionUnavailableLocal => _local(
        en: 'Plan changes and billing management are not available in-app yet.',
        it: 'Modifiche piano e gestione fatturazione non sono ancora disponibili in-app.',
        ar: 'تغييرات الخطة وإدارة الفوترة غير متاحة داخل التطبيق بعد.',
      );

  String monthlyPriceLocal(String amount) => _local(
        en: '$amount/month',
        it: '$amount/mese',
        ar: '$amount/شهرياً',
      );

  String yearlyPriceLocal(String amount) => _local(
        en: '$amount/year',
        it: '$amount/anno',
        ar: '$amount/سنوياً',
      );

  String approxMonthlyPriceLocal(String amount) => _local(
        en: '(~$amount/month)',
        it: '(~$amount/mese)',
        ar: '(~$amount/شهرياً)',
      );
}

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
    final l = AppLocalizations.of(context);
    final sub = context.watch<BusinessAuthProvider>().subscription;
    final hasActivePaidPlan =
        sub.plan == BusinessSubscriptionPlan.pro || sub.plan.isPremium;

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
        title: Text(
          l.businessPremiumTitleLocal,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
      ),
      body: hasActivePaidPlan
          ? _buildManageSubscription(sub, l)
          : SingleChildScrollView(
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
            Text(
              l.hireFasterWithPremiumLocal,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.unlockPowerfulRecruitingLocal,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.secondary),
            ),
            const SizedBox(height: 32),

            // ── Benefits List ──
            _benefitRow(Icons.bolt, AppColors.purple, l.benefitQuickPlugLocal),
            _benefitRow(Icons.star, AppColors.amber, l.benefitFeaturedJobsLocal),
            _benefitRow(Icons.bar_chart, AppColors.teal, l.benefitApplicantInsightsLocal),
            _benefitRow(Icons.tune, const Color(0xFF3B82F6), l.benefitAdvancedFilters),
            _benefitRow(Icons.all_inclusive, AppColors.green, l.benefitUnlimitedJobsLocal),
            _benefitRow(Icons.visibility, AppColors.teal, l.benefitPriorityVisibilityLocal),

            const SizedBox(height: 32),

            // ── Pricing Cards ──
            _pricingCard(
              index: 0,
              name: l.planBasic,
              price: l.monthlyPriceLocal('\u00A329.99'),
              badge: null,
              badgeColor: Colors.transparent,
            ),
            const SizedBox(height: 12),
            _pricingCard(
              index: 1,
              name: l.planPro,
              price: l.monthlyPriceLocal('\u00A359.99'),
              badge: l.mostPopular,
              badgeColor: AppColors.amber,
            ),
            const SizedBox(height: 12),
            _pricingCard(
              index: 2,
              name: l.planPremium,
              price: l.yearlyPriceLocal('\u00A3499'),
              subPrice: l.approxMonthlyPriceLocal('\u00A341.58'),
              badge: l.savePercent30Local,
              badgeColor: AppColors.green,
            ),

            const SizedBox(height: 32),

            Text(
              l.billingPreviewOnlyLocal,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.secondary),
            ),
            const SizedBox(height: 16),

            // ── Start Free Trial ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l.billingUnavailableInAppLocal),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  l.billingComingSoonLocal,
                  style: const TextStyle(
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
              child: Text(
                l.maybeLater,
                style: const TextStyle(
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

  // ── Already on an active paid business plan ──
  Widget _buildManageSubscription(
    BusinessSubscription sub,
    AppLocalizations l,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, size: 60, color: AppColors.gold),
            const SizedBox(height: 16),
            Text(
              l.planActiveSuffixLocal(sub.plan.displayName),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.charcoal),
            ),
            const SizedBox(height: 8),
            Text(
              sub.renewalDate != null
                  ? l.planRenewsOnLocal(sub.renewalDate!)
                  : l.premiumPlanIsActiveLocal,
              style: const TextStyle(fontSize: 14, color: AppColors.secondary),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.teal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  l.manageSubscriptionSoonLocal,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.manageSubscriptionUnavailableLocal,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
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
