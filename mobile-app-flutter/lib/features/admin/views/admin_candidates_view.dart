import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/features/admin/views/admin_candidate_detail_view.dart';

class AdminCandidatesView extends StatefulWidget {
  const AdminCandidatesView({super.key});
  @override State<AdminCandidatesView> createState() => _AdminCandidatesViewState();
}

class _AdminCandidatesViewState extends State<AdminCandidatesView> {
  bool _showSearch = false;
  String _searchText = '';
  String _selectedFilter = 'All';
  final _filters = ['All', 'Verified', 'Pending Review', 'Suspended', 'New'];

  final _candidates = [
    _Candidate('Elena Rossi', 'ER', 0.52, 'Executive Chef', 'London, UK', 'Full-time', '8 years', 'Italian, English', 'Verified', 'Active since Jan 2025', 245),
    _Candidate('Marco Bianchi', 'MB', 0.35, 'Sommelier', 'Milan, Italy', 'Full-time', '5 years', 'Italian, English, French', 'Verified', 'Active since Feb 2025', 132),
    _Candidate('Sofia Andersen', 'SA', 0.72, 'Front Desk Manager', 'Dubai, UAE', 'Full-time', '3 years', 'English, Arabic', 'Pending Review', 'Joined Mar 2026', 0),
    _Candidate('Ahmed Al-Rashid', 'AA', 0.15, 'Barista', 'Dubai, UAE', 'Part-time', '2 years', 'Arabic, English', 'New', 'Joined today', 0),
    _Candidate('Liam O\'Brien', 'LO', 0.88, 'Concierge', 'London, UK', 'Full-time', '6 years', 'English, German', 'Suspended', 'Suspended Mar 2026', 89),
  ];

  List<_Candidate> get _filtered {
    var list = _candidates.toList();
    if (_selectedFilter != 'All') list = list.where((c) => c.status == _selectedFilter).toList();
    if (_searchText.isNotEmpty) list = list.where((c) => c.name.toLowerCase().contains(_searchText.toLowerCase()) || c.role.toLowerCase().contains(_searchText.toLowerCase())).toList();
    return list;
  }

  int _countFor(String f) => f == 'All' ? _candidates.length : _candidates.where((c) => c.status == f).count;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AdminTopBar(title: 'Candidates', onBack: () => Navigator.pop(context), trailing: GestureDetector(
              onTap: () => setState(() { _showSearch = !_showSearch; if (!_showSearch) _searchText = ''; }),
              child: Icon(_showSearch ? Icons.close : Icons.search, size: 22, color: _showSearch ? AppColors.teal : AppColors.charcoal),
            )),
            if (_showSearch) AdminSearchBar(hint: 'Search by name, role, or location...', text: _searchText, onChanged: (v) => setState(() => _searchText = v), onClear: () => setState(() => _searchText = '')),
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: AdminFilterChips(filters: _filters, selected: _selectedFilter, onSelected: (f) => setState(() => _selectedFilter = f), counts: {for (var f in _filters) f: _countFor(f)}),
            ),
            Expanded(
              child: _filtered.isEmpty
                ? AdminEmptyState(icon: Icons.people, title: _searchText.isNotEmpty ? 'No results for "$_searchText"' : 'No candidates found', subtitle: 'Try adjusting your filters or search.', onShowAll: () => setState(() { _selectedFilter = 'All'; _searchText = ''; }))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sectionGap, AppSpacing.xl, AppSpacing.xxxl),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (_, i) => _candidateCard(_filtered[i]),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _candidateCard(_Candidate c) {
    final statusColor = c.status == 'Verified' ? AppColors.online : c.status == 'Pending Review' ? AppColors.amber : c.status == 'Suspended' ? AppColors.urgent : AppColors.teal;
    return Container(
      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AvatarCircle(initials: c.initials, hue: c.hue, verified: c.status == 'Verified'),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(c.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal))),
                  const SizedBox(width: AppSpacing.sm),
                  StatusPill(text: c.status, color: statusColor),
                ]),
                const SizedBox(height: AppSpacing.xs),
                Row(children: [
                  Expanded(child: Text('${c.role} · ${c.location}', style: const TextStyle(fontSize: 13, color: AppColors.secondary))),
                  if (c.jobType.isNotEmpty) StatusPill(text: c.jobType, color: AppColors.teal),
                ]),
                const SizedBox(height: AppSpacing.xs),
                Row(children: [
                  Text(c.experience, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                  const Text(' · ', style: TextStyle(color: AppColors.tertiary)),
                  Expanded(child: Text(c.languages, style: const TextStyle(fontSize: 13, color: AppColors.secondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ])),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.sm, AppSpacing.xl, 0),
            child: Row(children: [
              Text(c.activeSince, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
              if (c.profileViews > 0) ...[const SizedBox(width: AppSpacing.md), Icon(Icons.visibility, size: 10, color: AppColors.tertiary), const SizedBox(width: 3), Text('${c.profileViews} views', style: const TextStyle(fontSize: 10, color: AppColors.tertiary))],
            ]),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0), child: Divider(height: 1, color: AppColors.divider)),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
            child: Row(children: [
              Expanded(child: _actionBtn('View Profile', AppColors.teal, Colors.white, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCandidateDetailView())))),
              const SizedBox(width: AppSpacing.md),
              if (c.status == 'Verified') Expanded(child: _actionBtn('Suspend', AppColors.urgent, AppColors.urgent, () {}, filled: false))
              else if (c.status == 'Suspended') Expanded(child: _actionBtn('Activate', AppColors.online, AppColors.online, () {}, filled: false))
              else Expanded(child: _actionBtn('Verify', AppColors.teal, AppColors.teal, () {}, filled: false)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _actionBtn('Review', AppColors.teal, AppColors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminCandidateDetailView())), filled: false)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String text, Color bg, Color fg, VoidCallback onTap, {bool filled = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? bg : bg.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: filled ? fg : bg)),
      ),
    );
  }
}

extension _IterableExt<T> on Iterable<T> {
  int get count => length;
}

class _Candidate {
  final String name, initials, role, location, jobType, experience, languages, status, activeSince;
  final double hue;
  final int profileViews;
  _Candidate(this.name, this.initials, this.hue, this.role, this.location, this.jobType, this.experience, this.languages, this.status, this.activeSince, this.profileViews);
}
