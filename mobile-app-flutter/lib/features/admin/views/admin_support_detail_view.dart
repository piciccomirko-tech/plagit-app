import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/admin_providers.dart';

class AdminSupportDetailView extends StatefulWidget {
  final String issueId;
  const AdminSupportDetailView({super.key, required this.issueId});
  @override
  State<AdminSupportDetailView> createState() =>
      _AdminSupportDetailViewState();
}

class _AdminSupportDetailViewState extends State<AdminSupportDetailView> {
  String _selectedStatus = 'Open';
  final _noteCtrl = TextEditingController();
  final _resolutionCtrl = TextEditingController();
  Map<String, dynamic>? get _issue {
    try {
      return MockData.adminSupportIssues
          .firstWhere((s) => s['id'] == widget.issueId);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    final issue = _issue;
    if (issue != null) {
      _selectedStatus = issue['status'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = _issue;
    if (s == null) {
      return Scaffold(
        backgroundColor: aBg,
        body: SafeArea(child: Column(children: [
          aTopBar(context, l.adminSectionSupportIssue),
          Expanded(child: Center(child: Text(l.adminEmptyIssueNotFound))),
        ])),
      );
    }

    final priority = s['priority'] as String;
    final priorityColor = priority == 'High' ? aUrgent : aAmber;

    return Scaffold(
      backgroundColor: aBg,
      body: SafeArea(child: Column(children: [
        aTopBar(context, s['title'] as String),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailRow(l.adminFieldCategory, l.adminValueSupport),
                    _detailRow(l.adminFieldPriority, aPriorityLabel(l, priority),
                        valueColor: priorityColor),
                    _detailRow(l.adminFieldCreated, s['created'] as String),
                    _detailRow(l.adminFieldUpdated, s['updated'] as String),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('${l.adminFieldUser}: ',
                            style: const TextStyle(
                                fontSize: 13, color: aSecondary)),
                        GestureDetector(
                          onTap: () {},
                          child: Text(s['userName'] as String,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: aTeal,
                                  decoration: TextDecoration.underline)),
                        ),
                        const SizedBox(width: 8),
                        _typeBadge(s['userType'] as String),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Description
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.adminSectionDescription,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: aCharcoal)),
                    const SizedBox(height: 8),
                    Text(s['description'] as String,
                        style: const TextStyle(
                            fontSize: 13,
                            color: aSecondary,
                            height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Status update row
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.adminSectionUpdateStatus,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: aCharcoal)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedStatus,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: aBg,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                            ),
                            items: [
                              DropdownMenuItem(
                                  value: 'Open', child: Text(aStatusLabel(l, 'Open'))),
                              DropdownMenuItem(
                                  value: 'In Review',
                                  child: Text(aStatusLabel(l, 'In Review'))),
                              DropdownMenuItem(
                                  value: 'Waiting',
                                  child: Text(aStatusLabel(l, 'Waiting'))),
                              DropdownMenuItem(
                                  value: 'Resolved',
                                  child: Text(aStatusLabel(l, 'Resolved'))),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _selectedStatus = v);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () async {
                            final ok = await context.read<AdminActionsProvider>().updateSupportStatus(s['id'] as String, _selectedStatus);
                            if (ok && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(l.adminSnackbarStatusUpdatedTo(aStatusLabel(l, _selectedStatus))),
                                backgroundColor: AppColors.teal,
                              ));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: aTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text(l.adminActionUpdate,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Notes thread
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.adminTabNotes,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: aCharcoal)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: aBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Admin User',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: aCharcoal)),
                              const Spacer(),
                              Text(s['updated'] as String,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: aTertiary)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                              'Looking into this issue. Checking server logs for upload errors.',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: aSecondary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l.adminPlaceholderAddNote,
                        hintStyle: const TextStyle(
                            fontSize: 13, color: aTertiary),
                        filled: true,
                        fillColor: aBg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: aTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(l.adminActionAddNote,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Mark resolved
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.adminSectionResolution,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: aCharcoal)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _resolutionCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: l.adminPlaceholderResolutionSummary,
                        hintStyle: const TextStyle(
                            fontSize: 13, color: aTertiary),
                        filled: true,
                        fillColor: aBg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final ok = await context.read<AdminActionsProvider>().resolveSupportIssue(
                            s['id'] as String,
                            resolution: _resolutionCtrl.text.isNotEmpty ? _resolutionCtrl.text : null,
                          );
                          if (ok && mounted) {
                            setState(() => _selectedStatus = 'Resolved');
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(l.adminSnackbarIssueResolved),
                              backgroundColor: AppColors.green,
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: aTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(l.adminActionMarkResolved,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        )),
      ])),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: aCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [aCardShadow],
      ),
      child: child,
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: aSecondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? aCharcoal)),
        ],
      ),
    );
  }

  Widget _typeBadge(String type) {
    final isBusiness = type == 'Business';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isBusiness
            ? aPurple.withValues(alpha: 0.10)
            : aTeal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(type,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isBusiness ? aPurple : aTeal)),
    );
  }
}
