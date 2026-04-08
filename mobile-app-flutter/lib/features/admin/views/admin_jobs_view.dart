import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/features/admin/views/admin_job_detail_view.dart';

class AdminJobsView extends StatefulWidget {
  const AdminJobsView({super.key});
  @override State<AdminJobsView> createState() => _State();
}

class _State extends State<AdminJobsView> {
  bool _showSearch = false;
  String _searchText = '';
  String _selectedFilter = 'All';
  final _filters = ['All', 'Active', 'Paused', 'Closed', 'Draft', 'Flagged', 'Featured', 'No Applicants'];

  final _jobs = [
    _Job('Senior Chef', 'Nobu Restaurant', 'NR', 0.55, 'Dubai, UAE', 'Active', 'Full-time', '\$5,500/mo', 'Chef', true, true, 245, 12, 12, 3, 2, 0, 'Mar 18', 'Apr 18'),
    _Job('Head Sommelier', 'The Ritz London', 'RL', 0.3, 'London, UK', 'Active', 'Full-time', '\$4,200/mo', 'F&B', true, false, 180, 8, 8, 2, 1, 0, 'Mar 15', 'Apr 30'),
    _Job('Bartender', 'Sketch London', 'SL', 0.42, 'London, UK', 'Paused', 'Part-time', '\$18/hr', 'Bar', false, false, 90, 5, 3, 1, 0, 0, 'Mar 10', 'Apr 10'),
    _Job('Concierge', 'Burj Al Arab', 'BA', 0.1, 'Dubai, UAE', 'Active', 'Full-time', '\$3,800/mo', 'Front Desk', true, true, 320, 0, 0, 0, 0, 0, 'Mar 20', '-'),
    _Job('Pastry Chef', 'Zuma Dubai', 'ZD', 0.7, 'Dubai, UAE', 'Draft', 'Full-time', 'Not specified', 'Kitchen', false, false, 0, 0, 0, 0, 0, 0, 'Mar 22', '-'),
    _Job('Room Attendant', 'The Ritz London', 'RL', 0.3, 'London, UK', 'Flagged', 'Full-time', '\$2,200/mo', 'Housekeeping', true, false, 150, 20, 6, 2, 0, 2, 'Mar 5', 'Apr 5'),
  ];

  List<_Job> get _filtered {
    var list = _jobs.toList();
    if (_selectedFilter == 'No Applicants') list = list.where((j) => j.applicants == 0 && j.status == 'Active').toList();
    else if (_selectedFilter == 'Featured') list = list.where((j) => j.isFeatured).toList();
    else if (_selectedFilter != 'All') list = list.where((j) => j.status == _selectedFilter).toList();
    if (_searchText.isNotEmpty) list = list.where((j) => j.title.toLowerCase().contains(_searchText.toLowerCase()) || j.business.toLowerCase().contains(_searchText.toLowerCase())).toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [
      AdminTopBar(title: 'Jobs', onBack: () => Navigator.pop(context), trailing: GestureDetector(onTap: () => setState(() { _showSearch = !_showSearch; if (!_showSearch) _searchText = ''; }), child: Icon(_showSearch ? Icons.close : Icons.search, size: 22, color: AppColors.charcoal))),
      if (_showSearch) AdminSearchBar(hint: 'Search title, business, location...', text: _searchText, onChanged: (v) => setState(() => _searchText = v), onClear: () => setState(() => _searchText = '')),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.xs), child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl), child: Row(children: [
        AdminSummaryChip(label: 'All', count: '${_jobs.length}', color: AppColors.charcoal), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Active', count: '${_jobs.where((j) => j.status == 'Active').length}', color: AppColors.online), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Paused', count: '${_jobs.where((j) => j.status == 'Paused').length}', color: AppColors.amber), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'Flagged', count: '${_jobs.where((j) => j.status == 'Flagged').length}', color: AppColors.urgent), const SizedBox(width: AppSpacing.sm),
        AdminSummaryChip(label: 'No Apps', count: '${_jobs.where((j) => j.applicants == 0 && j.status == 'Active').length}', color: AppColors.urgent),
      ]))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminFilterChips(filters: _filters, selected: _selectedFilter, onSelected: (f) => setState(() => _selectedFilter = f))),
      Padding(padding: const EdgeInsets.only(top: AppSpacing.sm), child: AdminSortRow(count: _filtered.length, entityName: 'jobs', sortLabel: 'Newest', onSort: () {})),
      Expanded(child: _filtered.isEmpty
        ? AdminEmptyState(icon: Icons.work, title: 'No jobs match this filter', subtitle: 'Try adjusting your filters or search.', onShowAll: () => setState(() { _selectedFilter = 'All'; _searchText = ''; }))
        : SingleChildScrollView(padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xxxl), child: Container(
          decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(children: _filtered.asMap().entries.map((e) {
            final j = e.value;
            final statusColor = j.status == 'Active' ? AppColors.online : j.status == 'Paused' ? AppColors.amber : j.status == 'Flagged' ? AppColors.urgent : j.status == 'Draft' ? AppColors.secondary : AppColors.tertiary;
            return Column(children: [
              if (e.key > 0) Padding(padding: EdgeInsets.only(left: AppSpacing.xl + 44 + AppSpacing.md), child: const Divider(height: 1, color: AppColors.divider)),
              GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminJobDetailView())),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  AvatarCircle(initials: j.bizInitials, hue: j.hue),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Flexible(child: Text(j.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)), const SizedBox(width: AppSpacing.xs), StatusPill(text: j.status, color: statusColor), if (j.isFeatured) ...[const SizedBox(width: AppSpacing.xs), const StatusPill(text: 'Featured', color: AppColors.amber)]]),
                    const SizedBox(height: AppSpacing.xs),
                    Row(children: [Text(j.business, style: const TextStyle(fontSize: 13, color: AppColors.secondary)), if (j.isVerified) ...[const SizedBox(width: 3), const Icon(Icons.verified, size: 10, color: AppColors.teal)], const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.tertiary)), Expanded(child: Text(j.location, style: const TextStyle(fontSize: 13, color: AppColors.tertiary), maxLines: 1))]),
                    const SizedBox(height: AppSpacing.xs),
                    Row(children: [Text(j.employmentType, style: const TextStyle(fontSize: 10, color: AppColors.secondary)), const Text(' · ', style: TextStyle(fontSize: 10, color: AppColors.tertiary)), Text(j.salary, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)), const SizedBox(width: AppSpacing.sm), StatusPill(text: j.category, color: AppColors.teal)]),
                    const SizedBox(height: AppSpacing.xs),
                    Row(children: [_m(Icons.visibility, '${j.views}'), const SizedBox(width: AppSpacing.md), _m(Icons.people, '${j.applicants}'), const SizedBox(width: AppSpacing.md), _m(Icons.check_circle, '${j.shortlisted}'), const SizedBox(width: AppSpacing.md), _m(Icons.calendar_today, '${j.interviews}'), if (j.flagCount > 0) ...[const SizedBox(width: AppSpacing.md), Icon(Icons.flag, size: 10, color: AppColors.urgent), Text('${j.flagCount}', style: const TextStyle(fontSize: 10, color: AppColors.urgent))]]),
                    const SizedBox(height: AppSpacing.xs),
                    Row(children: [
                      if (j.applicants == 0 && j.status == 'Active') ...[Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.full), border: Border.all(color: AppColors.urgent.withValues(alpha: 0.3), width: 0.5)), child: const Text('No Applicants', style: TextStyle(fontSize: 10, color: AppColors.urgent))), const SizedBox(width: AppSpacing.sm)],
                      Text('Posted ${j.postedDate}', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                      if (j.expiryDate != '-') Text(' · Expires ${j.expiryDate}', style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                    ]),
                  ])),
                  const Icon(Icons.more_horiz, size: 18, color: AppColors.tertiary),
                ]))),
            ]);
          }).toList()),
        ))),
    ])));
  }

  Widget _m(IconData i, String t) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(i, size: 10, color: AppColors.tertiary), const SizedBox(width: 2), Text(t, style: const TextStyle(fontSize: 10, color: AppColors.secondary))]);
}

class _Job {
  final String title, business, bizInitials, location, status, employmentType, salary, category, postedDate, expiryDate;
  final double hue;
  final bool isVerified, isFeatured;
  final int views, saves, applicants, shortlisted, interviews, flagCount;
  _Job(this.title, this.business, this.bizInitials, this.hue, this.location, this.status, this.employmentType, this.salary, this.category, this.isVerified, this.isFeatured, this.views, this.saves, this.applicants, this.shortlisted, this.interviews, this.flagCount, this.postedDate, this.expiryDate);
}
