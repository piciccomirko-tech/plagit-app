import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminReportsView extends StatefulWidget {
  const AdminReportsView({super.key});
  @override State<AdminReportsView> createState() => _S();
}

class _S extends State<AdminReportsView> {
  String _filter = 'All';
  final _filters = ['All', 'Open', 'Urgent', 'Under Review', 'Resolved', 'Users', 'Jobs', 'Messages', 'Repeat Offender'];
  final _reports = [
    ('Fake job listing - Senior Chef', 'Fake Jobs Dubai LLC', 'Job', 'Scam', 'Open', 'Urgent', 'Ali Khan', 'Mar 18', 0, 3, ''),
    ('Spam messages to candidates', 'Quick Hire Agency', 'Message', 'Spam', 'Open', 'High', 'Elena Rossi', 'Mar 17', 3, 2, ''),
    ('Fake profile - nonexistent company', 'Ghost Hotels', 'Business', 'Fake', 'Under Review', 'Medium', 'Marco Bianchi', 'Mar 16', 0, 1, 'Admin M.'),
    ('Harassment in messages', 'John Smith', 'User', 'Harassment', 'Open', 'Urgent', 'Sofia Andersen', 'Mar 15', 2, 4, ''),
    ('Misleading salary information', 'Budget Restaurant', 'Job', 'Misleading', 'Resolved', 'Low', 'Liam O\'Brien', 'Mar 14', 0, 1, 'Admin M.'),
    ('Community spam post', 'Spam Bot', 'Community', 'Spam', 'Resolved', 'Low', 'System', 'Mar 13', 0, 1, 'Admin M.'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _reports : _filter == 'Repeat Offender' ? _reports.where((r) => r.$9 >= 2).toList() : _filter == 'Users' || _filter == 'Jobs' || _filter == 'Messages' ? _reports.where((r) => r.$3 == (_filter == 'Users' ? 'User' : _filter == 'Messages' ? 'Message' : 'Job')).toList() : _reports.where((r) => r.$5 == _filter || r.$6 == _filter).toList();
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Reports & Flags', onBack: () => Navigator.pop(context)),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
        AdminSummaryChip(label: 'All', count: '${_reports.length}', color: AppColors.charcoal), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Open', count: '${_reports.where((r) => r.$5 == 'Open').length}', color: AppColors.urgent), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Urgent', count: '${_reports.where((r) => r.$6 == 'Urgent').length}', color: AppColors.urgent), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Review', count: '${_reports.where((r) => r.$5 == 'Under Review').length}', color: AppColors.amber), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Resolved', count: '${_reports.where((r) => r.$5 == 'Resolved').length}', color: AppColors.online),
      ]))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminFilterChips(filters: _filters, selected: _filter, onSelected: (f) => setState(() => _filter = f))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminSortRow(count: filtered.length, entityName: 'reports', sortLabel: 'Severity', onSort: () {})),
      Expanded(child: filtered.isEmpty ? AdminEmptyState(icon: Icons.flag, title: 'No reports match', subtitle: 'Try adjusting filters.') : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Container(
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final r = e.value;
            final typeColor = r.$3 == 'User' ? AppColors.teal : r.$3 == 'Business' ? AppColors.indigo : r.$3 == 'Job' ? AppColors.amber : r.$3 == 'Message' ? AppColors.urgent : AppColors.online;
            final typeIcon = r.$3 == 'User' ? Icons.person : r.$3 == 'Business' ? Icons.business : r.$3 == 'Job' ? Icons.work : r.$3 == 'Message' ? Icons.chat_bubble : Icons.forum;
            final sevColor = r.$6 == 'Urgent' || r.$6 == 'High' ? AppColors.urgent : r.$6 == 'Medium' ? AppColors.amber : AppColors.tertiary;
            final statusColor = r.$5 == 'Open' ? AppColors.amber : r.$5 == 'Under Review' ? AppColors.indigo : r.$5 == 'Resolved' ? AppColors.online : AppColors.tertiary;
            return Column(children: [
              if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 36 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.sm)), child: Icon(typeIcon, size: 16, color: typeColor)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(r.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: AppSpacing.xs), SeverityBadge(text: r.$6, color: sevColor), const SizedBox(width: AppSpacing.xs), StatusPill(text: r.$5, color: statusColor)]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [Text(r.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)), const SizedBox(width: AppSpacing.sm), StatusPill(text: r.$3, color: typeColor), const SizedBox(width: AppSpacing.sm), StatusPill(text: r.$4, color: r.$4 == 'Scam' || r.$4 == 'Harassment' ? AppColors.urgent : r.$4 == 'Spam' || r.$4 == 'Fake' ? AppColors.amber : AppColors.indigo)]),
                  const SizedBox(height: AppSpacing.xs),
                  Text('By: ${r.$7} · ${r.$8}', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [
                    if (r.$9 >= 2) ...[Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: AppColors.urgent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.warning, size: 10, color: AppColors.urgent), Text(' Repeat x${r.$9}', style: const TextStyle(fontSize: 10, color: AppColors.urgent))])), const SizedBox(width: AppSpacing.sm)],
                    if (r.$10 > 1) ...[Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.flag, size: 10, color: AppColors.amber), Text(' ${r.$10} flags', style: const TextStyle(fontSize: 10, color: AppColors.amber))]), const SizedBox(width: AppSpacing.sm)],
                    if (r.$11.isNotEmpty) StatusPill(text: r.$11, color: AppColors.indigo) else if (r.$5 == 'Open') Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: AppColors.amber.withValues(alpha: 0.3), width: 0.5)), child: const Text('Unassigned', style: TextStyle(fontSize: 10, color: AppColors.amber))),
                  ]),
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
