import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/business_interview.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

/// Business interview detail screen.
class BusinessInterviewDetailView extends StatefulWidget {
  final String interviewId;
  const BusinessInterviewDetailView({super.key, required this.interviewId});

  @override
  State<BusinessInterviewDetailView> createState() =>
      _BusinessInterviewDetailViewState();
}

class _BusinessInterviewDetailViewState
    extends State<BusinessInterviewDetailView> {
  String? _localStatusOverride;
  bool _completing = false;

  bool get _isArabic =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  bool get _isItalian =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'it';

  String _localText({
    required String en,
    required String it,
    required String ar,
  }) => _isArabic ? ar : _isItalian ? it : en;

  String _effectiveStatus(BusinessInterview iv) =>
      _localStatusOverride ?? iv.status;

  Color _avatarColor(String name) {
    final hue = (name.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.45).toColor();
  }

  void _confirmInterview() {
    setState(() => _localStatusOverride = 'Confirmed');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).interviewConfirmed),
        backgroundColor: AppColors.teal,
      ),
    );
  }

  Future<void> _markCompleted() async {
    if (_completing) return;
    setState(() => _completing = true);
    try {
      await context.read<BusinessInterviewsProvider>().markInterviewComplete(
        widget.interviewId,
      );
      if (!mounted) return;
      setState(() => _localStatusOverride = 'Completed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).interviewMarkedCompleted),
          backgroundColor: AppColors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  void _cancelInterview() {
    final l = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _localText(
            en: 'Cancel Interview',
            it: 'Annulla colloquio',
            ar: 'إلغاء المقابلة',
          ),
        ),
        content: Text(l.cancelInterviewConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              _localText(en: 'No', it: 'No', ar: 'لا'),
              style: const TextStyle(color: AppColors.secondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.pop();
            },
            child: Text(
              _localText(
                en: 'Yes, Cancel',
                it: 'Sì, annulla',
                ar: 'نعم، إلغاء',
              ),
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessInterviewsProvider>();
    final BusinessInterview? interview = provider.interviews
        .where((i) => i.id == widget.interviewId)
        .firstOrNull;

    // Not found / loading
    if (interview == null) {
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
            _localText(
              en: 'Interview Details',
              it: 'Dettagli colloquio',
              ar: 'تفاصيل المقابلة',
            ),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          centerTitle: true,
        ),
        body: provider.loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.teal))
            : Center(
                child: Text(AppLocalizations.of(context).interviewNotFound, style: const TextStyle(color: AppColors.secondary)),
              ),
      );
    }

    final status = _effectiveStatus(interview);
    final isVideo = interview.format == 'Video';
    final isInPerson = interview.format == 'In Person';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const BackChevron(size: 28, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _localText(
            en: 'Interview Details',
            it: 'Dettagli colloquio',
            ar: 'تفاصيل المقابلة',
          ),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Large status badge centered
            Center(child: StatusBadge(status: status, large: true)),
            const SizedBox(height: 20),

            // Candidate info card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _avatarColor(interview.candidateName),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      interview.candidateInitials,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          interview.candidateName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.charcoal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          interview.jobTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interview details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Column(
                children: [
                  _infoRow(
                    Icons.calendar_today,
                    AppColors.teal,
                    AppLocalizations.of(context).dateLabel,
                    interview.date,
                  ),
                  const Divider(height: 20, color: AppColors.divider),
                  _infoRow(
                    Icons.access_time,
                    AppColors.purple,
                    AppLocalizations.of(context).timeLabel,
                    interview.time,
                  ),
                  const Divider(height: 20, color: AppColors.divider),
                  _infoRow(
                    isVideo
                        ? Icons.videocam
                        : isInPerson
                            ? Icons.place
                            : Icons.phone,
                    AppColors.amber,
                    AppLocalizations.of(context).formatLabel,
                    interview.format,
                  ),
                  if (isVideo && interview.link != null) ...[
                    const Divider(height: 20, color: AppColors.divider),
                    Row(
                      children: [
                        const Icon(Icons.link, size: 20, color: AppColors.teal),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _localText(
                                en: 'Meeting Link',
                                it: 'Link meeting',
                                ar: 'رابط الاجتماع',
                              ),
                              style: const TextStyle(fontSize: 12, color: AppColors.secondary),
                            ),
                            const SizedBox(height: 2),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context).openingMeetingLink),
                                    backgroundColor: AppColors.teal,
                                  ),
                                );
                              },
                              child: Text(
                                _localText(
                                  en: 'Join meeting',
                                  it: 'Partecipa al meeting',
                                  ar: 'انضم إلى الاجتماع',
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                  if (isInPerson && interview.location != null) ...[
                    const Divider(height: 20, color: AppColors.divider),
                    _infoRow(
                      Icons.place,
                      AppColors.green,
                      AppLocalizations.of(context).locationLabel,
                      interview.location ?? '',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes card
            if (interview.notes != null)
              Container(
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
                    Text(
                      _localText(
                        en: 'Notes',
                        it: 'Note',
                        ar: 'ملاحظات',
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      interview.notes ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.secondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Action buttons based on status
            if (status == 'Invited') ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _confirmInterview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _localText(
                      en: 'Confirm Interview',
                      it: 'Conferma colloquio',
                      ar: 'تأكيد المقابلة',
                    ),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).rescheduleComingSoon),
                        backgroundColor: AppColors.teal,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _localText(
                      en: 'Reschedule',
                      it: 'Riprogramma',
                      ar: 'إعادة الجدولة',
                    ),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _cancelInterview,
                  child: Text(
                    AppLocalizations.of(context).cancelAction,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ),
            ],

            if (status == 'Confirmed') ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _localText(
                            en: 'Notes feature coming soon',
                            it: 'Funzione note in arrivo',
                            ar: 'ميزة الملاحظات قريبًا',
                          ),
                        ),
                        backgroundColor: AppColors.teal,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _localText(
                      en: 'Add Notes',
                      it: 'Aggiungi note',
                      ar: 'إضافة ملاحظات',
                    ),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _completing ? null : _markCompleted,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _completing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.teal),
                          ),
                        )
                      : Text(
                          _localText(
                            en: 'Mark as Completed',
                            it: 'Segna come completato',
                            ar: 'تحديد كمكتملة',
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _cancelInterview,
                  child: Text(
                    _localText(
                      en: 'Cancel Interview',
                      it: 'Annulla colloquio',
                      ar: 'إلغاء المقابلة',
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.red,
                    ),
                  ),
                ),
              ),
            ],

            if (status == 'Completed') ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).candidateMarkedHired),
                        backgroundColor: AppColors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _localText(
                      en: 'Mark as Hired',
                      it: 'Segna come assunto',
                      ar: 'تحديد كتم التوظيف',
                    ),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context).feedbackComingSoon),
                        backgroundColor: AppColors.teal,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _localText(
                      en: 'Send Feedback',
                      it: 'Invia feedback',
                      ar: 'إرسال الملاحظات',
                    ),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, Color iconColor, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: AppColors.secondary),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
