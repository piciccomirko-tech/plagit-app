import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Application detail — mirrors CandidateRealAppDetailView.swift.
class CandidateApplicationDetailView extends StatefulWidget {
  final String applicationId;
  const CandidateApplicationDetailView({super.key, required this.applicationId});

  @override
  State<CandidateApplicationDetailView> createState() => _CandidateApplicationDetailViewState();
}

class _CandidateApplicationDetailViewState extends State<CandidateApplicationDetailView> {
  late String _currentStatus;
  bool _isWithdrawing = false;
  String? _withdrawError;

  // Mock application data
  late final Map<String, dynamic> _app;

  @override
  void initState() {
    super.initState();
    _app = {
      'id': widget.applicationId,
      'jobTitle': 'Head Chef',
      'jobId': 'job-123',
      'businessName': 'The Grand Hotel',
      'businessInitials': 'GH',
      'businessAvatarHue': 0.55,
      'businessVerified': true,
      'status': 'under_review',
      'jobLocation': 'London, UK',
      'salary': '\u00a340,000 - \u00a350,000',
    };
    _currentStatus = _app['status'] as String;
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'applied': return AppColors.teal;
      case 'under_review':
      case 'shortlisted': return AppColors.amber;
      case 'interview': return AppColors.indigo;
      case 'offer': return AppColors.online;
      case 'rejected':
      case 'withdrawn': return AppColors.tertiary;
      default: return AppColors.secondary;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'applied': return 'Applied';
      case 'under_review': return 'Under Review';
      case 'shortlisted': return 'Shortlisted';
      case 'interview': return 'Interview';
      case 'offer': return 'Offer';
      case 'rejected': return 'Rejected';
      case 'withdrawn': return 'Withdrawn';
      default: return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.xs),
                    _buildHeroCard(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildProgressTracker(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildStatusContext(),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildActionsCard(),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(width: 36, height: 36, child: Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal)),
          ),
          const Spacer(),
          const Text('Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    final hue = (_app['businessAvatarHue'] as num).toDouble();
    final sc = _statusColor(_currentStatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      HSLColor.fromAHSL(1, hue * 360, 0.45, 0.82).toColor(),
                      HSLColor.fromAHSL(1, hue * 360, 0.55, 0.70).toColor(),
                    ],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(_app['businessInitials'] as String, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_app['jobTitle'] as String, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(_app['businessName'] as String, style: const TextStyle(fontSize: 15, color: AppColors.secondary)),
                        if (_app['businessVerified'] == true) ...[
                          const SizedBox(width: AppSpacing.sm),
                          const Icon(Icons.verified, size: 10, color: AppColors.teal),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(color: sc.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.full)),
                child: Text(_statusLabel(_currentStatus), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: sc)),
              ),
              if (_app['jobLocation'] != null) ...[
                const SizedBox(width: AppSpacing.md),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_on, size: 10, color: AppColors.teal),
                    const SizedBox(width: AppSpacing.xs),
                    Text(_app['jobLocation'] as String, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                  ],
                ),
              ],
              if (_app['salary'] != null) ...[
                const SizedBox(width: AppSpacing.md),
                Text(_app['salary'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTracker() {
    final steps = ['applied', 'under_review', 'interview', 'offer'];
    final labels = ['Applied', 'Review', 'Interview', 'Offer'];
    final currentIdx = steps.indexOf(_currentStatus).clamp(0, steps.length - 1);
    final sc = _statusColor(_currentStatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Application Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                // Line
                final lineIdx = i ~/ 2;
                final lineColor = lineIdx < currentIdx ? sc.withValues(alpha: 0.4) : AppColors.border;
                return Expanded(child: Container(height: 2, color: lineColor));
              }
              final idx = i ~/ 2;
              final isActive = idx == currentIdx;
              final isPast = idx == 0 || idx < currentIdx;
              final dotColor = isActive ? sc : (isPast ? sc.withValues(alpha: 0.4) : AppColors.border);
              final textColor = isActive ? sc : (isPast ? AppColors.secondary : AppColors.tertiary);

              return Column(
                children: [
                  SizedBox(
                    width: 20, height: 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (isActive)
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: sc.withValues(alpha: 0.25), width: 3)),
                          ),
                        Container(
                          width: isActive ? 12 : 8, height: isActive ? 12 : 8,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(labels[idx], style: TextStyle(fontSize: 10, color: textColor)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusContext() {
    String icon, title, subtitle;
    Color color;

    switch (_currentStatus) {
      case 'interview':
        icon = 'calendar_today'; title = 'Interview Scheduled'; subtitle = 'Check your interviews tab for details'; color = AppColors.indigo;
        break;
      case 'under_review':
      case 'shortlisted':
        icon = 'visibility'; title = 'Under Review'; subtitle = 'The employer is reviewing your application'; color = AppColors.amber;
        break;
      case 'offer':
        icon = 'card_giftcard'; title = 'Offer Received'; subtitle = 'Congratulations! You have received an offer'; color = AppColors.online;
        break;
      case 'withdrawn':
        icon = 'cancel'; title = 'Withdrawn'; subtitle = 'You withdrew this application'; color = AppColors.tertiary;
        break;
      case 'rejected':
        icon = 'cancel'; title = 'Rejected'; subtitle = 'This application was not successful'; color = AppColors.tertiary;
        break;
      default:
        icon = 'schedule'; title = 'Application Submitted'; subtitle = 'The employer will review your application soon'; color = AppColors.teal;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.10)),
                child: Icon(_getIcon(icon), size: 14, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                  ],
                ),
              ),
            ],
          ),
          if (_withdrawError != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_withdrawError!, style: const TextStyle(fontSize: 13, color: AppColors.urgent)),
          ],
        ],
      ),
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'calendar_today': return Icons.calendar_today;
      case 'visibility': return Icons.visibility;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'cancel': return Icons.cancel;
      case 'schedule': return Icons.schedule;
      default: return Icons.info;
    }
  }

  Widget _buildActionsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          if (_app['jobId'] != null)
            GestureDetector(
              onTap: () => context.push('/candidate/job/${_app['jobId']}'),
              child: _buildActionRow(Icons.work, 'View Job Listing', AppColors.teal),
            ),
          if (_currentStatus != 'withdrawn' && _currentStatus != 'rejected') ...[
            if (_app['jobId'] != null) const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: _showWithdrawDialog,
              child: _buildActionRow(Icons.cancel, 'Withdraw Application', AppColors.urgent),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.md),
        Text(label, style: TextStyle(fontSize: 15, color: color)),
        const Spacer(),
        const Icon(Icons.chevron_right, size: 11, color: AppColors.tertiary),
      ],
    );
  }

  void _showWithdrawDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Application?'),
        content: const Text('Are you sure you want to withdraw this application? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _withdraw();
            },
            child: const Text('Withdraw', style: TextStyle(color: AppColors.urgent)),
          ),
        ],
      ),
    );
  }

  void _withdraw() {
    setState(() { _isWithdrawing = true; _withdrawError = null; });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() { _isWithdrawing = false; _currentStatus = 'withdrawn'; });
      }
    });
  }
}
