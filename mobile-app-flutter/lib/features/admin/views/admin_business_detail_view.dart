import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminBusinessDetailView extends StatefulWidget {
  const AdminBusinessDetailView({super.key});
  @override State<AdminBusinessDetailView> createState() => _State();
}

class _State extends State<AdminBusinessDetailView> {
  String _status = 'Active';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        AdminTopBar(title: 'Business Detail', onBack: () => Navigator.pop(context)),
        Expanded(child: SingleChildScrollView(child: Column(children: [
          const SizedBox(height: AppSpacing.xs),
          _headerCard(),
          const SizedBox(height: AppSpacing.sectionGap),
          _businessInfoCard(),
          const SizedBox(height: AppSpacing.sectionGap),
          _documentsCard(),
          const SizedBox(height: AppSpacing.sectionGap),
          _activityCard(),
          const SizedBox(height: AppSpacing.sectionGap),
          _postedJobsCard(),
          const SizedBox(height: AppSpacing.sectionGap),
          _adminActionsCard(),
          const SizedBox(height: AppSpacing.xxxl),
        ]))),
      ])),
    );
  }

  Widget _headerCard() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AvatarCircle(initials: 'NR', hue: 0.55, size: 64, verified: _status == 'Active'),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          StatusPill(text: _status, color: _status == 'Active' ? AppColors.online : AppColors.urgent),
          const SizedBox(height: AppSpacing.sm),
          const StatusPill(text: 'Restaurant', color: AppColors.indigo),
        ]),
      ]),
      const SizedBox(height: AppSpacing.xl),
      const Text('Nobu Restaurant', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
      const SizedBox(height: AppSpacing.sm),
      const Row(children: [IconLabel(icon: Icons.location_on, text: 'Dubai, UAE'), SizedBox(width: AppSpacing.lg), IconLabel(icon: Icons.calendar_today, text: 'Since Jan 2025')]),
      const SizedBox(height: AppSpacing.sm),
      Row(children: [
        const Text('4 active jobs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
        const Spacer(),
        SizedBox(width: 60, child: LinearProgressIndicator(value: 0.90, backgroundColor: AppColors.surface, color: AppColors.online, minHeight: 4, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: AppSpacing.sm),
        const Text('90% trust', style: TextStyle(fontSize: 10, color: AppColors.online)),
      ]),
    ]));
  }

  Widget _businessInfoCard() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Business Information'),
      const SizedBox(height: AppSpacing.lg),
      Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)), child: const Column(children: [
        AdminInfoRow(icon: Icons.business, label: 'Legal Name', value: 'Nobu Hospitality LLC'),
        Divider(height: 1, color: AppColors.divider),
        AdminInfoRow(icon: Icons.restaurant, label: 'Business Type', value: 'Restaurant - Fine Dining'),
        Divider(height: 1, color: AppColors.divider),
        AdminInfoRow(icon: Icons.email, label: 'Email', value: 'admin@nobu-dubai.com'),
        Divider(height: 1, color: AppColors.divider),
        AdminInfoRow(icon: Icons.phone, label: 'Phone', value: '+971 4 123 4567'),
        Divider(height: 1, color: AppColors.divider),
        AdminInfoRow(icon: Icons.location_on, label: 'City', value: 'Dubai'),
        Divider(height: 1, color: AppColors.divider),
        AdminInfoRow(icon: Icons.public, label: 'Country', value: 'United Arab Emirates'),
        Divider(height: 1, color: AppColors.divider),
        AdminInfoRow(icon: Icons.link, label: 'Website', value: 'noburestaurants.com'),
      ])),
    ]));
  }

  Widget _documentsCard() {
    final docs = [('Trade License', Icons.description, 'Verified'), ('Business Registration', Icons.account_balance, 'Verified'), ('Owner ID', Icons.badge, 'Pending'), ('Address Proof', Icons.location_on, 'Verified'), ('VAT Certificate', Icons.document_scanner, 'Missing')];
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Verification & Documents'),
      const SizedBox(height: AppSpacing.lg),
      Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)), child: Column(children: docs.asMap().entries.map((e) {
        final d = e.value;
        final color = d.$3 == 'Verified' ? AppColors.online : d.$3 == 'Pending' ? AppColors.amber : AppColors.urgent;
        return Column(children: [
          if (e.key > 0) const Divider(height: 1, color: AppColors.divider),
          Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2), child: Row(children: [
            Icon(d.$2, size: 16, color: AppColors.teal), const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(d.$1, style: const TextStyle(fontSize: 14, color: AppColors.charcoal))),
            StatusPill(text: d.$3, color: color),
            if (d.$3 != 'Missing') ...[const SizedBox(width: AppSpacing.sm), const Text('View', style: TextStyle(fontSize: 10, color: AppColors.teal))],
          ])),
        ]);
      }).toList())),
    ]));
  }

  Widget _activityCard() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Business Activity'),
      const SizedBox(height: AppSpacing.lg),
      Row(children: [_miniStat('12', 'Jobs Posted', AppColors.teal), const SizedBox(width: AppSpacing.md), _miniStat('4', 'Active Now', AppColors.indigo), const SizedBox(width: AppSpacing.md), _miniStat('28', 'Total Hires', AppColors.online)]),
      const SizedBox(height: AppSpacing.lg),
      Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)), child: const Column(children: [
        AdminInfoRow(icon: Icons.trending_up, label: 'Response Rate', value: '92%'),
        Divider(height: 1, color: AppColors.divider),
        AdminInfoRow(icon: Icons.flag, label: 'Reports', value: '0'),
        Divider(height: 1, color: AppColors.divider),
        AdminInfoRow(icon: Icons.access_time, label: 'Last Active', value: '2 hours ago'),
        Divider(height: 1, color: AppColors.divider),
        AdminInfoRow(icon: Icons.star, label: 'Platform Trust', value: 'High'),
      ])),
    ]));
  }

  Widget _miniStat(String n, String l, Color c) => Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: AppSpacing.md), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)), child: Column(children: [Text(n, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c)), const SizedBox(height: 2), Text(l, style: const TextStyle(fontSize: 10, color: AppColors.secondary))])));

  Widget _postedJobsCard() {
    final jobs = [('Senior Chef', 'Full-time', '12 applicants', 'Active'), ('Sous Chef', 'Full-time', '8 applicants', 'Active'), ('Bartender', 'Part-time', '5 applicants', 'Paused'), ('Host/Hostess', 'Full-time', '0 applicants', 'Active')];
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Posted Jobs'),
      const SizedBox(height: AppSpacing.lg),
      ...jobs.map((j) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(j.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
          Text('${j.$2} · ${j.$3}', style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
        ])),
        StatusPill(text: j.$4, color: j.$4 == 'Active' ? AppColors.online : AppColors.amber),
      ]))),
    ]));
  }

  Widget _adminActionsCard() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Admin Actions'),
      const SizedBox(height: AppSpacing.lg),
      _actionBtn('Verify Business', Icons.verified, AppColors.teal, () {}),
      const SizedBox(height: AppSpacing.sm),
      _actionBtn('Feature on Home', Icons.star, AppColors.amber, () {}),
      const SizedBox(height: AppSpacing.sm),
      if (_status == 'Active') _actionBtn('Suspend Business', Icons.pause_circle, AppColors.urgent, () => setState(() => _status = 'Suspended'))
      else _actionBtn('Activate Business', Icons.play_circle, AppColors.online, () => setState(() => _status = 'Active')),
      const SizedBox(height: AppSpacing.sm),
      _actionBtn('Add Note', Icons.note_add, AppColors.indigo, () {}),
    ]));
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onTap) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.md)), child: Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: AppSpacing.md), Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)), const Spacer(), Icon(Icons.chevron_right, size: 14, color: color)])));
}
