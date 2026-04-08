import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/business_service.dart';

/// Job management list — mirrors BusinessRealJobsView.swift.
class BusinessJobsTab extends StatefulWidget {
  const BusinessJobsTab({super.key});

  @override
  State<BusinessJobsTab> createState() => _BusinessJobsTabState();
}

class _BusinessJobsTabState extends State<BusinessJobsTab> {
  final _service = BusinessService();
  List<Map<String, dynamic>> _jobs = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';

  static const _filters = ['All', 'active', 'paused', 'closed', 'draft'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getJobs();
      final jobs = (data['jobs'] ?? data['data'] ?? []) as List;
      if (mounted) setState(() { _jobs = jobs.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered =>
      _filter == 'All' ? _jobs : _jobs.where((j) => j['status'] == _filter).toList();

  Color _statusColor(String? s) {
    switch (s) {
      case 'active': return AppColors.online;
      case 'paused': return AppColors.amber;
      case 'closed': return AppColors.tertiary;
      case 'draft': return AppColors.secondary;
      default: return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            const Text('Jobs', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/business/post-job'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.indigo, borderRadius: BorderRadius.circular(AppRadius.full)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Post Job', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                ]),
              ),
            ),
          ]),
        ),
        // Filters
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _filters[i];
              final active = f == _filter;
              return GestureDetector(
                onTap: () => setState(() => _filter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? AppColors.indigo : AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: active ? null : Border.all(color: AppColors.border),
                  ),
                  child: Center(child: Text(f[0].toUpperCase() + f.substring(1), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary))),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.indigo))
              : _error != null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(_error!, style: const TextStyle(color: AppColors.urgent)), TextButton(onPressed: _load, child: const Text('Retry'))]))
                  : _filtered.isEmpty
                      ? const Center(child: Text('No jobs yet', style: TextStyle(color: AppColors.secondary)))
                      : RefreshIndicator(
                          color: AppColors.indigo,
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final j = _filtered[i];
                              final status = j['status']?.toString() ?? 'draft';
                              return GestureDetector(
                                onTap: () => context.push('/business/job/${j['id']}'),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
                                  child: Row(children: [
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(j['title']?.toString() ?? 'Untitled', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                                      if (j['location'] != null) Text(j['location'].toString(), style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                                      if (j['applicant_count'] != null || j['applicants'] != null)
                                        Text('${j['applicant_count'] ?? j['applicants'] ?? 0} applicants', style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
                                    ])),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.full)),
                                      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status))),
                                    ),
                                  ]),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ]),
    );
  }
}
