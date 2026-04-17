import 'package:flutter/cupertino.dart';
import 'package:plagit/core/l10n_helpers.dart';

/// Single source of truth for the application-status pill.
///
/// Used by the candidate `Application` and the business `Applicant` views,
/// plus the admin applications screen — so all 3 sides display the same
/// status with the same color and the same chip styling.
///
/// Status taxonomy (must mirror `ApplicationStatus` / `ApplicantStatus`):
///   • applied            → neutral grey
///   • underReview        → indigo
///   • shortlisted        → purple
///   • interviewInvited   → amber
///   • interviewScheduled → teal
///   • hired              → green
///   • rejected           → red
///   • withdrawn          → muted grey
class ApplicationStatusPill extends StatelessWidget {
  /// Display name of the status (e.g. "Interview Invited"). The widget
  /// normalises the string so it accepts snake_case, camelCase, or display.
  final String status;

  /// Compact mode (smaller padding & font) for use inside dense list cards.
  final bool compact;

  /// Whether to render the leading status dot.
  final bool showDot;

  const ApplicationStatusPill({
    super.key,
    required this.status,
    this.compact = false,
    this.showDot = true,
  });

  /// Returns the (background-tint, foreground) pair for any known status.
  static (Color bg, Color fg) colorsFor(String status) {
    final key = status.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    Color fg;
    switch (key) {
      case 'applied':
        fg = const Color(0xFF8E8E93); // neutral grey
      case 'underreview':
      case 'review':
        fg = const Color(0xFF5856D6); // indigo
      case 'shortlisted':
        fg = const Color(0xFFAF52DE); // purple
      case 'interviewinvited':
      case 'invited':
        fg = const Color(0xFFFF9500); // amber
      case 'interviewscheduled':
      case 'interview':
        fg = const Color(0xFF00B5B0); // teal
      case 'hired':
      case 'offer':
      case 'accepted':
        fg = const Color(0xFF34C759); // green
      case 'rejected':
        fg = const Color(0xFFFF3B30); // red
      case 'withdrawn':
        fg = const Color(0xFF9EA3AD); // muted grey
      default:
        fg = const Color(0xFF8E8E93);
    }
    return (fg.withValues(alpha: 0.12), fg);
  }

  /// Pretty display label — title-cases known camelCase / snake_case forms.
  static String displayLabel(String status) {
    final key = status.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    return switch (key) {
      'applied' => 'Applied',
      'underreview' || 'review' => 'Under Review',
      'shortlisted' => 'Shortlisted',
      'interviewinvited' || 'invited' => 'Interview Invited',
      'interviewscheduled' || 'interview' => 'Interview Scheduled',
      'hired' || 'offer' || 'accepted' => 'Hired',
      'rejected' => 'Rejected',
      'withdrawn' => 'Withdrawn',
      _ => status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = colorsFor(status);
    // Use the localized label so the pill reads in the device language.
    // Falls back to the raw status if it's not a known key (see helper).
    final label = localizedApplicationStatus(context, status);

    final hPad = compact ? 8.0 : 10.0;
    final vPad = compact ? 4.0 : 5.0;
    final fontSize = compact ? 10.5 : 11.5;
    final dotSize = compact ? 5.0 : 6.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: -0.1,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper: returns the icon associated with each application status.
///
/// Used by candidate detail views to render contextual hints
/// ("Employer is reviewing your profile", "Interview scheduled — confirm").
IconData statusIconFor(String status) {
  final key = status.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
  return switch (key) {
    'applied' => CupertinoIcons.paperplane_fill,
    'underreview' || 'review' => CupertinoIcons.eye_fill,
    'shortlisted' => CupertinoIcons.star_fill,
    'interviewinvited' || 'invited' => CupertinoIcons.bell_fill,
    'interviewscheduled' || 'interview' => CupertinoIcons.calendar,
    'hired' || 'offer' || 'accepted' => CupertinoIcons.checkmark_seal_fill,
    'rejected' => CupertinoIcons.xmark_circle_fill,
    'withdrawn' => CupertinoIcons.minus_circle_fill,
    _ => CupertinoIcons.paperplane_fill,
  };
}
