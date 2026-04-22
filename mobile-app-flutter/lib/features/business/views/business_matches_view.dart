import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/applicant.dart';
import 'package:plagit/models/business_match_candidate.dart';
import 'package:plagit/repositories/business_repository.dart';

extension _BusinessMatchesL10n on AppLocalizations {
  String get yourMatchesTitle => matchesTitle;
  String get retryAction => retry;
  String get noMatchesYet => noMatchesTitle;
  String get businessMatchesViewAction {
    switch (localeName) {
      case 'it':
        return 'Vedi';
      case 'ar':
        return 'عرض';
      default:
        return 'View';
    }
  }

  String get businessMatchesHideAction {
    switch (localeName) {
      case 'it':
        return 'Nascondi';
      case 'ar':
        return 'إخفاء';
      default:
        return 'Hide';
    }
  }

  String get businessMatchesEmptySubtitle {
    switch (localeName) {
      case 'it':
        return 'I candidati attivi per questo lavoro appariranno qui.';
      case 'ar':
        return 'سيظهر هنا المرشحون النشطون لهذه الوظيفة.';
      default:
        return 'Active candidates for this job will appear here.';
    }
  }

  String businessMatchesSummary(int count, String jobTitle) {
    final label = switch (localeName) {
      'it' => count == 1 ? '1 candidato attivo' : '$count candidati attivi',
      'ar' => count == 1 ? 'مرشح نشط واحد' : '$count مرشحين نشطين',
      _ => count == 1 ? '1 active candidate' : '$count active candidates',
    };
    if (jobTitle.trim().isEmpty) return label;
    return '$label — $jobTitle';
  }
}

/// Business Matches screen — candidates matching a specific job.
/// Mirrors BusinessMatchesView.swift with mock data.
class BusinessMatchesView extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  const BusinessMatchesView(
      {super.key, required this.jobId, required this.jobTitle});

  @override
  State<BusinessMatchesView> createState() => _BusinessMatchesViewState();
}

class _BusinessMatchesViewState extends State<BusinessMatchesView> {
  bool _loading = true;
  String? _error;
  final Set<String> _dismissed = {};
  final BusinessRepository _repo = BusinessRepository();

  final List<BusinessMatchCandidate> _matches = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final matches = await _repo.fetchMatches(jobId: widget.jobId);
      if (!mounted) return;
      setState(() {
        _matches
          ..clear()
          ..addAll(matches);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<BusinessMatchCandidate> get _visible =>
      _matches.where((c) => !_dismissed.contains(c.applicantId)).toList();

  void _deny(String id) {
    setState(() => _dismissed.add(id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(
                width: 36,
                height: 36,
                child: BackChevron(size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          Text(AppLocalizations.of(context).yourMatchesTitle,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.teal));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded,
                size: 28, color: AppColors.tertiary),
            const SizedBox(height: AppSpacing.md),
            Text(_error!,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.secondary)),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: _load,
              child: Text(AppLocalizations.of(context).retryAction,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.teal)),
            ),
          ],
        ),
      );
    }
    if (_visible.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 36, color: AppColors.tertiary),
            const SizedBox(height: AppSpacing.lg),
            Text(AppLocalizations.of(context).noMatchesYet,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Text(
                  AppLocalizations.of(context).businessMatchesEmptySubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14, color: AppColors.secondary)),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
                AppLocalizations.of(context)
                    .businessMatchesSummary(_visible.length, widget.jobTitle),
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary)),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._visible.map((c) => _candidateCard(c)),
        ],
      ),
    );
  }

  Widget _candidateCard(BusinessMatchCandidate c) {
    final id = c.applicantId;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                _avatar(c.initials, _avatarHue(c), 48),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.charcoal)),
                      if (c.role.isNotEmpty)
                        Text(c.role,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.secondary)),
                    ],
                  ),
                ),
                _statusBadge(c.status),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Tags
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (c.role.isNotEmpty)
                  _tagPill(c.role, Icons.work, AppColors.indigo),
                if (c.location.isNotEmpty)
                  _tagPill(c.location, Icons.place, AppColors.secondary),
              ],
            ),

            if (c.experience.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(c.experience,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.secondary)),
            ],

            const SizedBox(height: AppSpacing.md),

            // Actions
            Row(
              children: [
                _actionChip(
                  AppLocalizations.of(context).businessMatchesViewAction,
                  Icons.person,
                  AppColors.teal,
                  true,
                  () => context.push('/business/candidate/${c.candidateId}'),
                ),
                const SizedBox(width: AppSpacing.md),
                _actionChip(
                  AppLocalizations.of(context).businessMatchesHideAction,
                  Icons.visibility_off,
                  AppColors.urgent,
                  false,
                  () => _deny(id),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => context.push('/business/messages'),
                  child: const Icon(Icons.chat_bubble_outline,
                      size: 14, color: AppColors.indigo),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagPill(String text, IconData icon, Color color) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(text,
              style: TextStyle(fontSize: 11, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _statusBadge(ApplicantStatus status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        status.localizedLabel(AppLocalizations.of(context)),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _actionChip(
      String label, IconData icon, Color color, bool filled, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 12, color: filled ? Colors.white : color),
            const SizedBox(width: AppSpacing.xs),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: filled ? Colors.white : color)),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String initials, double hue, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            HSLColor.fromAHSL(1, hue * 360, 0.45, 0.90).toColor(),
            HSLColor.fromAHSL(1, hue * 360, 0.55, 0.75).toColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: TextStyle(
              fontSize: size * 0.30,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
    );
  }

  double _avatarHue(BusinessMatchCandidate candidate) {
    final seed =
        candidate.candidateId.isNotEmpty ? candidate.candidateId : candidate.name;
    final hash = seed.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return (hash % 360) / 360;
  }

  Color _statusColor(ApplicantStatus status) {
    return switch (status) {
      ApplicantStatus.shortlisted => AppColors.teal,
      ApplicantStatus.underReview => AppColors.indigo,
      ApplicantStatus.interviewInvited ||
      ApplicantStatus.interviewScheduled => AppColors.amber,
      ApplicantStatus.hired => AppColors.online,
      _ => AppColors.secondary,
    };
  }
}
