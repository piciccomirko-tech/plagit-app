import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/business_service.dart';

/// Business dashboard — mirrors BusinessHomeView.swift overview section.
class BusinessDashboardTab extends StatefulWidget {
  const BusinessDashboardTab({super.key});

  @override
  State<BusinessDashboardTab> createState() => _BusinessDashboardTabState();
}

class _BusinessDashboardTabState extends State<BusinessDashboardTab> {
  final _service = BusinessService();
  Map<String, dynamic>? _data;
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
      final data = await _service.getHome();
      if (mounted) setState(() { _data = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final biz = _data?['business'] as Map<String, dynamic>?;
    final stats = _data?['stats'] as Map<String, dynamic>?;
    final nextInterview = _data?['nextInterview'] as Map<String, dynamic>?;

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.indigo,
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text(
              'Welcome back',
              style: const TextStyle(fontSize: 15, color: AppColors.secondary),
            ),
            Text(
              biz?['companyName'] ?? biz?['company_name'] ?? 'Your Business',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.charcoal),
            ),
            const SizedBox(height: 24),

            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.indigo)))
            else if (_error != null)
              _ErrorCard(message: _error!, onRetry: _load)
            else ...[
              // ── Stats grid ──
              Row(children: [
                _StatCard(label: 'Active Jobs', value: '${stats?['activeJobs'] ?? stats?['active_jobs'] ?? 0}', color: AppColors.indigo),
                const SizedBox(width: 10),
                _StatCard(label: 'Applicants', value: '${stats?['totalApplicants'] ?? stats?['total_applicants'] ?? 0}', color: AppColors.teal),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                _StatCard(label: 'New', value: '${stats?['newApplicants'] ?? stats?['new_applicants'] ?? 0}', color: AppColors.amber),
                const SizedBox(width: 10),
                _StatCard(label: 'Interviews', value: '${stats?['interviews'] ?? 0}', color: AppColors.online),
              ]),
              const SizedBox(height: 20),

              // ── Next interview ──
              if (nextInterview != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.indigo.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.indigo.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: AppColors.indigo, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Next Interview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.indigo)),
                            Text(nextInterview['candidateName'] ?? nextInterview['candidate_name'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
                            Text(nextInterview['jobTitle'] ?? nextInterview['job_title'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // ── Quick actions ──
              Row(children: [
                Expanded(child: _ActionButton(icon: Icons.add_circle_outline, label: 'Post Job', color: AppColors.indigo, onTap: () => context.push('/business/post-job'))),
                const SizedBox(width: 10),
                Expanded(child: _ActionButton(icon: Icons.chat_outlined, label: 'Messages', color: AppColors.teal, onTap: () {})),
                const SizedBox(width: 10),
                Expanded(child: _ActionButton(icon: Icons.event_outlined, label: 'Interviews', color: AppColors.amber, onTap: () {})),
              ]),
              const SizedBox(height: 24),

              // ── Unread messages ──
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
                child: Row(children: [
                  Icon(Icons.mail_outline, size: 20, color: AppColors.indigo),
                  const SizedBox(width: 12),
                  const Text('Unread messages', style: TextStyle(fontSize: 14, color: AppColors.charcoal)),
                  const Spacer(),
                  Text('${_data?['unreadMessages'] ?? _data?['unread_messages'] ?? 0}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.indigo)),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
      ]),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
      ]),
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorCard({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.urgent.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.lg)),
    child: Column(children: [
      Text(message, style: const TextStyle(fontSize: 14, color: AppColors.urgent), textAlign: TextAlign.center),
      const SizedBox(height: 12),
      TextButton(onPressed: onRetry, child: const Text('Retry')),
    ]),
  );
}
