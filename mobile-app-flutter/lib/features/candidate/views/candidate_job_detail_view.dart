import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/repositories/candidate_repository.dart';

class CandidateJobDetailView extends StatefulWidget {
  final String jobId;
  const CandidateJobDetailView({super.key, required this.jobId});

  @override
  State<CandidateJobDetailView> createState() => _CandidateJobDetailViewState();
}

class _CandidateJobDetailViewState extends State<CandidateJobDetailView> {
  int _tabIndex = 0;
  bool _applied = false;
  bool _applying = false;
  Job? _job;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadJob());
  }

  static const _tabLabels = ['Overview', 'Requirements', 'Benefits'];

  Future<void> _loadJob() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final provider = context.read<CandidateJobsProvider>();
    final cached = provider.jobs.cast<Job?>().firstWhere(
      (j) => j?.id == widget.jobId,
      orElse: () => null,
    );

    if (cached != null) {
      setState(() {
        _job = cached;
        _loading = false;
      });
      return;
    }

    try {
      final job = await CandidateRepository().fetchJobDetail(widget.jobId);
      if (!mounted) return;
      setState(() {
        _job = job;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.jobDetailL10n;

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.secondary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.retryAction),
              ),
            ],
          ),
        ),
      );
    }

    final job = _job;
    if (job == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            l10n.jobNotFound,
            style: const TextStyle(fontSize: 14, color: AppColors.secondary),
          ),
        ),
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
                        if (job.featured) _badge(l10n.featuredBadge, AppColors.amber),
                        if (job.urgent) _badge(l10n.urgentBadge, AppColors.red),
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
                              l10n.jobTabLabel(_tabLabels[i]),
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
                            ? Center(child: StatusBadge(status: l10n.appliedStatus, large: true))
                            : ElevatedButton(
                                onPressed: _applying ? null : () => _showApplyDialog(job),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.teal,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: _applying
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(l10n.applyNow,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
    final l10n = context.jobDetailL10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.aboutRole,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
        const SizedBox(height: 10),
        Text(
          job.description ?? '',
          style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.secondary),
        ),
        const SizedBox(height: 20),
        Text(l10n.aboutCompany,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
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
            ],
          ),
        ),
      ],
    );
  }

  // ── Requirements Tab ──
  Widget _buildRequirements(Job job) {
    final l10n = context.jobDetailL10n;
    final items = job.requirements ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.requirementsTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
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
    final l10n = context.jobDetailL10n;
    final items = job.benefits ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.benefitsTitle,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
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
    final l10n = context.jobDetailL10n;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.applyDialogTitle(job.title, job.company),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l10n.applyNoteHint,
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
            child: Text(l10n.cancelAction, style: const TextStyle(color: AppColors.secondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _submitApplication(note: noteController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(l10n.confirmAction),
          ),
        ],
      ),
    );
  }

  Future<void> _submitApplication({String? note}) async {
    final l10n = context.jobDetailL10n;
    setState(() => _applying = true);
    try {
      await CandidateRepository().applyToJob(widget.jobId, note: note?.isEmpty ?? true ? null : note);
      if (!mounted) return;
      setState(() {
        _applying = false;
        _applied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.applicationSent),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _applying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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

extension _CandidateJobDetailL10n on BuildContext {
  _CandidateJobDetailStrings get jobDetailL10n =>
      _CandidateJobDetailStrings(Localizations.localeOf(this).languageCode);
}

class _CandidateJobDetailStrings {
  final String _lang;
  const _CandidateJobDetailStrings(this._lang);

  String get retryAction => _lang == 'it'
      ? 'Riprova'
      : _lang == 'ar'
          ? 'إعادة المحاولة'
          : 'Retry';

  String get jobNotFound => _lang == 'it'
      ? 'Offerta non trovata'
      : _lang == 'ar'
          ? 'الوظيفة غير موجودة'
          : 'Job not found';

  String get featuredBadge => _lang == 'it'
      ? 'In evidenza'
      : _lang == 'ar'
          ? 'مميز'
          : 'Featured';

  String get urgentBadge => _lang == 'it'
      ? 'Urgente'
      : _lang == 'ar'
          ? 'عاجل'
          : 'Urgent';

  String get appliedStatus => _lang == 'it'
      ? 'Candidatura inviata'
      : _lang == 'ar'
          ? 'تم التقديم'
          : 'Applied';

  String get applyNow => _lang == 'it'
      ? 'Candidati ora'
      : _lang == 'ar'
          ? 'قدّم الآن'
          : 'Apply Now';

  String get aboutRole => _lang == 'it'
      ? 'Informazioni sul ruolo'
      : _lang == 'ar'
          ? 'حول هذا الدور'
          : 'About this role';

  String get aboutCompany => _lang == 'it'
      ? 'Informazioni sull’azienda'
      : _lang == 'ar'
          ? 'حول الشركة'
          : 'About the company';

  String get requirementsTitle => _lang == 'it'
      ? 'Requisiti'
      : _lang == 'ar'
          ? 'المتطلبات'
          : 'Requirements';

  String get benefitsTitle => _lang == 'it'
      ? 'Benefit'
      : _lang == 'ar'
          ? 'المزايا'
          : 'Benefits';

  String get applyNoteHint => _lang == 'it'
      ? 'Aggiungi una nota (opzionale)'
      : _lang == 'ar'
          ? 'أضف ملاحظة (اختياري)'
          : 'Add a note (optional)';

  String get cancelAction => _lang == 'it'
      ? 'Annulla'
      : _lang == 'ar'
          ? 'إلغاء'
          : 'Cancel';

  String get confirmAction => _lang == 'it'
      ? 'Conferma'
      : _lang == 'ar'
          ? 'تأكيد'
          : 'Confirm';

  String get applicationSent => _lang == 'it'
      ? 'Candidatura inviata!'
      : _lang == 'ar'
          ? 'تم إرسال الطلب!'
          : 'Application sent!';

  String jobTabLabel(String key) {
    switch (key) {
      case 'Overview':
        return _lang == 'it'
            ? 'Panoramica'
            : _lang == 'ar'
                ? 'نظرة عامة'
                : 'Overview';
      case 'Requirements':
        return requirementsTitle;
      case 'Benefits':
        return benefitsTitle;
      default:
        return key;
    }
  }

  String applyDialogTitle(String title, String company) => _lang == 'it'
      ? 'Candidarti per $title presso $company?'
      : _lang == 'ar'
          ? 'التقديم على $title لدى $company؟'
          : 'Apply for $title at $company?';
}
