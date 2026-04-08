import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class CandidateApplicationsTab extends StatefulWidget {
  const CandidateApplicationsTab({super.key});

  @override
  State<CandidateApplicationsTab> createState() =>
      _CandidateApplicationsTabState();
}

class _CandidateApplicationsTabState extends State<CandidateApplicationsTab> {
  String _selectedFilter = 'All';

  static const _filters = [
    'All',
    'Applied',
    'Under Review',
    'Interview Scheduled',
    'Shortlisted',
    'Rejected',
  ];

  List<Map<String, dynamic>> get _allApps =>
      MockData.applications.cast<Map<String, dynamic>>();

  List<Map<String, dynamic>> get _filteredApps {
    if (_selectedFilter == 'All') return _allApps;
    return _allApps
        .where((a) => a['status'] == _selectedFilter)
        .toList();
  }

  int _countFor(String filter) {
    if (filter == 'All') return _allApps.length;
    return _allApps.where((a) => a['status'] == filter).length;
  }

  Color _avatarColor(String name) {
    final hue = MockData.companyHue(name).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.50).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredApps;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Applications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter tab bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((f) {
                  final selected = _selectedFilter == f;
                  final count = _countFor(f);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.teal : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: selected
                                ? AppColors.teal
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          '$f ($count)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              '${filtered.length} application${filtered.length == 1 ? '' : 's'}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Application list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_outlined,
                            size: 56, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        Text(
                          'No applications found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final app = filtered[i];
                      return _ApplicationCard(
                        app: app,
                        avatarColor: _avatarColor(app['company'] as String),
                        onTap: () => context.push(
                          '/candidate/application/${app['id']}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final Map<String, dynamic> app;
  final Color avatarColor;
  final VoidCallback onTap;

  const _ApplicationCard({
    required this.app,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final company = app['company'] as String;
    final initial = company.isNotEmpty ? company[0] : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppColors.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app['jobTitle'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$company \u00B7 ${app['location']}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: app['status'] as String),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Applied ${app['date']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.tertiary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColors.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
