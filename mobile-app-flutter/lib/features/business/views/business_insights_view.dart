import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/business_insights.dart';
import 'package:plagit/repositories/business_repository.dart';

extension _BusinessInsightsL10n on AppLocalizations {
  String get insightsTitleLocal => insights;
}

/// Business Insights / Analytics screen.
/// Mirrors BusinessInsightsView.swift.
class BusinessInsightsView extends StatefulWidget {
  const BusinessInsightsView({super.key});

  @override
  State<BusinessInsightsView> createState() => _BusinessInsightsViewState();
}

class _BusinessInsightsViewState extends State<BusinessInsightsView> {
  final BusinessRepository _repo = BusinessRepository();

  bool _loading = true;
  String? _error;
  BusinessInsights? _insights;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final insights = await _repo.fetchInsights();
      if (!mounted) return;
      setState(() {
        _insights = insights;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool _isEmpty(BusinessInsights insights) {
    return insights.activeJobsCount == 0 &&
        insights.totalApplicants == 0 &&
        insights.interviewCount == 0 &&
        insights.hiredCount == 0 &&
        insights.unreadMessages == 0 &&
        insights.totalJobViews == 0 &&
        insights.totalJobSaves == 0 &&
        insights.topPerformingJob == null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: BackChevron(size: 22, color: AppColors.charcoal),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l.insightsTitleLocal,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36, height: 36),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 40, color: AppColors.secondary),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: _load,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    AppLocalizations.of(context).retry,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final insights = _insights;
    if (insights == null || _isEmpty(insights)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.bar_chart_outlined,
                size: 44,
                color: AppColors.secondary,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'No insights available yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Insights will appear once your jobs and applicants start generating activity.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.secondary),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.xxxl),
      child: Column(
        children: [
          _insightCard(
            title: 'Active Jobs',
            number: insights.activeJobsCount.toString(),
            change: 'Currently live listings',
            icon: Icons.work_rounded,
            color: AppColors.teal,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _insightCard(
            title: 'Applicants',
            number: insights.totalApplicants.toString(),
            change: 'Across all current jobs',
            icon: Icons.people_outline,
            color: AppColors.amber,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _insightCard(
            title: 'Interviews',
            number: insights.interviewCount.toString(),
            change: 'Scheduled or tracked interviews',
            icon: Icons.calendar_today_outlined,
            color: AppColors.online,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _insightCard(
            title: 'Unread Messages',
            number: insights.unreadMessages.toString(),
            change: 'Pending conversation replies',
            icon: Icons.mark_chat_unread_outlined,
            color: AppColors.indigo,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _insightCard(
            title: 'Job Views',
            number: insights.totalJobViews.toString(),
            change: 'Combined views on active jobs',
            icon: Icons.visibility_outlined,
            color: AppColors.indigo,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _insightCard(
            title: 'Job Saves',
            number: insights.totalJobSaves.toString(),
            change: 'Combined saves on active jobs',
            icon: Icons.bookmark_border,
            color: AppColors.teal,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (insights.topPerformingJob != null)
            _topJobCard(insights.topPerformingJob!),
        ],
      ),
    );
  }

  Widget _topJobCard(BusinessInsightsTopJob topJob) {
    final initials = topJob.title.isEmpty
        ? '--'
        : topJob.title
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part.substring(0, 1).toUpperCase())
            .join();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).topPerformingJob,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        HSLColor.fromAHSL(1, 198, 0.45, 0.90).toColor(),
                        HSLColor.fromAHSL(1, 198, 0.55, 0.75).toColor(),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topJob.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${topJob.applicants} applicants · ${topJob.views} views · ${topJob.saves} saves',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _insightCard({
    required String title,
    required String number,
    required String change,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    number,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal,
                    ),
                  ),
                  Text(
                    change,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
