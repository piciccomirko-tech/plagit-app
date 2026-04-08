import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/job_card.dart';
import 'package:plagit/providers/candidate_providers.dart';

class CandidateJobsTab extends StatefulWidget {
  const CandidateJobsTab({super.key});

  @override
  State<CandidateJobsTab> createState() => _CandidateJobsTabState();
}

class _CandidateJobsTabState extends State<CandidateJobsTab> {
  static const _chipLabels = ['All', 'Nearby', 'Featured', 'Urgent', 'Saved'];
  static const _sortLabels = ['Newest', 'Salary \u2191', 'Distance'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateJobsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateJobsProvider>();

    // Loading state
    if (provider.loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    // Error state
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.error!,
                style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<CandidateJobsProvider>().load(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final jobs = provider.jobs;
    final selectedChipIndex = _chipLabels.indexOf(provider.filter).clamp(0, _chipLabels.length - 1);
    final selectedSortIndex = _sortLabels.indexOf(provider.sort).clamp(0, _sortLabels.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('Find Work',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.charcoal)),
            ),
            const SizedBox(height: 14),

            // ── Search Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEEEF0),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text('Search jobs, roles, restaurants...',
                          style: TextStyle(fontSize: 14, color: AppColors.tertiary)),
                    ),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (_) => Container(
                            padding: const EdgeInsets.all(24),
                            height: 200,
                            child: const Center(
                              child: Text('Filters coming soon',
                                  style: TextStyle(fontSize: 16, color: AppColors.secondary)),
                            ),
                          ),
                        );
                      },
                      child: const Icon(Icons.tune, color: AppColors.charcoal, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── Filter Chips ──
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _chipLabels.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = selectedChipIndex == i;
                  return GestureDetector(
                    onTap: () => provider.setFilter(_chipLabels[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.teal : Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: selected ? null : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _chipLabels[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // ── Sort Row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: List.generate(_sortLabels.length, (i) {
                  final selected = selectedSortIndex == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () => provider.setSort(_sortLabels[i]),
                      child: Column(
                        children: [
                          Text(
                            _sortLabels[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected ? AppColors.teal : AppColors.secondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 2,
                            width: 40,
                            color: selected ? AppColors.teal : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),

            // ── Job Count ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${jobs.length} jobs available',
                style: const TextStyle(fontSize: 13, color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 10),

            // ── Job List ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final job = jobs[i];
                  return JobCard(
                    job: job.toJson(),
                    saved: provider.savedIds.contains(job.id),
                    onTap: () => context.push('/candidate/job/${job.id}'),
                    onSave: () => provider.toggleSave(job.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
