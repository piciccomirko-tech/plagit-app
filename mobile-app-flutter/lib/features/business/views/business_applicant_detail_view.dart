import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
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

  String _localText({
    required String en,
    required String it,
    required String ar,
  }) {
    final code = Localizations.localeOf(context).languageCode;
    if (code == 'it') return it;
    if (code == 'ar') return ar;
    return en;
  }

  String _applicantTitle() =>
      _localText(en: 'Applicant', it: 'Candidato', ar: 'المتقدم');

  String _retryLabel() => _localText(en: 'Retry', it: 'Riprova', ar: 'إعادة المحاولة');

  String _rejectApplicantTitle() => _localText(
        en: 'Reject Applicant',
        it: 'Rifiuta candidato',
        ar: 'رفض المتقدم',
      );

  String _rejectApplicantConfirm(String name) => _localText(
        en: 'Are you sure you want to reject $name?',
        it: 'Vuoi davvero rifiutare $name?',
        ar: 'هل تريد بالتأكيد رفض $name؟',
      );

  String _rejectActionLabel() =>
      _localText(en: 'Reject', it: 'Rifiuta', ar: 'رفض');

  String _shortlistLabel() =>
      _localText(en: 'Shortlist', it: 'Shortlist', ar: 'القائمة المختصرة');

  String _messageLabel() =>
      _localText(en: 'Message', it: 'Messaggio', ar: 'رسالة');

  String _interviewLabel() =>
      _localText(en: 'Interview', it: 'Colloquio', ar: 'مقابلة');

  String _aboutLabel() => _localText(en: 'About', it: 'Profilo', ar: 'نبذة');

  String _experienceLabel() =>
      _localText(en: 'Experience', it: 'Esperienza', ar: 'الخبرة');

  String _previousEmployerLabel() => _localText(
        en: 'Previous Employer',
        it: 'Datore di lavoro precedente',
        ar: 'صاحب العمل السابق',
      );

  String _earlierVenueLabel() => _localText(
        en: 'Earlier Venue',
        it: 'Struttura precedente',
        ar: 'مكان عمل سابق',
      );

  String _skillsLabel() => _localText(en: 'Skills', it: 'Competenze', ar: 'المهارات');

  String _customerServiceLabel() => _localText(
        en: 'Customer Service',
        it: 'Servizio clienti',
        ar: 'خدمة العملاء',
      );

  String _teamworkLabel() =>
      _localText(en: 'Teamwork', it: 'Lavoro di squadra', ar: 'العمل الجماعي');

  String _communicationLabel() =>
      _localText(en: 'Communication', it: 'Comunicazione', ar: 'التواصل');

  String _languagesLabel() =>
      _localText(en: 'Languages', it: 'Lingue', ar: 'اللغات');

  String _availabilityLabel() =>
      _localText(en: 'Availability', it: 'Disponibilità', ar: 'التوفر');

  String _salaryExpectationLabel() => _localText(
        en: 'Salary Expectation',
        it: 'Aspettativa salariale',
        ar: 'الراتب المتوقع',
      );

  String _cvLabel() => 'CV';

  String _viewCvLabel() =>
      _localText(en: 'View CV', it: 'Apri CV', ar: 'عرض السيرة الذاتية');

  String _applicationSectionLabel() =>
      _localText(en: 'Application', it: 'Candidatura', ar: 'الترشح');

  String _appliedToLabel(Applicant a) => _localText(
        en: 'Applied to ${a.role} on ${a.date}',
        it: 'Candidatura per ${a.role} il ${a.date}',
        ar: 'تم التقديم إلى ${a.role} في ${a.date}',
      );

  String _timelineSectionLabel() =>
      _localText(en: 'Timeline', it: 'Timeline', ar: 'الجدول الزمني');

  String _appliedLabel() =>
      _localText(en: 'Applied', it: 'Candidatura inviata', ar: 'تم التقديم');

  String _viewedLabel() =>
      _localText(en: 'Viewed', it: 'Visualizzato', ar: 'تمت المشاهدة');

  String _pendingReviewLabel() => _localText(
        en: 'Pending Review',
        it: 'In attesa di revisione',
        ar: 'بانتظار المراجعة',
      );

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

  Future<void> _openApplicantMessages(Applicant applicant) async {
    final provider = context.read<BusinessMessagesProvider>();
    if (provider.conversations.isEmpty && !provider.loading) {
      try {
        await provider.load();
      } catch (_) {
        // Fall back to the messages area below.
      }
    }
    if (!mounted) return;
    final conversation = provider.conversations
        .where(
          (c) =>
              (applicant.candidateId?.isNotEmpty == true &&
                  c.candidateId == applicant.candidateId) ||
              c.candidateName.toLowerCase() == applicant.name.toLowerCase(),
        )
        .firstOrNull;
    if (conversation != null) {
      context.push('/business/chat/${conversation.id}');
      return;
    }
    context.push('/business/messages');
  }

  void _confirmReject(String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_rejectApplicantTitle()),
        content: Text(_rejectApplicantConfirm(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context).cancelAction),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BusinessApplicantsProvider>().reject(widget.applicantId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$name rejected'), duration: const Duration(seconds: 1)),
              );
            },
            child: Text(
              _rejectActionLabel(),
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
            title: Text(_applicantTitle(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
            title: Text(_applicantTitle(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
            title: Text(_applicantTitle(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
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
                  child: Text(_retryLabel()),
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
          title: Text(_applicantTitle(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        ),
        body: Center(
          child: Text(
            AppLocalizations.of(context).applicantNotFound,
            style: const TextStyle(color: AppColors.secondary),
          ),
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
                  label: _shortlisting ? '...' : _shortlistLabel(),
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
                  label: _messageLabel(),
                  color: AppColors.teal,
                  filled: false,
                  onTap: () => _openApplicantMessages(a),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionBtn(
                  icon: Icons.calendar_today_outlined,
                  label: _interviewLabel(),
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
                  label: _rejectActionLabel(),
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
            title: _aboutLabel(),
            child: Text(a.bio ?? '', style: const TextStyle(fontSize: 14, color: AppColors.secondary, height: 1.6)),
          ),
          const SizedBox(height: 12),

          // -- B. Experience --
          _SectionCard(
            title: _experienceLabel(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.experience, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                const SizedBox(height: 10),
                _ExperienceItem(
                  title: a.role,
                  company: _previousEmployerLabel(),
                  period: '2023 - Present',
                ),
                const Divider(height: 16, color: AppColors.divider),
                _ExperienceItem(
                  title: a.role,
                  company: _earlierVenueLabel(),
                  period: '2021 - 2023',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // -- C. Skills --
          _SectionCard(
            title: _skillsLabel(),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                a.role,
                _customerServiceLabel(),
                _teamworkLabel(),
                _communicationLabel(),
              ]
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
            title: _languagesLabel(),
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
            title: _availabilityLabel(),
            child: Text(a.availability ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
          ),
          const SizedBox(height: 12),

          // -- F. Salary Expectation --
          _SectionCard(
            title: _salaryExpectationLabel(),
            child: Text(a.salaryExpectation ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal)),
          ),
          const SizedBox(height: 12),

          // -- CV section --
          _SectionCard(
            title: _cvLabel(),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context).cvViewerComingSoon),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                icon: const Icon(Icons.description_outlined, size: 18),
                label: Text(_viewCvLabel()),
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
                Text(_applicationSectionLabel(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                const SizedBox(height: 10),
                Text(
                  _appliedToLabel(a),
                  style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                ),
                const SizedBox(height: 8),
                StatusBadge(status: a.status.displayName, label: a.status.localizedLabel(l)),
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
                Text(_timelineSectionLabel(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
                const SizedBox(height: 12),
                _TimelineStep(label: _appliedLabel(), done: true),
                _TimelineStep(label: _viewedLabel(), done: true),
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
        return _shortlistLabel();
      case 'Interview Scheduled':
        return _localText(
          en: 'Interview Scheduled',
          it: 'Colloquio fissato',
          ar: 'تم تحديد المقابلة',
        );
      case 'Rejected':
        return _rejectActionLabel();
      case 'Under Review':
        return _localText(
          en: 'Under Review',
          it: 'In revisione',
          ar: 'قيد المراجعة',
        );
      default:
        return _pendingReviewLabel();
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
