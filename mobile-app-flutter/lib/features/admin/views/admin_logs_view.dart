import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminLogsView extends StatefulWidget {
  const AdminLogsView({super.key});
  @override State<AdminLogsView> createState() => _S();
}

class _S extends State<AdminLogsView> {
  String _filter = 'All';
  final _filters = ['All', 'Today', 'Users', 'Jobs', 'Businesses', 'Reports', 'Billing', 'Settings'];
  final _logs = [
    ('Business verified', 'The Ritz London', 'Businesses', 'Admin M.', '2 min ago', 'Success', null, null),
    ('Candidate verified', 'Elena Rossi', 'Users', 'Admin M.', '15 min ago', 'Success', null, null),
    ('Report resolved', 'Spam post removed', 'Reports', 'Admin M.', '32 min ago', 'Success', 'Open', 'Resolved'),
    ('Job approved', 'Senior Chef at Nobu', 'Jobs', 'Admin M.', '1h ago', 'Success', 'Pending', 'Active'),
    ('Account suspended', 'Suspicious activity - John D.', 'Users', 'Admin M.', '2h ago', 'Success', 'Active', 'Suspended'),
    ('Subscription renewed', 'Nobu Restaurant - Premium', 'Billing', 'System', '3h ago', 'Success', null, null),
    ('Settings updated', 'Push notifications enabled', 'Settings', 'Admin M.', '5h ago', 'Success', 'Disabled', 'Enabled'),
    ('Failed payment retry', 'Sketch London - Basic', 'Billing', 'System', '6h ago', 'Failed', null, null),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _logs : _filter == 'Today' ? _logs : _logs.where((l) => l.$3 == _filter).toList();
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Admin Logs', onBack: () => Navigator.pop(context)),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
        AdminSummaryChip(label: 'All', count: '${_logs.length}', color: AppColors.charcoal), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Today', count: '${_logs.length}', color: AppColors.teal), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Users', count: '${_logs.where((l) => l.$3 == 'Users').length}', color: AppColors.teal), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Jobs', count: '${_logs.where((l) => l.$3 == 'Jobs').length}', color: AppColors.indigo), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Reports', count: '${_logs.where((l) => l.$3 == 'Reports').length}', color: AppColors.urgent), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Billing', count: '${_logs.where((l) => l.$3 == 'Billing').length}', color: AppColors.online),
      ]))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminFilterChips(filters: _filters, selected: _filter, onSelected: (f) => setState(() => _filter = f))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminSortRow(count: filtered.length, entityName: 'log entries', sortLabel: 'Newest', onSort: () {})),
      Expanded(child: filtered.isEmpty ? AdminEmptyState(icon: Icons.history, title: 'No logs match', subtitle: 'Try adjusting filters.') : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Container(
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final l = e.value;
            final catColor = l.$3 == 'Users' ? AppColors.teal : l.$3 == 'Jobs' ? AppColors.indigo : l.$3 == 'Businesses' ? AppColors.amber : l.$3 == 'Reports' ? AppColors.urgent : l.$3 == 'Billing' ? AppColors.online : AppColors.secondary;
            final catIcon = l.$3 == 'Users' ? Icons.person : l.$3 == 'Jobs' ? Icons.work : l.$3 == 'Businesses' ? Icons.business : l.$3 == 'Reports' ? Icons.flag : l.$3 == 'Billing' ? Icons.credit_card : Icons.settings;
            return Column(children: [
              if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 36 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: catColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.sm)), child: Icon(catIcon, size: 16, color: catColor)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(l.$2, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                  if (l.$7 != null && l.$8 != null) ...[const SizedBox(height: AppSpacing.xs), Row(children: [Text(l.$7!, style: const TextStyle(fontSize: 10, color: AppColors.urgent, decoration: TextDecoration.lineThrough)), const SizedBox(width: AppSpacing.xs), const Icon(Icons.arrow_forward, size: 10, color: AppColors.tertiary), const SizedBox(width: AppSpacing.xs), Text(l.$8!, style: const TextStyle(fontSize: 10, color: AppColors.online))])],
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [Text(l.$4, style: const TextStyle(fontSize: 10, color: AppColors.teal)), const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.tertiary)), Text(l.$5, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)), const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.tertiary)), Text(l.$6, style: TextStyle(fontSize: 10, color: l.$6 == 'Success' ? AppColors.online : AppColors.urgent))]),
                ])),
              ])),
            ]);
          }).toList()),
        ),
      )),
    ])));
  }
}
