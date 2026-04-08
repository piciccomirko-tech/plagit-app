import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/services/candidate_service.dart';

/// Job detail — replicates CandidateJobDetailView.swift exactly.
class CandidateJobDetailView extends StatefulWidget {
  final String jobId;
  const CandidateJobDetailView({super.key, required this.jobId});

  @override
  State<CandidateJobDetailView> createState() => _CandidateJobDetailViewState();
}

class _CandidateJobDetailViewState extends State<CandidateJobDetailView> {
  final _service = CandidateService();
  Map<String, dynamic>? _job;
  bool _loading = true;
  bool _applying = false;
  bool _applied = false;
  String? _error;
  String? _applyError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final resp = await _service.getJobDetail(widget.jobId);
      final job = (resp['data'] ?? resp['job'] ?? resp) as Map<String, dynamic>;
      if (mounted) setState(() {
        _job = job;
        _applied = job['has_applied'] == true || job['already_applied'] == true;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _apply() async {
    setState(() { _applying = true; _applyError = null; });
    try {
      await _service.applyToJob(widget.jobId);
      if (mounted) setState(() { _applied = true; _applying = false; });
    } catch (e) {
      if (mounted) setState(() { _applyError = e.toString(); _applying = false; });
    }
  }

  String? _f(List<String> keys) {
    for (final k in keys) {
      final v = _job?[k];
      if (v != null && v.toString().isNotEmpty) return v.toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.teal, strokeWidth: 2.5))
            : _error != null
                ? Center(child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.warning_amber_rounded, size: 32, color: AppColors.tertiary),
                      const SizedBox(height: 16),
                      Text(_error!, style: const TextStyle(fontSize: 14, color: AppColors.secondary), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      GestureDetector(onTap: _load, child: const Text('Retry', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.teal))),
                    ]),
                  ))
                : Stack(children: [
                    // Scrollable content
                    SingleChildScrollView(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        _buildTopBar(),
                        Padding(padding: const EdgeInsets.only(top: 16), child: _buildHeroCard()),
                        Padding(padding: const EdgeInsets.only(top: 28), child: _buildDetailSections()),
                        const SizedBox(height: 120), // space for sticky bar
                      ]),
                    ),
                    // Sticky apply bar
                    Positioned(left: 0, right: 0, bottom: 0, child: _buildApplyBar()),
                  ]),
      ),
    );
  }

  // ── Top Bar (matches Swift topBar) ──

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 36, height: 36,
            alignment: Alignment.center,
            child: const Icon(Icons.chevron_left, size: 22, color: AppColors.charcoal),
          ),
        ),
        const Spacer(),
        const Text('Job Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
        const Spacer(),
        const SizedBox(width: 36, height: 36),
      ]),
    );
  }

  // ── Hero Card (matches Swift heroCard — left-aligned, horizontal) ──

  Widget _buildHeroCard() {
    final title = _f(['title']) ?? 'Job';
    final company = _f(['business_name', 'company_name']) ?? 'Unknown';
    final initials = _f(['business_initials']) ?? (company.isNotEmpty ? company[0].toUpperCase() : '?');
    final location = _f(['location']);
    final employmentType = _f(['employment_type', 'contract_type']);
    final salary = _f(['salary', 'salary_range']);
    final isFeatured = _job?['is_featured'] == true;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Avatar + title/company row
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Center(child: Text(initials, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.teal))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.charcoal, height: 1.25)),
            const SizedBox(height: 4),
            Text(company, style: const TextStyle(fontSize: 15, color: AppColors.secondary)),
          ])),
        ]),
        const SizedBox(height: 16),

        // Info pills row
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (location != null) _infoPill(Icons.location_on_outlined, location),
          if (employmentType != null) _infoPill(Icons.work_outline, employmentType),
          if (salary != null) _infoPill(Icons.payments_outlined, salary),
        ]),

        // Featured badge
        if (isFeatured) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppRadius.full)),
            child: const Text('Featured', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.amber)),
          ),
        ],
      ]),
    );
  }

  Widget _infoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: AppColors.teal),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.charcoal)),
      ]),
    );
  }

  // ── Detail Sections (matches Swift detailSections) ──

  Widget _buildDetailSections() {
    final isUrgent = _job?['is_urgent'] == true;
    final numHires = (_job?['num_hires'] as num?)?.toInt() ?? 1;
    final description = _f(['description']);
    final requirements = _f(['requirements']);
    final startDate = _f(['start_date', 'startDate']);
    final endDate = _f(['end_date', 'endDate']);
    final shiftHours = _f(['shift_hours', 'shiftHours']);
    final category = _f(['category']);
    final venueType = _f(['business_venue_type', 'venue_type']);
    final employmentType = _f(['employment_type', 'contract_type']);
    final salary = _f(['salary', 'salary_range']);
    final businessLocation = _f(['business_location']);
    final views = (_job?['views'] as num?)?.toInt();
    final businessName = _f(['business_name', 'company_name']);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Badges row ──
      if (isUrgent || numHires > 1)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Wrap(spacing: 8, children: [
            if (isUrgent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppRadius.full)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.bolt, size: 12, color: AppColors.amber),
                  const SizedBox(width: 4),
                  const Text('Urgent Hiring', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.amber)),
                ]),
              ),
            if (numHires > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.teal.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(AppRadius.full)),
                child: Text('$numHires positions', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teal)),
              ),
          ]),
        ),

      // ── About Role ──
      if (description != null)
        _sectionCard('About Role', child: Text(description, style: const TextStyle(fontSize: 15, color: AppColors.charcoal, height: 1.55))),

      // ── Requirements ──
      if (requirements != null)
        _sectionCard('Requirements', child: Text(requirements, style: const TextStyle(fontSize: 15, color: AppColors.charcoal, height: 1.55))),

      // ── Schedule ──
      if (startDate != null || shiftHours != null)
        _sectionCard('Schedule', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (startDate != null) _infoRow(Icons.calendar_today, 'Start Date', startDate),
          if (endDate != null) ...[const SizedBox(height: 8), _infoRow(Icons.event, 'End Date', endDate)],
          if (shiftHours != null) ...[const SizedBox(height: 8), _infoRow(Icons.schedule, 'Shift Hours', shiftHours)],
        ])),

      // ── Job Details (always shown) ──
      _sectionCard('Job Details', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (category != null) _infoRow(Icons.sell_outlined, 'Category', category),
        if (venueType != null) ...[const SizedBox(height: 12), _infoRow(Icons.store_outlined, 'Venue Type', venueType)],
        if (employmentType != null) ...[const SizedBox(height: 12), _infoRow(Icons.work_outline, 'Employment', employmentType)],
        if (salary != null) ...[const SizedBox(height: 12), _infoRow(Icons.payments_outlined, 'Salary', salary)],
        if (businessLocation != null) ...[const SizedBox(height: 12), _infoRow(Icons.location_on_outlined, 'Business Location', businessLocation)],
        if (views != null && views > 0) ...[const SizedBox(height: 12), _infoRow(Icons.visibility_outlined, 'Job Views', '$views')],
      ])),

      // ── About Business ──
      if (businessName != null)
        _sectionCard('About Business', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (venueType != null)
            Text(venueType, style: const TextStyle(fontSize: 15, color: AppColors.charcoal)),
          if (businessLocation != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.location_on_outlined, size: 12, color: AppColors.tertiary),
              const SizedBox(width: 4),
              Text(businessLocation, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
            ]),
          ],
        ])),
    ]);
  }

  Widget _sectionCard(String title, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(subtle: true),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary)),
          const SizedBox(height: 12),
          child,
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Icon(icon, size: 14, color: AppColors.teal),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.tertiary)),
        const SizedBox(height: 1),
        Text(value, style: const TextStyle(fontSize: 15, color: AppColors.charcoal)),
      ])),
    ]);
  }

  // ── Apply Bar (matches Swift applyBar — sticky bottom) ──

  Widget _buildApplyBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: AppColors.divider.withValues(alpha: 0.5), width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (_applyError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_applyError!, style: const TextStyle(fontSize: 13, color: AppColors.urgent)),
          ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: _applied
              ? Container(
                  decoration: BoxDecoration(
                    color: AppColors.online.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.check_circle, size: 18, color: AppColors.online),
                    SizedBox(width: 8),
                    Text('Applied', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.online)),
                  ])),
                )
              : DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.teal, AppColors.tealDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: MaterialButton(
                    onPressed: _applying ? null : _apply,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: _applying
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Apply Now', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
        ),
      ]),
    );
  }

  static BoxDecoration _cardDecoration({bool subtle = false}) => BoxDecoration(
    color: AppColors.cardBackground,
    borderRadius: BorderRadius.circular(AppRadius.lg),
    boxShadow: [BoxShadow(
      color: Colors.black.withValues(alpha: subtle ? 0.03 : 0.04),
      blurRadius: subtle ? 8 : 12,
      offset: Offset(0, subtle ? 3 : 4),
    )],
  );
}
