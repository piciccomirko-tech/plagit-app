import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/profile_photo.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

// ═══════════════════════════════════════════════════════
// Admin color aliases — maps old tokens to AppColors
// so existing pages get the approved palette automatically.
// ═══════════════════════════════════════════════════════

const aTeal = AppColors.teal;
const aTealLight = Color(0x1A00B5B0);
const aBg = AppColors.background;
const aCard = Colors.white;
const aSurface = Color(0xFFF9FAFB);
const aCharcoal = AppColors.charcoal;
const aSecondary = AppColors.secondary;
const aTertiary = AppColors.tertiary;
const aDivider = AppColors.divider;
const aBorder = AppColors.border;
const aGreen = AppColors.green;
const aUrgent = AppColors.red;
const aAmber = AppColors.amber;
const aIndigo = Color(0xFF6676F0);
const aPurple = AppColors.purple;

BoxShadow get aCardShadow => BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5));
BoxShadow get aSubtleShadow => BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3));

// ═══════════════════════════════════════════════════════
// Top bar — refined to match approved admin baseline
// 19px bold title (matches sectionTitle), back button r20
// ═══════════════════════════════════════════════════════

Widget aTopBar(BuildContext context, String title, {Widget? trailing}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => context.canPop() ? context.pop() : null,
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: aSurface, borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
        const Spacer(),
        trailing ?? const SizedBox(width: 36, height: 36),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════
// Filter chips — refined styling
// ═══════════════════════════════════════════════════════

Widget aChips({required List<String> labels, required int selected, required ValueChanged<int> onTap, Map<String, int>? counts}) {
  return SizedBox(
    height: 44,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 6),
      itemCount: labels.length,
      separatorBuilder: (_, i) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final active = selected == i;
        final count = (i > 0 && counts != null) ? (counts[labels[i].toLowerCase()] ?? 0) : 0;
        final display = (i > 0 && count > 0) ? '${labels[i]} $count' : labels[i];
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: active ? AppColors.teal : Colors.white,
              borderRadius: BorderRadius.circular(100),
              border: active ? null : Border.all(color: AppColors.border, width: 0.5),
              boxShadow: active ? null : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 1))],
            ),
            child: Center(
              child: Text(display, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary)),
            ),
          ),
        );
      },
    ),
  );
}

// ═══════════════════════════════════════════════════════
// Empty state — refined
// ═══════════════════════════════════════════════════════

Widget aEmpty(IconData icon, String title, String sub) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, size: 24, color: AppColors.teal),
        ),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 4),
        Text(sub, style: const TextStyle(fontSize: 13, color: AppColors.secondary), textAlign: TextAlign.center),
      ],
    ),
  );
}

Widget aLoading() => const Center(child: CircularProgressIndicator(color: AppColors.teal));

// ═══════════════════════════════════════════════════════
// Avatar — unchanged API, uses ProfilePhoto
// ═══════════════════════════════════════════════════════

Widget aAvatar(String initials, double size, {double fs = 13, bool verified = false, String? photoUrl}) {
  return ProfilePhoto(
    photoUrl: photoUrl,
    initials: initials,
    size: size,
    square: true,
    verified: verified,
    hueSeed: initials,
  );
}

// ═══════════════════════════════════════════════════════
// Pill badge — refined
// ═══════════════════════════════════════════════════════

Widget aPill(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(100)),
    child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
  );
}

// ═══════════════════════════════════════════════════════
// Sort row — used in list pages
// ═══════════════════════════════════════════════════════

Widget aSortRow(BuildContext context, int count, String entity) {
  final l = AppLocalizations.of(context);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    child: Row(
      children: [
        Text('$count $entity', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
        const Spacer(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.adminSortNewest, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
            const SizedBox(width: 4),
            const Icon(Icons.swap_vert, size: 14, color: AppColors.teal),
          ],
        ),
      ],
    ),
  );
}

// ═══════════════════════════════════════════════════════
// Status label localization — returns the localized label
// for backend/mock status strings (case-insensitive).
// Falls back to the raw string when no mapping exists.
// ═══════════════════════════════════════════════════════

String aStatusLabel(AppLocalizations l, String status) {
  switch (status.toLowerCase()) {
    case 'active': return l.adminStatusActive;
    case 'paused': return l.adminStatusPaused;
    case 'closed': return l.adminStatusClosed;
    case 'draft': return l.adminStatusDraft;
    case 'flagged': return l.adminStatusFlagged;
    case 'suspended': return l.adminStatusSuspended;
    case 'pending': return l.adminStatusPending;
    case 'confirmed': return l.adminStatusConfirmed;
    case 'completed': return l.adminStatusCompleted;
    case 'cancelled': return l.adminStatusCancelled;
    case 'accepted': return l.adminStatusAccepted;
    case 'denied': return l.adminStatusDenied;
    case 'expired': return l.adminStatusExpired;
    case 'resolved': return l.adminStatusResolved;
    case 'scheduled': return l.adminStatusScheduled;
    case 'banned': return l.adminStatusBanned;
    case 'verified': return l.adminStatusVerified;
    case 'failed': return l.adminStatusFailed;
    case 'success': return l.adminStatusSuccess;
    case 'delivered': return l.adminStatusDelivered;
    case 'applied': return l.adminStatusApplied;
    case 'under review':
    case 'underreview': return l.adminStatusUnderReview;
    case 'shortlisted': return l.adminStatusShortlisted;
    case 'interview':
    case 'interviewinvited':
    case 'interviewscheduled': return l.adminStatusInterview;
    case 'hired': return l.adminStatusHired;
    case 'rejected': return l.adminStatusRejected;
    case 'open': return l.adminStatusOpen;
    case 'in review':
    case 'inreview': return l.adminStatusInReview;
    case 'waiting': return l.adminStatusWaiting;
    case 'withdrawn': return l.adminStatusWithdrawn;
    case 'no-show':
    case 'noshow': return l.adminStatusNoShow;
    case 'in progress':
    case 'inprogress': return l.adminStatusInProgress;
    case 'reviewed': return l.adminStatusReviewed;
    case 'decision': return l.adminStatusDecision;
    default: return status;
  }
}

String aPriorityLabel(AppLocalizations l, String priority) {
  switch (priority.toLowerCase()) {
    case 'high': return l.adminPriorityHigh;
    case 'medium': return l.adminPriorityMedium;
    case 'low': return l.adminPriorityLow;
    default: return priority;
  }
}
