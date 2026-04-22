import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/business_candidate_profile.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/repositories/business_repository.dart';

extension _BusinessCandidateProfileL10nX on AppLocalizations {
  String _local({
    required String en,
    required String it,
    required String ar,
  }) {
    if (localeName.startsWith('it')) return it;
    if (localeName.startsWith('ar')) return ar;
    return en;
  }

  String get candidateProfileTitle => _local(
    en: 'Candidate Profile',
    it: 'Profilo candidato',
    ar: 'ملف المرشح',
  );

  String get retryAction => retry;

  String get languagesLabel => _local(
    en: 'Languages',
    it: 'Lingue',
    ar: 'اللغات',
  );

  String get jobTypeLabel => _local(
    en: 'Job Type',
    it: 'Tipo di lavoro',
    ar: 'نوع الوظيفة',
  );

  String get aboutSection => _local(
    en: 'About',
    it: 'Chi sono',
    ar: 'نبذة',
  );

  String get skillsSection => _local(
    en: 'Skills',
    it: 'Competenze',
    ar: 'المهارات',
  );
}

/// View candidate profile — mirrors BusinessRealCandidateProfileView.swift.
class BusinessCandidateProfileView extends StatefulWidget {
  final String candidateId;
  const BusinessCandidateProfileView({super.key, required this.candidateId});

  @override
  State<BusinessCandidateProfileView> createState() => _BusinessCandidateProfileViewState();
}

class _BusinessCandidateProfileViewState extends State<BusinessCandidateProfileView> {
  final _repo = BusinessRepository();
  BusinessCandidateProfile? _candidate;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final candidate = await _repo.fetchCandidateProfile(widget.candidateId);
      if (mounted) setState(() { _candidate = candidate; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _openCandidateMessages() async {
    final provider = context.read<BusinessMessagesProvider>();
    if (provider.conversations.isEmpty && !provider.loading) {
      try {
        await provider.load();
      } catch (_) {
        // Fall back to the messages area below.
      }
    }
    if (!mounted) return;

    final candidate = _candidate;
    final candidateName = candidate?.name.toLowerCase() ?? '';
    final conversation = provider.conversations
        .where(
          (c) =>
              c.candidateId == widget.candidateId ||
              (candidateName.isNotEmpty &&
                  c.candidateName.toLowerCase() == candidateName),
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
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.chevron_left, size: 28), onPressed: () => context.pop()),
              Text(l.candidateProfileTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            ]),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.indigo))
                : _error != null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(_error!, style: const TextStyle(color: AppColors.urgent)),
                        TextButton(onPressed: _load, child: Text(l.retryAction)),
                      ]))
                    : ListView(padding: const EdgeInsets.all(20), children: [
                        // ── Avatar + name ──
                        Center(
                          child: Column(children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: AppColors.indigo.withValues(alpha: 0.12),
                              child: Text(
                                (_candidate?.initials.isNotEmpty == true
                                        ? _candidate!.initials[0]
                                        : 'C')
                                    .toUpperCase(),
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.indigo),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(_candidate?.name ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                            if (_candidate?.role != null && _candidate!.role!.isNotEmpty)
                              Text(_candidate!.role!, style: const TextStyle(fontSize: 15, color: AppColors.indigo)),
                          ]),
                        ),
                        const SizedBox(height: 24),

                        // ── Info fields ──
                        _InfoRow(icon: Icons.location_on_outlined, label: l.locationLabel, value: _candidate?.location),
                        _InfoRow(icon: Icons.access_time_outlined, label: l.experienceLabel, value: _candidate?.experience),
                        _InfoRow(
                          icon: Icons.language_outlined,
                          label: l.languagesLabel,
                          value: _candidate == null || _candidate!.languages.isEmpty
                              ? null
                              : _candidate!.languages.join(', '),
                        ),
                        _InfoRow(icon: Icons.work_outline, label: l.jobTypeLabel, value: _candidate?.jobType),

                        if (_candidate?.bio != null && _candidate!.bio!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(l.aboutSection, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                          const SizedBox(height: 8),
                          Text(_candidate!.bio!, style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.5)),
                        ],

                        if (_candidate != null && _candidate!.skills.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(l.skillsSection, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                          const SizedBox(height: 8),
                          Wrap(spacing: 8, runSpacing: 6, children: _candidate!.skills.map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.indigo.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)),
                            child: Text(s.toString(), style: const TextStyle(fontSize: 13, color: AppColors.indigo)),
                          )).toList()),
                        ],

                        const SizedBox(height: 32),

                        // ── Action buttons ──
                        Row(children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: _openCandidateMessages,
                                icon: const Icon(Icons.chat_outlined, size: 18),
                                label: Text(l.messageAction),
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.indigo, side: const BorderSide(color: AppColors.indigo)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/business/schedule-interview', extra: {
                                  'candidateId': _candidate?.id ?? widget.candidateId,
                                  'candidateName': _candidate?.name ?? '',
                                  'jobTitle': _candidate?.role ?? _candidate?.jobType ?? '',
                                }),
                                icon: const Icon(Icons.event_outlined, size: 18),
                                label: Text(l.interviewAction),
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.indigo),
                              ),
                            ),
                          ),
                        ]),
                      ]),
          ),
        ]),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const _InfoRow({required this.icon, required this.label, this.value});
  @override
  Widget build(BuildContext context) {
    if (value == null || value!.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.indigo),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
          const Spacer(),
          Flexible(child: Text(value!, style: const TextStyle(fontSize: 15, color: AppColors.charcoal), textAlign: TextAlign.right)),
        ]),
      ),
    );
  }
}
