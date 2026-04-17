import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/admin_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

class AdminInterviewDetailView extends StatefulWidget {
  final String interviewId;
  const AdminInterviewDetailView({super.key, required this.interviewId});
  @override
  State<AdminInterviewDetailView> createState() => _AdminInterviewDetailViewState();
}

class _AdminInterviewDetailViewState extends State<AdminInterviewDetailView> {
  final _noteController = TextEditingController();

  Map<String, dynamic> get _interview {
    return MockData.adminInterviews.firstWhere(
      (i) => i['id'] == widget.interviewId,
      orElse: () => MockData.adminInterviews.first,
    );
  }

  final _timelineSteps = [
    'Scheduled',
    'Confirmed',
    'In Progress',
    'Completed',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final iv = _interview;
    final status = iv['status'] as String;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const BackChevron(size: 28, color: AppColors.charcoal),
                  ),
                  const Spacer(),
                  Text(
                    l.adminSectionInterviewDetail,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Candidate link
                    _linkTile(
                      icon: Icons.person,
                      label: l.adminFieldCandidate,
                      value: iv['candidateName'] as String,
                      onTap: () => context.push('/admin/candidates/${iv['candidateId']}'),
                    ),
                    const SizedBox(height: 8),
                    // Business link
                    _linkTile(
                      icon: Icons.business,
                      label: l.adminFieldBusiness,
                      value: iv['business'] as String,
                      onTap: () => context.push('/admin/businesses/ab1'),
                    ),
                    const SizedBox(height: 8),
                    // Job link
                    _linkTile(
                      icon: Icons.work,
                      label: l.adminFieldJob,
                      value: iv['jobTitle'] as String,
                      onTap: () => context.push('/admin/jobs/aj1'),
                    ),
                    const SizedBox(height: 20),
                    // Status large
                    Center(
                      child: StatusBadge(status: status, large: true),
                    ),
                    const SizedBox(height: 20),
                    // Info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.cardDecoration,
                      child: Column(
                        children: [
                          _infoRow(Icons.calendar_today, l.adminFieldDate, iv['date'] as String),
                          const Divider(height: 20, color: AppColors.divider),
                          _infoRow(Icons.access_time, l.adminFieldTime, iv['time'] as String),
                          const Divider(height: 20, color: AppColors.divider),
                          _infoRow(Icons.videocam, l.adminFieldFormat, iv['format'] as String),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Timeline
                    _buildTimeline(l, status),
                    const SizedBox(height: 20),
                    // Notes
                    _buildNotesSection(l),
                    const SizedBox(height: 20),
                    // Actions
                    _buildActions(l, status),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppColors.cardDecoration,
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.teal),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
              ],
            ),
            const Spacer(),
            const ForwardChevron(size: 28, color: AppColors.teal),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.teal),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
      ],
    );
  }

  Widget _buildTimeline(AppLocalizations l, String currentStatus) {
    final statusIndex = {
      'Upcoming': 0,
      'Confirmed': 1,
      'Completed': 3,
      'No-Show': 3,
      'Cancelled': 0,
    };
    final ci = statusIndex[currentStatus] ?? 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.adminSectionTimeline, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: 16),
          ..._timelineSteps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isCompleted = i <= ci;
            final isLast = i == _timelineSteps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? AppColors.teal : AppColors.divider,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle,
                        size: 12,
                        color: isCompleted ? Colors.white : AppColors.tertiary,
                      ),
                    ),
                    if (!isLast) Container(width: 2, height: 24, color: isCompleted ? AppColors.teal.withValues(alpha: 0.3) : AppColors.divider),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    aStatusLabel(l, step),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: i == ci ? FontWeight.w600 : FontWeight.w400,
                      color: isCompleted ? AppColors.charcoal : AppColors.tertiary,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotesSection(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.adminSectionAdminNotes, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: l.adminPlaceholderAddNote,
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.tertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                if (_noteController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.adminSnackbarNoteAdded)),
                  );
                  _noteController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l.adminActionAddNote),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AppLocalizations l, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.adminSectionActions, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: 16),
          Row(
            children: [
              if (status != 'No-Show' && status != 'Cancelled' && status != 'Completed')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await context.read<AdminActionsProvider>().markInterviewNoShow(_interview['id'] as String);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.adminSnackbarMarkedNoShow), backgroundColor: AppColors.amber),
                        );
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l.adminActionMarkNoShow, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              if (status != 'No-Show' && status != 'Cancelled' && status != 'Completed')
                const SizedBox(width: 8),
              if (status != 'Cancelled' && status != 'Completed')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await context.read<AdminActionsProvider>().cancelInterview(_interview['id'] as String);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.adminSnackbarInterviewCancelled), backgroundColor: AppColors.red),
                        );
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l.adminActionCancel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              if (status != 'Completed' && status != 'Cancelled')
                const SizedBox(width: 8),
              if (status != 'Completed' && status != 'Cancelled' && status != 'No-Show')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await context.read<AdminActionsProvider>().markInterviewComplete(_interview['id'] as String);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l.adminSnackbarInterviewCompleted), backgroundColor: AppColors.green),
                        );
                        setState(() {});
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(l.adminActionComplete, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
