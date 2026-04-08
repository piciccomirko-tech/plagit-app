import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class AdminModerationView extends StatefulWidget {
  const AdminModerationView({super.key});
  @override
  State<AdminModerationView> createState() => _AdminModerationViewState();
}

class _AdminModerationViewState extends State<AdminModerationView> {
  String _filter = 'All';
  final _filters = ['All', 'High', 'Medium', 'Low', 'Resolved'];

  List<Map<String, dynamic>> get _filtered {
    final reports = MockData.adminModerationReports;
    if (_filter == 'All') return List<Map<String, dynamic>>.from(reports);
    if (_filter == 'Resolved') {
      return List<Map<String, dynamic>>.from(
        reports.where((r) => r['status'] == 'Resolved'),
      );
    }
    return List<Map<String, dynamic>>.from(
      reports.where((r) => r['priority'] == _filter),
    );
  }

  int get _openCount {
    return MockData.adminModerationReports.where((r) => r['status'] == 'Open').length;
  }

  IconData _entityIcon(String entityType) {
    switch (entityType) {
      case 'Job':
        return Icons.work;
      case 'Message':
        return Icons.chat;
      case 'Business':
        return Icons.business;
      default:
        return Icons.flag;
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.red;
      case 'Medium':
        return AppColors.amber;
      case 'Low':
        return AppColors.secondary;
      default:
        return AppColors.secondary;
    }
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
                        'Moderation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '$_openCount',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.red),
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
                      child: Text('No reports match', style: TextStyle(color: AppColors.secondary)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final r = filtered[index];
                        final priorityColor = _priorityColor(r['priority'] as String);
                        return GestureDetector(
                          onTap: () => context.push('/admin/moderation/${r['id']}'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: AppColors.cardDecoration,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: priorityColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _entityIcon(r['entityType'] as String),
                                    size: 18,
                                    color: priorityColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        r['title'] as String,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.charcoal,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        r['entity'] as String,
                                        style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          // Priority badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: priorityColor,
                                              borderRadius: BorderRadius.circular(100),
                                            ),
                                            child: Text(
                                              r['priority'] as String,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          StatusBadge(status: r['status'] as String),
                                          const Spacer(),
                                          Text(
                                            r['date'] as String,
                                            style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
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
