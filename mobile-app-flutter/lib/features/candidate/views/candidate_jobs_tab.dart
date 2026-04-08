import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/job_card.dart';

class CandidateJobsTab extends StatefulWidget {
  const CandidateJobsTab({super.key});

  @override
  State<CandidateJobsTab> createState() => _CandidateJobsTabState();
}

class _CandidateJobsTabState extends State<CandidateJobsTab> {
  int _selectedChip = 0;
  int _selectedSort = 0;
  final Set<String> _savedIds = {...MockData.savedJobIds};

  static const _chipLabels = ['All', 'Nearby', 'Featured', 'Urgent', 'Saved'];
  static const _sortLabels = ['Newest', 'Salary \u2191', 'Distance'];

  List<Map<String, dynamic>> get _filteredJobs {
    final allJobs = MockData.jobs.cast<Map<String, dynamic>>();
    switch (_selectedChip) {
      case 1: // Nearby
        return allJobs.where((j) => j['location'] == 'London').toList();
      case 2: // Featured
        return allJobs.where((j) => j['featured'] == true).toList();
      case 3: // Urgent
        return allJobs.where((j) => j['urgent'] == true).toList();
      case 4: // Saved
        return allJobs.where((j) => _savedIds.contains(j['id'])).toList();
      default:
        return allJobs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _filteredJobs;

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
                  final selected = _selectedChip == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedChip = i),
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
                  final selected = _selectedSort == i;
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSort = i),
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
                  final id = job['id'] as String;
                  return JobCard(
                    job: job,
                    saved: _savedIds.contains(id),
                    onTap: () => context.push('/candidate/job/$id'),
                    onSave: () {
                      setState(() {
                        if (_savedIds.contains(id)) {
                          _savedIds.remove(id);
                        } else {
                          _savedIds.add(id);
                        }
                      });
                    },
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
