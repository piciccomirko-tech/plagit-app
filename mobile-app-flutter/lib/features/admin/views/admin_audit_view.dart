import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

class AdminAuditView extends StatefulWidget {
  const AdminAuditView({super.key});
  @override
  State<AdminAuditView> createState() => _AdminAuditViewState();
}

class _AdminAuditViewState extends State<AdminAuditView> {
  String _search = '';
  String _filter = 'All';
  final _filters = [
    'All',
    'Verified',
    'Suspended',
    'Featured',
    'Override',
    'Resolved'
  ];

  List<Map<String, dynamic>> get _filtered {
    var list = MockData.adminAuditLog.toList();
    if (_filter != 'All') {
      list = list.where((a) => a['action'] == _filter).toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((a) =>
              (a['target'] as String).toLowerCase().contains(q) ||
              (a['action'] as String).toLowerCase().contains(q) ||
              (a['admin'] as String).toLowerCase().contains(q))
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
        title: const Text('Audit Log',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal)),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search audit log...',
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
                        Icon(Icons.history,
                            size: 48, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        const Text('No audit entries found',
                            style: TextStyle(
                                fontSize: 15, color: AppColors.secondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => _auditRow(results[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _auditRow(Map<String, dynamic> a) {
    final action = a['action'] as String;
    final (IconData icon, Color color) = _actionStyle(action);

    return GestureDetector(
      onTap: () => context.push('/admin/audit/${a['id']}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          children: [
            // Admin avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text('AU',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy)),
            ),
            const SizedBox(width: 10),
            // Action icon
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 10),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$action ${a['target']}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(a['targetType'] as String,
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.secondary)),
                ],
              ),
            ),
            Text(a['timestamp'] as String,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.tertiary)),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _actionStyle(String action) {
    switch (action) {
      case 'Verified':
        return (Icons.check, AppColors.green);
      case 'Suspended':
        return (Icons.block, AppColors.red);
      case 'Featured':
        return (Icons.star, AppColors.amber);
      case 'Override':
        return (Icons.edit, AppColors.purple);
      case 'Resolved':
        return (Icons.check_circle, AppColors.teal);
      default:
        return (Icons.info, AppColors.secondary);
    }
  }
}
