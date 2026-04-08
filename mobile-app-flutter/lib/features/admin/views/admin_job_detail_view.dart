import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminJobDetailView extends StatefulWidget {
  const AdminJobDetailView({super.key});
  @override State<AdminJobDetailView> createState() => _State();
}

class _State extends State<AdminJobDetailView> {
  String _status = 'Active';

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Job Detail', onBack: () => Navigator.pop(context)),
      Expanded(child: SingleChildScrollView(child: Column(children: [
        const SizedBox(height: AppSpacing.xs),
        _headerCard(),
        const SizedBox(height: AppSpacing.sectionGap),
        _jobInfoCard(),
        const SizedBox(height: AppSpacing.sectionGap),
        _descriptionCard(),
        const SizedBox(height: AppSpacing.sectionGap),
        _businessSummaryCard(),
        const SizedBox(height: AppSpacing.sectionGap),
        _applicationsSnapshot(),
        const SizedBox(height: AppSpacing.sectionGap),
        _adminActionsCard(),
        const SizedBox(height: AppSpacing.xxxl),
      ]))),
    ])));
  }

  Widget _headerCard() {
    final statusColor = _status == 'Active' ? AppColors.online : _status == 'Paused' ? AppColors.amber : AppColors.tertiary;
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const AvatarCircle(initials: 'NR', hue: 0.55, size: 54), const Spacer(), StatusPill(text: _status, color: statusColor)]),
      const SizedBox(height: AppSpacing.xl),
      const Text('Senior Chef', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
      const Text('Nobu Restaurant', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.secondary)),
      const SizedBox(height: AppSpacing.sm),
      const Row(children: [IconLabel(icon: Icons.location_on, text: 'Dubai, UAE'), SizedBox(width: AppSpacing.lg), IconLabel(icon: Icons.schedule, text: 'Full-time'), SizedBox(width: AppSpacing.lg), IconLabel(icon: Icons.work, text: 'Chef')]),
      const SizedBox(height: AppSpacing.sm),
      const Row(children: [Text('\$5,500/mo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)), Text(' · ', style: TextStyle(color: AppColors.tertiary)), Text('Posted Mar 18, 2026', style: TextStyle(fontSize: 13, color: AppColors.tertiary))]),
      const SizedBox(height: AppSpacing.sm),
      Row(children: [const Text('12 applicants', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)), const Spacer(), SizedBox(width: 60, child: LinearProgressIndicator(value: 0.85, backgroundColor: AppColors.surface, color: AppColors.teal, minHeight: 4, borderRadius: BorderRadius.circular(2))), const SizedBox(width: AppSpacing.sm), const Text('85% quality', style: TextStyle(fontSize: 10, color: AppColors.teal))]),
    ]));
  }

  Widget _jobInfoCard() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Job Information'),
      const SizedBox(height: AppSpacing.lg),
      Container(decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)), child: const Column(children: [
        AdminInfoRow(icon: Icons.category, label: 'Category', value: 'Fine Dining'),
        Divider(height: 1, color: AppColors.divider), AdminInfoRow(icon: Icons.description, label: 'Contract', value: 'Permanent'),
        Divider(height: 1, color: AppColors.divider), AdminInfoRow(icon: Icons.schedule, label: 'Shift Pattern', value: 'Evenings & Weekends'),
        Divider(height: 1, color: AppColors.divider), AdminInfoRow(icon: Icons.payments, label: 'Salary', value: '\$5,500/mo'),
        Divider(height: 1, color: AppColors.divider), AdminInfoRow(icon: Icons.work, label: 'Experience', value: '3+ years required'),
        Divider(height: 1, color: AppColors.divider), AdminInfoRow(icon: Icons.language, label: 'Languages', value: 'English required'),
        Divider(height: 1, color: AppColors.divider), AdminInfoRow(icon: Icons.calendar_today, label: 'Start Date', value: 'Immediate'),
        Divider(height: 1, color: AppColors.divider), AdminInfoRow(icon: Icons.flight, label: 'Visa Support', value: 'Yes'),
        Divider(height: 1, color: AppColors.divider), AdminInfoRow(icon: Icons.home, label: 'Accommodation', value: 'Provided'),
      ])),
    ]));
  }

  Widget _descriptionCard() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Job Description'),
      const SizedBox(height: AppSpacing.lg),
      const Text('We are looking for a talented and passionate Senior Chef to join our Dubai team. You will lead kitchen operations for private dining and premium events.', style: TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.5)),
      const SizedBox(height: AppSpacing.lg),
      const Text('Key Responsibilities', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
      const SizedBox(height: AppSpacing.sm),
      ...[
        'Lead kitchen operations for private dining and events',
        'Develop seasonal tasting menus with executive team',
        'Manage and train junior kitchen staff',
        'Ensure food safety and quality standards',
      ].map((b) => _bullet(b)),
      const SizedBox(height: AppSpacing.lg),
      const Text('Benefits', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
      const SizedBox(height: AppSpacing.sm),
      ...['Visa sponsorship and relocation support', 'Staff accommodation provided', 'Daily meals during shifts', 'Performance bonuses', 'Health insurance'].map((b) => _check(b)),
    ]));
  }

  Widget _bullet(String t) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('  \u2022  ', style: TextStyle(color: AppColors.teal)), Expanded(child: Text(t, style: const TextStyle(fontSize: 13, color: AppColors.secondary)))]));
  Widget _check(String t) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [const Icon(Icons.check_circle, size: 14, color: AppColors.online), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(t, style: const TextStyle(fontSize: 13, color: AppColors.secondary)))]));

  Widget _businessSummaryCard() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Business Summary'),
      const SizedBox(height: AppSpacing.lg),
      Row(children: [const AvatarCircle(initials: 'NR', hue: 0.55, size: 40, verified: true), const SizedBox(width: AppSpacing.md), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Nobu Restaurant', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)), Text('Restaurant - Fine Dining · Dubai, UAE', style: TextStyle(fontSize: 12, color: AppColors.secondary))]))]),
    ]));
  }

  Widget _applicationsSnapshot() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Applications Snapshot'),
      const SizedBox(height: AppSpacing.lg),
      Row(children: [_ms('12', 'Applied', AppColors.teal), const SizedBox(width: AppSpacing.md), _ms('5', 'Shortlisted', AppColors.indigo), const SizedBox(width: AppSpacing.md), _ms('3', 'Interview', AppColors.online), const SizedBox(width: AppSpacing.md), _ms('1', 'Offered', AppColors.amber)]),
    ]));
  }

  Widget _ms(String n, String l, Color c) => Expanded(child: Column(children: [Text(n, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c)), const SizedBox(height: 2), Text(l, style: const TextStyle(fontSize: 10, color: AppColors.secondary))]));

  Widget _adminActionsCard() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Admin Actions'),
      const SizedBox(height: AppSpacing.lg),
      if (_status == 'Active') _btn('Pause Job', Icons.pause_circle, AppColors.amber, () => setState(() => _status = 'Paused'))
      else _btn('Activate Job', Icons.play_circle, AppColors.online, () => setState(() => _status = 'Active')),
      const SizedBox(height: AppSpacing.sm),
      _btn('Close Job', Icons.close, AppColors.tertiary, () => setState(() => _status = 'Closed')),
      const SizedBox(height: AppSpacing.sm),
      _btn('Feature Job', Icons.star, AppColors.amber, () {}),
      const SizedBox(height: AppSpacing.sm),
      _btn('Add Note', Icons.note_add, AppColors.indigo, () {}),
      const SizedBox(height: AppSpacing.sm),
      _btn('Delete Job', Icons.delete, AppColors.urgent, () {}),
    ]));
  }

  Widget _btn(String l, IconData i, Color c, VoidCallback t) => GestureDetector(onTap: t, child: Container(padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg), decoration: BoxDecoration(color: c.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.md)), child: Row(children: [Icon(i, size: 16, color: c), const SizedBox(width: AppSpacing.md), Text(l, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c)), const Spacer(), Icon(Icons.chevron_right, size: 14, color: c)])));
}
