import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Candidate interviews list — mirrors CandidateInterviewsListView.swift.
class CandidateInterviewsView extends StatefulWidget {
  const CandidateInterviewsView({super.key});

  @override
  State<CandidateInterviewsView> createState() => _CandidateInterviewsViewState();
}

class _CandidateInterviewsViewState extends State<CandidateInterviewsView> {
  bool _loading = true;
  String? _error;
  String _selectedFilter = 'All';

  final List<String> _filters = ['All', 'pending', 'confirmed', 'completed', 'cancelled'];
  final Map<String, String> _filterLabels = {
    'All': 'All',
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
  };

  // Mock data
  final List<Map<String, dynamic>> _interviews = [
    {
      'id': '1',
      'jobTitle': 'Head Chef',
      'businessName': 'The Grand Hotel',
      'businessInitials': 'GH',
      'businessAvatarHue': 0.55,
      'status': 'confirmed',
      'scheduledAt': '2026-04-15T10:00:00.000Z',
      'interviewType': 'video_call',
      'location': null,
    },
    {
      'id': '2',
      'jobTitle': 'Restaurant Manager',
      'businessName': 'Bella Italia',
      'businessInitials': 'BI',
      'businessAvatarHue': 0.1,
      'status': 'pending',
      'scheduledAt': '2026-04-18T14:30:00.000Z',
      'interviewType': 'in_person',
      'location': 'London, UK',
    },
    {
      'id': '3',
      'jobTitle': 'Bartender',
      'businessName': 'Sky Lounge',
      'businessInitials': 'SL',
      'businessAvatarHue': 0.7,
      'status': 'completed',
      'scheduledAt': '2026-04-05T09:00:00.000Z',
      'interviewType': 'phone',
      'location': null,
    },
  ];

  List<Map<String, dynamic>> get _filteredInterviews {
    if (_selectedFilter == 'All') return _interviews;
    return _interviews.where((iv) => iv['status'] == _selectedFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.amber;
      case 'confirmed': return AppColors.teal;
      case 'completed': return AppColors.online;
      case 'cancelled': return AppColors.urgent;
      case 'rescheduled': return AppColors.indigo;
      default: return AppColors.secondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      case 'rescheduled': return 'Rescheduled';
      default: return status;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'video_call': return 'Video Call';
      case 'phone': return 'Phone';
      case 'in_person': return 'In Person';
      default: return type;
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return 'TBD';
    try {
      final date = DateTime.parse(iso);
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final ampm = date.hour >= 12 ? 'PM' : 'AM';
      final min = date.minute.toString().padLeft(2, '0');
      return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$min $ampm';
    } catch (_) {
      return iso!;
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
            _buildFilterChips(),
            const SizedBox(height: AppSpacing.xs),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.lg),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const SizedBox(
              width: 36, height: 36,
              child: Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal),
            ),
          ),
          const Spacer(),
          const Text('Interviews', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          const Spacer(),
          const SizedBox(width: 36, height: 36),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: _filters.map((f) {
          final active = _selectedFilter == f;
          final count = f == 'All'
              ? _interviews.length
              : _interviews.where((iv) => iv['status'] == f).length;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: active ? AppColors.teal : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: active ? null : Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _filterLabels[f] ?? f,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text('$count', style: TextStyle(fontSize: 11, color: active ? Colors.white70 : AppColors.tertiary)),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5));
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 32, color: AppColors.tertiary),
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
    if (_filteredInterviews.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xxxl),
      itemCount: _filteredInterviews.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _buildInterviewCard(_filteredInterviews[index]),
      ),
    );
  }

  Widget _buildInterviewCard(Map<String, dynamic> iv) {
    final status = iv['status'] as String;
    final sc = _statusColor(status);
    final hue = (iv['businessAvatarHue'] as num?)?.toDouble() ?? 0.5;

    return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      HSLColor.fromAHSL(1, hue * 360, 0.45, 0.82).toColor(),
                      HSLColor.fromAHSL(1, hue * 360, 0.55, 0.70).toColor(),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(iv['businessInitials'] ?? '—', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(iv['jobTitle'] ?? 'Interview', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal))),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
                          decoration: BoxDecoration(color: sc.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)),
                          child: Text(_statusLabel(status), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: sc)),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(iv['businessName'] ?? 'Unknown', style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(_formatDate(iv['scheduledAt'] as String?), style: const TextStyle(fontSize: 13, color: AppColors.charcoal)),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.indigo.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)),
                          child: Text(_typeLabel(iv['interviewType'] ?? ''), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.indigo)),
                        ),
                        if (iv['location'] != null && (iv['location'] as String).isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Text(iv['location'] as String, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => context.push('/candidate/interview/${iv['id']}'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(AppRadius.full)),
                alignment: Alignment.center,
                child: const Text('View Details', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.tealLight),
              child: const Icon(Icons.calendar_today, size: 20, color: AppColors.teal),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text('No interviews yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'When employers schedule interviews, they\'ll appear here.',
              style: TextStyle(fontSize: 13, color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
