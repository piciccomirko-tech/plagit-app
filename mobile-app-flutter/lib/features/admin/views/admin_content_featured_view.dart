import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminContentFeaturedView extends StatefulWidget {
  const AdminContentFeaturedView({super.key});
  @override State<AdminContentFeaturedView> createState() => _S();
}

class _S extends State<AdminContentFeaturedView> {
  String _filter = 'All';
  final _filters = ['All', 'Featured Employer', 'Featured Job', 'Home Banner', 'Active', 'Scheduled', 'Pinned', 'Expired'];
  final _items = [
    ('Nobu Restaurant Spotlight', 'Featured Employer', 'Active', 'Home Banner', 'Nobu Restaurant', true, 450, 120, 1, 'Mar 15'),
    ('Senior Chef at Nobu', 'Featured Job', 'Active', 'Job Feed Top', 'Senior Chef', false, 320, 85, 2, 'Mar 12'),
    ('Spring Hiring Season Banner', 'Home Banner', 'Active', 'Home Hero', '', true, 800, 200, 1, 'Mar 1'),
    ('Luxury Hotels Hiring', 'Featured Employer', 'Scheduled', 'Home Banner', 'The Ritz London', false, 0, 0, 3, 'Mar 20'),
    ('Bartender of the Month', 'Featured Job', 'Expired', 'Job Feed', 'Bartender Role', false, 150, 30, 5, 'Feb 28'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _items : _filter == 'Pinned' ? _items.where((i) => i.$6).toList() : _items.where((i) => i.$2 == _filter || i.$3 == _filter).toList();
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Content / Featured', onBack: () => Navigator.pop(context), trailing: const Icon(Icons.add_circle, size: 24, color: AppColors.teal)),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
        AdminSummaryChip(label: 'All', count: '${_items.length}', color: AppColors.charcoal, width: 66), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Employers', count: '${_items.where((i) => i.$2 == 'Featured Employer').length}', color: AppColors.teal, width: 66), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Jobs', count: '${_items.where((i) => i.$2 == 'Featured Job').length}', color: AppColors.indigo, width: 66), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Banners', count: '${_items.where((i) => i.$2 == 'Home Banner').length}', color: AppColors.amber, width: 66), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Active', count: '${_items.where((i) => i.$3 == 'Active').length}', color: AppColors.online, width: 66),
      ]))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminFilterChips(filters: _filters, selected: _filter, onSelected: (f) => setState(() => _filter = f))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminSortRow(count: filtered.length, entityName: 'items', sortLabel: 'Priority', onSort: () {})),
      Expanded(child: filtered.isEmpty ? AdminEmptyState(icon: Icons.star, title: 'No content matches', subtitle: 'Try adjusting filters.') : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Container(
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final it = e.value;
            final typeColor = it.$2 == 'Featured Employer' ? AppColors.teal : it.$2 == 'Featured Job' ? AppColors.indigo : AppColors.amber;
            final typeIcon = it.$2 == 'Featured Employer' ? Icons.business : it.$2 == 'Featured Job' ? Icons.work : Icons.view_carousel;
            final statusColor = it.$3 == 'Active' ? AppColors.online : it.$3 == 'Scheduled' ? AppColors.indigo : AppColors.tertiary;
            return Column(children: [
              if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 36 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.sm)), child: Icon(typeIcon, size: 16, color: typeColor)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(it.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: AppSpacing.xs), StatusPill(text: it.$3, color: statusColor), if (it.$6) ...[const SizedBox(width: AppSpacing.xs), const StatusPill(text: 'Pinned', color: AppColors.amber)]]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [StatusPill(text: it.$2, color: typeColor), const SizedBox(width: AppSpacing.sm), Text(it.$4, style: const TextStyle(fontSize: 10, color: AppColors.tertiary))]),
                  if (it.$5.isNotEmpty) ...[const SizedBox(height: AppSpacing.xs), Row(children: [const Icon(Icons.link, size: 10, color: AppColors.tertiary), const SizedBox(width: 2), Text(it.$5, style: const TextStyle(fontSize: 10, color: AppColors.secondary))])],
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [if (it.$7 > 0) ...[const Icon(Icons.visibility, size: 10, color: AppColors.tertiary), const SizedBox(width: 2), Text('${it.$7}', style: const TextStyle(fontSize: 10, color: AppColors.secondary)), const SizedBox(width: AppSpacing.md)], if (it.$8 > 0) ...[const Icon(Icons.touch_app, size: 10, color: AppColors.tertiary), const SizedBox(width: 2), Text('${it.$8}', style: const TextStyle(fontSize: 10, color: AppColors.secondary)), const SizedBox(width: AppSpacing.md)], Text('#${it.$9}', style: const TextStyle(fontSize: 10, color: AppColors.teal)), const SizedBox(width: AppSpacing.md), Text(it.$10, style: const TextStyle(fontSize: 10, color: AppColors.tertiary))]),
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
