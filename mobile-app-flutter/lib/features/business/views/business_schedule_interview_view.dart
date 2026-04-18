import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/providers/business_providers.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

const _tealMain = Color(0xFF00B5B0);
const _tealDark = Color(0xFF009490);
const _bgMain = Color(0xFFF6F7F8);
const _cardBg = Color(0xFFFFFFFF);
const _surface = Color(0xFFF9FAFB);
const _charcoal = Color(0xFF1A1C24);
const _secondary = Color(0xFF707580);
const _tertiary = Color(0xFF9EA3AD);
const _border = Color(0xFFE6E8ED);
const _urgent = Color(0xFFF55748);

BoxShadow get _cardShadow => BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 5));
BoxShadow get _subtleShadow => BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3));

const _types = ['Video Call', 'Phone', 'In Person'];
const _timezones = ['UTC', 'GST', 'GMT', 'CET', 'EST', 'PST'];

class BusinessScheduleInterviewView extends StatefulWidget {
  const BusinessScheduleInterviewView({super.key});
  @override
  State<BusinessScheduleInterviewView> createState() => _BusinessScheduleInterviewViewState();
}

class _BusinessScheduleInterviewViewState extends State<BusinessScheduleInterviewView> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  int _selectedType = 0;
  int _selectedTz = 2; // GMT
  final _linkCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _linkCtrl.dispose(); _locationCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<BusinessInterviewsProvider>().scheduleInterview({
        'date': '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        'time': '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
        'format': _types[_selectedType],
        'timezone': _timezones[_selectedTz],
        'link': _linkCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
      });
      if (mounted) {
        showDialog(context: context, builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(AppLocalizations.of(context).interviewSentTitle, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          content: Text(AppLocalizations.of(context).interviewSentSubtitle, style: const TextStyle(fontSize: 15, color: _secondary)),
          actions: [TextButton(onPressed: () { Navigator.pop(ctx); context.pop(); }, child: Text(AppLocalizations.of(context).okAction, style: TextStyle(color: _tealMain, fontWeight: FontWeight.w600)))],
        ));
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: _bgMain, body: SafeArea(child: Column(children: [
      // Header
      Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: Row(children: [
        GestureDetector(onTap: () => context.pop(), child: Container(width: 36, height: 36, decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.chevron_left, size: 28, color: _charcoal))),
        const SizedBox(width: 12),
        Text(AppLocalizations.of(context).scheduleInterviewTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _charcoal)),
      ])),

      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.only(top: 20), child: Column(children: [
        // CANDIDATE CARD
        Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border.withValues(alpha: 0.5)), boxShadow: [_subtleShadow]),
          child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: _tealMain.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.person, size: 20, color: _tealMain)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppLocalizations.of(context).candidate, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _charcoal)),
              const SizedBox(height: 2),
              Text(AppLocalizations.of(context).forOpenPosition, style: const TextStyle(fontSize: 13, color: _secondary)),
            ])),
            const Icon(Icons.chevron_right, size: 28, color: _tertiary),
          ])),
        const SizedBox(height: 16),

        // FORM CARD
        Container(margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border.withValues(alpha: 0.5)), boxShadow: [_cardShadow]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Date & Time
            Text(AppLocalizations.of(context).dateAndTimeUpper, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _tertiary, letterSpacing: 0.8)), const SizedBox(height: 10),
            GestureDetector(onTap: () async {
              final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
              if (!context.mounted) return;
              if (d != null) setState(() => _selectedDate = d);
              final t = await showTimePicker(context: context, initialTime: _selectedTime);
              if (!context.mounted) return;
              if (t != null) setState(() => _selectedTime = t);
            }, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13), decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: _border.withValues(alpha: 0.5))),
              child: Row(children: [
                Icon(Icons.calendar_today, size: 15, color: _tealMain),
                const SizedBox(width: 10),
                Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at ${_selectedTime.format(context)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _charcoal)),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 28, color: _tertiary),
              ]))),
            const SizedBox(height: 20),

            // Type chips
            Text(AppLocalizations.of(context).interviewTypeUpper, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _tertiary, letterSpacing: 0.8)), const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: List.generate(_types.length, (i) {
              final active = _selectedType == i;
              return GestureDetector(onTap: () => setState(() => _selectedType = i),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9), decoration: BoxDecoration(color: active ? _tealMain : Colors.white, borderRadius: BorderRadius.circular(100), border: active ? null : Border.all(color: _border, width: 0.5)),
                  child: Text(_types[i], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : _secondary))));
            })),
            const SizedBox(height: 20),

            // Timezone chips
            Text(AppLocalizations.of(context).timezoneUpper, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _tertiary, letterSpacing: 0.8)), const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: List.generate(_timezones.length, (i) {
              final active = _selectedTz == i;
              return GestureDetector(onTap: () => setState(() => _selectedTz = i),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7), decoration: BoxDecoration(color: active ? _tealMain : Colors.white, borderRadius: BorderRadius.circular(100), border: active ? null : Border.all(color: _border, width: 0.5)),
                  child: Text(_timezones[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? Colors.white : _secondary))));
            })),
            const SizedBox(height: 20),

            // Conditional fields
            if (_selectedType == 0) _field(AppLocalizations.of(context).businessFieldMeetingLink, Icons.link, _linkCtrl),
            if (_selectedType == 2) _field(AppLocalizations.of(context).businessFieldLocation, Icons.location_on_outlined, _locationCtrl),
          ])),

        if (_error != null) Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: Text(_error!, style: const TextStyle(fontSize: 13, color: _urgent))),

        // SUBMIT
        Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 32), child: GestureDetector(onTap: _loading ? null : _submit,
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [_tealMain, _tealDark]), borderRadius: BorderRadius.circular(100)),
            child: Center(child: _loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(AppLocalizations.of(context).sendInterviewInvite, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white)))))),
      ]))),
    ])));
  }

  Widget _field(String label, IconData icon, TextEditingController ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 11, color: _tertiary)), const SizedBox(height: 6),
      Container(decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(8)),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), child: Row(children: [
          Icon(icon, size: 13, color: _tealMain), const SizedBox(width: 8),
          Expanded(child: TextField(controller: ctrl, style: const TextStyle(fontSize: 15, color: _charcoal),
            decoration: InputDecoration(hintText: label, hintStyle: const TextStyle(fontSize: 15, color: _tertiary), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero))),
        ]))),
      const SizedBox(height: 16),
    ]);
  }
}
