import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

class CandidateJobDetailView extends StatefulWidget {
  final String jobId;
  const CandidateJobDetailView({super.key, required this.jobId});

  @override
  State<CandidateJobDetailView> createState() => _CandidateJobDetailViewState();
}

class _CandidateJobDetailViewState extends State<CandidateJobDetailView> {
  int _tabIndex = 0;
  bool _applied = false;
  Job? _job;

  @override
  void initState() {
    super.initState();
    final provider = context.read<CandidateJobsProvider>();
    _job = provider.jobs.cast<Job?>().firstWhere(
      (j) => j?.id == widget.jobId,
      orElse: () => null,
    );
    // Fallback: look up from all mock jobs if not in provider list
    _job ??= Job.mockAll().cast<Job?>().firstWhere(
      (j) => j?.id == widget.jobId,
      orElse: () => null,
    );
  }

  static const _tabLabels = ['Overview', 'Requirements', 'Benefits'];

  @override
  Widget build(BuildContext context) {
    final job = _job;
    if (job == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('Job not found')),
      );
    }

    final hue = MockData.companyHue(job.company).toDouble();
    final initials = job.company.isNotEmpty ? job.company[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.charcoal),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                // ── Company Avatar ──
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: HSLColor.fromAHSL(1, hue, 0.30, 0.88).toColor(),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: HSLColor.fromAHSL(1, hue, 0.50, 0.45).toColor(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Title ──
                Center(
                  child: Text(
                    job.title,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.charcoal),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),

                // ── Company + Location ──
                Center(
                  child: Text(
                    '${job.company}  \u{1F4CD} ${job.location}',
                    style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),

                // ── Chips Row ──
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _chip(job.salary, AppColors.teal, Colors.white),
                      _chip(job.contract, const Color(0xFFEEEEF0), AppColors.charcoal),
                    ],
                  ),
                ),

                if (job.featured || job.urgent) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Wrap(
                      spacing: 8,
                      children: [
                        if (job.featured) _badge('Featured', AppColors.amber),
                        if (job.urgent) _badge('Urgent', AppColors.red),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 18),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 14),

                // ── Tab Bar ──
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEF0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Row(
                    children: List.generate(_tabLabels.length, (i) {
                      final selected = _tabIndex == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _tabIndex = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: selected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: selected
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)]
                                  : null,
                            ),
                            child: Text(
                              _tabLabels[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected ? AppColors.charcoal : AppColors.secondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 18),

                // ── Tab Content ──
                if (_tabIndex == 0) _buildOverview(job),
                if (_tabIndex == 1) _buildRequirements(job),
                if (_tabIndex == 2) _buildBenefits(job),
              ],
            ),
          ),

          // ── FIXED BOTTOM BAR ──
          Consumer<CandidateJobsProvider>(
            builder: (context, jobsProvider, _) {
              final saved = jobsProvider.isSaved(job.id);
              return Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Save button
                      GestureDetector(
                        onTap: () => jobsProvider.toggleSave(job.id),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: saved ? AppColors.teal.withValues(alpha: 0.10) : const Color(0xFFEEEEF0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            saved ? Icons.favorite : Icons.favorite_border,
                            color: saved ? AppColors.teal : AppColors.secondary,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Apply button
                      Expanded(
                        child: _applied
                            ? Center(child: StatusBadge(status: 'Applied', large: true))
                            : ElevatedButton(
                                onPressed: () => _showApplyDialog(job),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.teal,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Apply Now',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Overview Tab ──
  Widget _buildOverview(Job job) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About this role',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
        const SizedBox(height: 10),
        Text(
          job.description ?? '',
          style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.secondary),
        ),
        const SizedBox(height: 20),
        const Text('About the company',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.company,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
                    const SizedBox(height: 2),
                    Text(job.location, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                  ],
                ),
              ),
              const ForwardChevron(color: AppColors.tertiary),
            ],
          ),
        ),
      ],
    );
  }

  // ── Requirements Tab ──
  Widget _buildRequirements(Job job) {
    final items = job.requirements ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Requirements',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
        const SizedBox(height: 12),
        ...items.map((r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6, color: AppColors.teal),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(r, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.secondary)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ── Benefits Tab ──
  Widget _buildBenefits(Job job) {
    final items = job.benefits ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Benefits',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
        const SizedBox(height: 12),
        ...items.map((b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6, color: AppColors.green),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(b, style: const TextStyle(fontSize: 14, height: 1.5, color: AppColors.secondary)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ── Apply Dialog ──
  void _showApplyDialog(Job job) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Apply for ${job.title} at ${job.company}?',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                hintStyle: const TextStyle(color: AppColors.tertiary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.teal),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.secondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _submitApplication();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitApplication() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _applied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Application sent!'),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Helpers ──
  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(text, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
