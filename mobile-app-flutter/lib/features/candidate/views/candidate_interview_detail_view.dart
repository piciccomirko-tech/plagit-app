import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class CandidateInterviewDetailView extends StatefulWidget {
  final String interviewId;
  const CandidateInterviewDetailView({super.key, required this.interviewId});

  @override
  State<CandidateInterviewDetailView> createState() =>
      _CandidateInterviewDetailViewState();
}

class _CandidateInterviewDetailViewState
    extends State<CandidateInterviewDetailView> {
  late Map<String, dynamic> _interview;

  @override
  void initState() {
    super.initState();
    _interview = Map<String, dynamic>.from(
      MockData.interviews.firstWhere(
        (i) => i['id'] == widget.interviewId,
        orElse: () => MockData.interviews.first,
      ),
    );
  }

  String get _status => _interview['status'] as String;
  bool get _isVideo => _interview['format'] == 'Video';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Interview Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status badge centered
            Center(child: StatusBadge(status: _status, large: true)),
            const SizedBox(height: 16),

            // Role + company
            Text(
              _interview['jobTitle'] as String,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              _interview['company'] as String,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Info card
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
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Date',
                    value: _interview['date'] as String,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value: _interview['time'] as String,
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: _isVideo ? Icons.videocam : Icons.place,
                    label: 'Format',
                    value: _interview['format'] as String,
                  ),
                  if (_isVideo && _interview['link'] != null) ...[
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.link,
                      label: 'Link',
                      valueWidget: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Opening meeting link...')),
                          );
                        },
                        child: const Text(
                          'Join meeting',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (!_isVideo && _interview['location'] != null) ...[
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.place,
                      label: 'Location',
                      value: _interview['location'] as String,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notes card
            if (_interview['notes'] != null)
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
                      'Notes from employer',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _interview['notes'] as String,
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

            // Action buttons
            if (_status == 'Invited') ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _interview['status'] = 'Confirmed';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Interview accepted!'),
                        backgroundColor: AppColors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Accept Interview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Decline Interview'),
                        content: const Text(
                            'Are you sure you want to decline this interview?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              context.pop();
                            },
                            child: const Text(
                              'Decline',
                              style: TextStyle(color: AppColors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.red,
                    side: const BorderSide(color: AppColors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],

            if (_status == 'Confirmed') ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to calendar')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Add to Calendar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => context.push('/candidate/job/1'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Job',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Related application link
            GestureDetector(
              onTap: () => context.push('/candidate/application/1'),
              child: const Text(
                'Related Application',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.secondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        const Spacer(),
        valueWidget ??
            Text(
              value ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.secondary,
              ),
            ),
      ],
    );
  }
}
