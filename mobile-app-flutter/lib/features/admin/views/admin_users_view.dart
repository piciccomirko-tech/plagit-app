import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminUsersView extends StatefulWidget {
  const AdminUsersView({super.key});
  @override State<AdminUsersView> createState() => _S();
}

class _S extends State<AdminUsersView> {
  String _filter = 'All';
  bool _showSearch = false;
  String _searchText = '';
  final _filters = ['All', 'Candidates', 'Businesses', 'Admins', 'Verified', 'Suspended', 'Banned'];
  final _users = [
    ('Elena Rossi', 'ER', 0.52, 'elena@email.com', 'Candidate', 'Executive Chef', 'London, UK', 'Active', true, 'Mar 2025', '2h ago'),
    ('Nobu Restaurant', 'NR', 0.55, 'admin@nobu.com', 'Business', 'Restaurant', 'Dubai, UAE', 'Active', true, 'Jan 2025', '30m ago'),
    ('Marco Bianchi', 'MB', 0.35, 'marco@email.com', 'Candidate', 'Sommelier', 'Milan, Italy', 'Active', true, 'Feb 2025', '1d ago'),
    ('Sketch London', 'SL', 0.42, 'info@sketch.com', 'Business', 'Restaurant', 'London, UK', 'Suspended', false, 'Feb 2025', '3d ago'),
    ('Super Admin', 'SA', 0.8, 'admin@plagit.com', 'Admin', 'Super Admin', '-', 'Active', true, 'Nov 2024', '5m ago'),
    ('Sofia Andersen', 'SA', 0.72, 'sofia@email.com', 'Candidate', 'Front Desk', 'Dubai, UAE', 'Active', false, 'Mar 2026', '3h ago'),
  ];

  List get _filtered {
    var list = _users.toList();
    if (_filter == 'Candidates') list = list.where((u) => u.$5 == 'Candidate').toList();
    else if (_filter == 'Businesses') list = list.where((u) => u.$5 == 'Business').toList();
    else if (_filter == 'Admins') list = list.where((u) => u.$5 == 'Admin').toList();
    else if (_filter == 'Verified') list = list.where((u) => u.$9).toList();
    else if (_filter == 'Suspended') list = list.where((u) => u.$8 == 'Suspended').toList();
    if (_searchText.isNotEmpty) list = list.where((u) => u.$1.toLowerCase().contains(_searchText.toLowerCase()) || u.$4.toLowerCase().contains(_searchText.toLowerCase())).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Users', onBack: () => Navigator.pop(context), trailing: GestureDetector(onTap: () => setState(() { _showSearch = !_showSearch; if (!_showSearch) _searchText = ''; }), child: Icon(_showSearch ? Icons.close : Icons.search, size: 22, color: AppColors.charcoal))),
      if (_showSearch) AdminSearchBar(hint: 'Search name, email, role, location...', text: _searchText, onChanged: (v) => setState(() => _searchText = v), onClear: () => setState(() => _searchText = '')),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
        AdminSummaryChip(label: 'All', count: '${_users.length}', color: AppColors.charcoal, width: 72), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Candidates', count: '${_users.where((u) => u.$5 == 'Candidate').length}', color: AppColors.teal, width: 72), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Businesses', count: '${_users.where((u) => u.$5 == 'Business').length}', color: AppColors.indigo, width: 72), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Verified', count: '${_users.where((u) => u.$9).length}', color: AppColors.online, width: 72),
      ]))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminFilterChips(filters: _filters, selected: _filter, onSelected: (f) => setState(() => _filter = f))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminSortRow(count: _filtered.length, entityName: 'users', sortLabel: 'Newest', onSort: () {})),
      Expanded(child: _filtered.isEmpty ? AdminEmptyState(icon: Icons.people, title: 'No users match', subtitle: 'Try adjusting filters.') : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Container(
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: _filtered.asMap().entries.map((e) {
            final u = e.value;
            final typeColor = u.$5 == 'Candidate' ? AppColors.teal : u.$5 == 'Business' ? AppColors.indigo : AppColors.amber;
            return Column(children: [
              if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 44 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AvatarCircle(initials: u.$2, hue: u.$3, verified: u.$9),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(u.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: AppSpacing.xs), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: typeColor, borderRadius: BorderRadius.circular(AppRadius.full)), child: Text(u.$5, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white))), if (u.$8 != 'Active') ...[const SizedBox(width: AppSpacing.xs), StatusPill(text: u.$8, color: AppColors.urgent)]]),
                  const SizedBox(height: AppSpacing.xs),
                  Text(u.$4, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [Text(u.$6, style: const TextStyle(fontSize: 13, color: AppColors.charcoal)), if (u.$7 != '-') ...[const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.tertiary)), Text(u.$7, style: const TextStyle(fontSize: 13, color: AppColors.tertiary))]]),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Joined ${u.$10} · Active ${u.$11}', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                ])),
                const Icon(Icons.more_horiz, size: 18, color: AppColors.tertiary),
              ])),
            ]);
          }).toList()),
        ),
      )),
    ])));
  }
}
