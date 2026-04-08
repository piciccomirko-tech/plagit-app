import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/candidate_service.dart';

class CandidateApplicationsTab extends StatefulWidget {
  const CandidateApplicationsTab({super.key});

  @override
  State<CandidateApplicationsTab> createState() => _CandidateApplicationsTabState();
}

class _CandidateApplicationsTabState extends State<CandidateApplicationsTab> {
  final _service = CandidateService();
  List<Map<String, dynamic>> _applications = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';

  static const _filters = ['All', 'applied', 'under_review', 'interview', 'offer', 'rejected'];
  static const _filterLabels = {'All': 'All', 'applied': 'Applied', 'under_review': 'Review', 'interview': 'Interview', 'offer': 'Offer', 'rejected': 'Rejected'};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getApplications();
      final apps = (data['applications'] ?? data['data'] ?? []) as List;
      if (mounted) setState(() { _applications = apps.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered =>
      _filter == 'All' ? _applications : _applications.where((a) => a['status'] == _filter).toList();

  Color _statusColor(String? status) {
    switch (status) {
      case 'applied': return AppColors.teal;
      case 'under_review': case 'shortlisted': return AppColors.amber;
      case 'interview': return AppColors.indigo;
      case 'offer': return AppColors.online;
      case 'rejected': case 'withdrawn': return AppColors.tertiary;
      default: return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Text('Applications', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        ),

        // ── Filters ──
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _filters[i];
              final active = f == _filter;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: active ? AppColors.teal : AppColors.border),
                    boxShadow: active ? [BoxShadow(color: AppColors.teal.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))] : null,
                  ),
                  child: Center(child: Text(_filterLabels[f] ?? f, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary))),
                ),
              );
            },
          ),
        ),

        // ── Count ──
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 0),
          child: Text('${_filtered.length} applications', style: const TextStyle(fontSize: 13, color: AppColors.tertiary)),
        ),

        // ── List ──
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5))
              : _error != null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.error_outline, size: 28, color: AppColors.urgent),
                      const SizedBox(height: 10),
                      Text(_error!, style: const TextStyle(fontSize: 14, color: AppColors.urgent), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                    ]))
                  : _filtered.isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          color: AppColors.teal,
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) {
                              final app = _filtered[i];
                              final status = app['status']?.toString() ?? 'applied';
                              return Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(color: AppColors.border),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5))],
                                ),
                                child: Row(children: [
                                  // Status icon badge
                                  Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.md)),
                                    child: Icon(_statusIcon(status), size: 20, color: _statusColor(status)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(app['job_title']?.toString() ?? app['title']?.toString() ?? 'Job', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                                    const SizedBox(height: 2),
                                    Text(app['business_name']?.toString() ?? app['company_name']?.toString() ?? '', style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
                                    if (app['location'] != null) ...[
                                      const SizedBox(height: 3),
                                      Row(mainAxisSize: MainAxisSize.min, children: [
                                        const Icon(Icons.location_on_outlined, size: 12, color: AppColors.tertiary),
                                        const SizedBox(width: 3),
                                        Text(app['location'].toString(), style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
                                      ]),
                                    ],
                                  ])),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.full)),
                                    child: Text(
                                      (_filterLabels[status] ?? status).toUpperCase(),
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status)),
                                    ),
                                  ),
                                ]),
                              );
                            },
                          ),
                        ),
        ),
      ]),
    );
  }

  IconData _statusIcon(String? status) {
    switch (status) {
      case 'applied': return Icons.send;
      case 'under_review': case 'shortlisted': return Icons.hourglass_top;
      case 'interview': return Icons.event;
      case 'offer': return Icons.star;
      case 'rejected': case 'withdrawn': return Icons.close;
      default: return Icons.circle_outlined;
    }
  }

  Widget _buildEmpty() => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 60, height: 60,
        decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.06), shape: BoxShape.circle),
        child: Icon(Icons.description_outlined, size: 26, color: AppColors.teal.withValues(alpha: 0.4)),
      ),
      const SizedBox(height: 16),
      Text(
        _applications.isNotEmpty ? 'No matches for this filter' : 'No applications yet',
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
      ),
      const SizedBox(height: 6),
      Text(
        _applications.isNotEmpty ? 'Try selecting a different status above.' : 'Start exploring jobs and apply to\npositions that match your skills.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.4),
      ),
    ]),
  ));
}
