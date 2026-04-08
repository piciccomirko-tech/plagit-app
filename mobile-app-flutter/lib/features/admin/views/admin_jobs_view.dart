import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class AdminJobsView extends StatefulWidget {
  const AdminJobsView({super.key});
  @override
  State<AdminJobsView> createState() => _AdminJobsViewState();
}

class _AdminJobsViewState extends State<AdminJobsView> {
  String _search = '';
  String _filter = 'All';
  final _filters = ['All', 'Active', 'Paused', 'Closed', 'Flagged', 'Featured'];

  List<Map<String, dynamic>> get _filtered {
    var list = MockData.adminJobs.toList();
    if (_filter == 'Active') {
      list = list.where((j) => j['status'] == 'Active').toList();
    } else if (_filter == 'Paused') {
      list = list.where((j) => j['status'] == 'Paused').toList();
    } else if (_filter == 'Closed') {
      list = list.where((j) => j['status'] == 'Closed').toList();
    } else if (_filter == 'Flagged') {
      list = list.where((j) => j['flagged'] == true).toList();
    } else if (_filter == 'Featured') {
      list = list.where((j) => j['featured'] == true).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((j) =>
              (j['title'] as String).toLowerCase().contains(q) ||
              (j['business'] as String).toLowerCase().contains(q) ||
              (j['location'] as String).toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            const Text('Jobs',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text('34',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                hintStyle:
                    const TextStyle(fontSize: 14, color: AppColors.tertiary),
                prefixIcon: const Icon(Icons.search,
                    size: 20, color: AppColors.tertiary),
                filled: true,
                fillColor: AppColors.background,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: _filters.map((f) {
                final sel = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.teal
                            : AppColors.teal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(f,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : AppColors.teal)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // List
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.work_outline,
                            size: 48, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        const Text('No jobs found',
                            style: TextStyle(
                                fontSize: 15, color: AppColors.secondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _jobCard(results[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _jobCard(Map<String, dynamic> j) {
    final featured = j['featured'] == true;
    final urgent = j['urgent'] == true;
    final flagged = j['flagged'] == true;
    final applicants = j['applicants'] as int;
    return GestureDetector(
      onTap: () => context.push('/admin/jobs/${j['id']}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(j['title'] as String,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.charcoal)),
                      const SizedBox(height: 2),
                      Text(j['business'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.secondary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 11, color: AppColors.tertiary),
                          const SizedBox(width: 2),
                          Text(j['location'] as String,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.tertiary)),
                          const SizedBox(width: 10),
                          const Icon(Icons.attach_money,
                              size: 11, color: AppColors.tertiary),
                          Text(j['salary'] as String,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.tertiary)),
                        ],
                      ),
                    ],
                  ),
                ),
                // 3-dot menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      size: 20, color: AppColors.secondary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onSelected: (val) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('$val: ${j['title']}'),
                          duration: const Duration(seconds: 1)),
                    );
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: featured ? 'Unfeature' : 'Feature',
                      child: Row(
                        children: [
                          Icon(Icons.star,
                              size: 16,
                              color: featured
                                  ? AppColors.secondary
                                  : AppColors.amber),
                          const SizedBox(width: 8),
                          Text(featured ? 'Unfeature' : 'Feature'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Pause',
                      child: Row(
                        children: [
                          Icon(Icons.pause_circle_outline,
                              size: 16, color: AppColors.amber),
                          SizedBox(width: 8),
                          Text('Pause'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Close',
                      child: Row(
                        children: [
                          Icon(Icons.cancel_outlined,
                              size: 16, color: AppColors.red),
                          SizedBox(width: 8),
                          Text('Close'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'Remove',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline,
                              size: 16, color: AppColors.red),
                          SizedBox(width: 8),
                          Text('Remove',
                              style: TextStyle(color: AppColors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Bottom row: badges
            Row(
              children: [
                // Applicant count pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('$applicants applicants',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal)),
                ),
                const SizedBox(width: 6),
                StatusBadge(status: j['status'] as String),
                if (featured) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text('Featured',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.amber)),
                  ),
                ],
                if (urgent) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text('Urgent',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.red)),
                  ),
                ],
                if (flagged) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag, size: 10, color: AppColors.red),
                        const SizedBox(width: 3),
                        const Text('Flagged',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.red)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
