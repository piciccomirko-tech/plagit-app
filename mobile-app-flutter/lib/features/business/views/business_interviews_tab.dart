import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/business_service.dart';

/// Interviews list — mirrors BusinessRealInterviewsView.swift.
class BusinessInterviewsTab extends StatefulWidget {
  const BusinessInterviewsTab({super.key});

  @override
  State<BusinessInterviewsTab> createState() => _BusinessInterviewsTabState();
}

class _BusinessInterviewsTabState extends State<BusinessInterviewsTab> {
  final _service = BusinessService();
  List<Map<String, dynamic>> _interviews = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';

  static const _filters = ['All', 'pending', 'confirmed', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.getInterviews();
      final list = (data['interviews'] ?? data['data'] ?? []) as List;
      if (mounted) setState(() { _interviews = list.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filtered =>
      _filter == 'All' ? _interviews : _interviews.where((i) => i['status'] == _filter).toList();

  Color _statusColor(String? s) {
    switch (s) {
      case 'pending': return AppColors.amber;
      case 'confirmed': return AppColors.indigo;
      case 'completed': return AppColors.online;
      case 'cancelled': return AppColors.tertiary;
      default: return AppColors.secondary;
    }
  }

  String _typeLabel(String? t) {
    switch (t) {
      case 'video_call': return 'Video Call';
      case 'phone': return 'Phone';
      case 'in_person': return 'In Person';
      default: return t ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(children: [
            const Text('Interviews', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/business/schedule-interview'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.indigo, borderRadius: BorderRadius.circular(AppRadius.full)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.add, size: 16, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Schedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                ]),
              ),
            ),
          ]),
        ),
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
                      ? const Center(child: Text('No interviews yet', style: TextStyle(color: AppColors.secondary)))
                      : RefreshIndicator(
                          color: AppColors.indigo,
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final iv = _filtered[i];
                              final status = iv['status']?.toString() ?? 'pending';
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    Expanded(child: Text(iv['candidateName'] ?? iv['candidate_name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: _statusColor(status).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.full)),
                                      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status))),
                                    ),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text(iv['jobTitle'] ?? iv['job_title'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                                  const SizedBox(height: 6),
                                  Row(children: [
                                    Icon(Icons.videocam_outlined, size: 14, color: AppColors.tertiary),
                                    const SizedBox(width: 4),
                                    Text(_typeLabel(iv['type'] ?? iv['interview_type']), style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
                                    const SizedBox(width: 12),
                                    if (iv['scheduledAt'] != null || iv['scheduled_at'] != null) ...[
                                      Icon(Icons.schedule, size: 14, color: AppColors.tertiary),
                                      const SizedBox(width: 4),
                                      Text(iv['scheduledAt'] ?? iv['scheduled_at'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
                                    ],
                                  ]),
                                ]),
                              );
                            },
                          ),
                        ),
        ),
      ]),
    );
  }
}
