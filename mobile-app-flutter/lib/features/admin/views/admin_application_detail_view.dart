import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class AdminApplicationDetailView extends StatefulWidget {
  final String applicationId;
  const AdminApplicationDetailView({super.key, required this.applicationId});
  @override
  State<AdminApplicationDetailView> createState() => _AdminApplicationDetailViewState();
}

class _AdminApplicationDetailViewState extends State<AdminApplicationDetailView> {
  String? _overrideStatus;
  final _reasonController = TextEditingController();
  final _noteController = TextEditingController();

  Map<String, dynamic> get _app {
    return MockData.adminApplications.firstWhere(
      (a) => a['id'] == widget.applicationId,
      orElse: () => MockData.adminApplications.first,
    );
  }

  final _allStatuses = [
    'Applied',
    'Under Review',
    'Interview',
    'Shortlisted',
    'Rejected',
    'Hired',
  ];

  final _timelineSteps = [
    'Applied',
    'Viewed',
    'Shortlisted',
    'Interview',
    'Decision',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = _app;
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
                    child: const Icon(Icons.chevron_left, size: 24, color: AppColors.charcoal),
                  ),
                  const Spacer(),
                  const Text(
                    'Application Detail',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal),
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
                    // Candidate card
                    _linkCard(
                      icon: Icons.person,
                      label: 'Candidate',
                      value: app['candidateName'] as String,
                      subtitle: app['candidateId'] as String,
                      onTap: () => context.push('/admin/candidates/${app['candidateId']}'),
                    ),
                    const SizedBox(height: 12),
                    // Job card
                    _linkCard(
                      icon: Icons.work,
                      label: 'Job',
                      value: app['jobTitle'] as String,
                      onTap: () => context.push('/admin/jobs/aj1'),
                    ),
                    const SizedBox(height: 12),
                    // Business card
                    _linkCard(
                      icon: Icons.business,
                      label: 'Business',
                      value: app['business'] as String,
                      onTap: () => context.push('/admin/businesses/${app['businessId']}'),
                    ),
                    const SizedBox(height: 20),
                    // Status badge centered
                    Center(
                      child: StatusBadge(status: app['status'] as String, large: true),
                    ),
                    const SizedBox(height: 24),
                    // Timeline
                    _buildTimeline(app['status'] as String),
                    const SizedBox(height: 24),
                    // Admin Override
                    _buildOverrideSection(),
                    const SizedBox(height: 24),
                    // Notes
                    _buildNotesSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkCard({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppColors.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.teal),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                  ),
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final statusMap = {
      'Applied': 0,
      'Under Review': 1,
      'Shortlisted': 2,
      'Interview': 3,
      'Hired': 4,
      'Rejected': 4,
    };
    final currentIndex = statusMap[currentStatus] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Timeline',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          const SizedBox(height: 16),
          ..._timelineSteps.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            final isCompleted = i <= currentIndex;
            final isCurrent = i == currentIndex;
            final isLast = i == _timelineSteps.length - 1;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted ? AppColors.teal : AppColors.divider,
                      ),
                      child: Icon(
                        isCompleted ? Icons.check : Icons.circle,
                        size: 14,
                        color: isCompleted ? Colors.white : AppColors.tertiary,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 28,
                        color: isCompleted ? AppColors.teal.withValues(alpha: 0.3) : AppColors.divider,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    step,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
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

  Widget _buildOverrideSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admin Override',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _overrideStatus,
                hint: const Text('Select status', style: TextStyle(fontSize: 14, color: AppColors.tertiary)),
                isExpanded: true,
                items: _allStatuses.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)));
                }).toList(),
                onChanged: (v) => setState(() => _overrideStatus = v),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              hintText: 'Reason for override...',
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _overrideStatus == null
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirm Override'),
                          content: Text(
                            'Change status to "$_overrideStatus"?\n\nReason: ${_reasonController.text.isEmpty ? "None provided" : _reasonController.text}',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Status override applied')),
                                );
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Apply Override', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notes',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Add a note...',
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
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                if (_noteController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note saved')),
                  );
                  _noteController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Note'),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No notes yet.',
            style: TextStyle(fontSize: 13, color: AppColors.tertiary),
          ),
        ],
      ),
    );
  }
}
