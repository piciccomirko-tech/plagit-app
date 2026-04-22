import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/business_shortlist_candidate.dart';
import 'package:plagit/repositories/business_repository.dart';

extension _BusinessShortlistL10n on AppLocalizations {
  String get retryAction => retry;
  String get noShortlistedHeadline {
    switch (localeName) {
      case 'it':
        return 'Nessun candidato preselezionato';
      case 'ar':
        return 'لا يوجد مرشحون في القائمة المختصرة';
      default:
        return 'No shortlisted candidates';
    }
  }

  String get noShortlistedSubtext {
    switch (localeName) {
      case 'it':
        return 'Preseleziona candidati da Vicino a te, Candidati o risultati di ricerca.';
      case 'ar':
        return 'اختر مرشحين من القريبين أو المتقدمين أو نتائج البحث.';
      default:
        return 'Shortlist candidates from Nearby, Applicants, or search results.';
    }
  }
}

/// Business Shortlist screen — shortlisted candidates.
/// Mirrors BusinessShortlistView.swift with mock data.
class BusinessShortlistView extends StatefulWidget {
  const BusinessShortlistView({super.key});

  @override
  State<BusinessShortlistView> createState() => _BusinessShortlistViewState();
}

class _BusinessShortlistViewState extends State<BusinessShortlistView> {
  bool _loading = true;
  String? _error;
  final BusinessRepository _repo = BusinessRepository();
  List<BusinessShortlistCandidate> _candidates = [];

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
      final candidates = await _repo.fetchShortlist();
      if (!mounted) return;
      setState(() {
        _candidates = candidates;
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
    final l = AppLocalizations.of(context);
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
          Text(l.shortlistTitle,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.tealLight,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text('${_candidates.length}',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.teal)),
          ),
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
    if (_candidates.isEmpty) {
      return _emptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      itemCount: _candidates.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _candidateCard(_candidates[i]),
      ),
    );
  }

  Widget _candidateCard(BusinessShortlistCandidate c) {
    return GestureDetector(
      onTap: () {
        // Navigate to candidate profile placeholder
      },
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
        child: Row(
          children: [
            _avatar(c.initials, _avatarHue(c), 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(c.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.charcoal)),
                      // Flag placeholder
                    ],
                  ),
                  if (c.role.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(c.role,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.secondary)),
                  ],
                  Row(
                    children: [
                      if (c.experience.isNotEmpty)
                        Text(c.experience,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.tertiary)),
                      if (c.location.isNotEmpty) ...[
                        Text(' \u00b7 ',
                            style: TextStyle(color: AppColors.tertiary)),
                        Flexible(
                          child: Text(c.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.tertiary)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.star, size: 14, color: AppColors.amber),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.amber.withValues(alpha: 0.08),
              ),
              child:
                  const Icon(Icons.star_border, size: 24, color: AppColors.amber),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l.noShortlistedHeadline,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.sm),
            Text(
                l.noShortlistedSubtext,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
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

  double _avatarHue(BusinessShortlistCandidate candidate) {
    final seed =
        candidate.candidateId.isNotEmpty ? candidate.candidateId : candidate.name;
    final hash = seed.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return (hash % 360) / 360;
  }
}
