import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class AdminBusinessesView extends StatefulWidget {
  const AdminBusinessesView({super.key});
  @override
  State<AdminBusinessesView> createState() => _AdminBusinessesViewState();
}

class _AdminBusinessesViewState extends State<AdminBusinessesView> {
  String _search = '';
  String _filter = 'All';
  final _filters = ['All', 'Active', 'Suspended', 'Verified', 'Premium'];

  List<Map<String, dynamic>> get _filtered {
    var list = MockData.adminBusinesses.toList();
    if (_filter == 'Active') {
      list = list.where((b) => b['status'] == 'Active').toList();
    } else if (_filter == 'Suspended') {
      list = list.where((b) => b['status'] == 'Suspended').toList();
    } else if (_filter == 'Verified') {
      list = list.where((b) => b['verified'] == 'Verified').toList();
    } else if (_filter == 'Premium') {
      list = list.where((b) => b['plan'] == 'Premium').toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((b) =>
              (b['name'] as String).toLowerCase().contains(q) ||
              (b['category'] as String).toLowerCase().contains(q) ||
              (b['location'] as String).toLowerCase().contains(q))
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
            const Text('Businesses',
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
              child: const Text('89',
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
                hintText: 'Search businesses...',
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
          // Filters
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
                        Icon(Icons.business_outlined,
                            size: 48, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        const Text('No businesses found',
                            style: TextStyle(
                                fontSize: 15, color: AppColors.secondary)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _businessCard(results[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _businessCard(Map<String, dynamic> b) {
    final verified = b['verified'] as String;
    final plan = b['plan'] as String;
    final activeJobs = b['activeJobs'] as int;
    return GestureDetector(
      onTap: () => context.push('/admin/businesses/${b['id']}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          children: [
            // Logo avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(b['initials'] as String,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navy)),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b['name'] as String,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 2),
                  Text(b['category'] as String,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.secondary)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: AppColors.tertiary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(b['location'] as String,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.tertiary),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text('$activeJobs jobs',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Badges
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusBadge(status: b['status'] as String),
                const SizedBox(height: 4),
                _verifiedBadge(verified),
                const SizedBox(height: 4),
                _planBadge(plan),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _verifiedBadge(String verified) {
    IconData icon;
    Color color;
    if (verified == 'Verified') {
      icon = Icons.check_circle;
      color = AppColors.teal;
    } else {
      icon = Icons.cancel_outlined;
      color = AppColors.secondary;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 3),
        Text(verified,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _planBadge(String plan) {
    final isPremium = plan == 'Premium';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isPremium
            ? AppColors.purple.withValues(alpha: 0.10)
            : AppColors.secondary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(plan,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isPremium ? AppColors.purple : AppColors.secondary)),
    );
  }
}
