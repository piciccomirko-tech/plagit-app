import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminCommunityView extends StatefulWidget {
  const AdminCommunityView({super.key});
  @override State<AdminCommunityView> createState() => _S();
}

class _S extends State<AdminCommunityView> {
  String _filter = 'All';
  final _filters = ['All', 'Published', 'Draft', 'Scheduled', 'Pinned', 'Featured on Home', 'Career Tips', 'Training', 'Featured Employers'];
  final _posts = [
    ('Top 10 Interview Tips for Hospitality', 'Career Tips', 'Admin', 'Published', true, true, 320, 45, '3 min read', 'Mar 15', '', ''),
    ('Luxury Hotel Training Programs 2026', 'Training', 'Admin', 'Published', false, false, 180, 22, '5 min read', 'Mar 12', '', ''),
    ('Nobu Restaurant - Why Work With Us', 'Featured Employers', 'Nobu Restaurant', 'Published', true, true, 450, 68, '4 min read', 'Mar 10', 'Nobu Restaurant', 'Senior Chef'),
    ('Seasonal Menu Planning Guide', 'Career Tips', 'Admin', 'Draft', false, false, 0, 0, '6 min read', 'Mar 20', '', ''),
    ('Bartending Masterclass Series', 'Training', 'Admin', 'Scheduled', false, false, 0, 0, '8 min read', 'Mar 22', '', ''),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _posts : _filter == 'Pinned' ? _posts.where((p) => p.$5).toList() : _filter == 'Featured on Home' ? _posts.where((p) => p.$6).toList() : _posts.where((p) => p.$4 == _filter || p.$2 == _filter).toList();
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Community', onBack: () => Navigator.pop(context), trailing: const Icon(Icons.add_circle, size: 24, color: AppColors.teal)),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
        AdminSummaryChip(label: 'All', count: '${_posts.length}', color: AppColors.charcoal, width: 66), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Published', count: '${_posts.where((p) => p.$4 == 'Published').length}', color: AppColors.online, width: 66), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Drafts', count: '${_posts.where((p) => p.$4 == 'Draft').length}', color: AppColors.secondary, width: 66), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Pinned', count: '${_posts.where((p) => p.$5).length}', color: AppColors.amber, width: 66),
      ]))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminFilterChips(filters: _filters, selected: _filter, onSelected: (f) => setState(() => _filter = f))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminSortRow(count: filtered.length, entityName: 'items', sortLabel: 'Newest', onSort: () {})),
      Expanded(child: filtered.isEmpty ? AdminEmptyState(icon: Icons.chat_bubble, title: 'No content matches', subtitle: 'Try adjusting filters.') : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Container(
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final p = e.value;
            final catColor = p.$2 == 'Career Tips' ? AppColors.amber : p.$2 == 'Training' ? AppColors.indigo : p.$2 == 'Featured Employers' ? AppColors.teal : AppColors.secondary;
            final catIcon = p.$2 == 'Career Tips' ? Icons.lightbulb : p.$2 == 'Training' ? Icons.book : p.$2 == 'Featured Employers' ? Icons.business : Icons.chat_bubble;
            final statusColor = p.$4 == 'Published' ? AppColors.online : p.$4 == 'Draft' ? AppColors.secondary : p.$4 == 'Scheduled' ? AppColors.indigo : AppColors.tertiary;
            return Column(children: [
              if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 36 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: catColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.sm)), child: Icon(catIcon, size: 16, color: catColor)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(p.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: AppSpacing.xs), StatusPill(text: p.$4, color: statusColor)]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [StatusPill(text: p.$2, color: catColor), const SizedBox(width: AppSpacing.sm), Text(p.$3, style: const TextStyle(fontSize: 13, color: AppColors.secondary)), if (p.$5) ...[const SizedBox(width: AppSpacing.sm), const StatusPill(text: 'Pinned', color: AppColors.amber)], if (p.$6) ...[const SizedBox(width: AppSpacing.sm), const StatusPill(text: 'Home', color: AppColors.teal)]]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [if (p.$7 > 0) ...[const Icon(Icons.visibility, size: 10, color: AppColors.tertiary), const SizedBox(width: 2), Text('${p.$7}', style: const TextStyle(fontSize: 10, color: AppColors.secondary)), const SizedBox(width: AppSpacing.md)], if (p.$8 > 0) ...[const Icon(Icons.bookmark, size: 10, color: AppColors.tertiary), const SizedBox(width: 2), Text('${p.$8}', style: const TextStyle(fontSize: 10, color: AppColors.secondary)), const SizedBox(width: AppSpacing.md)], Text(p.$9, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)), const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.tertiary)), Text(p.$4 == 'Published' ? 'Published ${p.$10}' : 'Created ${p.$10}', style: const TextStyle(fontSize: 10, color: AppColors.tertiary))]),
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
