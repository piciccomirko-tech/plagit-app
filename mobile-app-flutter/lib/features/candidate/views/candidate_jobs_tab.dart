import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/candidate_service.dart';

class CandidateJobsTab extends StatefulWidget {
  const CandidateJobsTab({super.key});

  @override
  State<CandidateJobsTab> createState() => _CandidateJobsTabState();
}

class _CandidateJobsTabState extends State<CandidateJobsTab> {
  final _service = CandidateService();
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _jobs = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';
  String _sort = 'recent';

  static const _filters = ['All', 'Full-time', 'Part-time', 'International'];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getJobs(
        search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
        jobType: _filter == 'All' ? null : _filter,
        sort: _sort,
      );
      final jobs = (data['jobs'] ?? data['data'] ?? []) as List;
      if (mounted) setState(() { _jobs = jobs.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Find Work', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
              if (_jobs.isNotEmpty && !_loading)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text('${_jobs.length} positions available', style: const TextStyle(fontSize: 13, color: AppColors.tertiary)),
                ),
            ])),
            GestureDetector(
              onTap: () => _showSortSheet(),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: Icon(Icons.sort, size: 18, color: AppColors.teal.withValues(alpha: 0.7)),
              ),
            ),
          ]),
        ),

        // ── Search ──
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _loadJobs(),
              style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
              decoration: InputDecoration(
                hintText: 'Search jobs, roles, companies...',
                hintStyle: const TextStyle(fontSize: 15, color: AppColors.tertiary),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Icon(Icons.search, size: 20, color: AppColors.tertiary),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? GestureDetector(
                        onTap: () { _searchCtrl.clear(); _loadJobs(); },
                        child: const Padding(padding: EdgeInsets.only(right: 12), child: Icon(Icons.close, size: 18, color: AppColors.tertiary)),
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                fillColor: Colors.transparent,
                filled: true,
              ),
            ),
          ),
        ),

        // ── Filters ──
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final f = _filters[i];
              final active = f == _filter;
              return GestureDetector(
                onTap: () { setState(() => _filter = f); _loadJobs(); },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: active ? AppColors.teal : AppColors.border),
                    boxShadow: active
                        ? [BoxShadow(color: AppColors.teal.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2))]
                        : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Center(child: Text(f, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w500, color: active ? Colors.white : AppColors.secondary))),
                ),
              );
            },
          ),
        ),

        // ── Results ──
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5))
              : _error != null
                  ? _buildError()
                  : _jobs.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: AppColors.teal,
                          onRefresh: _loadJobs,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
                            itemCount: _jobs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 14),
                            itemBuilder: (_, i) => _JobCard(job: _jobs[i], onTap: () => context.push('/candidate/job/${_jobs[i]['id']}')),
                          ),
                        ),
        ),
      ]),
    );
  }

  void _showSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const SizedBox(height: 12),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Sort By', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(height: 16),
            _SortOption(label: 'Most Recent', value: 'recent', active: _sort == 'recent', onTap: () { _sort = 'recent'; Navigator.pop(context); _loadJobs(); }),
            _SortOption(label: 'Best Match', value: 'match', active: _sort == 'match', onTap: () { _sort = 'match'; Navigator.pop(context); _loadJobs(); }),
            _SortOption(label: 'A – Z', value: 'az', active: _sort == 'az', onTap: () { _sort = 'az'; Navigator.pop(context); _loadJobs(); }),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _buildError() => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error_outline, size: 28, color: AppColors.urgent),
      const SizedBox(height: 10),
      Text(_error!, style: const TextStyle(fontSize: 14, color: AppColors.urgent), textAlign: TextAlign.center),
      const SizedBox(height: 12),
      TextButton(onPressed: _loadJobs, child: const Text('Retry')),
    ]),
  ));

  Widget _buildEmpty() => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.lg)),
        child: Icon(Icons.work_outline, size: 26, color: AppColors.teal.withValues(alpha: 0.4)),
      ),
      const SizedBox(height: 16),
      const Text('No jobs found', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
      const SizedBox(height: 6),
      const Text('Try adjusting your search or filters\nto discover new opportunities.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.4)),
    ]),
  ));
}

class _SortOption extends StatelessWidget {
  final String label, value;
  final bool active;
  final VoidCallback onTap;
  const _SortOption({required this.label, required this.value, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      child: Row(children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: active ? FontWeight.w600 : FontWeight.w400, color: active ? AppColors.teal : AppColors.charcoal)),
        const Spacer(),
        if (active) const Icon(Icons.check, size: 18, color: AppColors.teal),
      ]),
    ),
  );
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;
  const _JobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final companyName = (job['business_name'] ?? job['company_name'] ?? '').toString();
    final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C';
    final location = job['location']?.toString();
    final contractType = (job['contract_type'] ?? job['employment_type'])?.toString();
    final salary = job['salary_range']?.toString();
    final isInternational = job['open_to_international'] == true;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Company avatar ──
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(child: Text(initial, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.teal))),
          ),
          const SizedBox(width: 14),

          // ── Content ──
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Title
            Text(
              job['title']?.toString() ?? 'Untitled',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal, height: 1.3),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Company
            Text(companyName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.secondary)),

            // ── Meta ──
            if (location != null || contractType != null) ...[
              const SizedBox(height: 10),
              // Thin separator
              Container(height: 1, color: AppColors.divider.withValues(alpha: 0.6)),
              const SizedBox(height: 10),
              // Location + type row
              Row(children: [
                if (location != null) ...[
                  Icon(Icons.location_on_outlined, size: 15, color: AppColors.teal.withValues(alpha: 0.6)),
                  const SizedBox(width: 5),
                  Flexible(child: Text(location, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal), overflow: TextOverflow.ellipsis)),
                ],
                if (location != null && contractType != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.tertiary.withValues(alpha: 0.4), shape: BoxShape.circle)),
                  ),
                if (contractType != null)
                  Text(contractType, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
              ]),
              // Salary + international
              if (salary != null || isInternational)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Row(children: [
                    if (salary != null) ...[
                      Icon(Icons.payments_outlined, size: 15, color: AppColors.teal.withValues(alpha: 0.6)),
                      const SizedBox(width: 5),
                      Text(salary, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                    ],
                    if (salary != null && isInternational)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(width: 3, height: 3, decoration: BoxDecoration(color: AppColors.tertiary.withValues(alpha: 0.4), shape: BoxShape.circle)),
                      ),
                    if (isInternational) ...[
                      Icon(Icons.language, size: 15, color: AppColors.teal.withValues(alpha: 0.6)),
                      const SizedBox(width: 5),
                      const Text('International', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
                    ],
                  ]),
                ),
            ],
          ])),

          // ── Urgent badge + chevron ──
          const SizedBox(width: 8),
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (job['is_urgent'] == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.urgent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Urgent', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.urgent)),
              )
            else
              const SizedBox.shrink(),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Icon(Icons.chevron_right, size: 20, color: AppColors.tertiary),
            ),
          ]),
        ]),
      ),
    );
  }
}
