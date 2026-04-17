/// Temporary dev-only control panel for mock billing testing.
///
/// **This file is dev-only.** All entry points are guarded by
/// `kDebugMode` so the panel is a no-op in release builds — it's
/// safe to ship the binary with this file present. The whole
/// `lib/features/dev/` folder can be deleted in a single gesture
/// when real billing is reconnected:
///
///   1. `rm -rf lib/features/dev/`
///   2. Remove the two trigger points (route in `app_router.dart`
///      and the long-press on the close button in
///      `candidate_subscription_view.dart`).
///
/// Nothing else depends on this file.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/models/subscription_state.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

// Dev-panel visual tokens — intentionally understated so the panel
// reads as "debug utility" not "product surface".
const _bg = Color(0xFFFAFBFC);
const _card = Color(0xFFFFFFFF);
const _divider = Color(0xFFE9EBEF);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _tealMain = Color(0xFF00B5B0);
const _amber = Color(0xFFF59E33);
const _urgent = Color(0xFFF55748);
const _green = Color(0xFF2ECC70);

/// Dev-only billing controls. Shows current premium state and four
/// actions:
///   1. Activate Premium
///   2. Deactivate Premium
///   3. Restore Success
///   4. Restore Nothing
///
/// Open via [BillingDevPanel.show] (bottom sheet) or by navigating
/// to `/dev/billing` (full screen).
class BillingDevPanel extends StatefulWidget {
  const BillingDevPanel({super.key, this.isFullScreen = false});

  /// Set to `true` when rendered inside a standalone route (instead
  /// of as a bottom sheet).
  final bool isFullScreen;

  /// Show the panel as a bottom sheet. In release builds this is a
  /// no-op — the sheet never opens.
  static Future<void> show(BuildContext context) async {
    if (!kDebugMode) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BillingDevPanel(),
    );
  }

  @override
  State<BillingDevPanel> createState() => _BillingDevPanelState();
}

class _BillingDevPanelState extends State<BillingDevPanel> {
  /// Plan used by "Activate Premium" and "Restore Success" buttons.
  /// Toggleable via the Annual/Monthly segmented control at the top
  /// of the panel.
  SubscriptionPlan _selectedPlan = SubscriptionPlan.candidateAnnual;

  bool _busy = false;
  String? _lastAction;

  @override
  Widget build(BuildContext context) {
    // Hard-guard against release-build rendering. This should never
    // fire because `show()` and the route already guard on
    // kDebugMode, but a belt-and-braces check keeps the panel
    // invisible if it somehow slips through.
    if (!kDebugMode) return const SizedBox.shrink();

    final auth = context.watch<CandidateAuthProvider>();
    final sub = auth.subscription;
    final isPremium = auth.isPremium;

    final content = Container(
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: widget.isFullScreen
            ? null
            : const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: widget.isFullScreen,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.isFullScreen) ...[
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1D1D6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── Header ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _urgent.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'DEV ONLY',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: _urgent,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Billing Controls',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _charcoal,
                      letterSpacing: -0.25,
                    ),
                  ),
                  const Spacer(),
                  if (widget.isFullScreen)
                    GestureDetector(
                      onTap: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/candidate/home');
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDDDFE4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 13, color: Colors.white),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // ── Current state readout ──
              _stateCard(sub, isPremium),

              const SizedBox(height: 14),

              // ── Plan selector (annual / monthly) ──
              _planSelector(),

              const SizedBox(height: 14),

              // ── Action buttons ──
              _actionButton(
                label: 'Activate Premium',
                subtitle: 'Skip purchase UI — set state directly',
                icon: Icons.bolt,
                color: _tealMain,
                onTap: _busy
                    ? null
                    : () => _runAction(
                          'Activated ${_selectedPlan.periodLabel.toLowerCase()}',
                          () => auth.devActivatePremium(_selectedPlan),
                        ),
              ),
              const SizedBox(height: 10),
              _actionButton(
                label: 'Deactivate Premium',
                subtitle: 'Reset to free, clear persisted state',
                icon: Icons.power_settings_new,
                color: _charcoal,
                onTap: _busy
                    ? null
                    : () => _runAction(
                          'Deactivated',
                          () => auth.devDeactivatePremium(),
                        ),
              ),
              const SizedBox(height: 10),
              _actionButton(
                label: 'Restore → Success',
                subtitle: 'Seed mock + run restore',
                icon: Icons.cloud_download,
                color: _green,
                onTap: _busy
                    ? null
                    : () => _runAction(
                          'Restore → Success',
                          () async {
                            auth.devSimulateRestoreSuccess(_selectedPlan);
                            await auth.restorePurchases();
                          },
                        ),
              ),
              const SizedBox(height: 10),
              _actionButton(
                label: 'Restore → Nothing',
                subtitle: 'Clear seed + run restore (revokes if premium)',
                icon: Icons.cloud_off,
                color: _amber,
                onTap: _busy
                    ? null
                    : () => _runAction(
                          'Restore → Nothing',
                          () async {
                            await auth.devSimulateRestoreNothing();
                            await auth.restorePurchases();
                          },
                        ),
              ),

              const SizedBox(height: 14),

              // ── Footer note ──
              Text(
                'Mock billing mode · _useMockBilling = true in candidate_providers.dart',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w400,
                  color: _tertiary.withValues(alpha: 0.88),
                  letterSpacing: -0.05,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.isFullScreen) {
      return Scaffold(backgroundColor: _bg, body: content);
    }
    return content;
  }

  // ─────────────────────────────────────────
  // Building blocks
  // ─────────────────────────────────────────

  Widget _stateCard(CandidateSubscription sub, bool isPremium) {
    final dotColor = isPremium ? _green : _tertiary;
    final statusLabel = isPremium ? 'PREMIUM ACTIVE' : 'FREE';
    final planLine = isPremium
        ? 'Plan: ${sub.plan.displayName} · ${sub.plan.periodLabel}'
        : 'Plan: Free';
    final renewsOn = sub.renewalDateParsed;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _divider, width: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: dotColor,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              if (_lastAction != null)
                Flexible(
                  child: Text(
                    'last: $_lastAction',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: _tertiary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            planLine,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _charcoal,
              letterSpacing: -0.15,
            ),
          ),
          if (renewsOn != null) ...[
            const SizedBox(height: 2),
            Text(
              'Renews: ${_formatDate(renewsOn)}',
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: _secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _planSelector() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEF1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _planSegment('Annual', SubscriptionPlan.candidateAnnual),
          ),
          Expanded(
            child: _planSegment('Monthly', SubscriptionPlan.candidateMonthly),
          ),
        ],
      ),
    );
  }

  Widget _planSegment(String label, SubscriptionPlan plan) {
    final selected = _selectedPlan == plan;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _card : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: selected ? _charcoal : _secondary,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1.0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _divider, width: 0.6),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _charcoal,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: _secondary,
                        letterSpacing: -0.05,
                      ),
                    ),
                  ],
                ),
              ),
              if (_busy)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.6,
                    valueColor: AlwaysStoppedAnimation<Color>(_tertiary),
                  ),
                )
              else
                const ForwardChevron(size: 28, color: _tertiary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runAction(String label, Future<void> Function() fn) async {
    setState(() => _busy = true);
    try {
      await fn();
      if (!mounted) return;
      setState(() {
        _lastAction = label;
        _busy = false;
      });
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text('[DEV] $label'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _charcoal,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(
          content: Text('[DEV] Error: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _urgent,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ));
    }
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
