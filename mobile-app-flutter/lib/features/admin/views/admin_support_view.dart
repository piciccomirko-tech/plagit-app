import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class AdminSupportView extends StatefulWidget {
  const AdminSupportView({super.key});
  @override
  State<AdminSupportView> createState() => _AdminSupportViewState();
}

class _AdminSupportViewState extends State<AdminSupportView> {
  String _filter = 'All';
  final _filters = ['All', 'Open', 'In Review', 'Waiting', 'Resolved'];

  List<Map<String, dynamic>> get _filtered {
    if (_filter == 'All') return MockData.adminSupportIssues.toList();
    return MockData.adminSupportIssues
        .where((s) => s['status'] == _filter)
        .toList();
  }

  int get _openCount =>
      MockData.adminSupportIssues.where((s) => s['status'] == 'Open').length;

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
            const Text('Support Issues',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.charcoal)),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text('$_openCount open',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.red)),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
                        Icon(Icons.support_agent,
                            size: 48, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        const Text('No issues found',
                            style: TextStyle(
                                fontSize: 15, color: AppColors.secondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _issueCard(results[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _issueCard(Map<String, dynamic> s) {
    final priority = s['priority'] as String;
    final priorityColor =
        priority == 'High' ? AppColors.red : AppColors.amber;
    return GestureDetector(
      onTap: () => context.push('/admin/support/${s['id']}'),
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
              children: [
                Expanded(
                  child: Text(s['title'] as String,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                StatusBadge(status: s['status'] as String),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(s['userName'] as String,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.secondary)),
                const SizedBox(width: 8),
                _typeBadge(s['userType'] as String),
                const Spacer(),
                _priorityBadge(priority, priorityColor),
              ],
            ),
            const SizedBox(height: 4),
            Text(s['created'] as String,
                style:
                    const TextStyle(fontSize: 11, color: AppColors.tertiary)),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(String type) {
    final isBusiness = type == 'Business';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isBusiness
            ? AppColors.purple.withValues(alpha: 0.10)
            : AppColors.teal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(type,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isBusiness ? AppColors.purple : AppColors.teal)),
    );
  }

  Widget _priorityBadge(String priority, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(priority,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
