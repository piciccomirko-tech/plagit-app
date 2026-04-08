import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Business Interview Detail screen.
/// Mirrors BusinessInterviewDetailView.swift with mock data.
class BusinessInterviewDetailView extends StatefulWidget {
  final String interviewId;
  const BusinessInterviewDetailView({super.key, required this.interviewId});

  @override
  State<BusinessInterviewDetailView> createState() =>
      _BusinessInterviewDetailViewState();
}

class _BusinessInterviewDetailViewState
    extends State<BusinessInterviewDetailView> {
  bool _loading = true;
  bool _updating = false;
  String? _updateError;
  Map<String, dynamic>? _interview;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _interview = _mockInterview(widget.interviewId);
        _loading = false;
      });
    });
  }

  Map<String, dynamic> _mockInterview(String id) => {
        'id': id,
        'status': 'confirmed',
        'candidateName': 'Marco Rossi',
        'candidateRole': 'Senior Chef',
        'candidateInitials': 'MR',
        'candidateAvatarHue': 0.55,
        'jobTitle': 'Head Chef',
        'interviewType': 'video_call',
        'scheduledAt': '2026-04-12T10:00:00Z',
        'timezone': 'CET',
        'meetingLink': 'https://meet.google.com/abc-defg-hij',
        'location': null,
      };

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return AppColors.amber;
      case 'confirmed':
        return AppColors.teal;
      case 'completed':
        return AppColors.online;
      case 'cancelled':
      case 'declined':
        return AppColors.urgent;
      default:
        return AppColors.secondary;
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'pending':
        return Icons.access_time;
      case 'confirmed':
        return Icons.check_circle;
      case 'completed':
        return Icons.verified;
      case 'cancelled':
        return Icons.cancel;
      case 'declined':
        return Icons.thumb_down;
      default:
        return Icons.help_outline;
    }
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'video_call':
        return 'Video Call';
      case 'phone':
        return 'Phone';
      case 'in_person':
        return 'In Person';
      default:
        return t;
    }
  }

  IconData _typeIcon(String t) {
    switch (t) {
      case 'video_call':
        return Icons.videocam;
      case 'phone':
        return Icons.phone;
      case 'in_person':
        return Icons.place;
      default:
        return Icons.calendar_today;
    }
  }

  String _statusSubtitle(String s) {
    switch (s) {
      case 'pending':
        return 'Waiting for candidate response';
      case 'confirmed':
        return 'Interview confirmed';
      case 'completed':
        return 'Interview completed';
      default:
        return '';
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _updating = true;
      _updateError = null;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _interview!['status'] = newStatus;
      _updating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.teal))
            : _interview == null
                ? _notFound()
                : _content(),
      ),
    );
  }

  Widget _notFound() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Interview not found',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal)),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () => context.pop(),
            child: const Text('Go Back',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.teal)),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    final iv = _interview!;
    final status = iv['status'] as String;
    return SingleChildScrollView(
      child: Column(
        children: [
          _topBar(),
          const SizedBox(height: AppSpacing.lg),
          _statusBanner(iv),
          const SizedBox(height: AppSpacing.sectionGap),
          _candidateCard(iv),
          const SizedBox(height: AppSpacing.sectionGap),
          _detailsCard(iv),
          if (status == 'pending' || status == 'confirmed') ...[
            const SizedBox(height: AppSpacing.sectionGap),
            _actionsCard(iv),
          ],
          if (_updateError != null)
            Padding(
              padding: const EdgeInsets.only(
                  top: AppSpacing.md,
                  left: AppSpacing.xl,
                  right: AppSpacing.xl),
              child: Text(_updateError!,
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.urgent)),
            ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(
              width: 36,
              height: 36,
              child:
                  Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal),
            ),
          ),
          const Spacer(),
          const Text('Interview Details',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _statusBanner(Map<String, dynamic> iv) {
    final status = iv['status'] as String;
    final sc = _statusColor(status);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: sc.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: sc.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(_statusIcon(status), size: 20, color: sc),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(status[0].toUpperCase() + status.substring(1),
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500, color: sc)),
                  const SizedBox(height: 2),
                  Text(_statusSubtitle(status),
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.secondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _candidateCard(Map<String, dynamic> iv) {
    final initials = iv['candidateInitials'] ?? '--';
    final hue = (iv['candidateAvatarHue'] as double?) ?? 0.5;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            _avatar(initials, hue, 48),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(iv['candidateName'] ?? 'Candidate',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.charcoal)),
                  if (iv['candidateRole'] != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(iv['candidateRole'],
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.secondary)),
                  ],
                  if (iv['jobTitle'] != null) ...[
                    const SizedBox(height: 2),
                    Text('for ${iv['jobTitle']}',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.teal)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsCard(Map<String, dynamic> iv) {
    final type = iv['interviewType'] as String;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            _detailRow(Icons.calendar_today, 'Date', 'Sunday, Apr 12, 2026'),
            const SizedBox(height: AppSpacing.lg),
            _detailRow(Icons.access_time, 'Time',
                '10:00 AM ${iv['timezone'] ?? ''}'),
            const SizedBox(height: AppSpacing.lg),
            _detailRow(_typeIcon(type), 'Type', _typeLabel(type)),
            if (type == 'video_call' &&
                iv['meetingLink'] != null &&
                (iv['meetingLink'] as String).isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _linkCta(
                icon: Icons.videocam,
                title: 'Join Video Call',
                subtitle: iv['meetingLink'],
              ),
            ],
            if (type == 'in_person' &&
                iv['location'] != null &&
                (iv['location'] as String).isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _linkCta(
                icon: Icons.map,
                title: 'Open in Maps',
                subtitle: iv['location'],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.teal),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: AppColors.tertiary)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.charcoal)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _linkCta(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.tealLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.teal),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.teal)),
                const SizedBox(height: 2),
                Text(subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.tertiary)),
              ],
            ),
          ),
          const Icon(Icons.open_in_new, size: 11, color: AppColors.teal),
        ],
      ),
    );
  }

  Widget _actionsCard(Map<String, dynamic> iv) {
    final status = iv['status'] as String;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            if (status == 'pending') ...[
              _actionBtn('Confirm Interview', Icons.check_circle,
                  AppColors.online, true, () => _updateStatus('confirmed')),
              const SizedBox(height: AppSpacing.sm),
              _actionBtn('Cancel Interview', Icons.cancel, AppColors.urgent,
                  false, () => _updateStatus('cancelled')),
            ] else if (status == 'confirmed') ...[
              _actionBtn('Mark as Completed', Icons.verified, AppColors.teal,
                  true, () => _updateStatus('completed')),
              const SizedBox(height: AppSpacing.sm),
              _actionBtn('Cancel Interview', Icons.cancel, AppColors.urgent,
                  false, () => _updateStatus('cancelled')),
            ],
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, bool primary,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: _updating ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: primary ? color : color.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 15, color: primary ? Colors.white : color),
            const SizedBox(width: AppSpacing.sm),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: primary ? Colors.white : color)),
            const Spacer(),
            if (_updating)
              SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primary ? Colors.white : color)),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String initials, double hue, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            HSLColor.fromAHSL(1, hue * 360, 0.45, 0.90).toColor(),
            HSLColor.fromAHSL(1, hue * 360, 0.55, 0.75).toColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: TextStyle(
              fontSize: size * 0.32,
              fontWeight: FontWeight.w700,
              color: Colors.white)),
    );
  }
}
