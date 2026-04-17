import 'package:flutter/material.dart';
import 'package:plagit/features/admin/views/admin_shared_widgets.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

class AdminSubscriptionDetailView extends StatefulWidget {
  final String subscriptionId;
  const AdminSubscriptionDetailView(
      {super.key, required this.subscriptionId});
  @override
  State<AdminSubscriptionDetailView> createState() =>
      _AdminSubscriptionDetailViewState();
}

class _AdminSubscriptionDetailViewState
    extends State<AdminSubscriptionDetailView> {
  String _selectedPlan = 'Candidate Premium';
  final _overrideDateCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  Map<String, dynamic>? get _sub {
    try {
      return MockData.adminSubscriptions
          .firstWhere((s) => s['id'] == widget.subscriptionId);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    final s = _sub;
    if (s != null) {
      _selectedPlan = s['plan'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = _sub;
    if (s == null) {
      return Scaffold(
        backgroundColor: aBg,
        body: SafeArea(child: Column(children: [
          aTopBar(context, l.adminSectionSubscriptionDetail),
          Expanded(child: Center(child: Text(l.adminEmptySubscriptionNotFound))),
        ])),
      );
    }

    final status = s['status'] as String;
    final statusColor = status == 'Active' ? aGreen : status == 'Expired' ? aUrgent : aAmber;

    return Scaffold(
      backgroundColor: aBg,
      body: SafeArea(child: Column(children: [
        aTopBar(context, l.adminSectionSubscriptionDetail),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info card
              _card(
                child: Row(
                  children: [
                    aAvatar(
                      (s['userName'] as String)
                          .split(' ')
                          .map((w) => w.isNotEmpty ? w[0] : '')
                          .take(2)
                          .join()
                          .toUpperCase(),
                      48,
                      fs: 16,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s['userName'] as String,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: aCharcoal)),
                          const SizedBox(height: 2),
                          Text(s['userType'] as String,
                              style: const TextStyle(
                                  fontSize: 13, color: aSecondary)),
                          const SizedBox(height: 2),
                          Text(s['plan'] as String,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: aTeal)),
                        ],
                      ),
                    ),
                    aPill(aStatusLabel(l, status), statusColor),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Plan details
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.adminSectionPlanDetails,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: aCharcoal)),
                    const SizedBox(height: 12),
                    _detailRow(l.adminFieldPlan, s['plan'] as String),
                    _detailRow(l.adminFieldPrice, s['price'] as String),
                    _detailRow(l.adminFieldStartDate, s['startDate'] as String),
                    _detailRow(l.adminFieldRenewalDate, s['renewalDate'] as String),
                    _detailRow(l.adminFieldStatus, aStatusLabel(l, s['status'] as String)),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Admin override
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.adminSectionAdminOverride,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: aCharcoal)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPlan,
                      decoration: InputDecoration(
                        labelText: l.adminFieldPlan,
                        labelStyle: const TextStyle(
                            fontSize: 13, color: aSecondary),
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
                            value: 'Candidate Premium',
                            child: Text(l.adminPlanCandidatePremium)),
                        DropdownMenuItem(
                            value: 'Business Pro',
                            child: Text(l.adminPlanBusinessPro)),
                        DropdownMenuItem(
                            value: 'Business Premium',
                            child: Text(l.adminPlanBusinessPremium)),
                        DropdownMenuItem(
                            value: 'Free', child: Text(l.adminPlanFree)),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _selectedPlan = v);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _overrideDateCtrl,
                      decoration: InputDecoration(
                        labelText: l.adminFieldNewRenewalDate,
                        hintText: l.adminPlaceholderDateExample,
                        labelStyle: const TextStyle(
                            fontSize: 13, color: aSecondary),
                        hintStyle: const TextStyle(
                            fontSize: 13, color: aTertiary),
                        filled: true,
                        fillColor: aBg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _reasonCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: l.adminFieldReason,
                        hintText: l.adminPlaceholderReasonOverride,
                        labelStyle: const TextStyle(
                            fontSize: 13, color: aSecondary),
                        hintStyle: const TextStyle(
                            fontSize: 13, color: aTertiary),
                        filled: true,
                        fillColor: aBg,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: aTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(l.adminActionApplyOverride,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // History timeline
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.adminSectionHistory,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: aCharcoal)),
                    const SizedBox(height: 12),
                    _timelineEntry(
                      l.adminTimelineSubscriptionCreated,
                      s['startDate'] as String,
                      aGreen,
                    ),
                    _timelineEntry(
                      '${l.adminTimelinePaymentProcessed} - ${s['price']}',
                      s['startDate'] as String,
                      aTeal,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Notes section
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
                      child: Text(
                        l.adminEmptyNoAdminNotes,
                        style: const TextStyle(
                            fontSize: 13, color: aTertiary),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: aSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: aCharcoal)),
        ],
      ),
    );
  }

  Widget _timelineEntry(String title, String date, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 20,
                color: aDivider,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: aCharcoal)),
                Text(date,
                    style: const TextStyle(
                        fontSize: 11, color: aTertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
