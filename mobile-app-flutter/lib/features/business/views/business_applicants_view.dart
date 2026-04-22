import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/applicant.dart';
import 'package:plagit/providers/business_providers.dart';

/// Business Applicants tab — list of all applicants across jobs.
class BusinessApplicantsView extends StatefulWidget {
  const BusinessApplicantsView({super.key});

  @override
  State<BusinessApplicantsView> createState() => _BusinessApplicantsViewState();
}

class _BusinessApplicantsViewState extends State<BusinessApplicantsView> {
  String _selectedSort = 'Newest';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _shortlistingIds = <String>{};

  static const _filters = [
    'All',
    'Applied',
    'Shortlisted',
    'Under Review',
    'Interview',
    'Rejected',
  ];
  static const _sorts = ['Newest', 'Most Experienced', 'Best Match'];

  String _localText(
    BuildContext context, {
    required String en,
    required String it,
    required String ar,
  }) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'it') return it;
    if (code == 'ar') return ar;
    return en;
  }

  String _filterLabel(BuildContext context, String filter) {
    final l = AppLocalizations.of(context);
    return switch (filter) {
      'All' => l.filterAll,
      'Applied' => l.statusApplied,
      'Shortlisted' => _localText(
        context,
        en: 'Shortlisted',
        it: 'In shortlist',
        ar: 'في القائمة المختصرة',
      ),
      'Under Review' => _localText(
        context,
        en: 'Under Review',
        it: 'In revisione',
        ar: 'قيد المراجعة',
      ),
      'Interview' => _localText(
        context,
        en: 'Interview',
        it: 'Colloquio',
        ar: 'مقابلة',
      ),
      'Rejected' => l.statusRejected,
      _ => filter,
    };
  }

  String _sortLabel(BuildContext context, String sort) {
    return switch (sort) {
      'Newest' => _localText(
        context,
        en: 'Newest',
        it: 'Più recenti',
        ar: 'الأحدث',
      ),
      'Most Experienced' => _localText(
        context,
        en: 'Most Experienced',
        it: 'Più esperienza',
        ar: 'الأكثر خبرة',
      ),
      'Best Match' => _localText(
        context,
        en: 'Best Match',
        it: 'Miglior match',
        ar: 'أفضل تطابق',
      ),
      _ => sort,
    };
  }

  String _applicantsCountLabel(BuildContext context, int count) {
    if (Localizations.localeOf(context).languageCode == 'it') {
      return '$count candidati';
    }
    if (Localizations.localeOf(context).languageCode == 'ar') {
      return '$count متقدمين';
    }
    return '$count applicants';
  }

  String _searchApplicantsHint(BuildContext context) => _localText(
        context,
        en: 'Search applicants...',
        it: 'Cerca candidati...',
        ar: 'ابحث عن المتقدمين...',
      );

  String _noApplicantsFound(BuildContext context) => _localText(
        context,
        en: 'No applicants found',
        it: 'Nessun candidato trovato',
        ar: 'لم يتم العثور على متقدمين',
      );

  String _applicantsTitle(BuildContext context) => _localText(
        context,
        en: 'Applicants',
        it: 'Candidati',
        ar: 'المتقدمون',
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessApplicantsProvider>().load();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Applies local search on top of provider-filtered applicants.
  List<Applicant> _applySearch(List<Applicant> list) {
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where((a) =>
            a.name.toLowerCase().contains(q) ||
            a.role.toLowerCase().contains(q) ||
            (a.jobTitle?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  List<Applicant> _applySort(List<Applicant> list) {
    final sorted = List<Applicant>.from(list);
    switch (_selectedSort) {
      case 'Most Experienced':
        sorted.sort(
          (a, b) => _experienceScore(b.experience).compareTo(
            _experienceScore(a.experience),
          ),
        );
        break;
      case 'Best Match':
        sorted.sort((a, b) {
          final match = _matchScore(b).compareTo(_matchScore(a));
          if (match != 0) return match;
          return _experienceScore(b.experience).compareTo(
            _experienceScore(a.experience),
          );
        });
        break;
      case 'Newest':
      default:
        sorted.sort((a, b) => _recencyScore(a.date).compareTo(_recencyScore(b.date)));
        break;
    }
    return sorted;
  }

  int _experienceScore(String raw) {
    final match = RegExp(r'(\d+)').firstMatch(raw);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  int _recencyScore(String raw) {
    final value = raw.trim().toLowerCase();
    final match = RegExp(r'(\d+)').firstMatch(value);
    final amount = int.tryParse(match?.group(1) ?? '') ?? 0;
    if (value.contains('hr')) return amount;
    if (value.contains('hour')) return amount;
    if (value.contains('day')) return amount * 24;
    if (value.contains('week')) return amount * 24 * 7;
    if (value.contains('month')) return amount * 24 * 30;
    return 1 << 30;
  }

  int _matchScore(Applicant applicant) {
    final statusScore = switch (applicant.status) {
      ApplicantStatus.interviewScheduled => 5,
      ApplicantStatus.interviewInvited => 4,
      ApplicantStatus.shortlisted => 3,
      ApplicantStatus.underReview => 2,
      ApplicantStatus.applied => 1,
      ApplicantStatus.hired => 0,
      ApplicantStatus.rejected => -1,
      ApplicantStatus.withdrawn => -2,
    };
    return statusScore * 100 +
        (applicant.verified ? 10 : 0) +
        _experienceScore(applicant.experience);
  }

  Future<void> _shortlistApplicant(Applicant applicant) async {
    if (_shortlistingIds.contains(applicant.id)) return;
    setState(() => _shortlistingIds.add(applicant.id));
    try {
      await context.read<BusinessApplicantsProvider>().shortlist(applicant.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).xShortlisted(applicant.name)),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), duration: const Duration(seconds: 1)),
      );
    } finally {
      if (mounted) {
        setState(() => _shortlistingIds.remove(applicant.id));
      }
    }
  }

  Future<void> _openApplicantMessages(Applicant applicant) async {
    final provider = context.read<BusinessMessagesProvider>();
    if (provider.conversations.isEmpty && !provider.loading) {
      try {
        await provider.load();
      } catch (_) {
        // Fall back to the messages area below.
      }
    }
    if (!mounted) return;
    final conversation = provider.conversations
        .where(
          (c) =>
              (applicant.candidateId?.isNotEmpty == true &&
                  c.candidateId == applicant.candidateId) ||
              c.candidateName.toLowerCase() == applicant.name.toLowerCase(),
        )
        .firstOrNull;
    if (conversation != null) {
      context.push('/business/chat/${conversation.id}');
      return;
    }
    context.push('/business/messages');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessApplicantsProvider>();

    // ── Loading state ──
    if (provider.loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: const Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    // ── Error state ──
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.red),
              const SizedBox(height: 12),
              Text(
                provider.error!,
                style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<BusinessApplicantsProvider>().load(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppLocalizations.of(context).retry),
              ),
            ],
          ),
        ),
      );
    }

    // ── Content state ──
    final selectedFilter = provider.filter;
    final filtered = _applySort(_applySearch(provider.applicants));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: _searchApplicantsHint(context),
                hintStyle: const TextStyle(color: AppColors.tertiary, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.tertiary, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.teal),
                ),
              ),
            ),
          ),

          // ── Filter tabs ──
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = f == selectedFilter;
                return GestureDetector(
                  onTap: () => context.read<BusinessApplicantsProvider>().setFilter(f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.teal : Colors.white,
                      borderRadius: BorderRadius.circular(100),
                      border: active ? null : Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        _filterLabel(context, f),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ── Sort row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _sorts.map((s) {
                final active = s == _selectedSort;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedSort = s),
                    child: Text(
                      _sortLabel(context, s),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? AppColors.teal : AppColors.secondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // ── Count ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _applicantsCountLabel(context, filtered.length),
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
          ),
          const SizedBox(height: 8),

          // ── Applicant list ──
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_off_outlined,
                            size: 56, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        Text(
                          _noApplicantsFound(context),
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) =>
                        _ApplicantCard(
                          applicant: filtered[i],
                          shortlisting:
                              _shortlistingIds.contains(filtered[i].id),
                          onShortlist: () => _shortlistApplicant(filtered[i]),
                          onMessage: () => _openApplicantMessages(filtered[i]),
                        ),
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: Text(_applicantsTitle(context)),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Applicant applicant;
  final bool shortlisting;
  final Future<void> Function() onShortlist;
  final Future<void> Function() onMessage;
  const _ApplicantCard({
    required this.applicant,
    required this.shortlisting,
    required this.onShortlist,
    required this.onMessage,
  });

  Color _avatarColor(String initials) {
    final hue = (initials.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.5, 0.45).toColor();
  }

  String _localText(
    BuildContext context, {
    required String en,
    required String it,
    required String ar,
  }) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'it') return it;
    if (code == 'ar') return ar;
    return en;
  }

  String _applyingForLabel(BuildContext context) => _localText(
        context,
        en: 'Applying for: ${applicant.jobTitle ?? applicant.role}',
        it: 'Candidatura per: ${applicant.jobTitle ?? applicant.role}',
        ar: 'يتقدم إلى: ${applicant.jobTitle ?? applicant.role}',
      );

  String _appliedDateLabel(BuildContext context) => _localText(
        context,
        en: 'Applied ${applicant.date}',
        it: 'Candidatura ${applicant.date}',
        ar: 'تم التقديم ${applicant.date}',
      );

  String _shortlistLabel(BuildContext context) =>
      _localText(context, en: 'Shortlist', it: 'Shortlist', ar: 'القائمة المختصرة');

  String _rejectLabel(BuildContext context) =>
      _localText(context, en: 'Reject', it: 'Rifiuta', ar: 'رفض');

  String _messageLabel(BuildContext context) =>
      _localText(context, en: 'Message', it: 'Messaggio', ar: 'رسالة');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/business/applicant/${applicant.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ── Avatar ──
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _avatarColor(applicant.initials),
                  child: Text(
                    applicant.initials,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // ── Info column ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              applicant.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.charcoal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (applicant.verified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified, size: 14, color: AppColors.teal),
                          ],
                        ],
                      ),
                      Text(
                        _applyingForLabel(context),
                        style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                      ),
                      Text(
                        '${applicant.experience} \u00B7 ${applicant.location}',
                        style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: applicant.status.displayName),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _appliedDateLabel(context),
                style: const TextStyle(fontSize: 11, color: AppColors.secondary),
              ),
            ),
            const SizedBox(height: 8),
            // ── Quick actions ──
            Row(
              children: [
                _ActionButton(
                  label: shortlisting
                      ? '...'
                      : '\u2713 ${_shortlistLabel(context)}',
                  color: AppColors.teal,
                  onTap: shortlisting ? null : onShortlist,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: '\u2717 ${_rejectLabel(context)}',
                  color: AppColors.red,
                  onTap: () {
                    context.read<BusinessApplicantsProvider>().reject(applicant.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${applicant.name} rejected'), duration: const Duration(seconds: 1)),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  label: '\uD83D\uDCAC ${_messageLabel(context)}',
                  color: AppColors.secondary,
                  onTap: onMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ActionButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
