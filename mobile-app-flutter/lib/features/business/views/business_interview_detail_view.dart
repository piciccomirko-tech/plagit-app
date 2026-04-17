import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/models/business_interview.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Business interview detail screen.
class BusinessInterviewDetailView extends StatefulWidget {
  final String interviewId;
  const BusinessInterviewDetailView({super.key, required this.interviewId});

  @override
  State<BusinessInterviewDetailView> createState() =>
      _BusinessInterviewDetailViewState();
}

class _BusinessInterviewDetailViewState
    extends State<BusinessInterviewDetailView> {
  String? _localStatusOverride;

  String _effectiveStatus(BusinessInterview iv) =>
      _localStatusOverride ?? iv.status;

  Color _avatarColor(String name) {
    final hue = (name.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.45).toColor();
  }

  void _confirmInterview() {
    setState(() => _localStatusOverride = 'Confirmed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Interview confirmed'),
        backgroundColor: AppColors.teal,
      ),
    );
  }

  void _markCompleted() {
    setState(() => _localStatusOverride = 'Completed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Interview marked as completed'),
        backgroundColor: AppColors.green,
      ),
    );
  }

  void _cancelInterview() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Interview'),
        content: const Text('Are you sure you want to cancel this interview?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('No', style: TextStyle(color: AppColors.secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessInterviewsProvider>();
    final BusinessInterview? interview = provider.interviews
        .where((i) => i.id == widget.interviewId)
        .firstOrNull;

    // Not found / loading
    if (interview == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const BackChevron(size: 28, color: AppColors.charcoal),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Interview Details',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          centerTitle: true,
        ),
        body: provider.loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
            : const Center(
                child: Text('Interview not found', style: TextStyle(color: AppColors.secondary)),
              ),
      );
    }

    final status = _effectiveStatus(interview);
    final isVideo = interview.format == 'Video';
    final isInPerson = interview.format == 'In Person';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const BackChevron(size: 28, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Interview Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Large status badge centered
            Center(child: StatusBadge(status: status, large: true)),
            const SizedBox(height: 20),

            // Candidate info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _avatarColor(interview.candidateName),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      interview.candidateInitials,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          interview.candidateName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          interview.jobTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interview details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Column(
                children: [
                  _infoRow(
                    Icons.calendar_today,
                    AppColors.teal,
                    'Date',
                    interview.date,
                  ),
                  const Divider(height: 20, color: AppColors.divider),
                  _infoRow(
                    Icons.access_time,
                    AppColors.purple,
                    'Time',
                    interview.time,
                  ),
                  const Divider(height: 20, color: AppColors.divider),
                  _infoRow(
                    isVideo
                        ? Icons.videocam
                        : isInPerson
                            ? Icons.place
                            : Icons.phone,
                    AppColors.amber,
                    'Format',
                    interview.format,
                  ),
                  if (isVideo && interview.link != null) ...[
                    const Divider(height: 20, color: AppColors.divider),
                    Row(
                      children: [
                        const Icon(Icons.link, size: 20, color: AppColors.teal),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Meeting Link',
                              style: TextStyle(fontSize: 12, color: AppColors.secondary),
                            ),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Opening meeting link...'),
                                    backgroundColor: AppColors.teal,
                                  ),
                                );
                              },
                              child: const Text(
                                'Join meeting',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                  if (isInPerson && interview.location != null) ...[
                    const Divider(height: 20, color: AppColors.divider),
                    _infoRow(
                      Icons.place,
                      AppColors.green,
                      'Location',
                      interview.location ?? '',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes card
            if (interview.notes != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [AppColors.cardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      interview.notes ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Action buttons based on status
            if (status == 'Invited') ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _confirmInterview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Interview',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reschedule feature coming soon'),
                        backgroundColor: AppColors.teal,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Reschedule',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _cancelInterview,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ),
            ],

            if (status == 'Confirmed') ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notes feature coming soon'),
                        backgroundColor: AppColors.teal,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Notes',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _markCompleted,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Mark as Completed',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _cancelInterview,
                  child: const Text(
                    'Cancel Interview',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ),
            ],

            if (status == 'Completed') ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Candidate marked as hired!'),
                        backgroundColor: AppColors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Mark as Hired',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feedback feature coming soon'),
                        backgroundColor: AppColors.teal,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Send Feedback',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, Color iconColor, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.secondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
