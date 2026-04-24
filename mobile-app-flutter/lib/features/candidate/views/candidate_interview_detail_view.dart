import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/city_helpers.dart';
import 'package:plagit/core/l10n_helpers.dart';
import 'package:plagit/core/network/api_error.dart';
import 'package:plagit/core/widgets/app_back_title_bar.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/interview.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/repositories/candidate_repository.dart';

// ═══════════════════════════════════════════════════════════════
// Theme tokens — match Phase 1 premium screens
// ═══════════════════════════════════════════════════════════════
const _tealMain = Color(0xFF00B5B0);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _divider = Color(0xFFEFEFF4);
const _amber = Color(0xFFF59E33);
const _red = Color(0xFFFF3B30);

// Whisper-quiet card shadow — micro-pass dropped this to 0.03/10/y2 so the
// cards barely separate from the background. They feel embedded, not lifted.
BoxShadow get _cardShadow => BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 2),
    );

class CandidateInterviewDetailView extends StatefulWidget {
  final String interviewId;
  final CandidateRepository? repo;
  const CandidateInterviewDetailView({
    super.key,
    required this.interviewId,
    this.repo,
  });

  @override
  State<CandidateInterviewDetailView> createState() =>
      _CandidateInterviewDetailViewState();
}

class _CandidateInterviewDetailViewState
    extends State<CandidateInterviewDetailView> {
  Interview? _interview;
  InterviewStatus? _currentStatus;
  bool _loading = true;
  String? _error;
  bool _notFound = false;

  CandidateRepository get _repo => widget.repo ?? CandidateRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInterview());
  }

  Future<void> _loadInterview() async {
    setState(() {
      _loading = true;
      _error = null;
      _notFound = false;
    });

    final provider = context.read<CandidateInterviewsProvider>();
    final cached = provider.interviews.cast<Interview?>().firstWhere(
      (i) => i?.id == widget.interviewId,
      orElse: () => null,
    );

    if (cached != null) {
      setState(() {
        _interview = cached;
        _currentStatus = cached.status;
        _loading = false;
      });
      return;
    }

    try {
      final interview = await _repo.fetchInterviewDetail(widget.interviewId);
      if (!mounted) return;
      setState(() {
        _interview = interview;
        _currentStatus = interview.status;
        _loading = false;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (e.type == ApiErrorType.notFound) {
          _notFound = true;
        } else {
          _error = e.message;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Interview get _resolvedInterview => _interview!;
  InterviewStatus get _resolvedStatus => _currentStatus ?? _resolvedInterview.status;

  bool get _isVideo => _resolvedInterview.format == InterviewFormat.video;
  bool get _isInPerson => _resolvedInterview.format == InterviewFormat.inPerson;

  // ── Status-aware visual + copy ──
  Color get _statusColor => switch (_resolvedStatus) {
        InterviewStatus.confirmed => _tealMain,
        InterviewStatus.invited => _amber,
        InterviewStatus.completed => _secondary,
        InterviewStatus.noShow => _red,
        InterviewStatus.cancelled => _red,
      };

  IconData get _statusIcon => switch (_resolvedStatus) {
        InterviewStatus.confirmed => CupertinoIcons.checkmark_seal_fill,
        InterviewStatus.invited => CupertinoIcons.bell_fill,
        InterviewStatus.completed => CupertinoIcons.flag_fill,
        InterviewStatus.noShow => CupertinoIcons.exclamationmark_circle_fill,
        InterviewStatus.cancelled => CupertinoIcons.xmark_seal_fill,
      };

  String _statusHeadline(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (_resolvedStatus) {
      InterviewStatus.confirmed => l.interviewConfirmedHeadline,
      InterviewStatus.invited => l.localizedInterviewScheduledHeadline(),
      InterviewStatus.completed => l.localizedInterviewCompletedHeadline(),
      InterviewStatus.noShow => l.localizedInterviewStatusUpdatedHeadline(),
      InterviewStatus.cancelled => l.localizedInterviewCancelledHeadline(),
    };
  }

  String _statusSubline(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (_resolvedStatus) {
      InterviewStatus.confirmed => l.interviewConfirmedSubline,
      InterviewStatus.invited => l.localizedInterviewScheduledSubline(),
      InterviewStatus.completed => l.localizedInterviewCompletedSubline(),
      InterviewStatus.noShow => l.localizedInterviewNoShowSubline(),
      InterviewStatus.cancelled => l.localizedInterviewCancelledSubline(),
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: _bgMain,
        body: SafeArea(
          child: Column(
            children: [
              AppBackTitleBar(
                title: AppLocalizations.of(context).interviewDetails,
                onBack: () => context.canPop() ? context.pop() : null,
              ),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: _tealMain),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: _bgMain,
        body: SafeArea(
          child: Column(
            children: [
              AppBackTitleBar(
                title: AppLocalizations.of(context).interviewDetails,
                onBack: () => context.canPop() ? context.pop() : null,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _secondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _loadInterview,
                        child: Text(
                          AppLocalizations.of(context).retry,
                          style: TextStyle(
                            color: _tealMain,
                            fontWeight: FontWeight.w600,
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
      );
    }

    if (_notFound || _interview == null) {
      return Scaffold(
        backgroundColor: _bgMain,
        body: SafeArea(
          child: Column(
            children: [
              AppBackTitleBar(
                title: AppLocalizations.of(context).interviewDetails,
                onBack: () => context.canPop() ? context.pop() : null,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).localizedInterviewNotFound(),
                    style: TextStyle(
                      fontSize: 14,
                      color: _secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          children: [
            AppBackTitleBar(
              title: AppLocalizations.of(context).interviewDetails,
              onBack: () => context.canPop() ? context.pop() : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroStatusCard(),
                    const SizedBox(height: 12),
                    _buildDetailsCard(),
                    const SizedBox(height: 12),
                    _buildEmployerCard(),
                    const SizedBox(height: 20),
                    _buildActionBar(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 1. HERO STATUS CARD — refined: lighter, slimmer, more elegant
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeroStatusCard() {
    final accent = _statusColor;
    final interview = _resolvedInterview;
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 13, 17, 11),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.07),
            accent.withValues(alpha: 0.018),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.10), width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Status icon — slightly larger for stronger anchor.
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.15),
                      blurRadius: 7,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(_statusIcon, size: 19, color: Colors.white),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusHeadline(context),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: accent,
                        letterSpacing: -0.25,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _statusSubline(context),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: _secondary,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          // Date / time strip — readable text, slightly larger inline icons.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.calendar, size: 13, color: accent),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    interview.date.isEmpty
                        ? AppLocalizations.of(context)
                            .localizedInterviewDateNotAvailable()
                        : interview.date,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _charcoal,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 12,
                  color: _divider,
                ),
                const SizedBox(width: 10),
                Icon(CupertinoIcons.time, size: 13, color: accent),
                const SizedBox(width: 7),
                Text(
                  interview.time.isEmpty
                      ? AppLocalizations.of(context)
                          .localizedInterviewTimeNotAvailable()
                      : interview.time,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _charcoal,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 2. INTERVIEW DETAILS CARD — refined: tighter rows, smaller tiles
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDetailsCard() {
    final interview = _resolvedInterview;
    final hasNotes =
        interview.notes != null && interview.notes!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 4),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [_cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 2),
            child: Text(
              AppLocalizations.of(context).interviewDetails.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: _tertiary,
              ),
            ),
          ),
          _DetailRow(
            icon: CupertinoIcons.calendar,
            label: AppLocalizations.of(context).dateLabel,
            value: interview.date.isEmpty ? '—' : interview.date,
          ),
          _DetailRow(
            icon: CupertinoIcons.time,
            label: AppLocalizations.of(context).timeLabel,
            value: interview.time.isEmpty ? '—' : interview.time,
          ),
          _DetailRow(
            icon: _isVideo
                ? CupertinoIcons.videocam_fill
                : _isInPerson
                    ? CupertinoIcons.location_solid
                    : CupertinoIcons.phone_fill,
            label: AppLocalizations.of(context).formatLabel,
            value: localizedInterviewFormat(context, interview.format.displayName),
            isLast: !(_isInPerson && interview.location != null) && !hasNotes,
          ),
          if (_isInPerson && interview.location != null)
            _DetailRow(
              icon: CupertinoIcons.placemark_fill,
              label: AppLocalizations.of(context).location,
              value: localizedCity(context, interview.location!),
              isLast: !hasNotes,
            ),
          if (hasNotes) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(height: 1, color: _divider),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.only(left: 2),
              child: Text(
                AppLocalizations.of(context).localizedInterviewNotesFromEmployer(),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _charcoal,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 0, 2, 14),
              child: Text(
                interview.notes!,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: _secondary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 3. EMPLOYER CARD — refined: lighter, more elegant
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmployerCard() {
    final interview = _resolvedInterview;
    final hue = (interview.company.hashCode % 360).abs().toDouble();
    final initials = _initialsFor(interview.company);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [_cardShadow],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HSLColor.fromAHSL(1, hue, 0.48, 0.58).toColor(),
                  HSLColor.fromAHSL(1, (hue + 30) % 360, 0.44, 0.52).toColor(),
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  interview.company,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _charcoal,
                    letterSpacing: -0.15,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).hiringForTemplate(interview.jobTitle),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: _tertiary,
                    letterSpacing: -0.05,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. ACTION BAR — status-aware, refined heights
  // ═══════════════════════════════════════════════════════════════

  Widget _buildActionBar() {
    return const SizedBox.shrink();
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// ═══════════════════════════════════════════════════════════════
// Reusable row + button widgets — local to this screen
// ═══════════════════════════════════════════════════════════════

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: isLast ? 13 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Quiet but legible icon tile.
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: _tealMain.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 13, color: _tealMain),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: _tertiary,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: _charcoal,
                    letterSpacing: -0.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension _CandidateInterviewDetailL10n on AppLocalizations {
  String localizedInterviewScheduledHeadline() => _lang(
        en: 'Interview scheduled',
        it: 'Colloquio programmato',
        ar: 'تمت جدولة المقابلة',
      );

  String localizedInterviewCompletedHeadline() => _lang(
        en: 'Interview completed',
        it: 'Colloquio completato',
        ar: 'اكتملت المقابلة',
      );

  String localizedInterviewStatusUpdatedHeadline() => _lang(
        en: 'Interview status updated',
        it: 'Stato del colloquio aggiornato',
        ar: 'تم تحديث حالة المقابلة',
      );

  String localizedInterviewCancelledHeadline() => _lang(
        en: 'Interview cancelled',
        it: 'Colloquio annullato',
        ar: 'تم إلغاء المقابلة',
      );

  String localizedInterviewScheduledSubline() => _lang(
        en: 'Review the interview details below.',
        it: 'Controlla qui sotto i dettagli del colloquio.',
        ar: 'راجع تفاصيل المقابلة أدناه.',
      );

  String localizedInterviewCompletedSubline() => _lang(
        en: 'This interview has been marked as completed.',
        it: 'Questo colloquio è stato segnato come completato.',
        ar: 'تم وضع علامة على هذه المقابلة كمكتملة.',
      );

  String localizedInterviewNoShowSubline() => _lang(
        en: 'This interview has been marked as no-show.',
        it: 'Questo colloquio è stato segnato come mancata presenza.',
        ar: 'تم وضع علامة على هذه المقابلة كعدم حضور.',
      );

  String localizedInterviewCancelledSubline() => _lang(
        en: 'This interview is no longer scheduled.',
        it: 'Questo colloquio non è più programmato.',
        ar: 'لم تعد هذه المقابلة مجدولة.',
      );

  String localizedInterviewNotFound() => _lang(
        en: 'Interview not found',
        it: 'Colloquio non trovato',
        ar: 'المقابلة غير موجودة',
      );

  String localizedInterviewDateNotAvailable() => _lang(
        en: 'Date not available',
        it: 'Data non disponibile',
        ar: 'التاريخ غير متاح',
      );

  String localizedInterviewTimeNotAvailable() => _lang(
        en: 'Time not available',
        it: 'Orario non disponibile',
        ar: 'الوقت غير متاح',
      );

  String localizedInterviewNotesFromEmployer() => _lang(
        en: 'Notes from employer',
        it: 'Note del datore di lavoro',
        ar: 'ملاحظات من صاحب العمل',
      );

  String _lang({
    required String en,
    required String it,
    required String ar,
  }) {
    return switch (localeName.split('_').first) {
      'it' => it,
      'ar' => ar,
      _ => en,
    };
  }
}
