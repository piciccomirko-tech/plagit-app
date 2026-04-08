import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/business_service.dart';

/// View candidate profile — mirrors BusinessRealCandidateProfileView.swift.
class BusinessCandidateProfileView extends StatefulWidget {
  final String candidateId;
  const BusinessCandidateProfileView({super.key, required this.candidateId});

  @override
  State<BusinessCandidateProfileView> createState() => _BusinessCandidateProfileViewState();
}

class _BusinessCandidateProfileViewState extends State<BusinessCandidateProfileView> {
  final _service = BusinessService();
  Map<String, dynamic>? _candidate;
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
      final data = await _service.getCandidateProfile(widget.candidateId);
      final candidate = (data['candidate'] ?? data['profile'] ?? data) as Map<String, dynamic>;
      if (mounted) setState(() { _candidate = candidate; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.chevron_left, size: 28), onPressed: () => context.pop()),
              const Text('Candidate Profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            ]),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.indigo))
                : _error != null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(_error!, style: const TextStyle(color: AppColors.urgent)),
                        TextButton(onPressed: _load, child: const Text('Retry')),
                      ]))
                    : ListView(padding: const EdgeInsets.all(20), children: [
                        // ── Avatar + name ──
                        Center(
                          child: Column(children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: AppColors.indigo.withValues(alpha: 0.12),
                              child: Text(
                                (_candidate?['name']?.toString() ?? 'C').substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.indigo),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(_candidate?['name']?.toString() ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                            if (_candidate?['role'] != null)
                              Text(_candidate!['role'].toString(), style: const TextStyle(fontSize: 15, color: AppColors.indigo)),
                          ]),
                        ),
                        const SizedBox(height: 24),

                        // ── Info fields ──
                        _InfoRow(icon: Icons.location_on_outlined, label: 'Location', value: _candidate?['location']?.toString()),
                        _InfoRow(icon: Icons.access_time_outlined, label: 'Experience', value: _candidate?['experience']?.toString()),
                        _InfoRow(icon: Icons.language_outlined, label: 'Languages', value: _candidate?['languages']?.toString()),
                        _InfoRow(icon: Icons.work_outline, label: 'Job Type', value: _candidate?['jobType']?.toString() ?? _candidate?['job_type']?.toString()),

                        if (_candidate?['bio'] != null && _candidate!['bio'].toString().isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text('About', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                          const SizedBox(height: 8),
                          Text(_candidate!['bio'].toString(), style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.5)),
                        ],

                        if (_candidate?['skills'] != null) ...[
                          const SizedBox(height: 16),
                          const Text('Skills', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                          const SizedBox(height: 8),
                          Wrap(spacing: 8, runSpacing: 6, children: (_candidate!['skills'] as List).map((s) => Container(
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
                                onPressed: () => context.push('/business/chat/${widget.candidateId}'),
                                icon: const Icon(Icons.chat_outlined, size: 18),
                                label: const Text('Message'),
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.indigo, side: const BorderSide(color: AppColors.indigo)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: () => context.push('/business/schedule-interview', extra: {'candidateId': widget.candidateId}),
                                icon: const Icon(Icons.event_outlined, size: 18),
                                label: const Text('Interview'),
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
