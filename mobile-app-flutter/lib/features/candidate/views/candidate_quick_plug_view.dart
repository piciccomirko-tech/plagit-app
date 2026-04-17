import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/city_helpers.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/quick_plug_match.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _tealMain = Color(0xFF2BB8B0);
const _urgent = Color(0xFFF55748);
const _purple = Color(0xFF8F59F5);
const _border = Color(0xFFE6E8ED);

class CandidateQuickPlugView extends StatefulWidget {
  const CandidateQuickPlugView({super.key});

  @override
  State<CandidateQuickPlugView> createState() => _CandidateQuickPlugViewState();
}

class _CandidateQuickPlugViewState extends State<CandidateQuickPlugView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateQuickPlugProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateQuickPlugProvider>();

    return Scaffold(
      backgroundColor: _bgMain,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.canPop() ? context.pop() : null,
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.chevron_left, size: 28, color: _charcoal),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.bolt, size: 28, color: _purple),
                  const SizedBox(width: 4),
<<<<<<< HEAD
                  Text(AppLocalizations.of(context).quickPlug, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: _charcoal)),
                  const Spacer(),
                  if (provider.pendingCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: _tealMain.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(100)),
                      child: Text(AppLocalizations.of(context).quickPlugNewBadge(provider.pendingCount), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _tealMain)),
                    ),
=======
                  const ForwardChevron(size: 18, color: AppColors.tertiary),
>>>>>>> origin/phase10-rtl-overflow-hardening
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── CONTENT ──
            if (provider.loading)
              const Expanded(child: Center(child: CircularProgressIndicator(color: _purple)))
            else if (provider.error != null)
              Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.wifi_off, size: 40, color: _tertiary),
                const SizedBox(height: 16),
                Text(provider.error!, style: const TextStyle(fontSize: 14, color: _secondary), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                GestureDetector(onTap: () => provider.load(), child: Text(AppLocalizations.of(context).retry, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _purple))),
              ])))
            else if (provider.pendingLikes.isEmpty)
              Expanded(child: _emptyState())
            else
              Expanded(child: _likesList(provider)),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 64, height: 64, decoration: BoxDecoration(color: _purple.withValues(alpha: 0.10), shape: BoxShape.circle),
        child: const Icon(Icons.business_center, size: 28, color: _purple)),
      const SizedBox(height: 20),
      Text(AppLocalizations.of(context).quickPlugEmpty, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _charcoal)),
      const SizedBox(height: 8),
      Text(AppLocalizations.of(context).quickPlugSubtitle, style: const TextStyle(fontSize: 15, color: _secondary), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: () => context.push('/candidate/subscription'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: _purple, borderRadius: BorderRadius.circular(100)),
          child: Text(AppLocalizations.of(context).boostMyProfileCta, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
        ),
      ),
    ])));
  }

  Widget _likesList(CandidateQuickPlugProvider provider) {
    final likes = provider.pendingLikes;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      itemCount: likes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final like = likes[i];
        return _InterestCard(
          like: like,
          onAccept: () => provider.accept(like.id),
          onReject: () => provider.reject(like.id),
        );
      },
    );
  }
}

class _InterestCard extends StatelessWidget {
  final QuickPlugLike like;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _InterestCard({required this.like, required this.onAccept, required this.onReject});

  String get _timeAgo {
    final diff = DateTime.now().difference(like.likedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border.withValues(alpha: 0.7)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Business info row
          Row(
            children: [
              // Avatar
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [_tealMain, Color(0xFF1A9090)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(like.businessInitials, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(child: Text(like.businessName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _charcoal), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (like.businessVerified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified, size: 16, color: _tealMain),
                    ],
                  ]),
                  const SizedBox(height: 2),
                  if (like.jobTitle != null)
                    Text(AppLocalizations.of(context).lookingFor(like.jobTitle!), style: const TextStyle(fontSize: 13, color: _secondary)),
                  Row(children: [
                    const Icon(Icons.location_on, size: 12, color: _tertiary),
                    const SizedBox(width: 3),
                    Text(localizedCity(context, like.location), style: const TextStyle(fontSize: 12, color: _tertiary)),
                    const Spacer(),
                    Text(_timeAgo, style: const TextStyle(fontSize: 11, color: _tertiary)),
                  ]),
                ],
              )),
            ],
          ),

          const SizedBox(height: 14),

          // Action buttons
          Row(
            children: [
              // Reject
              Expanded(child: GestureDetector(
                onTap: onReject,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: _urgent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _urgent.withValues(alpha: 0.15)),
                  ),
                  child: Center(child: Text(AppLocalizations.of(context).decline, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _urgent))),
                ),
              )),
              const SizedBox(width: 10),
              // Accept
              Expanded(flex: 2, child: GestureDetector(
                onTap: onAccept,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [_tealMain, Color(0xFF1A9090)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(AppLocalizations.of(context).accept, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }
}
