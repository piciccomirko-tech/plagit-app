import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

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
                    child: const Icon(Icons.chevron_left, size: 24, color: AppColors.charcoal),
                  ),
                  const Spacer(),
                  const Text(
                    'Interview Detail',
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
                    // Candidate link
                    _linkTile(
                      icon: Icons.person,
                      label: 'Candidate',
                      value: iv['candidateName'] as String,
                      onTap: () => context.push('/admin/candidates/${iv['candidateId']}'),
                    ),
                    const SizedBox(height: 8),
                    // Business link
                    _linkTile(
                      icon: Icons.business,
                      label: 'Business',
                      value: iv['business'] as String,
                      onTap: () => context.push('/admin/businesses/ab1'),
                    ),
                    const SizedBox(height: 8),
                    // Job link
                    _linkTile(
                      icon: Icons.work,
                      label: 'Job',
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
                          _infoRow(Icons.calendar_today, 'Date', iv['date'] as String),
                          const Divider(height: 20, color: AppColors.divider),
                          _infoRow(Icons.access_time, 'Time', iv['time'] as String),
                          const Divider(height: 20, color: AppColors.divider),
                          _infoRow(Icons.videocam, 'Format', iv['format'] as String),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Timeline
                    _buildTimeline(status),
                    const SizedBox(height: 20),
                    // Notes
                    _buildNotesSection(),
                    const SizedBox(height: 20),
                    // Actions
                    _buildActions(status),
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
            const Icon(Icons.chevron_right, size: 18, color: AppColors.teal),
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

  Widget _buildTimeline(String currentStatus) {
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
          const Text('Timeline', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                    step,
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

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Admin Notes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                if (_noteController.text.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note added')),
                  );
                  _noteController.clear();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Add Note'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const SizedBox(height: 16),
          Row(
            children: [
              if (status != 'No-Show' && status != 'Cancelled' && status != 'Completed')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Marked as No-Show')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Mark No-Show', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              if (status != 'No-Show' && status != 'Cancelled' && status != 'Completed')
                const SizedBox(width: 8),
              if (status != 'Cancelled' && status != 'Completed')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Interview cancelled')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
              if (status != 'Completed' && status != 'Cancelled')
                const SizedBox(width: 8),
              if (status != 'Completed' && status != 'Cancelled' && status != 'No-Show')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Interview completed')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Complete', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
