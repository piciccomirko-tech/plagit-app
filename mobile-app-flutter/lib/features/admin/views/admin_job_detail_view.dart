import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/employment.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/providers/admin_providers.dart';

class AdminJobDetailView extends StatefulWidget {
  final String jobId;
  const AdminJobDetailView({super.key, required this.jobId});
  @override
  State<AdminJobDetailView> createState() => _AdminJobDetailViewState();
}

class _AdminJobDetailViewState extends State<AdminJobDetailView> {
  late Map<String, dynamic> _job;
  bool _featured = false;
  bool _flagged = false;
  final _flagReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _job = Map<String, dynamic>.from(
      MockData.adminJobs.firstWhere(
        (j) => j['id'] == widget.jobId,
        orElse: () => MockData.adminJobs.first,
      ),
    );
    _featured = _job['featured'] == true;
    _flagged = _job['flagged'] == true;
  }

  @override
  void dispose() {
    _flagReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final j = _job;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Text(j['title'] as String,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal)),
      ),
      body: Column(
        children: [
          // Admin actions
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                // Feature toggle
                Expanded(
                  child: _actionBtn(
                    _featured ? l.adminActionUnfeature : l.adminActionFeature,
                    AppColors.amber,
                    !_featured,
                    () async {
                      final id = j['id'] as String;
                      final bool ok;
                      if (_featured) {
                        ok = await context.read<AdminActionsProvider>().unfeatureJob(id);
                      } else {
                        ok = await context.read<AdminActionsProvider>().featureJob(id);
                      }
                      if (ok && mounted) {
                        setState(() => _featured = !_featured);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(_featured ? l.adminSnackbarJobFeatured : l.adminSnackbarJobUnfeatured),
                          backgroundColor: AppColors.amber,
                        ));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 6),
                // Pause
                Expanded(
                  child: _actionBtn(l.adminActionPause, AppColors.amber, false, () {
                    _showConfirmDialog(
                        l, l.adminDialogPauseJobTitle, l.adminDialogPauseJobBody, () {
                      setState(() => _job['status'] = 'Paused');
                    });
                  }),
                ),
                const SizedBox(width: 6),
                // Close
                Expanded(
                  child: _actionBtn(l.adminActionClose, AppColors.red, false, () {
                    _showConfirmDialog(
                        l, l.adminDialogCloseJobTitle, l.adminDialogCloseJobBody,
                        () {
                      setState(() => _job['status'] = 'Closed');
                    });
                  }),
                ),
                const SizedBox(width: 6),
                // Remove (text only)
                GestureDetector(
                  onTap: () {
                    _showConfirmDialog(l, l.adminDialogRemoveJobTitle,
                        l.adminDialogRemoveJobBody,
                        () async {
                      final ok = await context.read<AdminActionsProvider>().removeJob(j['id'] as String);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(l.adminSnackbarJobRemoved),
                          backgroundColor: AppColors.red,
                        ));
                        context.pop();
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Text(l.adminActionRemove,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.red)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Job info card
                  _jobInfoCard(l, j),
                  const SizedBox(height: 16),
                  // Structured compensation review (moderation-ready)
                  _compensationReviewCard(l, j),
                  const SizedBox(height: 16),
                  // Applicants summary
                  _applicantsSummary(l, j),
                  const SizedBox(height: 12),
                  // View Applicants button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/admin/applications'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l.adminActionViewApplicants,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Moderation section
                  _moderationSection(l),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobInfoCard(AppLocalizations l, Map<String, dynamic> j) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + status
          Row(
            children: [
              Expanded(
                child: Text(j['title'] as String,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal)),
              ),
              StatusBadge(status: j['status'] as String),
            ],
          ),
          const SizedBox(height: 8),
          // Business (tappable)
          GestureDetector(
            onTap: () =>
                context.push('/admin/businesses/${j['businessId']}'),
            child: Row(
              children: [
                const Icon(Icons.business,
                    size: 14, color: AppColors.teal),
                const SizedBox(width: 4),
                Text(j['business'] as String,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.teal,
                        decoration: TextDecoration.underline)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),
          // Smart compensation display — same format as Candidate / Business sides
          _infoRow(Icons.attach_money, l.adminFieldPay, _compFor(j).display),
          const SizedBox(height: 8),
          _infoRow(Icons.description_outlined, l.adminFieldType,
              _empTypeFor(j).label),
          const SizedBox(height: 8),
          _infoRow(
              Icons.location_on_outlined, l.adminFieldLocation, j['location'] as String),
          const SizedBox(height: 8),
          _infoRow(Icons.schedule, l.adminFieldPosted, j['posted'] as String),
          const SizedBox(height: 8),
          _infoRow(Icons.people_outline, l.adminStatApplicants,
              '${j['applicants']}'),
          const SizedBox(height: 8),
          _infoRow(Icons.visibility, l.adminFieldViews, '142'),
          const SizedBox(height: 12),
          // Badge row
          Row(
            children: [
              if (_featured)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 12, color: AppColors.amber),
                      const SizedBox(width: 3),
                      Text(l.adminBadgeFeatured,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.amber)),
                    ],
                  ),
                ),
              if (_featured && (j['urgent'] == true))
                const SizedBox(width: 6),
              if (j['urgent'] == true)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(l.adminBadgeUrgent,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.red)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Compensation helpers ──
  // Prefers the structured `compensation` map (sent by the new post-job flow
  // and embedded in our mock data) and falls back to parsing the legacy
  // `salary` string for older entries. Same model as Candidate / Business.
  EmploymentType _empTypeFor(Map<String, dynamic> j) =>
      EmploymentType.fromString(j['contract'] as String? ?? 'Full-time');

  Compensation _compFor(Map<String, dynamic> j) {
    final empType = _empTypeFor(j);
    final rawComp = j['compensation'];
    if (rawComp is Map) {
      return Compensation.fromJson(
          Map<String, dynamic>.from(rawComp), empType);
    }
    return Compensation.fromLegacy(j['salary'] as String? ?? '', empType);
  }

  /// Moderation-ready breakdown of the job's compensation.
  ///
  /// Renders the relevant fields per employment type so a moderator can
  /// validate the listing without guessing what the salary string means:
  ///   • Full-time → annual salary
  ///   • Temporary → monthly pay + contract duration
  ///   • Part-time → hourly rate + weekly hours
  ///   • Casual    → hourly rate
  /// Plus any optional extras (housing / travel / bonus / shift) if present.
  Widget _compensationReviewCard(AppLocalizations l, Map<String, dynamic> j) {
    final empType = _empTypeFor(j);
    final comp = _compFor(j);

    final List<Widget> rows = [];

    void addRow(IconData icon, String label, String value) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(_infoRow(icon, label, value));
    }

    // Always show the employment type & primary compensation summary first.
    addRow(Icons.work_outline, l.adminFieldEmployment, empType.label);
    addRow(Icons.payments_outlined, l.adminFieldSummary, comp.display);

    // Per-type structured fields
    switch (empType) {
      case EmploymentType.fullTime:
        if (comp.annualSalaryMin != null && comp.annualSalaryMax != null) {
          addRow(Icons.attach_money, l.adminFieldSalaryRange,
              '${comp.currency}${comp.annualSalaryMin!.toStringAsFixed(0)}–${comp.currency}${comp.annualSalaryMax!.toStringAsFixed(0)}/year');
        } else if (comp.annualSalary != null) {
          addRow(Icons.attach_money, l.adminFieldAnnual,
              '${comp.currency}${comp.annualSalary!.toStringAsFixed(0)}/year');
        } else {
          addRow(Icons.attach_money, l.adminFieldAnnual, l.adminMiscNotSpecified);
        }
        break;
      case EmploymentType.fixedTerm:
        if (comp.monthlyPay != null) {
          addRow(Icons.attach_money, l.adminFieldMonthly,
              '${comp.currency}${comp.monthlyPay!.toStringAsFixed(0)}/month');
        } else {
          addRow(Icons.attach_money, l.adminFieldMonthly, l.adminMiscNotSpecified);
        }
        if (comp.contractDurationMonths != null) {
          addRow(Icons.event_outlined, l.adminFieldDuration,
              '${comp.contractDurationMonths} month${comp.contractDurationMonths == 1 ? '' : 's'}');
        }
        break;
      case EmploymentType.partTime:
        if (comp.hourlyRate != null) {
          addRow(Icons.attach_money, l.adminFieldHourly,
              '${comp.currency}${comp.hourlyRate!.toStringAsFixed(0)}/hr');
        }
        if (comp.weeklyHours != null) {
          addRow(Icons.schedule, l.adminFieldWeeklyHours,
              '${comp.weeklyHours!.toStringAsFixed(0)} hrs');
        }
        break;
      case EmploymentType.hourly:
        if (comp.hourlyRate != null) {
          addRow(Icons.attach_money, l.adminFieldHourly,
              '${comp.currency}${comp.hourlyRate!.toStringAsFixed(0)}/hr');
        } else {
          addRow(Icons.attach_money, l.adminFieldHourly, l.adminMiscNotSpecified);
        }
        if (comp.weeklyHours != null) {
          addRow(Icons.schedule, l.adminFieldWeeklyHours,
              '${comp.weeklyHours!.toStringAsFixed(0)} hrs');
        }
        break;
    }

    // Optional extras
    if (comp.bonus != null && comp.bonus!.isNotEmpty) {
      addRow(Icons.card_giftcard, l.adminFieldBonus, comp.bonus!);
    }
    if (comp.shiftPattern != null && comp.shiftPattern!.isNotEmpty) {
      addRow(Icons.schedule_outlined, l.adminFieldShift, comp.shiftPattern!);
    }

    // Boolean perks rendered as compact chips
    final perks = <(String, IconData)>[
      if (comp.housingIncluded) (l.adminPerkHousing, Icons.home_outlined),
      if (comp.travelIncluded) (l.adminPerkTravel, Icons.flight_outlined),
      if (comp.overtimeAvailable) (l.adminPerkOvertime, Icons.timelapse),
      if (comp.flexibleSchedule) (l.adminPerkFlexible, Icons.tune),
      if (comp.weekendShifts) (l.adminPerkWeekend, Icons.weekend_outlined),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fact_check_outlined,
                  size: 16, color: AppColors.teal),
              const SizedBox(width: 6),
              Text(l.adminSectionCompensationReview,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(l.adminSectionModeration,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...rows,
          if (perks.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),
            Text(l.adminSectionExtras,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: perks
                  .map((p) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(p.$2, size: 12, color: AppColors.teal),
                            const SizedBox(width: 4),
                            Text(p.$1,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.teal)),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.tertiary),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.secondary)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.charcoal)),
        ),
      ],
    );
  }

  Widget _applicantsSummary(AppLocalizations l, Map<String, dynamic> j) {
    final total = j['applicants'] as int;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.adminSectionApplicantsSummary,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal)),
          const SizedBox(height: 12),
          Row(
            children: [
              _countChip(l.adminStatTotal, '$total', AppColors.charcoal),
              const SizedBox(width: 8),
              _countChip(l.adminStatNew, '${(total * 0.4).round()}', AppColors.teal),
              const SizedBox(width: 8),
              _countChip(
                  l.adminStatReviewed, '${(total * 0.3).round()}', AppColors.amber),
              const SizedBox(width: 8),
              _countChip(
                  l.adminStatShortlisted, '${(total * 0.2).round()}', AppColors.purple),
              const SizedBox(width: 8),
              _countChip(
                  l.adminStatRejected, '${(total * 0.1).round()}', AppColors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _countChip(String label, String count, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(count,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.secondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _moderationSection(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.adminSectionModeration,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal)),
          const SizedBox(height: 12),
          // Flag toggle
          Row(
            children: [
              Expanded(
                child: Text(_flagged ? l.adminModerationIsFlagged : l.adminModerationFlagThis,
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            _flagged ? AppColors.red : AppColors.secondary)),
              ),
              Switch(
                value: _flagged,
                onChanged: (v) => setState(() => _flagged = v),
                activeTrackColor: AppColors.red,
              ),
            ],
          ),
          if (_flagged) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _flagReasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: l.adminPlaceholderFlagReason,
                hintStyle: const TextStyle(
                    fontSize: 13, color: AppColors.tertiary),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionBtn(
      String text, Color color, bool filled, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: filled ? null : Border.all(color: color),
        ),
        alignment: Alignment.center,
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : color)),
      ),
    );
  }

  void _showConfirmDialog(
      AppLocalizations l, String title, String message, Function() onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal)),
        content: Text(message,
            style:
                const TextStyle(fontSize: 14, color: AppColors.secondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.adminActionCancel,
                style: const TextStyle(color: AppColors.secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(l.adminActionConfirm,
                style: const TextStyle(
                    color: AppColors.teal, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
