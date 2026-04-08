import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/business_service.dart';

/// Active job details with applicant list — mirrors BusinessRealJobDetailView.swift.
class BusinessJobDetailView extends StatefulWidget {
  final String jobId;
  const BusinessJobDetailView({super.key, required this.jobId});

  @override
  State<BusinessJobDetailView> createState() => _BusinessJobDetailViewState();
}

class _BusinessJobDetailViewState extends State<BusinessJobDetailView> {
  final _service = BusinessService();
  Map<String, dynamic>? _job;
  List<Map<String, dynamic>> _applicants = [];
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
      final data = await _service.getJobDetail(widget.jobId);
      final job = (data['job'] ?? data) as Map<String, dynamic>;
      final applicants = (data['applicants'] ?? job['applicants'] ?? []) as List;
      if (mounted) setState(() {
        _job = job;
        _applicants = applicants.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Color _statusColor(String? s) {
    switch (s) {
      case 'active': return AppColors.online;
      case 'paused': return AppColors.amber;
      case 'closed': return AppColors.tertiary;
      case 'draft': return AppColors.secondary;
      default: return AppColors.secondary;
    }
  }

  Color _applicantStatusColor(String? s) {
    switch (s) {
      case 'applied': return AppColors.indigo;
      case 'under_review': return AppColors.amber;
      case 'interview': return AppColors.teal;
      case 'offer': return AppColors.online;
      case 'rejected': return AppColors.urgent;
      default: return AppColors.secondary;
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
              const Text('Job Details', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                    : RefreshIndicator(
                        color: AppColors.indigo,
                        onRefresh: _load,
                        child: ListView(padding: const EdgeInsets.all(20), children: [
                          // ── Job header card ──
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.lg), border: Border.all(color: AppColors.border)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Expanded(child: Text(_job?['title']?.toString() ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.charcoal))),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: _statusColor(_job?['status']?.toString()).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.full)),
                                  child: Text((_job?['status'] ?? 'draft').toString().toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(_job?['status']?.toString()))),
                                ),
                              ]),
                              const SizedBox(height: 8),
                              if (_job?['location'] != null)
                                _InfoChip(icon: Icons.location_on_outlined, text: _job!['location'].toString()),
                              if (_job?['salary_range'] != null || _job?['salaryRange'] != null)
                                _InfoChip(icon: Icons.attach_money, text: (_job?['salary_range'] ?? _job?['salaryRange']).toString()),
                              if (_job?['contract_type'] != null || _job?['contractType'] != null)
                                _InfoChip(icon: Icons.work_outline, text: (_job?['contract_type'] ?? _job?['contractType']).toString()),
                            ]),
                          ),
                          const SizedBox(height: 16),

                          // ── Description ──
                          if (_job?['description'] != null && _job!['description'].toString().isNotEmpty) ...[
                            const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                            const SizedBox(height: 8),
                            Text(_job!['description'].toString(), style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.5)),
                            const SizedBox(height: 16),
                          ],

                          // ── Requirements ──
                          if (_job?['requirements'] != null && _job!['requirements'].toString().isNotEmpty) ...[
                            const Text('Requirements', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                            const SizedBox(height: 8),
                            Text(_job!['requirements'].toString(), style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.5)),
                            const SizedBox(height: 16),
                          ],

                          // ── Applicants section ──
                          Row(children: [
                            const Text('Applicants', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.indigo.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.full)),
                              child: Text('${_applicants.length}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.indigo)),
                            ),
                          ]),
                          const SizedBox(height: 12),

                          if (_applicants.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
                              child: const Center(child: Text('No applicants yet', style: TextStyle(color: AppColors.secondary))),
                            )
                          else
                            ..._applicants.map((a) {
                              final status = a['status']?.toString() ?? 'applied';
                              return GestureDetector(
                                onTap: () {
                                  final id = a['candidateId']?.toString() ?? a['candidate_id']?.toString() ?? a['id']?.toString();
                                  if (id != null) context.push('/business/candidate/$id');
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
                                  child: Row(children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.indigo.withValues(alpha: 0.10),
                                      child: Text(
                                        (a['name']?.toString() ?? 'C').substring(0, 1).toUpperCase(),
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.indigo),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(a['name']?.toString() ?? a['candidateName']?.toString() ?? a['candidate_name']?.toString() ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                                      if (a['role'] != null) Text(a['role'].toString(), style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                                    ])),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: _applicantStatusColor(status).withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.full)),
                                      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _applicantStatusColor(status))),
                                    ),
                                  ]),
                                ),
                              );
                            }),
                        ]),
                      ),
          ),
        ]),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Row(children: [
      Icon(icon, size: 15, color: AppColors.tertiary),
      const SizedBox(width: 6),
      Flexible(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.secondary))),
    ]),
  );
}
