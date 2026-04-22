import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/applicant.dart';
import 'package:plagit/models/business_job.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/repositories/business_repository.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

extension _BusinessJobsDetailL10nX on AppLocalizations {
  String _local({
    required String en,
    required String it,
    required String ar,
  }) {
    if (localeName.startsWith('it')) return it;
    if (localeName.startsWith('ar')) return ar;
    return en;
  }

  String get contractFullTime => _local(
    en: 'Full-time',
    it: 'Tempo pieno',
    ar: 'دوام كامل',
  );
  String get contractPartTime => _local(
    en: 'Part-time',
    it: 'Part-time',
    ar: 'دوام جزئي',
  );
  String get contractZeroHours => _local(
    en: 'Zero Hours',
    it: 'Zero ore',
    ar: 'ساعات صفرية',
  );
  String get contractTemporary => _local(
    en: 'Temporary',
    it: 'Temporaneo',
    ar: 'مؤقت',
  );
  String get retryAction => retry;
  String get jobNotFound => _local(
    en: 'Job not found',
    it: 'Lavoro non trovato',
    ar: 'الوظيفة غير موجودة',
  );
  String tabApplicantsCount(int count) => _local(
    en: 'Applicants ($count)',
    it: 'Candidati ($count)',
    ar: 'المتقدمون ($count)',
  );
  String applicantsCountLabel(int count) => _local(
    en: '$count applicants',
    it: '$count candidati',
    ar: '$count متقدمين',
  );
  String get tabDetails => _local(
    en: 'Details',
    it: 'Dettagli',
    ar: 'التفاصيل',
  );
  String get pauseJobButton => _local(
    en: 'Pause Job',
    it: 'Metti in pausa',
    ar: 'إيقاف الوظيفة مؤقتا',
  );
  String get closeJobButton => _local(
    en: 'Close Job',
    it: 'Chiudi lavoro',
    ar: 'إغلاق الوظيفة',
  );
  String get sectionDescription => _local(
    en: 'Description',
    it: 'Descrizione',
    ar: 'الوصف',
  );
  String get sectionRequirements => _local(
    en: 'Requirements',
    it: 'Requisiti',
    ar: 'المتطلبات',
  );
  String get sectionBenefits => _local(
    en: 'Benefits',
    it: 'Vantaggi',
    ar: 'المزايا',
  );
  String get labelPosted => _local(
    en: 'Posted',
    it: 'Pubblicato',
    ar: 'تاريخ النشر',
  );
  String get labelViews => _local(
    en: 'Views',
    it: 'Visualizzazioni',
    ar: 'المشاهدات',
  );
  String get labelSaves => _local(
    en: 'Saves',
    it: 'Salvataggi',
    ar: 'عمليات الحفظ',
  );
  String get noApplicantsText => _local(
    en: 'No applicants',
    it: 'Nessun candidato',
    ar: 'لا يوجد متقدمون',
  );
  String get quickActionShortlist => _local(
    en: 'Shortlist',
    it: 'Shortlist',
    ar: 'القائمة المختصرة',
  );
  String get quickActionReject => _local(
    en: 'Reject',
    it: 'Rifiuta',
    ar: 'رفض',
  );
  String get quickActionMessage => _local(
    en: 'Message',
    it: 'Messaggio',
    ar: 'رسالة',
  );
}

/// Business job detail — Details + Applicants tabs, provider-backed.
class BusinessJobDetailView extends StatefulWidget {
  final String jobId;
  const BusinessJobDetailView({super.key, required this.jobId});

  @override
  State<BusinessJobDetailView> createState() => _BusinessJobDetailViewState();
}

class _BusinessJobDetailViewState extends State<BusinessJobDetailView> {
  int _tabIndex = 0;
  String _applicantFilter = 'All';
  BusinessJob? _fetchedJob;
  bool _fetchingJob = false;
  bool _attemptedJobFetch = false;
  String? _jobFetchError;
  BusinessApplicantsProvider? _applicantsProvider;
  String? _previousApplicantsJobId;
  String _previousApplicantsFilter = 'All';

  static const _applicantFilters = [
    'All',
    'Applied',
    'Shortlisted',
    'Interview',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure both providers are loaded
      final jobsProv = context.read<BusinessJobsProvider>();
      if (jobsProv.jobs.isEmpty) {
        jobsProv.load();
      }
      final appProv = context.read<BusinessApplicantsProvider>();
      _applicantsProvider = appProv;
      _previousApplicantsJobId = appProv.jobId;
      _previousApplicantsFilter = appProv.filter;
      final needsApplicantContext =
          appProv.jobId != widget.jobId || appProv.filter != _applicantFilter;
      if (needsApplicantContext) {
        appProv.setContext(jobId: widget.jobId, filter: _applicantFilter);
      } else if (appProv.applicants.isEmpty && !appProv.loading) {
        appProv.load();
      }
    });
  }

  @override
  void dispose() {
    final appProv = _applicantsProvider;
    if (appProv == null) {
      super.dispose();
      return;
    }
    final shouldRestore =
        appProv.jobId != _previousApplicantsJobId ||
        appProv.filter != _previousApplicantsFilter;
    if (shouldRestore) {
      appProv.setContext(
        jobId: _previousApplicantsJobId,
        filter: _previousApplicantsFilter,
      );
    }
    super.dispose();
  }

  /// Find the job from the jobs provider by ID.
  BusinessJob? _findProviderJob(BusinessJobsProvider provider) {
    for (final job in provider.jobs) {
      if (job.id == widget.jobId) return job;
    }
    return null;
  }

  void _scheduleMissingJobFetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _fetchingJob || _attemptedJobFetch) return;
      _fetchMissingJob();
    });
  }

  Future<void> _fetchMissingJob() async {
    if (_fetchingJob) return;
    setState(() {
      _fetchingJob = true;
      _attemptedJobFetch = true;
      _jobFetchError = null;
    });

    try {
      final job = await BusinessRepository().fetchJobDetail(widget.jobId);
      if (!mounted) return;
      setState(() {
        _fetchedJob = job;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _jobFetchError = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _fetchingJob = false;
        });
      }
    }
  }

  /// Filter applicants for this job from the applicants provider.
  List<Applicant> _jobApplicants(BusinessApplicantsProvider provider) {
    return provider.applicants;
  }

  String _localizedContract(AppLocalizations l, String contract) {
    switch (contract) {
      case 'Full-time':
        return l.contractFullTime;
      case 'Part-time':
        return l.contractPartTime;
      case 'Zero Hours':
        return l.contractZeroHours;
      case 'Temporary':
        return l.contractTemporary;
      default:
        return contract;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final jobsProvider = context.watch<BusinessJobsProvider>();
    final applicantsProvider = context.watch<BusinessApplicantsProvider>();
    final providerJob = _findProviderJob(jobsProvider);
    final job = providerJob ?? _fetchedJob;

    if (!jobsProvider.loading &&
        jobsProvider.error == null &&
        job == null &&
        !_fetchingJob &&
        !_attemptedJobFetch) {
      _scheduleMissingJobFetch();
    }

    // ── Loading state ──
    if (jobsProvider.loading || (job == null && _fetchingJob)) {
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
            l.jobDetailsTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    // ── Error state ──
    if (jobsProvider.error != null) {
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
            l.jobDetailsTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.red),
              const SizedBox(height: 12),
              Text(
                jobsProvider.error!,
                style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<BusinessJobsProvider>().load(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l.retryAction),
              ),
            ],
          ),
        ),
      );
    }

    if (job == null && _jobFetchError != null) {
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
            l.jobDetailsTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.red),
              const SizedBox(height: 12),
              Text(
                _jobFetchError!,
                style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMissingJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l.retryAction),
              ),
            ],
          ),
        ),
      );
    }

    // ── Content state ──
    if (job == null) {
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
            l.jobDetailsTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
        ),
        body: Center(
          child: Text(l.jobNotFound, style: const TextStyle(fontSize: 16, color: AppColors.secondary)),
        ),
      );
    }

    final totalApplicants = job.applicants;

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
          l.jobDetailsTitle,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
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
                  job.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    StatusBadge(
                      status: job.status.displayName,
                      label: job.status.localizedLabel(l),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.applicantsCountLabel(job.applicants),
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
                    _InfoChip(text: job.salary, color: AppColors.teal),
                    _InfoChip(text: _localizedContract(l, job.contract), color: AppColors.secondary),
                    _InfoChip(text: job.location, color: AppColors.secondary),
                  ],
                ),
                if (job.urgent || job.featured) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (job.urgent)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt, size: 14, color: AppColors.red),
                              const SizedBox(width: 2),
                              Text(l.urgentBadge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.red)),
                            ],
                          ),
                        ),
                      if (job.urgent && job.featured) const SizedBox(width: 8),
                      if (job.featured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 14, color: AppColors.gold),
                              const SizedBox(width: 2),
                              Text(l.featuredBadge, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB8860B))),
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
                      label: l.tabDetails,
                      selected: _tabIndex == 0,
                      onTap: () => setState(() => _tabIndex = 0),
                    ),
                    const SizedBox(width: 24),
                    _TabButton(
                      label: l.tabApplicantsCount(totalApplicants),
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
                ? _buildDetailsTab(job, l)
                : _buildApplicantsTab(applicantsProvider, l),
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
                    child: Text(l.pauseJobButton, style: const TextStyle(fontWeight: FontWeight.w600)),
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
                    child: Text(l.closeJobButton, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(BusinessJob job, AppLocalizations l) {
    final description = job.description ?? '';
    final requirements = job.requirements ?? [];
    final benefits = job.benefits ?? [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Description ──
        Text(l.sectionDescription, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
        const SizedBox(height: 8),
        Text(description, style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.6)),
        const SizedBox(height: 16),

        // ── Requirements ──
        if (requirements.isNotEmpty) ...[
          Text(l.sectionRequirements, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
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
          Text(l.sectionBenefits, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
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
              _InfoRow(label: l.labelPosted, value: job.posted),
              const Divider(height: 20, color: AppColors.divider),
              _InfoRow(label: l.labelViews, value: '${job.views}'),
              const Divider(height: 20, color: AppColors.divider),
              _InfoRow(label: l.labelSaves, value: '${job.saves}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApplicantsTab(BusinessApplicantsProvider provider, AppLocalizations l) {
    final applicants = _jobApplicants(provider);
    return Column(
      children: [
        // ── Filter chips ──
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _applicantFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _applicantFilters[i];
              final active = f == _applicantFilter;
              return GestureDetector(
                onTap: () {
                  setState(() => _applicantFilter = f);
                  context.read<BusinessApplicantsProvider>().setContext(
                    jobId: widget.jobId,
                    filter: f,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppColors.teal : Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: active ? null : Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text(
                      _applicantFilterLabel(l, f),
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
          child: provider.loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.teal),
                )
              : provider.error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 40,
                            color: AppColors.red,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            provider.error!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context
                                .read<BusinessApplicantsProvider>()
                                .setContext(
                                  jobId: widget.jobId,
                                  filter: _applicantFilter,
                                ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(l.retryAction),
                          ),
                        ],
                      ),
                    )
                  : applicants.isEmpty
              ? Center(
                  child: Text(l.noApplicantsText, style: const TextStyle(color: AppColors.secondary)),
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

  String _applicantFilterLabel(AppLocalizations l, String id) {
    switch (id) {
      case 'All':
        return l.filterAll;
      case 'Applied':
        return l.filterApplied;
      case 'Shortlisted':
        return l.filterShortlisted;
      case 'Interview':
        return l.filterInterview;
      case 'Rejected':
        return l.filterRejected;
      default:
        return id;
    }
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
  final Applicant applicant;
  const _ApplicantRow({required this.applicant});

  Color _avatarColor(String initials) {
    final hue = (initials.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.5, 0.45).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => context.push('/business/applicant/${applicant.id}'),
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
                  backgroundColor: _avatarColor(applicant.initials),
                  child: Text(applicant.initials, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(applicant.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                      Text(applicant.role, style: const TextStyle(fontSize: 12, color: AppColors.secondary)),
                      Text(applicant.experience, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StatusBadge(status: applicant.status.displayName, label: applicant.status.localizedLabel(l)),
                    const SizedBox(height: 4),
                    Text(applicant.date, style: const TextStyle(fontSize: 10, color: AppColors.tertiary)),
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
                  child: Text('\u2713 ${l.quickActionShortlist}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.teal)),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {},
                  child: Text('\u2717 ${l.quickActionReject}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.red)),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {},
                  child: Text('\uD83D\uDCAC ${l.quickActionMessage}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.secondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
