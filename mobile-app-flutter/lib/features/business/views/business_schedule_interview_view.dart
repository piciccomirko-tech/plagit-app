import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/business_service.dart';

/// Schedule interview form — mirrors BusinessRealScheduleInterviewView.swift.
class BusinessScheduleInterviewView extends StatefulWidget {
  final String? candidateId;
  final String? jobId;
  const BusinessScheduleInterviewView({super.key, this.candidateId, this.jobId});

  @override
  State<BusinessScheduleInterviewView> createState() => _BusinessScheduleInterviewViewState();
}

class _BusinessScheduleInterviewViewState extends State<BusinessScheduleInterviewView> {
  final _service = BusinessService();
  final _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _type = 'video_call';
  int _duration = 30;
  bool _loading = false;
  String? _error;
  bool _sent = false;

  static const _types = [
    ('video_call', 'Video Call', Icons.videocam_outlined),
    ('phone', 'Phone', Icons.phone_outlined),
    ('in_person', 'In Person', Icons.location_on_outlined),
  ];

  static const _durations = [15, 30, 45, 60, 90];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      final scheduledAt = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _selectedTime.hour, _selectedTime.minute,
      );
      await _service.scheduleInterview({
        if (widget.candidateId != null) 'candidate_id': widget.candidateId,
        if (widget.jobId != null) 'job_id': widget.jobId,
        'scheduled_at': scheduledAt.toIso8601String(),
        'type': _type,
        'duration_minutes': _duration,
        'notes': _notesCtrl.text.trim(),
      });
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) return _buildSuccess();

    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
            child: Row(children: [
              IconButton(icon: const Icon(Icons.chevron_left, size: 28), onPressed: () => context.pop()),
              const Text('Schedule Interview', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
            ]),
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: ListView(padding: const EdgeInsets.all(20), children: [
              // ── Interview Type ──
              const Text('Interview Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              const SizedBox(height: 8),
              Row(children: _types.map((t) {
                final active = _type == t.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _type = t.$1),
                    child: Container(
                      margin: EdgeInsets.only(right: t.$1 != 'in_person' ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: active ? AppColors.indigo.withValues(alpha: 0.10) : AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: active ? AppColors.indigo : AppColors.border),
                      ),
                      child: Column(children: [
                        Icon(t.$3, size: 22, color: active ? AppColors.indigo : AppColors.tertiary),
                        const SizedBox(height: 4),
                        Text(t.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? AppColors.indigo : AppColors.secondary)),
                      ]),
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 20),

              // ── Date & Time ──
              const Text('Date & Time', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        Icon(Icons.calendar_today, size: 16, color: AppColors.indigo),
                        const SizedBox(width: 8),
                        Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontSize: 15, color: AppColors.charcoal)),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(color: AppColors.cardBackground, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        Icon(Icons.schedule, size: 16, color: AppColors.indigo),
                        const SizedBox(width: 8),
                        Text(_selectedTime.format(context), style: const TextStyle(fontSize: 15, color: AppColors.charcoal)),
                      ]),
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // ── Duration ──
              const Text('Duration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: _durations.map((d) {
                final active = _duration == d;
                return GestureDetector(
                  onTap: () => setState(() => _duration = d),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.indigo : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: active ? null : Border.all(color: AppColors.border),
                    ),
                    child: Text('$d min', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? Colors.white : AppColors.secondary)),
                  ),
                );
              }).toList()),
              const SizedBox(height: 20),

              // ── Notes ──
              TextField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes (optional)', hintText: 'Any additional info for the candidate...'),
              ),

              if (_error != null) ...[const SizedBox(height: 16), Text(_error!, style: const TextStyle(color: AppColors.urgent, fontSize: 14))],
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.indigo),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Send Interview Invite'),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildSuccess() {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(color: AppColors.online.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, size: 40, color: AppColors.online),
              ),
              const SizedBox(height: 20),
              const Text('Interview Scheduled!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.charcoal)),
              const SizedBox(height: 8),
              const Text('The candidate has been notified about the interview invitation.', style: TextStyle(fontSize: 15, color: AppColors.secondary), textAlign: TextAlign.center),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: () => context.pop(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.indigo),
                  child: const Text('Done'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
