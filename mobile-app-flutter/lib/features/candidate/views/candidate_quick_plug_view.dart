import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Quick Plug — fast-action hub. Mirrors CandidateQuickPlugView.swift.
class CandidateQuickPlugView extends StatelessWidget {
  const CandidateQuickPlugView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxxl),
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildQuickActions(context),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPremiumSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Quick Plug', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.purple, AppColors.purpleDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: const Icon(Icons.bolt, size: 24, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Boost your profile, get discovered faster, and land your next role.',
            style: TextStyle(fontSize: 15, color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          _buildActionCard(
            icon: Icons.arrow_upward,
            color: AppColors.purple,
            title: 'Boost My Profile',
            subtitle: 'Upgrade to get seen by more employers',
            onTap: () => context.push('/candidate/subscription'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActionCard(
            icon: Icons.work,
            color: AppColors.amber,
            title: 'Quick Apply',
            subtitle: 'Browse and apply to the latest jobs near you',
            onTap: () => context.pop(), // Go back to jobs tab
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActionCard(
            icon: Icons.notifications_active,
            color: AppColors.indigo,
            title: 'Priority Notifications',
            subtitle: 'Upgrade to get notified first when jobs match',
            onTap: () => context.push('/candidate/subscription'),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActionCard(
            icon: Icons.tune,
            color: AppColors.purple,
            title: 'Advanced Filters',
            subtitle: 'Upgrade to unlock premium search filters',
            onTap: () => context.push('/candidate/subscription'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 2),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 12, color: AppColors.tertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: GestureDetector(
        onTap: () => context.push('/candidate/subscription'),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.purple.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: AppColors.purple.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.purple.withValues(alpha: 0.1)),
                child: const Icon(Icons.workspace_premium, size: 16, color: AppColors.purple),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Go Premium', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                    SizedBox(height: 2),
                    Text('Unlock all filters, boost your profile, and get priority access.', style: TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 2),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(color: AppColors.purple, borderRadius: BorderRadius.circular(AppRadius.full)),
                child: const Text('Upgrade', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
