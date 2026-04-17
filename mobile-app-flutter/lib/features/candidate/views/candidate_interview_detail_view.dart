import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/city_helpers.dart';
import 'package:plagit/core/l10n_helpers.dart';
import 'package:plagit/core/widgets/app_back_title_bar.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/interview.dart';
import 'package:plagit/providers/candidate_providers.dart';

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
const _green = Color(0xFF34C759);

// Whisper-quiet card shadow — micro-pass dropped this to 0.03/10/y2 so the
// cards barely separate from the background. They feel embedded, not lifted.
BoxShadow get _cardShadow => BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 2),
    );

class CandidateInterviewDetailView extends StatefulWidget {
  final String interviewId;
  const CandidateInterviewDetailView({super.key, required this.interviewId});

  @override
  State<CandidateInterviewDetailView> createState() =>
      _CandidateInterviewDetailViewState();
}

class _CandidateInterviewDetailViewState
    extends State<CandidateInterviewDetailView> {
  late Interview _interview;
  late InterviewStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CandidateInterviewsProvider>();
    _interview = provider.interviews.firstWhere(
      (i) => i.id == widget.interviewId,
      orElse: () => provider.interviews.first,
    );
    _currentStatus = _interview.status;
  }

  bool get _isVideo => _interview.format == InterviewFormat.video;
  bool get _isInPerson => _interview.format == InterviewFormat.inPerson;

  // ── Status-aware visual + copy ──
  Color get _statusColor => switch (_currentStatus) {
        InterviewStatus.confirmed => _tealMain,
        InterviewStatus.invited => _amber,
        InterviewStatus.completed => _secondary,
        InterviewStatus.noShow => _red,
        InterviewStatus.cancelled => _red,
      };

  IconData get _statusIcon => switch (_currentStatus) {
        InterviewStatus.confirmed => CupertinoIcons.checkmark_seal_fill,
        InterviewStatus.invited => CupertinoIcons.bell_fill,
        InterviewStatus.completed => CupertinoIcons.flag_fill,
        InterviewStatus.noShow => CupertinoIcons.exclamationmark_circle_fill,
        InterviewStatus.cancelled => CupertinoIcons.xmark_seal_fill,
      };

  String _statusHeadline(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (_currentStatus) {
      InterviewStatus.confirmed => l.interviewConfirmedHeadline,
      InterviewStatus.invited => 'Interview invitation',
      InterviewStatus.completed => 'Interview completed',
      InterviewStatus.noShow => 'Marked as no-show',
      InterviewStatus.cancelled => 'Interview cancelled',
    };
  }

  String _statusSubline(BuildContext context) {
    final l = AppLocalizations.of(context);
    return switch (_currentStatus) {
      InterviewStatus.confirmed => l.interviewConfirmedSubline,
      InterviewStatus.invited => 'Review the details and accept to confirm.',
      InterviewStatus.completed => 'Hope it went well — best of luck.',
      InterviewStatus.noShow => 'Reach out to the employer if this was a mistake.',
      InterviewStatus.cancelled => 'This interview is no longer scheduled.',
    };
  }

  @override
  Widget build(BuildContext context) {
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
                    _interview.date.isEmpty ? 'Date TBC' : _interview.date,
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
                  _interview.time.isEmpty ? 'Time TBC' : _interview.time,
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
    final hasNotes =
        _interview.notes != null && _interview.notes!.trim().isNotEmpty;

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
            value: _interview.date.isEmpty ? '—' : _interview.date,
          ),
          _DetailRow(
            icon: CupertinoIcons.time,
            label: AppLocalizations.of(context).timeLabel,
            value: _interview.time.isEmpty ? '—' : _interview.time,
          ),
          _DetailRow(
            icon: _isVideo
                ? CupertinoIcons.videocam_fill
                : _isInPerson
                    ? CupertinoIcons.location_solid
                    : CupertinoIcons.phone_fill,
            label: AppLocalizations.of(context).formatLabel,
            value: localizedInterviewFormat(context, _interview.format.displayName),
            trailing: _isVideo && _interview.link != null
                ? _JoinMeetingButton(onTap: _onJoinMeeting)
                : null,
            isLast: !(_isInPerson && _interview.location != null) && !hasNotes,
          ),
          if (_isInPerson && _interview.location != null)
            _DetailRow(
              icon: CupertinoIcons.placemark_fill,
              label: AppLocalizations.of(context).location,
              value: localizedCity(context, _interview.location!),
              isLast: !hasNotes,
            ),
          if (hasNotes) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(height: 1, color: _divider),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.only(left: 2),
              child: Text(
                'Notes from employer',
                style: TextStyle(
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
                _interview.notes!,
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
    final hue = (_interview.company.hashCode % 360).abs().toDouble();
    final initials = _initialsFor(_interview.company);
    return GestureDetector(
      onTap: () => context.push('/candidate/job/1'),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
                    _interview.company,
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
                    AppLocalizations.of(context).hiringForTemplate(_interview.jobTitle),
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
            const SizedBox(width: 8),
            // View-job affordance — bare text + chevron, slightly bolder.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).viewJobAction,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _tealMain,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(CupertinoIcons.chevron_right,
                    size: 28, color: _tealMain),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // 4. ACTION BAR — status-aware, refined heights
  // ═══════════════════════════════════════════════════════════════

  Widget _buildActionBar() {
    final l = AppLocalizations.of(context);
    switch (_currentStatus) {
      case InterviewStatus.invited:
        return Column(
          children: [
            _PrimaryButton(label: l.acceptInterview, onTap: _onAccept),
            const SizedBox(height: 9),
            _SecondaryButton(
              label: l.decline,
              color: _red,
              onTap: _onDecline,
            ),
          ],
        );
      case InterviewStatus.confirmed:
        return Column(
          children: [
            _PrimaryButton(label: l.addToCalendar, onTap: _onAddToCalendar),
            const SizedBox(height: 9),
            _SecondaryButton(
              label: l.viewJobAction,
              color: _tealMain,
              onTap: () => context.push('/candidate/job/1'),
            ),
          ],
        );
      case InterviewStatus.completed:
      case InterviewStatus.noShow:
      case InterviewStatus.cancelled:
        return _SecondaryButton(
          label: l.viewJobAction,
          color: _tealMain,
          onTap: () => context.push('/candidate/job/1'),
        );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // Action handlers — preserved 1:1 from previous implementation
  // ═══════════════════════════════════════════════════════════════

  void _onAccept() {
    setState(() => _currentStatus = InterviewStatus.confirmed);
    final l = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l.interviewAcceptedSnack),
        backgroundColor: _green,
      ),
    );
  }

  void _onDecline() {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.declineInterviewTitle),
        content: Text(l.declineInterviewConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: Text(l.decline, style: const TextStyle(color: _red)),
          ),
        ],
      ),
    );
  }

  void _onAddToCalendar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).addedToCalendar)),
    );
  }

  void _onJoinMeeting() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(AppLocalizations.of(context).openingMeetingLink)),
    );
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
  final Widget? trailing;
  final bool isLast;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
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
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _JoinMeetingButton extends StatelessWidget {
  final VoidCallback onTap;
  const _JoinMeetingButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Tinted-on-tint variant — same colour family as the row's icon tiles
    // so the action reads as "part of the row", not "stuck on top of the row".
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: _tealMain.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.videocam_fill, size: 12, color: _tealMain),
            const SizedBox(width: 5),
            Text(
              AppLocalizations.of(context).joinMeeting,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _tealMain,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _tealMain,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SecondaryButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.32), width: 0.9),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}
