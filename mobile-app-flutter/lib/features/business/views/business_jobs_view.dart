import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/business_job.dart';
import 'package:plagit/providers/business_providers.dart';

/// Business Jobs tab — list of posted jobs with filter tabs.
class BusinessJobsView extends StatefulWidget {
  const BusinessJobsView({super.key});

  @override
  State<BusinessJobsView> createState() => _BusinessJobsViewState();
}

class _BusinessJobsViewState extends State<BusinessJobsView> {
  static const _filters = ['All', 'Active', 'Draft', 'Paused', 'Closed'];

  String _localText(
    BuildContext context, {
    required String en,
    required String it,
    required String ar,
  }) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'it') return it;
    if (code == 'ar') return ar;
    return en;
  }

  String _filterLabel(AppLocalizations l, String id) => switch (id) {
        'All' => l.filterAll,
        'Active' => _localText(
          context,
          en: 'Active',
          it: 'Attive',
          ar: 'نشطة',
        ),
        'Draft' => _localText(
          context,
          en: 'Draft',
          it: 'Bozze',
          ar: 'مسودات',
        ),
        'Paused' => _localText(
          context,
          en: 'Paused',
          it: 'In pausa',
          ar: 'متوقفة',
        ),
        'Closed' => _localText(
          context,
          en: 'Closed',
          it: 'Chiuse',
          ar: 'مغلقة',
        ),
        _ => id,
      };

  String _retryLabel(BuildContext context) =>
      _localText(context, en: 'Retry', it: 'Riprova', ar: 'إعادة المحاولة');

  String _jobsCountLabel(BuildContext context, int count) => _localText(
        context,
        en: '$count jobs',
        it: '$count lavori',
        ar: '$count وظائف',
      );

  String _noJobsForFilterLabel(BuildContext context, String filter) => _localText(
        context,
        en: 'No jobs for $filter',
        it: 'Nessun lavoro per $filter',
        ar: 'لا توجد وظائف ضمن $filter',
      );

  String _myJobsTitle(BuildContext context) =>
      _localText(context, en: 'My Jobs', it: 'I miei lavori', ar: 'وظائفي');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessJobsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessJobsProvider>();
    final l = AppLocalizations.of(context);

    // ── Loading state ──
    if (provider.loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    // ── Error state ──
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.red),
              const SizedBox(height: 12),
              Text(
                provider.error!,
                style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<BusinessJobsProvider>().load(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_retryLabel(context)),
              ),
            ],
          ),
        ),
      );
    }

    // ── Content state ──
    final jobs = provider.jobs;
    final selectedFilter = provider.filter;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter tabs ──
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = f == selectedFilter;
                return GestureDetector(
                  onTap: () => context.read<BusinessJobsProvider>().setFilter(f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.teal : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: active ? null : Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        _filterLabel(l, f),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Job count ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _jobsCountLabel(context, jobs.length),
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
          ),
          const SizedBox(height: 12),

          // ── Job list ──
          Expanded(
            child: jobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.work_off_outlined, size: 56, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        Text(
                          _noJobsForFilterLabel(
                            context,
                            _filterLabel(l, selectedFilter),
                          ),
                          style: const TextStyle(fontSize: 16, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: jobs.length,
                    itemBuilder: (_, i) => _JobCard(job: jobs[i]),
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(
        _myJobsTitle(context),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.charcoal,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: AppColors.teal, size: 28),
          onPressed: () => context.push('/business/post-job'),
        ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  final BusinessJob job;
  const _JobCard({required this.job});

  String _localText(
    BuildContext context, {
    required String en,
    required String it,
    required String ar,
  }) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'it') return it;
    if (code == 'ar') return ar;
    return en;
  }

  String _applicantsCountLabel(BuildContext context, int count) => _localText(
        context,
        en: '$count applicants',
        it: '$count candidati',
        ar: '$count متقدمين',
      );

  String _jobMenuLabel(BuildContext context, String key) => switch (key) {
        'edit' => _localText(
          context,
          en: 'Edit',
          it: 'Modifica',
          ar: 'تعديل',
        ),
        'pause' => _localText(
          context,
          en: 'Pause',
          it: 'Metti in pausa',
          ar: 'إيقاف مؤقت',
        ),
        'close' => _localText(
          context,
          en: 'Close',
          it: 'Chiudi',
          ar: 'إغلاق',
        ),
        'duplicate' => _localText(
          context,
          en: 'Duplicate',
          it: 'Duplica',
          ar: 'تكرار',
        ),
        _ => key,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => context.push('/business/job/${job.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title + badges ──
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
                StatusBadge(
                  status: job.status.displayName,
                  label: job.status.localizedLabel(l),
                ),
                if (job.urgent) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      l.urgentBadge,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),

            // ── Location · salary · contract ──
            Row(
              children: [
                Text(
                  job.location,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                ),
                const Text(' · ', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                Text(
                  job.salary,
                  style: const TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w500),
                ),
                const Text(' · ', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                Text(
                  job.contract,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── Applicants + posted + menu ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    _applicantsCountLabel(context, job.applicants),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l.postedAgo(job.posted),
                  style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.secondary),
                  onSelected: (v) {},
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(_jobMenuLabel(context, 'edit')),
                    ),
                    PopupMenuItem(
                      value: 'pause',
                      child: Text(_jobMenuLabel(context, 'pause')),
                    ),
                    PopupMenuItem(
                      value: 'close',
                      child: Text(_jobMenuLabel(context, 'close')),
                    ),
                    PopupMenuItem(
                      value: 'duplicate',
                      child: Text(_jobMenuLabel(context, 'duplicate')),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
