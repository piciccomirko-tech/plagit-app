import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/models/applicant.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/repositories/business_repository.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Applicant detail / candidate profile — uses typed Applicant model.
class BusinessApplicantDetailView extends StatefulWidget {
  final String applicantId;
  const BusinessApplicantDetailView({super.key, required this.applicantId});

  @override
  State<BusinessApplicantDetailView> createState() => _BusinessApplicantDetailViewState();
}

class _BusinessApplicantDetailViewState extends State<BusinessApplicantDetailView> {
  bool _shortlisting = false;
  Applicant? _fetchedApplicant;
  bool _fetchingApplicant = false;
  bool _attemptedFetch = false;
  String? _applicantError;

  Color _avatarColor(String initials) {
    final hue = (initials.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.5, 0.45).toColor();
  }

  Future<void> _shortlistApplicant(String applicantId, String name) async {
    if (_shortlisting) return;
    setState(() => _shortlisting = true);
    try {
      await context.read<BusinessApplicantsProvider>().shortlist(applicantId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$name shortlisted'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), duration: const Duration(seconds: 1)),
      );
    } finally {
      if (mounted) setState(() => _shortlisting = false);
    }
  }

  Future<void> _fetchApplicantDetail() async {
    if (_fetchingApplicant) return;
    setState(() {
      _attemptedFetch = true;
      _fetchingApplicant = true;
      _applicantError = null;
    });
    try {
      final applicant = await BusinessRepository().fetchApplicantDetail(
        widget.applicantId,
      );
      if (!mounted) return;
      setState(() {
        _fetchedApplicant = applicant;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _applicantError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _fetchingApplicant = false);
      }
    }
  }

  void _confirmReject(String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Applicant'),
        content: Text('Are you sure you want to reject $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BusinessApplicantsProvider>().reject(widget.applicantId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name rejected'), duration: const Duration(seconds: 1)),
              );
            },
            child: const Text('Reject', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessApplicantsProvider>();
    final Applicant? providerApplicant = provider.applicants
        .where((a) => a.id == widget.applicantId)
        .firstOrNull;
    final Applicant? applicant = providerApplicant ?? _fetchedApplicant;

    if (applicant == null) {
      if (provider.loading) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const BackChevron(size: 28, color: AppColors.charcoal),
              onPressed: () => context.pop(),
            ),
            title: const Text('Applicant', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          ),
          body: const Center(child: CircularProgressIndicator(color: AppColors.teal)),
        );
      }

      if (!_attemptedFetch && !_fetchingApplicant) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _fetchApplicantDetail();
        });
      }

      if (_fetchingApplicant) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const BackChevron(size: 28, color: AppColors.charcoal),
              onPressed: () => context.pop(),
            ),
            title: const Text('Applicant', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          ),
          body: const Center(child: CircularProgressIndicator(color: AppColors.teal)),
        );
      }

      if (_applicantError != null) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const BackChevron(size: 28, color: AppColors.charcoal),
              onPressed: () => context.pop(),
            ),
            title: const Text('Applicant', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _applicantError!,
                  style: const TextStyle(color: AppColors.secondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _fetchApplicantDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const BackChevron(size: 28, color: AppColors.charcoal),
            onPressed: () => context.pop(),
          ),
          title: const Text('Applicant', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        ),
        body: const Center(
          child: Text('Applicant not found', style: TextStyle(color: AppColors.secondary)),
        ),
      );
    }

    final a = applicant;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const BackChevron(size: 28, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Text(
          a.name,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // -- Large avatar --
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _avatarColor(a.initials),
                  child: Text(
                    a.initials,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                if (a.verified)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.check_circle, size: 22, color: AppColors.teal),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // -- Name + role --
          Center(
            child: Text(
              a.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(a.role, style: const TextStyle(fontSize: 15, color: AppColors.secondary)),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '${a.location}  \u2022  ${a.experience}',
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
          ),
          const SizedBox(height: 20),

          // -- Action buttons --
          Row(
            children: [
              Expanded(
                child: _ActionBtn(
                  icon: Icons.star_outline,
                  label: _shortlisting ? '...' : 'Shortlist',
                  color: AppColors.teal,
                  filled: true,
                  onTap: _shortlisting
                      ? null
                      : () => _shortlistApplicant(widget.applicantId, a.name),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.chat_bubble_outline,
                  label: 'Message',
                  color: AppColors.teal,
                  filled: false,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.calendar_today_outlined,
                  label: 'Interview',
                  color: AppColors.purple,
                  filled: true,
                  onTap: () => context.push(
                    '/business/schedule-interview',
                    extra: {
                      'candidateId': a.candidateId ?? a.id,
                      'candidateName': a.name,
                      'jobTitle': a.jobTitle ?? a.role,
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.close,
                  label: 'Reject',
                  color: AppColors.red,
                  filled: false,
                  textOnly: true,
                  onTap: () => _confirmReject(a.name),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // -- A. About --
          _SectionCard(
            title: 'About',
            child: Text(a.bio ?? '', style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.6)),
          ),
          const SizedBox(height: 12),

          // -- B. Experience --
          _SectionCard(
            title: 'Experience',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.experience, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                const SizedBox(height: 10),
                _ExperienceItem(
                  title: a.role,
                  company: 'Previous Employer',
                  period: '2023 - Present',
                ),
                const Divider(height: 16, color: AppColors.divider),
                _ExperienceItem(
                  title: a.role,
                  company: 'Earlier Venue',
                  period: '2021 - 2023',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // -- C. Skills --
          _SectionCard(
            title: 'Skills',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [a.role, 'Customer Service', 'Teamwork', 'Communication']
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(s, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.teal)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          // -- D. Languages --
          _SectionCard(
            title: 'Languages',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (a.languages ?? [])
                  .map((l) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.language, size: 16, color: AppColors.teal),
                            const SizedBox(width: 8),
                            Text(l, style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 12),

          // -- E. Availability --
          _SectionCard(
            title: 'Availability',
            child: Text(a.availability ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          ),
          const SizedBox(height: 12),

          // -- F. Salary Expectation --
          _SectionCard(
            title: 'Salary Expectation',
            child: Text(a.salaryExpectation ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal)),
          ),
          const SizedBox(height: 12),

          // -- CV section --
          _SectionCard(
            title: 'CV',
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CV viewer coming soon'), duration: Duration(seconds: 1)),
                  );
                },
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('View CV'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // -- Application context --
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                const SizedBox(height: 10),
                Text(
                  'Applied to ${a.role} on ${a.date}',
                  style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                ),
                const SizedBox(height: 8),
                StatusBadge(status: a.status.displayName),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // -- Timeline --
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                const SizedBox(height: 12),
                _TimelineStep(label: 'Applied', done: true),
                _TimelineStep(label: 'Viewed', done: true),
                _TimelineStep(
                  label: _timelineStatusLabel(a.status.displayName),
                  done: _isStatusReached(a.status.displayName),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _timelineStatusLabel(String status) {
    switch (status) {
      case 'Shortlisted':
        return 'Shortlisted';
      case 'Interview Scheduled':
        return 'Interview Scheduled';
      case 'Rejected':
        return 'Rejected';
      case 'Under Review':
        return 'Under Review';
      default:
        return 'Pending Review';
    }
  }

  bool _isStatusReached(String status) {
    return status != 'Applied';
  }
}

// ──────────────────────────────────────────────
// Subwidgets
// ──────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final bool textOnly;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    this.textOnly = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: filled ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: filled ? null : Border.all(color: textOnly ? Colors.transparent : color),
            ),
            child: Icon(
              icon,
              size: 22,
              color: filled ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ExperienceItem extends StatelessWidget {
  final String title;
  final String company;
  final String period;
  const _ExperienceItem({required this.title, required this.company, required this.period});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const SizedBox(height: 2),
        Text(company, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
        Text(period, style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final bool done;
  final bool isLast;
  const _TimelineStep({required this.label, required this.done, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? AppColors.green : AppColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                done ? Icons.check : Icons.circle,
                size: done ? 16 : 8,
                color: done ? Colors.white : AppColors.tertiary,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: done ? AppColors.green.withValues(alpha: 0.3) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: done ? AppColors.charcoal : AppColors.tertiary,
            ),
          ),
        ),
      ],
    );
  }
}
