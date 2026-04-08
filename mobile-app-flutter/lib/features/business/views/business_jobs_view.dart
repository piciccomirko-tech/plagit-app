import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
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
                child: const Text('Retry'),
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
              separatorBuilder: (_, __) => const SizedBox(width: 8),
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
                        f,
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
              '${jobs.length} jobs',
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
                          'No $selectedFilter jobs',
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
      title: const Text(
        'My Jobs',
        style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
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
                StatusBadge(status: job.status.displayName),
                if (job.urgent) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'Urgent',
                      style: TextStyle(
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
                    '${job.applicants} applicants',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Posted ${job.posted}',
                  style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20, color: AppColors.secondary),
                  onSelected: (v) {},
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'pause', child: Text('Pause')),
                    PopupMenuItem(value: 'close', child: Text('Close')),
                    PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
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
