import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/network/api_error.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/models/application.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/repositories/candidate_repository.dart';

class CandidateApplicationDetailView extends StatefulWidget {
  final String applicationId;
  final CandidateRepository? repo;

  const CandidateApplicationDetailView({
    super.key,
    required this.applicationId,
    this.repo,
  });

  @override
  State<CandidateApplicationDetailView> createState() =>
      _CandidateApplicationDetailViewState();
}

class _CandidateApplicationDetailViewState
    extends State<CandidateApplicationDetailView> {
  Application? _application;
  bool _loading = true;
  String? _error;
  bool _notFound = false;

  CandidateRepository get _repo => widget.repo ?? CandidateRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadApplication());
  }

  Future<void> _loadApplication() async {
    setState(() {
      _loading = true;
      _error = null;
      _notFound = false;
    });

    final provider = context.read<CandidateApplicationsProvider>();
    final cached = provider.applications.cast<Application?>().firstWhere(
      (a) => a?.id == widget.applicationId,
      orElse: () => null,
    );

    if (cached != null) {
      setState(() {
        _application = cached;
        _loading = false;
      });
      return;
    }

    try {
      final app = await _repo.fetchApplicationDetail(widget.applicationId);
      if (!mounted) return;
      setState(() {
        _application = app;
        _loading = false;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (e.type == ApiErrorType.notFound) {
          _notFound = true;
        } else {
          _error = e.message;
        }
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
    final l10n = context.applicationDetailL10n;
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.teal),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l10n.applicationTitle),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
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
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadApplication,
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

    if (_notFound || _application == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l10n.applicationTitle),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Text(
            l10n.applicationNotFound,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondary,
            ),
          ),
        ),
      );
    }

    final app = _application!;
    final rawStatus = app.status.displayName;
    final statusText = l10n.statusLabel(rawStatus);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.applicationTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: AppColors.cardDecoration,
              child: Column(
                children: [
                  Text(
                    app.jobTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${app.company} · ${app.location}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    app.salary ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(child: StatusBadge(status: statusText, large: true)),
            const SizedBox(height: 8),
            Text(
              l10n.appliedDate(app.date),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 28),
            _TimelineSection(status: rawStatus),
            const SizedBox(height: 20),
            _WhatHappensNextCard(status: rawStatus),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final String status;
  const _TimelineSection({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = context.applicationDetailL10n;
    final steps = _buildSteps();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.applicationTimelineTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isLast = i == steps.length - 1;
            return _TimelineItem(
              label: l10n.statusLabel(step['label'] as String),
              state: step['state'] as _StepState,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildSteps() {
    const labels = [
      'Applied',
      'Under Review',
      'Shortlisted',
      'Interview Scheduled',
      'Final Status',
    ];

    int completedCount;
    bool rejected = false;
    switch (status.toLowerCase()) {
      case 'applied':
        completedCount = 1;
        break;
      case 'under review':
        completedCount = 2;
        break;
      case 'shortlisted':
        completedCount = 3;
        break;
      case 'interview scheduled':
        completedCount = 4;
        break;
      case 'rejected':
        completedCount = 2;
        rejected = true;
        break;
      default:
        completedCount = 1;
    }

    return List.generate(labels.length, (i) {
      _StepState state;
      if (rejected && i == labels.length - 1) {
        state = _StepState.rejected;
      } else if (i < completedCount) {
        state = _StepState.complete;
      } else {
        state = _StepState.incomplete;
      }
      return {'label': labels[i], 'state': state};
    });
  }
}

enum _StepState { complete, incomplete, rejected }

class _TimelineItem extends StatelessWidget {
  final String label;
  final _StepState state;
  final bool isLast;

  const _TimelineItem({
    required this.label,
    required this.state,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final isComplete = state == _StepState.complete;
    final isRejected = state == _StepState.rejected;
    final circleColor = isComplete
        ? AppColors.green
        : isRejected
            ? AppColors.red
            : AppColors.border;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isComplete || isRejected
                        ? circleColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: circleColor,
                      width: 2,
                    ),
                  ),
                  child: isComplete
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : isRejected
                          ? const Icon(Icons.close, size: 14, color: Colors.white)
                          : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isComplete ? AppColors.green : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isComplete ? FontWeight.w600 : FontWeight.w400,
                color: isComplete
                    ? AppColors.charcoal
                    : isRejected
                        ? AppColors.red
                        : AppColors.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhatHappensNextCard extends StatelessWidget {
  final String status;
  const _WhatHappensNextCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = context.applicationDetailL10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: AppColors.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whatHappensNextTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.whatHappensNextBody(status),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.secondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

extension _ApplicationDetailL10n on BuildContext {
  _ApplicationDetailStrings get applicationDetailL10n =>
      _ApplicationDetailStrings(Localizations.localeOf(this).languageCode);
}

class _ApplicationDetailStrings {
  final String _lang;
  const _ApplicationDetailStrings(this._lang);

  String get applicationTitle => _lang == 'it'
      ? 'Candidatura'
      : _lang == 'ar'
          ? 'الطلب'
          : 'Application';

  String get retryAction => _lang == 'it'
      ? 'Riprova'
      : _lang == 'ar'
          ? 'إعادة المحاولة'
          : 'Retry';

  String get applicationNotFound => _lang == 'it'
      ? 'Candidatura non trovata'
      : _lang == 'ar'
          ? 'الطلب غير موجود'
          : 'Application not found';

  String appliedDate(String date) => _lang == 'it'
      ? 'Candidatura inviata $date'
      : _lang == 'ar'
          ? 'تم التقديم $date'
          : 'Applied $date';

  String get applicationTimelineTitle => _lang == 'it'
      ? 'Cronologia candidatura'
      : _lang == 'ar'
          ? 'الجدول الزمني للطلب'
          : 'Application Timeline';

  String get whatHappensNextTitle => _lang == 'it'
      ? 'Cosa succede ora'
      : _lang == 'ar'
          ? 'ماذا يحدث بعد ذلك'
          : 'What happens next';

  String statusLabel(String value) {
    switch (value) {
      case 'Applied':
        return _lang == 'it'
            ? 'Inviata'
            : _lang == 'ar'
                ? 'تم التقديم'
                : 'Applied';
      case 'Under Review':
        return _lang == 'it'
            ? 'In revisione'
            : _lang == 'ar'
                ? 'قيد المراجعة'
                : 'Under Review';
      case 'Shortlisted':
        return _lang == 'it'
            ? 'Selezionata'
            : _lang == 'ar'
                ? 'ضمن القائمة المختصرة'
                : 'Shortlisted';
      case 'Interview Scheduled':
        return _lang == 'it'
            ? 'Colloquio fissato'
            : _lang == 'ar'
                ? 'تم تحديد المقابلة'
                : 'Interview Scheduled';
      case 'Final Status':
        return _lang == 'it'
            ? 'Stato finale'
            : _lang == 'ar'
                ? 'الحالة النهائية'
                : 'Final Status';
      case 'Rejected':
        return _lang == 'it'
            ? 'Rifiutata'
            : _lang == 'ar'
                ? 'مرفوض'
                : 'Rejected';
      default:
        return value;
    }
  }

  String whatHappensNextBody(String status) {
    switch (status) {
      case 'Applied':
      case 'Inviata':
      case 'تم التقديم':
        return _lang == 'it'
            ? 'La tua candidatura è stata inviata con successo.'
            : _lang == 'ar'
                ? 'تم إرسال طلبك بنجاح.'
                : 'Your application was submitted successfully.';
      case 'Under Review':
      case 'In revisione':
      case 'قيد المراجعة':
        return _lang == 'it'
            ? 'La tua candidatura è attualmente in revisione.'
            : _lang == 'ar'
                ? 'طلبك قيد المراجعة حاليًا.'
                : 'Your application is currently under review.';
      case 'Shortlisted':
      case 'Selezionata':
      case 'ضمن القائمة المختصرة':
        return _lang == 'it'
            ? 'La tua candidatura è stata selezionata.'
            : _lang == 'ar'
                ? 'تم إدراج طلبك ضمن القائمة المختصرة.'
                : 'Your application has been shortlisted.';
      case 'Interview Scheduled':
      case 'Colloquio fissato':
      case 'تم تحديد المقابلة':
        return _lang == 'it'
            ? 'La tua candidatura è passata alla fase di colloquio.'
            : _lang == 'ar'
                ? 'انتقل طلبك إلى مرحلة المقابلة.'
                : 'Your application has progressed to an interview stage.';
      case 'Rejected':
      case 'Rifiutata':
      case 'مرفوض':
        return _lang == 'it'
            ? 'Questa candidatura non è più attiva.'
            : _lang == 'ar'
                ? 'هذا الطلب لم يعد نشطًا.'
                : 'This application is no longer active.';
      default:
        return _lang == 'it'
            ? 'Lo stato della tua candidatura è disponibile qui.'
            : _lang == 'ar'
                ? 'حالة طلبك متاحة هنا.'
                : 'Your application status is available here.';
    }
  }
}
