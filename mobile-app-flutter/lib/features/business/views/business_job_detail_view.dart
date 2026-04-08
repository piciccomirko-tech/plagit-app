import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

/// Business job detail — Details + Applicants tabs, mock-only.
class BusinessJobDetailView extends StatefulWidget {
  final String jobId;
  const BusinessJobDetailView({super.key, required this.jobId});

  @override
  State<BusinessJobDetailView> createState() => _BusinessJobDetailViewState();
}

class _BusinessJobDetailViewState extends State<BusinessJobDetailView> {
  int _tabIndex = 0;
  String _applicantFilter = 'All';

  Map<String, dynamic> get _job {
    final all = MockData.businessJobs.cast<Map<String, dynamic>>();
    return all.firstWhere(
      (j) => j['id'] == widget.jobId,
      orElse: () => all.first,
    );
  }

  List<Map<String, dynamic>> get _applicants {
    var list = MockData.businessApplicants
        .cast<Map<String, dynamic>>()
        .where((a) => a['jobId'] == widget.jobId)
        .toList();
    if (_applicantFilter != 'All') {
      if (_applicantFilter == 'Interview') {
        list = list
            .where((a) =>
                a['status'] == 'Interview Scheduled' ||
                a['status'] == 'Interview')
            .toList();
      } else {
        list = list.where((a) => a['status'] == _applicantFilter).toList();
      }
    }
    return list;
  }

  int get _totalApplicants => MockData.businessApplicants
      .cast<Map<String, dynamic>>()
      .where((a) => a['jobId'] == widget.jobId)
      .length;

  static const _applicantFilters = [
    'All',
    'Applied',
    'Shortlisted',
    'Interview',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    final job = _job;
    final status = job['status']?.toString() ?? 'Draft';
    final title = job['title']?.toString() ?? '';
    final salary = job['salary']?.toString() ?? '';
    final contract = job['contract']?.toString() ?? '';
    final location = job['location']?.toString() ?? '';
    final urgent = job['urgent'] == true;
    final featured = job['featured'] == true;
    final applicantCount = job['applicants'] ?? 0;
    final description = job['description']?.toString() ?? '';
    final requirements = (job['requirements'] as List?)?.cast<String>() ?? [];
    final benefits = (job['benefits'] as List?)?.cast<String>() ?? [];
    final posted = job['posted']?.toString() ?? '';
    final views = job['views']?.toString() ?? '0';
    final saves = job['saves']?.toString() ?? '0';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.teal),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Job header ──
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusBadge(status: status),
                    const SizedBox(width: 8),
                    Text(
                      '$applicantCount applicants',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // ── Chip row ──
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(text: salary, color: AppColors.teal),
                    _InfoChip(text: contract, color: AppColors.secondary),
                    _InfoChip(text: location, color: AppColors.secondary),
                  ],
                ),
                if (urgent || featured) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (urgent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt, size: 14, color: AppColors.red),
                              SizedBox(width: 2),
                              Text('Urgent', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.red)),
                            ],
                          ),
                        ),
                      if (urgent && featured) const SizedBox(width: 8),
                      if (featured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 14, color: AppColors.gold),
                              SizedBox(width: 2),
                              Text('Featured', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB8860B))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
                const Divider(height: 24, color: AppColors.divider),
                // ── Tab bar ──
                Row(
                  children: [
                    _TabButton(
                      label: 'Details',
                      selected: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                    const SizedBox(width: 24),
                    _TabButton(
                      label: 'Applicants ($_totalApplicants)',
                      selected: _tabIndex == 1,
                      onTap: () => setState(() => _tabIndex = 1),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Tab content ──
          Expanded(
            child: _tabIndex == 0
                ? _buildDetailsTab(description, requirements, benefits, posted, views, saves)
                : _buildApplicantsTab(),
          ),

          // ── Bottom bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.teal,
                      side: const BorderSide(color: AppColors.teal),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Pause Job', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: const BorderSide(color: AppColors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Close Job', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(
    String description,
    List<String> requirements,
    List<String> benefits,
    String posted,
    String views,
    String saves,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Description ──
        const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.6)),
        const SizedBox(height: 16),

        // ── Requirements ──
        if (requirements.isNotEmpty) ...[
          const Text('Requirements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
          const SizedBox(height: 8),
          ...requirements.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('  \u2022  ', style: TextStyle(fontSize: 14, color: AppColors.teal)),
                    Expanded(child: Text(r, style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.4))),
                  ],
                ),
              )),
          const SizedBox(height: 16),
        ],

        // ── Benefits ──
        if (benefits.isNotEmpty) ...[
          const Text('Benefits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
          const SizedBox(height: 8),
          ...benefits.map((b) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('  \u2022  ', style: TextStyle(fontSize: 14, color: AppColors.teal)),
                    Expanded(child: Text(b, style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.4))),
                  ],
                ),
              )),
          const SizedBox(height: 16),
        ],

        // ── Info rows ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppColors.cardShadow],
          ),
          child: Column(
            children: [
              _InfoRow(label: 'Posted', value: posted),
              const Divider(height: 20, color: AppColors.divider),
              _InfoRow(label: 'Views', value: views),
              const Divider(height: 20, color: AppColors.divider),
              _InfoRow(label: 'Saves', value: saves),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplicantsTab() {
    final applicants = _applicants;
    return Column(
      children: [
        // ── Filter chips ──
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _applicantFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _applicantFilters[i];
              final active = f == _applicantFilter;
              return GestureDetector(
                onTap: () => setState(() => _applicantFilter = f),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: active ? null : Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ── List ──
        Expanded(
          child: applicants.isEmpty
              ? const Center(
                  child: Text('No applicants', style: TextStyle(color: AppColors.secondary)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: applicants.length,
                  itemBuilder: (_, i) => _ApplicantRow(applicant: applicants[i]),
                ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Subwidgets
// ──────────────────────────────────────────────

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.teal : AppColors.secondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: label.length * 7.5,
            color: selected ? AppColors.teal : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String text;
  final Color color;
  const _InfoChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.secondary)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
      ],
    );
  }
}

class _ApplicantRow extends StatelessWidget {
  final Map<String, dynamic> applicant;
  const _ApplicantRow({required this.applicant});

  Color _avatarColor(String initials) {
    final hue = (initials.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.5, 0.45).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final name = applicant['name']?.toString() ?? '';
    final initials = applicant['initials']?.toString() ?? '';
    final role = applicant['role']?.toString() ?? '';
    final experience = applicant['experience']?.toString() ?? '';
    final status = applicant['status']?.toString() ?? '';
    final date = applicant['date']?.toString() ?? '';

    return GestureDetector(
      onTap: () => context.push('/business/applicant/${applicant['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: _avatarColor(initials),
                  child: Text(initials, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                      Text(role, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                      Text(experience, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(status: status),
                    const SizedBox(height: 4),
                    Text(date, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ── Quick actions ──
            Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const Text('\u2713 Shortlist', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal)),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {},
                  child: const Text('\u2717 Reject', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.red)),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {},
                  child: Text('\uD83D\uDCAC Message', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
