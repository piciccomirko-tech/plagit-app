import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Interview detail — mirrors CandidateRealInterviewDetailView.swift.
class CandidateInterviewDetailView extends StatefulWidget {
  final String interviewId;
  const CandidateInterviewDetailView({super.key, required this.interviewId});

  @override
  State<CandidateInterviewDetailView> createState() => _CandidateInterviewDetailViewState();
}

class _CandidateInterviewDetailViewState extends State<CandidateInterviewDetailView> {
  bool _loading = true;
  String? _error;
  bool _isResponding = false;

  // Mock interview data
  late Map<String, dynamic> _interview;

  @override
  void initState() {
    super.initState();
    _interview = {
      'id': widget.interviewId,
      'jobTitle': 'Head Chef',
      'businessName': 'The Grand Hotel',
      'businessInitials': 'GH',
      'businessAvatarHue': 0.55,
      'businessVerified': true,
      'jobLocation': 'London, UK',
      'status': 'pending',
      'scheduledAt': '2026-04-15T10:00:00.000Z',
      'timezone': 'GMT',
      'interviewType': 'video_call',
      'location': null,
      'meetingLink': 'https://meet.google.com/abc-defg-hij',
    };
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending': return AppColors.amber;
      case 'confirmed': return AppColors.teal;
      case 'completed': return AppColors.online;
      case 'cancelled': return AppColors.urgent;
      case 'rescheduled': return AppColors.indigo;
      default: return AppColors.secondary;
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      case 'rescheduled': return 'Rescheduled';
      default: return s;
    }
  }

  String _typeLabel(String t) {
    switch (t) {
      case 'video_call': return 'Video Call';
      case 'phone': return 'Phone';
      case 'in_person': return 'In Person';
      default: return t;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return 'TBD';
    try {
      final date = DateTime.parse(iso);
      final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
      final months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
      return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return iso!;
    }
  }

  String _formatTime(String? iso) {
    if (iso == null) return '';
    try {
      final date = DateTime.parse(iso);
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final ampm = date.hour >= 12 ? 'PM' : 'AM';
      final min = date.minute.toString().padLeft(2, '0');
      return '$hour:$min $ampm';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5))
            : _error != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 32, color: AppColors.tertiary),
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.secondary), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () => setState(() { _loading = true; _error = null; }),
              child: const Text('Retry', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teal)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final status = _interview['status'] as String;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTopBar(),
          const SizedBox(height: AppSpacing.lg),
          _buildStatusBanner(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildDetailsCard(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildCompanyCard(),
          if (status == 'pending' || status == 'confirmed') ...[
            const SizedBox(height: AppSpacing.sectionGap),
            _buildActionCard(),
          ],
          const SizedBox(height: AppSpacing.xxxl),
        ],
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
          const Text('Interview Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    final status = _interview['status'] as String;
    final sc = _statusColor(status);
    IconData statusIcon;
    switch (status) {
      case 'confirmed': statusIcon = Icons.check_circle_outline; break;
      case 'cancelled': statusIcon = Icons.cancel_outlined; break;
      default: statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: sc.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: sc.withValues(alpha: 0.12)),
            child: Icon(statusIcon, size: 18, color: sc),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_statusLabel(status), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                const SizedBox(height: AppSpacing.xs),
                Text(_interview['jobTitle'] as String, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    final tz = _interview['timezone'] as String?;
    final timeStr = _formatTime(_interview['scheduledAt'] as String?) + (tz != null ? ' $tz' : '');

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
            children: const [
              Icon(Icons.calendar_today, size: 12, color: AppColors.teal),
              SizedBox(width: AppSpacing.sm),
              Text('Interview Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildDetailRow(Icons.calendar_today, 'Date', _formatDate(_interview['scheduledAt'] as String?)),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(Icons.schedule, 'Time', timeStr),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(Icons.videocam, 'Type', _typeLabel(_interview['interviewType'] as String)),
          if (_interview['location'] != null && (_interview['location'] as String).isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow(Icons.location_on, 'Location', _interview['location'] as String),
          ],
          if (_interview['meetingLink'] != null && (_interview['meetingLink'] as String).isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            _buildDetailRow(Icons.link, 'Meeting Link', _interview['meetingLink'] as String),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: AppColors.teal),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, color: AppColors.charcoal)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyCard() {
    final hue = (_interview['businessAvatarHue'] as num).toDouble();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
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
            child: Text(_interview['businessInitials'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_interview['businessName'] as String, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                    if (_interview['businessVerified'] == true) ...[
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(Icons.verified, size: 10, color: AppColors.teal),
                    ],
                  ],
                ),
                if (_interview['jobLocation'] != null && (_interview['jobLocation'] as String).isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(_interview['jobLocation'] as String, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    final status = _interview['status'] as String;
    final type = _interview['interviewType'] as String;
    final link = _interview['meetingLink'] as String?;
    final location = _interview['location'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          // Accept/Decline
          if (status == 'pending')
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _isResponding ? null : () => _respond('confirmed'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(color: AppColors.online, borderRadius: BorderRadius.circular(AppRadius.md)),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, size: 14, color: Colors.white),
                          SizedBox(width: AppSpacing.xs),
                          Text('Accept', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GestureDetector(
                    onTap: _isResponding ? null : () => _respond('declined'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.urgent.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.cancel, size: 14, color: AppColors.urgent),
                          SizedBox(width: AppSpacing.xs),
                          Text('Decline', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.urgent)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          // Video call join button
          if (type == 'video_call' && link != null && link.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () {
                // Would open meeting link
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.videocam, size: 16, color: Colors.white),
                    SizedBox(width: AppSpacing.sm),
                    Text('Join Video Call', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ],
          // In-person maps button
          if (type == 'in_person' && location != null && location.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () {
                // Would open maps
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.tealLight,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.map, size: 16, color: AppColors.teal),
                    SizedBox(width: AppSpacing.sm),
                    Text('Open in Maps', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.teal)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _respond(String status) {
    setState(() => _isResponding = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isResponding = false;
          _interview['status'] = status == 'confirmed' ? 'confirmed' : 'cancelled';
        });
      }
    });
  }
}
