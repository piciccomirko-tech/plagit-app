import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminNotificationsView extends StatefulWidget {
  const AdminNotificationsView({super.key});
  @override State<AdminNotificationsView> createState() => _S();
}

class _S extends State<AdminNotificationsView> {
  String _filter = 'All';
  final _filters = ['All', 'Unread', 'Failed', 'Read', 'Candidate', 'Business', 'System'];
  final _notifs = [
    ('Interview Confirmed', 'Elena Rossi', 'Candidate', 'Push', 'Delivered', 'Interview #1234', 'interviews/detail', true, 0, 'Mar 20'),
    ('New Application Received', 'Nobu Restaurant', 'Business', 'Push', 'Delivered', 'Application #5678', 'applications/detail', true, 0, 'Mar 19'),
    ('Account Verification Required', 'Sofia Andersen', 'Candidate', 'Email', 'Failed', 'Profile Verification', 'profile/verify', false, 2, 'Mar 18'),
    ('Subscription Expiring', 'Sketch London', 'Business', 'In-App', 'Pending', 'Subscription #90', 'billing/detail', false, 0, 'Mar 17'),
    ('Welcome to Plagit', 'Ahmed Al-Rashid', 'Candidate', 'Push', 'Delivered', 'Onboarding', 'home', true, 0, 'Mar 16'),
    ('Payment Failed', 'Zuma Dubai', 'Business', 'Email', 'Failed', 'Invoice #456', 'billing/invoice', false, 3, 'Mar 15'),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'All' ? _notifs : _filter == 'Unread' ? _notifs.where((n) => !n.$8).toList() : _filter == 'Failed' ? _notifs.where((n) => n.$5 == 'Failed').toList() : _filter == 'Read' ? _notifs.where((n) => n.$8 && n.$5 != 'Failed').toList() : _notifs.where((n) => n.$3 == _filter).toList();
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Notifications', onBack: () => Navigator.pop(context)),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
        AdminSummaryChip(label: 'All', count: '${_notifs.length}', color: AppColors.charcoal), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Unread', count: '${_notifs.where((n) => !n.$8).length}', color: AppColors.amber), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Failed', count: '${_notifs.where((n) => n.$5 == 'Failed').length}', color: AppColors.urgent), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Candidate', count: '${_notifs.where((n) => n.$3 == 'Candidate').length}', color: AppColors.teal), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Business', count: '${_notifs.where((n) => n.$3 == 'Business').length}', color: AppColors.indigo),
      ]))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminFilterChips(filters: _filters, selected: _filter, onSelected: (f) => setState(() => _filter = f))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminSortRow(count: filtered.length, entityName: 'notifications', sortLabel: 'Newest', onSort: () {})),
      Expanded(child: filtered.isEmpty ? AdminEmptyState(icon: Icons.notifications_off, title: 'No notifications match', subtitle: 'Try adjusting filters.') : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl),
        child: Container(
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: filtered.asMap().entries.map((e) {
            final n = e.value;
            final typeColor = n.$4 == 'Push' ? AppColors.teal : n.$4 == 'Email' ? AppColors.indigo : n.$4 == 'In-App' ? AppColors.amber : AppColors.online;
            final typeIcon = n.$4 == 'Push' ? Icons.notifications : n.$4 == 'Email' ? Icons.email : n.$4 == 'In-App' ? Icons.phone_android : Icons.sms;
            final deliveryColor = n.$5 == 'Delivered' ? AppColors.online : n.$5 == 'Failed' ? AppColors.urgent : AppColors.amber;
            final deliveryIcon = n.$5 == 'Delivered' ? Icons.check_circle : n.$5 == 'Failed' ? Icons.cancel : Icons.schedule;
            return Column(children: [
              if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 36 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
              Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 36, height: 36, decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.sm)), child: Icon(typeIcon, size: 16, color: typeColor)),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [Flexible(child: Text(n.$1, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: AppSpacing.xs), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: deliveryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(deliveryIcon, size: 10, color: deliveryColor), const SizedBox(width: 2), Text(n.$5, style: TextStyle(fontSize: 10, color: deliveryColor))]))]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [Text(n.$2, style: const TextStyle(fontSize: 13, color: AppColors.secondary)), const SizedBox(width: AppSpacing.sm), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: (n.$3 == 'Candidate' ? AppColors.teal : AppColors.indigo).withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.full)), child: Text(n.$3, style: TextStyle(fontSize: 10, color: n.$3 == 'Candidate' ? AppColors.teal : AppColors.indigo))), const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.tertiary)), Text(n.$4, style: TextStyle(fontSize: 10, color: typeColor))]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [const Icon(Icons.link, size: 10, color: AppColors.tertiary), const SizedBox(width: 2), Text(n.$6, style: const TextStyle(fontSize: 10, color: AppColors.secondary))]),
                  const SizedBox(height: AppSpacing.xs),
                  Row(children: [if (!n.$8 && n.$5 != 'Failed') ...[Container(width: 5, height: 5, decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle)), const SizedBox(width: AppSpacing.sm)], if (n.$9 > 0) ...[StatusPill(text: 'Retried x${n.$9}', color: AppColors.amber), const SizedBox(width: AppSpacing.sm)], Text(n.$10, style: const TextStyle(fontSize: 10, color: AppColors.tertiary))]),
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
