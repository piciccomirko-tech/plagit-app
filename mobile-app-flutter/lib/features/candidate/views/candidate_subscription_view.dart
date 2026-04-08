import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Candidate subscription paywall — mirrors CandidateSubscriptionView.swift.
class CandidateSubscriptionView extends StatefulWidget {
  const CandidateSubscriptionView({super.key});

  @override
  State<CandidateSubscriptionView> createState() => _CandidateSubscriptionViewState();
}

class _CandidateSubscriptionViewState extends State<CandidateSubscriptionView> {
  String _selectedPlan = 'annual'; // 'monthly' or 'annual'
  bool _purchasing = false;

  final List<Map<String, dynamic>> _benefits = [
    {'icon': Icons.tune, 'text': 'Advanced search filters'},
    {'icon': Icons.notifications_active, 'text': 'Priority notifications for new matches'},
    {'icon': Icons.visibility, 'text': 'Improved profile visibility'},
    {'icon': Icons.auto_awesome, 'text': 'Premium badge on your profile'},
    {'icon': Icons.star, 'text': 'Early access to new job postings'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopBar(),
              const SizedBox(height: AppSpacing.xl),
              _buildHero(),
              const SizedBox(height: AppSpacing.xxl),
              _buildPlanCards(),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildBenefitsList(),
              const SizedBox(height: AppSpacing.xxl),
              _buildActionButton(),
              const SizedBox(height: AppSpacing.lg),
              _buildRestoreLink(),
              const SizedBox(height: AppSpacing.lg),
              _buildTerms(),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(width: 36, height: 36, child: Icon(Icons.close, size: 16, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [AppColors.amber.withValues(alpha: 0.2), AppColors.amber.withValues(alpha: 0.05)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.workspace_premium, size: 32, color: AppColors.amber),
        ),
        const SizedBox(height: AppSpacing.md),
        const Text('Go Premium', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
        const SizedBox(height: AppSpacing.sm),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Text(
            'Stand out from the crowd and land your dream hospitality role faster.',
            style: TextStyle(fontSize: 15, color: AppColors.secondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          _buildPlanCard(
            title: 'Annual Plan',
            price: '\u00a339.99',
            period: 'per year',
            saving: 'Save 50% vs monthly',
            badge: 'BEST VALUE',
            isSelected: _selectedPlan == 'annual',
            onTap: () => setState(() => _selectedPlan = 'annual'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildPlanCard(
            title: 'Monthly Plan',
            price: '\u00a36.99',
            period: 'per month',
            saving: null,
            badge: null,
            isSelected: _selectedPlan == 'monthly',
            onTap: () => setState(() => _selectedPlan = 'monthly'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    String? saving,
    String? badge,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: isSelected ? AppColors.teal : AppColors.divider, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.teal : AppColors.border, width: 2),
              ),
              child: isSelected
                  ? Center(child: Container(width: 12, height: 12, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.teal)))
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                      if (badge != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.amber, borderRadius: BorderRadius.circular(AppRadius.full)),
                          child: Text(badge, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ],
                  ),
                  if (saving != null)
                    Text(saving, style: const TextStyle(fontSize: 13, color: AppColors.online)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                Text(period, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's Included", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
          const SizedBox(height: AppSpacing.lg),
          ..._benefits.map((b) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tealLight),
                  child: Icon(b['icon'] as IconData, size: 14, color: AppColors.teal),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(b['text'] as String, style: const TextStyle(fontSize: 15, color: AppColors.charcoal))),
                const Icon(Icons.check, size: 12, color: AppColors.online),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: GestureDetector(
        onTap: _purchasing ? null : _purchase,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [BoxShadow(color: AppColors.teal.withValues(alpha: 0.18), blurRadius: 6, offset: const Offset(0, 2))],
          ),
          alignment: Alignment.center,
          child: _purchasing
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(
                  _selectedPlan == 'annual' ? 'Choose Annual Plan' : 'Choose Monthly Plan',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildRestoreLink() {
    return GestureDetector(
      onTap: () {
        // Mock restore
      },
      child: const Text('Restore Purchases', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
    );
  }

  Widget _buildTerms() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Text(
        'Subscription automatically renews unless cancelled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period.',
        style: TextStyle(fontSize: 10, color: AppColors.tertiary),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _purchase() {
    setState(() => _purchasing = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _purchasing = false);
        context.pop();
      }
    });
  }
}
