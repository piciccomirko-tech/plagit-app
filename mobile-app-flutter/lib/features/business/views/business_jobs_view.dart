import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

/// Business Jobs tab — list of posted jobs with filter tabs.
class BusinessJobsView extends StatefulWidget {
  const BusinessJobsView({super.key});

  @override
  State<BusinessJobsView> createState() => _BusinessJobsViewState();
}

class _BusinessJobsViewState extends State<BusinessJobsView> {
  String _selectedFilter = 'All';
  static const _filters = ['All', 'Active', 'Draft', 'Paused', 'Closed'];

  List<Map<String, dynamic>> get _filteredJobs {
    final all = MockData.businessJobs.cast<Map<String, dynamic>>();
    if (_selectedFilter == 'All') return all;
    return all.where((j) => j['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredJobs;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
      ),
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
                final active = f == _selectedFilter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = f),
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
              '${filtered.length} jobs',
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
          ),
          const SizedBox(height: 12),

          // ── Job list ──
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.work_off_outlined, size: 56, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        Text(
                          'No $_selectedFilter jobs',
                          style: const TextStyle(fontSize: 16, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _JobCard(job: filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final status = job['status']?.toString() ?? 'Draft';
    final urgent = job['urgent'] == true;
    final applicants = job['applicants'] ?? 0;

    return GestureDetector(
      onTap: () => context.push('/business/job/${job['id']}'),
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
                    job['title']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
                StatusBadge(status: status),
                if (urgent) ...[
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
                  job['location']?.toString() ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                ),
                const Text(' · ', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                Text(
                  job['salary']?.toString() ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w500),
                ),
                const Text(' · ', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                Text(
                  job['contract']?.toString() ?? '',
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
                    '$applicants applicants',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Posted ${job['posted'] ?? ''}',
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
