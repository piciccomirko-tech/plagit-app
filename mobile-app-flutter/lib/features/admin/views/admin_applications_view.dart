import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class AdminApplicationsView extends StatefulWidget {
  const AdminApplicationsView({super.key});
  @override
  State<AdminApplicationsView> createState() => _AdminApplicationsViewState();
}

class _AdminApplicationsViewState extends State<AdminApplicationsView> {
  String _filter = 'All';
  final _filters = [
    'All',
    'Applied',
    'Under Review',
    'Interview',
    'Shortlisted',
    'Rejected',
    'Hired',
  ];

  List<Map<String, dynamic>> get _filtered {
    final apps = MockData.adminApplications;
    if (_filter == 'All') return List<Map<String, dynamic>>.from(apps);
    return List<Map<String, dynamic>>.from(
      apps.where((a) => a['status'] == _filter),
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
                  const Text(
                    'Applications',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal),
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
            // Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${filtered.length} applications',
                  style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // List
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('No applications match', style: TextStyle(color: AppColors.secondary)),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final a = filtered[index];
                        return GestureDetector(
                          onTap: () => context.push('/admin/applications/${a['id']}'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: AppColors.cardDecoration,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a['candidateName'] as String,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.charcoal,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${a['jobTitle']} @ ${a['business']}',
                                        style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          StatusBadge(status: a['status'] as String),
                                          const Spacer(),
                                          Text(
                                            a['date'] as String,
                                            style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right, size: 18, color: AppColors.tertiary),
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
