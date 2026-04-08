import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';

class AdminCandidateDetailView extends StatefulWidget {
  const AdminCandidateDetailView({super.key});
  @override State<AdminCandidateDetailView> createState() => _AdminCandidateDetailViewState();
}

class _AdminCandidateDetailViewState extends State<AdminCandidateDetailView> {
  String _status = 'Verified';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(title: 'Candidate Detail', onBack: () => Navigator.pop(context), trailing: const Icon(Icons.more_horiz, size: 22, color: AppColors.charcoal)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(children: [
                  const SizedBox(height: AppSpacing.xs),
                  _summaryCard(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _profileInfoCard(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _workHistoryCard(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _documentsCard(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _activityCard(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _adminActionsCard(),
                  const SizedBox(height: AppSpacing.xxxl),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard() {
    final statusColor = _status == 'Verified' ? AppColors.online : _status == 'Suspended' ? AppColors.urgent : AppColors.amber;
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const AvatarCircle(initials: 'ER', hue: 0.52, size: 64, verified: true),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          StatusPill(text: _status, color: statusColor),
          const SizedBox(height: AppSpacing.sm),
          StatusPill(text: _status == 'Suspended' ? 'Suspended' : 'Active', color: _status == 'Suspended' ? AppColors.urgent : AppColors.online),
        ]),
      ]),
      const SizedBox(height: AppSpacing.xl),
      const Text('Elena Rossi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
      const SizedBox(height: AppSpacing.sm),
      Row(children: [
        const Text('Executive Chef', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.secondary)),
        const SizedBox(width: AppSpacing.sm),
        StatusPill(text: 'Full-time', color: AppColors.teal),
      ]),
      const SizedBox(height: AppSpacing.sm),
      const Row(children: [IconLabel(icon: Icons.location_on, text: 'London, UK'), SizedBox(width: AppSpacing.lg), IconLabel(icon: Icons.calendar_today, text: 'Since Jan 2025')]),
      const SizedBox(height: AppSpacing.sm),
      Row(children: [
        const Text('8 years experience', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
        const Spacer(),
        SizedBox(width: 60, child: LinearProgressIndicator(value: 0.85, backgroundColor: AppColors.surface, color: AppColors.online, minHeight: 4, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: AppSpacing.sm),
        const Text('85% complete', style: TextStyle(fontSize: 10, color: AppColors.online)),
      ]),
    ]));
  }

  Widget _profileInfoCard() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Profile Information'),
      const SizedBox(height: AppSpacing.lg),
      Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: const Column(children: [
          AdminInfoRow(icon: Icons.email, label: 'Email', value: 'elena.rossi@email.com'),
          Divider(height: 1, color: AppColors.divider),
          AdminInfoRow(icon: Icons.phone, label: 'Phone', value: '+44 7700 123456'),
          Divider(height: 1, color: AppColors.divider),
          AdminInfoRow(icon: Icons.cake, label: 'Date of Birth', value: '15 Mar 1990'),
          Divider(height: 1, color: AppColors.divider),
          AdminInfoRow(icon: Icons.language, label: 'Languages', value: 'Italian, English'),
          Divider(height: 1, color: AppColors.divider),
          AdminInfoRow(icon: Icons.public, label: 'Nationality', value: 'Italian'),
          Divider(height: 1, color: AppColors.divider),
          AdminInfoRow(icon: Icons.work, label: 'Preferred Role', value: 'Executive Chef'),
          Divider(height: 1, color: AppColors.divider),
          AdminInfoRow(icon: Icons.schedule, label: 'Availability', value: 'Immediate'),
        ]),
      ),
    ]));
  }

  Widget _workHistoryCard() {
    final jobs = [
      ('Head Chef', 'The Dorchester', 'London, UK', '2022 - Present', '2 years'),
      ('Sous Chef', 'Nobu Restaurant', 'London, UK', '2019 - 2022', '3 years'),
      ('Chef de Partie', 'Zuma', 'London, UK', '2017 - 2019', '2 years'),
    ];
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Work History'),
      const SizedBox(height: AppSpacing.lg),
      ...jobs.map((j) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 5), decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(j.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            Text('${j.$2} - ${j.$3}', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
            Text('${j.$4} · ${j.$5}', style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
          ])),
        ]),
      )),
    ]));
  }

  Widget _documentsCard() {
    final docs = [
      ('ID / Passport', Icons.badge, 'Verified'), ('Visa / Work Permit', Icons.document_scanner, 'Verified'),
      ('CV / Resume', Icons.description, 'Verified'), ('Certificates', Icons.school, 'Pending'), ('Right to Work', Icons.verified_user, 'Missing'),
    ];
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Verification & Documents'),
      const SizedBox(height: AppSpacing.lg),
      Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Column(children: docs.asMap().entries.map((e) {
          final d = e.value;
          final color = d.$3 == 'Verified' ? AppColors.online : d.$3 == 'Pending' ? AppColors.amber : AppColors.urgent;
          return Column(children: [
            if (e.key > 0) const Divider(height: 1, color: AppColors.divider),
            Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md + 2), child: Row(children: [
              Icon(d.$2, size: 16, color: AppColors.teal),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(d.$1, style: const TextStyle(fontSize: 14, color: AppColors.charcoal))),
              StatusPill(text: d.$3, color: color),
              if (d.$3 != 'Missing') ...[const SizedBox(width: AppSpacing.sm), const Text('View', style: TextStyle(fontSize: 10, color: AppColors.teal))],
            ])),
          ]);
        }).toList()),
      ),
    ]));
  }

  Widget _activityCard() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Platform Activity'),
      const SizedBox(height: AppSpacing.lg),
      Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
        child: const Column(children: [
          AdminInfoRow(icon: Icons.description, label: 'Applications', value: '12 total'),
          Divider(height: 1, color: AppColors.divider),
          AdminInfoRow(icon: Icons.calendar_today, label: 'Interviews', value: '4 completed'),
          Divider(height: 1, color: AppColors.divider),
          AdminInfoRow(icon: Icons.visibility, label: 'Profile Views', value: '245'),
          Divider(height: 1, color: AppColors.divider),
          AdminInfoRow(icon: Icons.access_time, label: 'Last Active', value: '2 hours ago'),
          Divider(height: 1, color: AppColors.divider),
          AdminInfoRow(icon: Icons.flag, label: 'Reports', value: '0'),
        ]),
      ),
    ]));
  }

  Widget _adminActionsCard() {
    return AdminCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const AdminSectionTitle(title: 'Admin Actions'),
      const SizedBox(height: AppSpacing.lg),
      if (_status == 'Verified') ...[
        _adminActionBtn('Suspend Account', Icons.pause_circle, AppColors.urgent, () => setState(() => _status = 'Suspended')),
        const SizedBox(height: AppSpacing.sm),
        _adminActionBtn('Reset Password', Icons.lock_reset, AppColors.amber, () {}),
      ] else if (_status == 'Suspended') ...[
        _adminActionBtn('Reactivate Account', Icons.play_circle, AppColors.online, () => setState(() => _status = 'Verified')),
      ] else ...[
        _adminActionBtn('Verify Account', Icons.verified, AppColors.teal, () => setState(() => _status = 'Verified')),
      ],
      const SizedBox(height: AppSpacing.sm),
      _adminActionBtn('Add Note', Icons.note_add, AppColors.indigo, () {}),
      const SizedBox(height: AppSpacing.sm),
      _adminActionBtn('View Applications', Icons.description, AppColors.teal, () {}),
    ]));
  }

  Widget _adminActionBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.md)),
        child: Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
          const Spacer(),
          Icon(Icons.chevron_right, size: 14, color: color),
        ]),
      ),
    );
  }
}
