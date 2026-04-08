import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/features/admin/views/admin_business_detail_view.dart';

class AdminBusinessesView extends StatefulWidget {
  const AdminBusinessesView({super.key});
  @override State<AdminBusinessesView> createState() => _State();
}

class _State extends State<AdminBusinessesView> {
  bool _showSearch = false;
  String _searchText = '';
  String _selectedFilter = 'All';
  final _filters = ['All', 'Verified', 'Unverified', 'Active Plan', 'Trial', 'Suspended', 'Flagged'];

  final _businesses = [
    _Biz('Nobu Restaurant', 'NR', 0.55, 'Restaurant', 'Dubai, UAE', true, true, 'Active', 'Premium', 'Active', 4, 28, 92, 0, 'Jan 2025', '2h ago'),
    _Biz('The Ritz London', 'RL', 0.3, 'Hotel', 'London, UK', true, false, 'Active', 'Enterprise', 'Active', 6, 45, 88, 0, 'Dec 2024', '1h ago'),
    _Biz('Zuma Dubai', 'ZD', 0.7, 'Restaurant', 'Dubai, UAE', false, false, 'Active', 'Basic', 'Trial', 2, 12, 65, 0, 'Mar 2026', '5h ago'),
    _Biz('Burj Al Arab', 'BA', 0.1, 'Hotel', 'Dubai, UAE', true, false, 'Active', 'Enterprise', 'Active', 8, 60, 95, 1, 'Nov 2024', '30m ago'),
    _Biz('Sketch London', 'SL', 0.42, 'Restaurant', 'London, UK', false, false, 'Suspended', 'Basic', 'Expired', 0, 5, 30, 2, 'Feb 2025', '3d ago'),
  ];

  List<_Biz> get _filtered {
    var list = _businesses.toList();
    if (_selectedFilter == 'Verified') list = list.where((b) => b.isVerified).toList();
    else if (_selectedFilter == 'Unverified') list = list.where((b) => !b.isVerified).toList();
    else if (_selectedFilter == 'Active Plan') list = list.where((b) => b.planStatus == 'Active').toList();
    else if (_selectedFilter == 'Trial') list = list.where((b) => b.planStatus == 'Trial').toList();
    else if (_selectedFilter == 'Suspended') list = list.where((b) => b.status == 'Suspended').toList();
    else if (_selectedFilter == 'Flagged') list = list.where((b) => b.flagCount > 0).toList();
    if (_searchText.isNotEmpty) list = list.where((b) => b.name.toLowerCase().contains(_searchText.toLowerCase())).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        AdminTopBar(title: 'Businesses', onBack: () => Navigator.pop(context), trailing: GestureDetector(onTap: () => setState(() { _showSearch = !_showSearch; if (!_showSearch) _searchText = ''; }), child: Icon(_showSearch ? Icons.close : Icons.search, size: 22, color: AppColors.charcoal))),
        if (_showSearch) AdminSearchBar(hint: 'Search name, email, contact, type...', text: _searchText, onChanged: (v) => setState(() => _searchText = v), onClear: () => setState(() => _searchText = '')),
        Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: _summaryCards()),
        Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminFilterChips(filters: _filters, selected: _selectedFilter, onSelected: (f) => setState(() => _selectedFilter = f))),
        Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminSortRow(count: _filtered.length, entityName: 'businesses', sortLabel: 'Newest', onSort: () {})),
        Expanded(child: _filtered.isEmpty
          ? AdminEmptyState(icon: Icons.business, title: 'No businesses match this filter', subtitle: 'Try adjusting your filters or search.', onShowAll: () => setState(() { _selectedFilter = 'All'; _searchText = ''; }))
          : _buildList()),
      ])),
    );
  }

  Widget _summaryCards() {
    return SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
      AdminSummaryChip(label: 'All', count: '${_businesses.length}', color: AppColors.charcoal), const SizedBox(width: AppSpacing.sm),
      AdminSummaryChip(label: 'Verified', count: '${_businesses.where((b) => b.isVerified).length}', color: AppColors.online), const SizedBox(width: AppSpacing.sm),
      AdminSummaryChip(label: 'Active', count: '${_businesses.where((b) => b.planStatus == 'Active').length}', color: AppColors.teal), const SizedBox(width: AppSpacing.sm),
      AdminSummaryChip(label: 'Trial', count: '${_businesses.where((b) => b.planStatus == 'Trial').length}', color: AppColors.indigo), const SizedBox(width: AppSpacing.sm),
      AdminSummaryChip(label: 'Suspended', count: '${_businesses.where((b) => b.status == 'Suspended').length}', color: AppColors.urgent),
    ]));
  }

  Widget _buildList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
      child: Container(
        decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: _filtered.asMap().entries.map((e) {
          final b = e.value;
          return Column(children: [
            if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 44 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
            GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBusinessDetailView())),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AvatarCircle(initials: b.initials, hue: b.hue, verified: b.isVerified),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(b.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: AppSpacing.xs), if (b.isFeatured) const StatusPill(text: 'Featured', color: AppColors.amber), if (b.status != 'Active') StatusPill(text: b.status, color: AppColors.urgent)]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [StatusPill(text: b.venueType, color: AppColors.indigo), const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.tertiary)), Expanded(child: Text(b.location, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 1))]),
                  const SizedBox(height: AppSpacing.xs),
                  StatusPill(text: '${b.plan} · ${b.planStatus}', color: b.planStatus == 'Active' ? AppColors.online : b.planStatus == 'Trial' ? AppColors.amber : AppColors.urgent),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [
                    _metric(Icons.work, '${b.activeJobs} jobs'), const SizedBox(width: AppSpacing.md),
                    _metric(Icons.people, '${b.applicants} apps'), const SizedBox(width: AppSpacing.md),
                    Icon(Icons.bolt, size: 10, color: b.responseRate >= 80 ? AppColors.online : b.responseRate >= 50 ? AppColors.amber : AppColors.urgent),
                    Text('${b.responseRate}%', style: TextStyle(fontSize: 10, color: b.responseRate >= 80 ? AppColors.online : b.responseRate >= 50 ? AppColors.amber : AppColors.urgent)),
                    if (b.flagCount > 0) ...[const SizedBox(width: AppSpacing.md), Icon(Icons.flag, size: 10, color: AppColors.urgent), Text('${b.flagCount}', style: const TextStyle(fontSize: 10, color: AppColors.urgent))],
                  ]),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Joined ${b.joined} · Active ${b.lastActive}', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                ])),
                const Icon(Icons.more_horiz, size: 18, color: AppColors.tertiary),
              ])),
            ),
          ]);
        }).toList()),
      ),
    );
  }

  Widget _metric(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 10, color: AppColors.tertiary), const SizedBox(width: 2), Text(text, style: const TextStyle(fontSize: 10, color: AppColors.secondary))]);
}

class _Biz {
  final String name, initials, venueType, location, status, plan, planStatus, joined, lastActive;
  final double hue;
  final bool isVerified, isFeatured;
  final int activeJobs, applicants, responseRate, flagCount;
  _Biz(this.name, this.initials, this.hue, this.venueType, this.location, this.isVerified, this.isFeatured, this.status, this.plan, this.planStatus, this.activeJobs, this.applicants, this.responseRate, this.flagCount, this.joined, this.lastActive);
}
