import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/business_nearby_talent_candidate.dart';
import 'package:plagit/repositories/business_repository.dart';

extension _BusinessNearbyTalentL10n on AppLocalizations {
  String get nearbyTalentTitle => nearbyTalent;
  String get retryAction => retry;
  String get allRolesLabel {
    switch (localeName) {
      case 'it':
        return 'Tutti i ruoli';
      case 'ar':
        return 'كل الأدوار';
      default:
        return 'All roles';
    }
  }

  String get nearbyTalentNoResults {
    switch (localeName) {
      case 'it':
        return 'Nessun risultato';
      case 'ar':
        return 'لا توجد نتائج';
      default:
        return 'No results';
    }
  }

  String nearbyTalentCandidatesFound(int count) {
    switch (localeName) {
      case 'it':
        return count == 1 ? '1 candidato trovato' : '$count candidati trovati';
      case 'ar':
        return count == 1 ? 'تم العثور على مرشح واحد' : 'تم العثور على $count مرشحين';
      default:
        return count == 1 ? '1 candidate found' : '$count candidates found';
    }
  }

  String get nearbyTalentNoCandidates {
    switch (localeName) {
      case 'it':
        return 'Nessun candidato trovato';
      case 'ar':
        return 'لم يتم العثور على مرشحين';
      default:
        return 'No candidates found';
    }
  }

  String nearbyTalentNoRoleCandidates(String role) {
    switch (localeName) {
      case 'it':
        return 'Nessun candidato $role trovato';
      case 'ar':
        return 'لم يتم العثور على مرشحين لوظيفة $role';
      default:
        return 'No $role candidates found';
    }
  }

  String get nearbyTalentViewAction {
    switch (localeName) {
      case 'it':
        return 'Vedi';
      case 'ar':
        return 'عرض';
      default:
        return 'View';
    }
  }

  String get nearbyTalentMarkAction {
    switch (localeName) {
      case 'it':
        return 'Segna';
      case 'ar':
        return 'تحديد';
      default:
        return 'Mark';
    }
  }

  String get nearbyTalentMarkedAction {
    switch (localeName) {
      case 'it':
        return 'Segnato';
      case 'ar':
        return 'تم التحديد';
      default:
        return 'Marked';
    }
  }

  String get nearbyTalentOpenMessagesAction {
    switch (localeName) {
      case 'it':
        return 'Apri messaggi';
      case 'ar':
        return 'افتح الرسائل';
      default:
        return 'Open Messages';
    }
  }
}

/// Business Nearby Talent screen with list view and role filters.
/// Mirrors BusinessNearbyTalentView.swift with only the currently supported
/// Nearby Talent data and filters.
class BusinessNearbyTalentView extends StatefulWidget {
  const BusinessNearbyTalentView({super.key});

  @override
  State<BusinessNearbyTalentView> createState() =>
      _BusinessNearbyTalentViewState();
}

class _BusinessNearbyTalentViewState extends State<BusinessNearbyTalentView> {
  final BusinessRepository _repo = BusinessRepository();
  bool _loading = true;
  String? _error;
  String _selectedRole = 'All';
  final Set<String> _markedCandidates = {};

  List<BusinessNearbyTalentCandidate> _candidates = const [];

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
      final candidates = await _repo.fetchNearbyTalent();
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

  List<String> get _roles {
    final roles = _candidates
        .map((c) => c.role.trim())
        .where((role) => role.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...roles];
  }

  List<BusinessNearbyTalentCandidate> get _displayed {
    var list = _candidates;
    if (_selectedRole != 'All') {
      list = list.where((c) => c.role == _selectedRole).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            _roleChips(),
            const SizedBox(height: AppSpacing.sm),
            _summaryRow(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ──
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
          Text(AppLocalizations.of(context).nearbyTalentTitle,
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

  // ── Role chips ──
  Widget _roleChips() {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: _roles.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final r = _roles[i];
          final active = _selectedRole == r;
          return GestureDetector(
            onTap: () => setState(() => _selectedRole = r),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: active ? AppColors.teal : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border:
                    active ? null : Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Text(r,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: active ? Colors.white : AppColors.charcoal)),
            ),
          );
        },
      ),
    );
  }

  // ── Summary ──
  Widget _summaryRow() {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _displayed.isEmpty ? AppColors.tertiary : AppColors.online,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
              _displayed.isEmpty
                  ? l.nearbyTalentNoResults
                  : l.nearbyTalentCandidatesFound(_displayed.length),
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal)),
          if (_selectedRole != 'All') ...[
            Text(' \u00b7 ', style: TextStyle(color: AppColors.tertiary)),
            Text(_selectedRole,
                style: const TextStyle(fontSize: 11, color: AppColors.teal)),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  // ── Body ──
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
            const Icon(Icons.wifi_off, size: 32, color: AppColors.tertiary),
            const SizedBox(height: AppSpacing.md),
            Text(_error!,
                style:
                    const TextStyle(fontSize: 12, color: AppColors.secondary)),
            GestureDetector(
                onTap: _load,
                child: Text(AppLocalizations.of(context).retryAction,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.teal))),
          ],
        ),
      );
    }
    if (_displayed.isEmpty) {
      return _emptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      itemCount: _displayed.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _candidateCard(_displayed[i]),
      ),
    );
  }

  Widget _emptyState() {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  _selectedRole != 'All'
                      ? l.nearbyTalentNoRoleCandidates(
                          _selectedRole.toLowerCase(),
                        )
                      : l.nearbyTalentNoCandidates,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoal)),
              const SizedBox(height: 4),
              if (_selectedRole != 'All') ...[
                const SizedBox(height: AppSpacing.md),
                GestureDetector(
                  onTap: () => setState(() => _selectedRole = 'All'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(AppLocalizations.of(context).allRolesLabel,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.tertiary)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Candidate Card ──
  Widget _candidateCard(BusinessNearbyTalentCandidate c) {
    final l = AppLocalizations.of(context);
    final id = c.id;
    final isMarked = _markedCandidates.contains(id);
    return Container(
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
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.charcoal)),
                    if (c.role.isNotEmpty)
                      Text(c.role,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.secondary)),
                    Row(
                      children: [
                        if (c.experience.isNotEmpty)
                          Text(c.experience,
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.tertiary)),
                        if (c.location.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.place, size: 8, color: AppColors.tertiary),
                          const SizedBox(width: 3),
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
              if (c.verified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.online.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: AppColors.online,
                  ),
                ),
            ],
          ),
          if (c.summary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              c.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),

          // Actions
          Row(
            children: [
              _smallAction(
                l.nearbyTalentViewAction,
                Icons.person,
                AppColors.teal,
                () => context.push('/business/candidate/$id'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _smallAction(
                  isMarked
                      ? l.nearbyTalentMarkedAction
                      : l.nearbyTalentMarkAction,
                  isMarked ? Icons.bookmark : Icons.bookmark_border,
                  isMarked ? AppColors.amber : AppColors.secondary, () {
                setState(() {
                  if (isMarked) {
                    _markedCandidates.remove(id);
                  } else {
                    _markedCandidates.add(id);
                  }
                });
              }),
              const SizedBox(width: AppSpacing.sm),
              _smallAction(
                  l.nearbyTalentOpenMessagesAction,
                  Icons.chat_bubble_outline,
                  AppColors.indigo,
                  () => context.push('/business/messages')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _smallAction(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: color)),
              ),
            ],
          ),
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

  double _avatarHue(BusinessNearbyTalentCandidate candidate) {
    final seed = candidate.id.isNotEmpty ? candidate.id : candidate.name;
    final hash = seed.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return (hash % 360) / 360;
  }
}
