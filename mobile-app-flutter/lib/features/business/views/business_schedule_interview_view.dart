import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/business_providers.dart';

/// Schedule interview form — all mock, no API calls.
class BusinessScheduleInterviewView extends StatefulWidget {
  final String candidateId;
  final String candidateName;
  final String jobTitle;

  const BusinessScheduleInterviewView({
    super.key,
    this.candidateId = '',
    this.candidateName = 'Yuki Tanaka',
    this.jobTitle = 'Waiter',
  });

  @override
  State<BusinessScheduleInterviewView> createState() =>
      _BusinessScheduleInterviewViewState();
}

class _BusinessScheduleInterviewViewState
    extends State<BusinessScheduleInterviewView> {
  final _locationCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _format = 'In Person';
  bool _submitting = false;

  bool get _canSubmit =>
      !_submitting && _selectedDate != null && _selectedTime != null;

  bool get _isArabic =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _candidateLabel() => _isArabic ? 'المرشح' : 'it' == Localizations.localeOf(context).languageCode ? 'Candidato' : 'Candidate';

  String _jobLabel() => _isArabic ? 'الوظيفة' : 'it' == Localizations.localeOf(context).languageCode ? 'Ruolo' : 'Job';

  String _meetingLinkLabel() => _isArabic ? 'رابط الاجتماع' : 'it' == Localizations.localeOf(context).languageCode ? 'Link meeting' : 'Meeting Link';

  String _selectCandidateLabel() =>
      _isArabic ? 'اختر المرشح' : 'it' == Localizations.localeOf(context).languageCode ? 'Seleziona candidato' : 'Select candidate';

  String _selectDateLabel() =>
      _isArabic ? 'اختر التاريخ' : 'it' == Localizations.localeOf(context).languageCode ? 'Seleziona data' : 'Select date';

  String _selectTimeLabel() =>
      _isArabic ? 'اختر الوقت' : 'it' == Localizations.localeOf(context).languageCode ? 'Seleziona orario' : 'Select time';

  String _interviewFormatLabel() =>
      _isArabic ? 'نوع المقابلة' : 'it' == Localizations.localeOf(context).languageCode ? 'Modalità colloquio' : 'Interview Format';

  String _notesInstructionsLabel() =>
      _isArabic ? 'ملاحظات / تعليمات' : 'it' == Localizations.localeOf(context).languageCode ? 'Note / Istruzioni' : 'Notes / Instructions';

  String _locationHint() =>
      _isArabic ? 'أدخل موقع المقابلة' : 'it' == Localizations.localeOf(context).languageCode ? 'Inserisci luogo del colloquio' : 'Enter interview location';

  String _meetingLinkHint() =>
      _isArabic ? 'ألصق رابط الاجتماع' : 'it' == Localizations.localeOf(context).languageCode ? 'Incolla il link del meeting' : 'Paste meeting link';

  String _notesHint() =>
      _isArabic ? 'أضف أي ملاحظات للمرشح...' : 'it' == Localizations.localeOf(context).languageCode ? 'Aggiungi eventuali note per il candidato...' : 'Add any notes for the candidate...';

  String _formatOptionLabel(String value) {
    return switch (value) {
      'In Person' => _isArabic ? 'حضوري' : 'it' == Localizations.localeOf(context).languageCode ? 'In presenza' : 'In Person',
      'Video' => _isArabic ? 'فيديو' : 'it' == Localizations.localeOf(context).languageCode ? 'Video' : 'Video',
      'Phone' => _isArabic ? 'هاتف' : 'it' == Localizations.localeOf(context).languageCode ? 'Telefono' : 'Phone',
      _ => value,
    };
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  DateTime _scheduledAt() {
    final date = _selectedDate!;
    final time = _selectedTime!;
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    final scheduledAt = _scheduledAt();
    final payload = <String, dynamic>{
      'candidateId': widget.candidateId,
      'candidateName': widget.candidateName,
      'jobTitle': widget.jobTitle,
      'date': _formatDate(scheduledAt),
      'time': _formatTime(TimeOfDay.fromDateTime(scheduledAt)),
      'format': _format,
      'type': _format,
      'interview_type': _format,
      'scheduledAt': scheduledAt.toIso8601String(),
      'scheduled_at': scheduledAt.toIso8601String(),
      'status': 'Invited',
      'notes': _notesCtrl.text.trim(),
    };

    final location = _locationCtrl.text.trim();
    final link = _linkCtrl.text.trim();
    if (location.isNotEmpty) payload['location'] = location;
    if (link.isNotEmpty) {
      payload['link'] = link;
      payload['meeting_link'] = link;
    }

    try {
      await context.read<BusinessInterviewsProvider>().scheduleInterview(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).interviewSent),
          backgroundColor: AppColors.teal,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _formatDate(DateTime d) {
    final months = _isArabic
        ? const ['ينا', 'فبر', 'مار', 'أبر', 'ماي', 'يون', 'يول', 'أغس', 'سبت', 'أكت', 'نوف', 'ديس']
        : 'it' == Localizations.localeOf(context).languageCode
            ? const ['Gen', 'Feb', 'Mar', 'Apr', 'Mag', 'Giu', 'Lug', 'Ago', 'Set', 'Ott', 'Nov', 'Dic']
            : const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = _isArabic
        ? const ['الاث', 'الثل', 'الأر', 'الخم', 'الجم', 'السب', 'الأحد']
        : 'it' == Localizations.localeOf(context).languageCode
            ? const ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom']
            : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final min = t.minute.toString().padLeft(2, '0');
    final period = _isArabic
        ? (t.period == DayPeriod.am ? 'ص' : 'م')
        : t.period == DayPeriod.am
            ? 'AM'
            : 'PM';
    return '$hour:$min $period';
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    _linkCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
          l.scheduleInterviewTitle,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Candidate
            Text(
              _candidateLabel(),
              style: TextStyle(fontSize: 12, color: AppColors.secondary),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                widget.candidateName.isNotEmpty
                    ? widget.candidateName
                    : _selectCandidateLabel(),
                style: TextStyle(
                  fontSize: 15,
                  color: widget.candidateName.isNotEmpty
                      ? AppColors.charcoal
                      : AppColors.tertiary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Job
            Text(
              _jobLabel(),
              style: TextStyle(fontSize: 12, color: AppColors.secondary),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                widget.jobTitle,
                style: const TextStyle(fontSize: 15, color: AppColors.charcoal),
              ),
            ),
            const SizedBox(height: 16),

            // Date
            Text(
              l.dateLabel,
              style: TextStyle(fontSize: 12, color: AppColors.secondary),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 10),
                    Text(
                      _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : _selectDateLabel(),
                      style: TextStyle(
                        fontSize: 15,
                        color: _selectedDate != null
                            ? AppColors.charcoal
                            : AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Time
            Text(
              l.timeLabel,
              style: TextStyle(fontSize: 12, color: AppColors.secondary),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 10),
                    Text(
                      _selectedTime != null
                          ? _formatTime(_selectedTime!)
                          : _selectTimeLabel(),
                      style: TextStyle(
                        fontSize: 15,
                        color: _selectedTime != null
                            ? AppColors.charcoal
                            : AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Interview Format
            Text(
              _interviewFormatLabel(),
              style: TextStyle(fontSize: 12, color: AppColors.secondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['In Person', 'Video', 'Phone'].map((label) {
                final selected = _format == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _format = label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.teal : Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: selected
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _formatOptionLabel(label),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Conditional: Location or Meeting Link
            if (_format == 'In Person') ...[
              Text(
                l.locationLabel,
                style: TextStyle(fontSize: 12, color: AppColors.secondary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  hintText: _locationHint(),
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.tertiary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.teal),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_format == 'Video') ...[
              Text(
                _meetingLinkLabel(),
                style: TextStyle(fontSize: 12, color: AppColors.secondary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _linkCtrl,
                decoration: InputDecoration(
                  hintText: _meetingLinkHint(),
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.tertiary),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.teal),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            Text(
              _notesInstructionsLabel(),
              style: TextStyle(fontSize: 12, color: AppColors.secondary),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _notesCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: _notesHint(),
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.tertiary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.teal),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _canSubmit ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.4),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        l.sendInviteCta,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
