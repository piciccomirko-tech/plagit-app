import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/models/application.dart';
import 'package:plagit/providers/candidate_providers.dart';

class CandidateApplicationDetailView extends StatelessWidget {
  final String applicationId;
  const CandidateApplicationDetailView({
    super.key,
    required this.applicationId,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateApplicationsProvider>();
    final Application? app = provider.applications.cast<Application?>().firstWhere(
      (a) => a?.id == applicationId,
      orElse: () => null,
    );

    if (app == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application')),
        body: const Center(child: Text('Application not found')),
      );
    }

    final statusText = app.status.displayName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Application',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Job info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppColors.cardDecoration,
              child: Column(
                children: [
                  Text(
                    app.jobTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${app.company} \u00B7 ${app.location}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    app.salary ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Status badge centered
            Center(child: StatusBadge(status: statusText, large: true)),
            const SizedBox(height: 8),
            Text(
              'Applied ${app.date}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 28),

            // Timeline
            _TimelineSection(status: statusText),
            const SizedBox(height: 20),

            // What happens next
            _WhatHappensNextCard(status: statusText),
            const SizedBox(height: 24),

            // Action buttons
            _ActionButtons(
              status: statusText,
              onWithdraw: () => _showWithdrawDialog(context),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Withdraw Application?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.secondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: const Text(
              'Withdraw',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timeline ──

class _TimelineSection extends StatelessWidget {
  final String status;
  const _TimelineSection({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Timeline',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isLast = i == steps.length - 1;
            return _TimelineItem(
              label: step['label'] as String,
              state: step['state'] as _StepState,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildSteps() {
    const labels = [
      'Applied',
      'Viewed by employer',
      'Shortlisted',
      'Interview Invited',
      'Decision',
    ];

    int completedCount;
    bool rejected = false;
    switch (status.toLowerCase()) {
      case 'applied':
        completedCount = 1;
        break;
      case 'under review':
        completedCount = 2;
        break;
      case 'shortlisted':
        completedCount = 3;
        break;
      case 'interview scheduled':
        completedCount = 4;
        break;
      case 'rejected':
        completedCount = 2;
        rejected = true;
        break;
      default:
        completedCount = 1;
    }

    return List.generate(labels.length, (i) {
      _StepState state;
      if (rejected && i == labels.length - 1) {
        state = _StepState.rejected;
      } else if (i < completedCount) {
        state = _StepState.complete;
      } else {
        state = _StepState.incomplete;
      }
      return {'label': labels[i], 'state': state};
    });
  }
}

enum _StepState { complete, incomplete, rejected }

class _TimelineItem extends StatelessWidget {
  final String label;
  final _StepState state;
  final bool isLast;

  const _TimelineItem({
    required this.label,
    required this.state,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = state == _StepState.complete;
    final isRejected = state == _StepState.rejected;
    final circleColor = isComplete
        ? AppColors.green
        : isRejected
            ? AppColors.red
            : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circle + line column
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isComplete || isRejected
                        ? circleColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: circleColor,
                      width: 2,
                    ),
                  ),
                  child: isComplete
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : isRejected
                          ? const Icon(Icons.close,
                              size: 14, color: Colors.white)
                          : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isComplete ? AppColors.green : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Label
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isComplete ? FontWeight.w600 : FontWeight.w400,
                color: isComplete
                    ? AppColors.charcoal
                    : isRejected
                        ? AppColors.red
                        : AppColors.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── What happens next ──

class _WhatHappensNextCard extends StatelessWidget {
  final String status;
  const _WhatHappensNextCard({required this.status});

  String get _text {
    switch (status.toLowerCase()) {
      case 'applied':
        return 'Your application has been submitted. The employer will review it shortly.';
      case 'under review':
        return 'The employer is currently reviewing your application. You will be notified of any updates.';
      case 'shortlisted':
        return 'Congratulations! You have been shortlisted. The employer may reach out for an interview soon.';
      case 'interview scheduled':
        return 'Your interview has been scheduled. Please check the interview details and prepare accordingly.';
      case 'rejected':
        return 'Unfortunately, your application was not successful this time. Keep applying to find your perfect role.';
      default:
        return 'We will keep you updated on any changes to your application status.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What happens next',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Buttons ──

class _ActionButtons extends StatelessWidget {
  final String status;
  final VoidCallback onWithdraw;
  const _ActionButtons({required this.status, required this.onWithdraw});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (status.toLowerCase() == 'interview scheduled')
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.push('/candidate/interviews/1'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'View Interview Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (status.toLowerCase() == 'applied' ||
            status.toLowerCase() == 'under review') ...[
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () {
                // Could navigate to chat
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.teal,
                side: const BorderSide(color: AppColors.teal, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Message Employer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 12),
        TextButton(
          onPressed: onWithdraw,
          child: const Text(
            'Withdraw Application',
            style: TextStyle(
              color: AppColors.red,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
