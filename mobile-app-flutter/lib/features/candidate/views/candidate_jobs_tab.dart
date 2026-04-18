import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/widgets/app_back_title_bar.dart';
import 'package:plagit/core/widgets/header_action_icon.dart';
import 'package:plagit/core/widgets/search_screen.dart';
import 'package:plagit/models/employment.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/providers/recent_searches_provider.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

// ═══════════════════════════════════════════════════════════════
// Theme (exact from Swift Theme.swift)
// ═══════════════════════════════════════════════════════════════
const _tealMain = Color(0xFF00B5B0);
const _tealLight = Color(0x1A00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _divider = Color(0xFFEBEDF0);
const _border = Color(0xFFE6E8ED);
const _urgent = Color(0xFFF55748);
const _amber = Color(0xFFF59E33);

class CandidateJobsTab extends StatefulWidget {
  const CandidateJobsTab({super.key});

  @override
  State<CandidateJobsTab> createState() => _CandidateJobsTabState();
}

class _CandidateJobsTabState extends State<CandidateJobsTab> {
  int _selectedChip = 0;
  int _sortIndex = 0;

  static const _chipLabels = [
    'All',
    'Full-time',
    'Part-time',
    'Temporary',
    'Casual',
  ];
  static const _sortOptions = ['Best Match', 'Most Recent', 'A-Z'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateJobsProvider>().load();
    });
  }

  /// Pushes the dedicated full-screen search route for jobs. The results
  /// builder reads the same `CandidateJobsProvider` so newly loaded jobs
  /// appear in the results immediately.
  void _openSearchScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SearchScreen(
          scope: RecentSearchScope.candidateJobs,
          title: 'Search Jobs',
          hintText: 'Search jobs, roles, locations…',
          resultsBuilder: (ctx, query) {
            final jobs = ctx.watch<CandidateJobsProvider>().jobs;
            final q = query.toLowerCase();
            final results = jobs
                .where(
                  (j) =>
                      j.title.toLowerCase().contains(q) ||
                      j.company.toLowerCase().contains(q) ||
                      j.location.toLowerCase().contains(q) ||
                      j.contract.toLowerCase().contains(q),
                )
                .toList();
            if (results.isEmpty) return SearchNoResults(query: query);
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _SearchJobResultRow(
                job: results[i],
                onTap: () => ctx.push('/candidate/job/${results[i].id}'),
              ),
            );
          },
        ),
      ),
    );
  }

  Map<String, int> _chipCounts(List<Job> jobs) {
    int ft = 0, pt = 0, tmp = 0, cas = 0;
    for (final j in jobs) {
      switch (j.employmentType) {
        case EmploymentType.fullTime:
          ft++;
        case EmploymentType.partTime:
          pt++;
        case EmploymentType.fixedTerm:
          tmp++;
        case EmploymentType.hourly:
          cas++;
      }
    }
    return {'Full-time': ft, 'Part-time': pt, 'Temporary': tmp, 'Casual': cas};
  }

  List<Job> _filtered(List<Job> jobs) {
    var result = jobs;
    // chip filter — drives off the typed EmploymentType, not legacy strings
    if (_selectedChip == 1) {
      result = result
          .where((j) => j.employmentType == EmploymentType.fullTime)
          .toList();
    } else if (_selectedChip == 2) {
      result = result
          .where((j) => j.employmentType == EmploymentType.partTime)
          .toList();
    } else if (_selectedChip == 3) {
      result = result
          .where((j) => j.employmentType == EmploymentType.fixedTerm)
          .toList();
    } else if (_selectedChip == 4) {
      result = result
          .where((j) => j.employmentType == EmploymentType.hourly)
          .toList();
    }
    // Text search now lives on a dedicated full-screen route (pushed from
    // the search icon in the top bar), so the main list no longer filters
    // by _searchText here.
    // sort
    if (_sortIndex == 1) {
      result = List.of(result)
        ..sort((a, b) => (b.postedDate ?? '').compareTo(a.postedDate ?? ''));
    } else if (_sortIndex == 2) {
      result = List.of(result)..sort((a, b) => a.title.compareTo(b.title));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateJobsProvider>();
    final allJobs = provider.jobs;
    final counts = _chipCounts(allJobs);
    final jobs = _filtered(allJobs);

    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // ══════════════════════════════════════
            // 2. TOP BAR
            // ══════════════════════════════════════
            AppBackTitleBar(
              title: 'Jobs',
              onBack: () => context.canPop() ? context.pop() : null,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              backBackgroundColor: _surface,
              titleStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.2,
              ),
              trailingMinWidth: 62,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HeaderActionIcon(
                    onTap: () => _openSearchScreen(context),
                    icon: const Icon(
                      CupertinoIcons.search,
                      size: 20,
                      color: Color(0xFF3C3C43),
                    ),
                  ),
                  const SizedBox(width: 18),
                  HeaderActionIcon(
                    onTap: () => _showFilterSheet(context),
                    icon: SizedBox(
                      width: 24,
                      height: 24,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            CupertinoIcons.slider_horizontal_3,
                            size: 20,
                            color: Color(0xFF3C3C43),
                          ),
                          if (_selectedChip > 0)
                            Positioned(
                              top: -3,
                              right: -3,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _tealMain,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // (Search now lives on a dedicated full-screen route pushed
            //  from the search icon in the top bar above.)

            // ══════════════════════════════════════
            // 4. QUICK FILTER CHIPS
            // ══════════════════════════════════════
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
                itemCount: _chipLabels.length,
                separatorBuilder: (_, i) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final active = _selectedChip == i;
                  final label = _chipLabels[i];
                  final count = counts[label];
                  final hasCount = i > 0 && count != null && count > 0;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedChip = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: active ? _tealMain : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: active
                            ? null
                            : Border.all(
                                color: const Color(0xFFE5E5EA),
                                width: 0.5,
                              ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF3C3C43),
                            ),
                          ),
                          if (hasCount) ...[
                            const SizedBox(width: 5),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: active
                                    ? Colors.white.withValues(alpha: 0.75)
                                    : const Color(0xFFAEAEB2),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ══════════════════════════════════════
            // 5/6. LOADING / ERROR
            // ══════════════════════════════════════
            if (provider.loading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: _tealMain),
                ),
              )
            else if (provider.error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 40, color: _tertiary),
                      const SizedBox(height: 16),
                      Text(
                        provider.error!,
                        style: const TextStyle(fontSize: 14, color: _secondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () =>
                            context.read<CandidateJobsProvider>().load(),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _tealMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // ══════════════════════════════════════
              // 7. SORT BAR
              // ══════════════════════════════════════
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Text(
                      '${jobs.length} jobs found',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showSortSheet(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _sortOptions[_sortIndex],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _tealMain,
                            ),
                          ),
                          const SizedBox(width: 3),
                          const Icon(
                            CupertinoIcons.chevron_down,
                            size: 11,
                            color: _tealMain,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ══════════════════════════════════════
              // 8. JOB CARDS LIST / 9. EMPTY STATE
              // ══════════════════════════════════════
              if (jobs.isEmpty)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              color: _tealLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.search,
                              size: 20,
                              color: _tealMain,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No jobs match your search',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _charcoal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try adjusting your filters',
                            style: TextStyle(fontSize: 13, color: _secondary),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _selectedChip = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(color: _tealMain),
                                  ),
                                  child: const Text(
                                    'Clear Filters',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: _tealMain,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => setState(() => _selectedChip = 0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _tealMain,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Text(
                                    'All Jobs',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 48),
                    itemCount: jobs.length,
                    separatorBuilder: (_, i) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _JobCard(
                      job: jobs[i],
                      onTap: () => context.push('/candidate/job/${jobs[i].id}'),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════
  // 10. FILTER BOTTOM SHEET
  // ══════════════════════════════════════
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgMain,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollCtrl) => Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _tertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedChip = 0);
                      Navigator.pop(ctx);
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _secondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _charcoal,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Text(
                      'Apply',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _tealMain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _divider),
            // Filter sections
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(20),
                children: [
                  _FilterSection(
                    title: 'Distance Radius',
                    isPremium: true,
                    child: Column(
                      children: [
                        Slider(
                          value: 25,
                          min: 5,
                          max: 50,
                          activeColor: _tealMain,
                          inactiveColor: _surface,
                          onChanged: (_) {},
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '5 km',
                              style: TextStyle(fontSize: 11, color: _secondary),
                            ),
                            Text(
                              '50 km',
                              style: TextStyle(fontSize: 11, color: _secondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FilterSection(
                    title: 'Contract Type',
                    isPremium: true,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'All',
                        'Full-time',
                        'Part-time',
                        'Temporary',
                        'Seasonal',
                      ].map((t) => _filterChip(t, t == 'All')).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FilterSection(
                    title: 'Shift Type',
                    isPremium: true,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'All',
                        'Morning',
                        'Afternoon',
                        'Evening',
                        'Night',
                        'Split',
                      ].map((t) => _filterChip(t, t == 'All')).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FilterSection(
                    title: 'Urgent Jobs Only',
                    isPremium: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Show only urgent listings',
                          style: TextStyle(fontSize: 13, color: _secondary),
                        ),
                        Switch(
                          value: false,
                          activeTrackColor: _tealMain,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FilterSection(
                    title: 'Verified Businesses Only',
                    isPremium: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Show only verified businesses',
                          style: TextStyle(fontSize: 13, color: _secondary),
                        ),
                        Switch(
                          value: false,
                          activeTrackColor: _tealMain,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? _tealMain : _surface,
        borderRadius: BorderRadius.circular(100),
        border: active ? null : Border.all(color: _border, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: active ? Colors.white : _secondary,
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort by',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _charcoal,
                ),
              ),
              const SizedBox(height: 16),
              ...List.generate(_sortOptions.length, (i) {
                final selected = _sortIndex == i;
                return GestureDetector(
                  onTap: () {
                    setState(() => _sortIndex = i);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Text(
                          _sortOptions[i],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: selected ? _tealMain : _charcoal,
                          ),
                        ),
                        const Spacer(),
                        if (selected)
                          const Icon(Icons.check, size: 18, color: _tealMain),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// JOB CARD
// ═══════════════════════════════════════════════════════════════

class _JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  const _JobCard({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hue = (job.company.hashCode % 360).abs().toDouble();
    final words = job.company.split(' ');
    final initials = words.length >= 2
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : (job.company.length >= 2
              ? job.company.substring(0, 2).toUpperCase()
              : job.company.toUpperCase());

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ══════════════════════════════════════
              // LEFT: LARGE MEDIA BLOCK (real photo if available)
              // ══════════════════════════════════════
              _buildMediaBlock(job, hue, initials),
              const SizedBox(width: 14),

              // ══════════════════════════════════════
              // RIGHT: INFO STACK + BOOKMARK + ARROW
              // ══════════════════════════════════════
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title row + bookmark (top right) ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            job.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                              letterSpacing: -0.3,
                              height: 1.15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: GestureDetector(
                            onTap: () {},
                            child: const Icon(
                              CupertinoIcons.bookmark,
                              size: 18,
                              color: Color(0xFFB0B0B5),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    // ── Business · location (one compact line) ──
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            job.company,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8E8E93),
                              letterSpacing: -0.1,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Text(
                          '  ·  ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFC7C7CC),
                          ),
                        ),
                        const Icon(
                          CupertinoIcons.location_solid,
                          size: 10,
                          color: Color(0xFFAEAEB2),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            job.location,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF8E8E93),
                              letterSpacing: -0.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // ── Compensation pill (full row — never truncates) ──
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _tealMain.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        job.compensationDisplay,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _tealMain,
                          letterSpacing: -0.1,
                          height: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ── Status badges row (with arrow CTA on the right) ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: [
                              _pill(
                                job.employmentLabel,
                                const Color(0xFFF2F2F7),
                                const Color(0xFF3C3C43),
                              ),
                              if (job.featured)
                                _pill(
                                  'Featured',
                                  _amber.withValues(alpha: 0.12),
                                  _amber,
                                ),
                              if (job.urgent)
                                _pill(
                                  'Urgent',
                                  _urgent.withValues(alpha: 0.12),
                                  _urgent,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Arrow CTA bottom-right (smaller, more elegant)
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: _tealMain.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            CupertinoIcons.arrow_right,
                            size: 12,
                            color: _tealMain,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the large 110×110 left media block.
  /// Shows the first venue image if available (asset or network),
  /// otherwise falls back to the gradient + initials placeholder.
  static Widget _buildMediaBlock(Job job, double hue, String initials) {
    final hasPhoto = job.venueImages.isNotEmpty;
    final firstImage = hasPhoto ? job.venueImages.first : null;

    Widget content;
    if (hasPhoto && firstImage!.startsWith('assets/')) {
      // Real local asset photo (e.g. The Ritz)
      content = Image.asset(
        firstImage,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initialsPlaceholder(hue, initials),
      );
    } else if (hasPhoto &&
        (firstImage!.startsWith('http://') ||
            firstImage.startsWith('https://'))) {
      // Network photo
      content = Image.network(
        firstImage,
        width: 110,
        height: 110,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 110,
            height: 110,
            color: const Color(0xFFF2F2F7),
            child: const Center(child: CupertinoActivityIndicator()),
          );
        },
        errorBuilder: (_, _, _) => _initialsPlaceholder(hue, initials),
      );
    } else {
      content = _initialsPlaceholder(hue, initials);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            content,
            // Subtle bottom gradient for badge legibility
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.30),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Verified badge — integrated bottom-right
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    size: 18,
                    color: _tealMain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _initialsPlaceholder(double hue, String initials) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HSVColor.fromAHSV(1, hue, 0.45, 0.92).toColor(),
            HSVColor.fromAHSV(1, hue, 0.55, 0.68).toColor(),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.6,
          ),
        ),
      ),
    );
  }

  static Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FILTER SECTION (with premium lock overlay)
// ═══════════════════════════════════════════════════════════════

class _FilterSection extends StatelessWidget {
  final String title;
  final bool isPremium;
  final Widget child;
  const _FilterSection({
    required this.title,
    this.isPremium = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _charcoal,
                    ),
                  ),
                  if (isPremium) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.lock, size: 12, color: _amber),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
          if (isPremium)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: _cardBg.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _amber,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SEARCH RESULT ROW — compact job row used inside the SearchScreen
// ═══════════════════════════════════════════════════════════════

class _SearchJobResultRow extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  const _SearchJobResultRow({required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hue = (job.company.hashCode % 360).abs().toDouble();
    final words = job.company.split(' ');
    final initials = words.length >= 2
        ? '${words[0][0]}${words[1][0]}'.toUpperCase()
        : (job.company.length >= 2
              ? job.company.substring(0, 2).toUpperCase()
              : job.company.toUpperCase());

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEFEFF4), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor(),
                    HSLColor.fromAHSL(
                      1,
                      (hue + 30) % 360,
                      0.50,
                      0.50,
                    ).toColor(),
                  ],
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _charcoal,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${job.company} · ${job.location}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.compensationDisplay,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _tealMain,
                      letterSpacing: -0.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const ForwardChevron(size: 13, color: Color(0xFFC7C7CC),
            ),
          ],
        ),
      ),
    );
  }
}
