import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class AdminInterviewsView extends StatefulWidget {
  const AdminInterviewsView({super.key});
  @override
  State<AdminInterviewsView> createState() => _AdminInterviewsViewState();
}

class _AdminInterviewsViewState extends State<AdminInterviewsView> {
  String _filter = 'All';
  final _filters = ['All', 'Upcoming', 'Completed', 'Cancelled', 'No-Show'];

  List<Map<String, dynamic>> get _filtered {
    final interviews = MockData.adminInterviews;
    if (_filter == 'All') return List<Map<String, dynamic>>.from(interviews);
    return List<Map<String, dynamic>>.from(
      interviews.where((i) => i['status'] == _filter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.chevron_left, size: 24, color: AppColors.charcoal),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Interviews',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${MockData.adminInterviews.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _filters.map((f) {
                  final isActive = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.teal : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isActive ? Colors.transparent : AppColors.divider,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isActive ? Colors.white : AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            // List
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No interviews match', style: TextStyle(color: AppColors.secondary)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final i = filtered[index];
                        final formatColor = (i['format'] as String) == 'Video'
                            ? AppColors.purple
                            : (i['format'] as String) == 'Phone'
                                ? AppColors.teal
                                : AppColors.amber;
                        return GestureDetector(
                          onTap: () => context.push('/admin/interviews/${i['id']}'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: AppColors.cardDecoration,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${i['candidateName']} - ${i['business']}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.charcoal,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    StatusBadge(status: i['status'] as String),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  i['jobTitle'] as String,
                                  style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12, color: AppColors.tertiary),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${i['date']} at ${i['time']}',
                                      style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: formatColor.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: Text(
                                        i['format'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: formatColor,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
