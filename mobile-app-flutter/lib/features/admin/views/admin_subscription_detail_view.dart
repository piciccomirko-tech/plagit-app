import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

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
  String _overrideDate = '';
  String _reason = '';

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
    final s = _sub;
    if (s == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
            onPressed: () => context.pop(),
          ),
          title: const Text('Subscription Detail'),
        ),
        body: const Center(child: Text('Subscription not found')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: const Text('Subscription Detail',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info card
            _card(
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      (s['userName'] as String)
                          .split(' ')
                          .map((w) => w.isNotEmpty ? w[0] : '')
                          .take(2)
                          .join()
                          .toUpperCase(),
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal),
                    ),
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
                                color: AppColors.charcoal)),
                        const SizedBox(height: 2),
                        Text(s['userType'] as String,
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.secondary)),
                        const SizedBox(height: 2),
                        Text(s['plan'] as String,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal)),
                      ],
                    ),
                  ),
                  StatusBadge(status: s['status'] as String),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Plan details
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Plan Details',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 12),
                  _detailRow('Plan', s['plan'] as String),
                  _detailRow('Price', s['price'] as String),
                  _detailRow('Start Date', s['startDate'] as String),
                  _detailRow('Renewal Date', s['renewalDate'] as String),
                  _detailRow('Status', s['status'] as String),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Admin override
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Admin Override',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 12),
                  // Plan selector
                  DropdownButtonFormField<String>(
                    value: _selectedPlan,
                    decoration: InputDecoration(
                      labelText: 'Plan',
                      labelStyle: const TextStyle(
                          fontSize: 13, color: AppColors.secondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Candidate Premium',
                          child: Text('Candidate Premium')),
                      DropdownMenuItem(
                          value: 'Business Pro',
                          child: Text('Business Pro')),
                      DropdownMenuItem(
                          value: 'Business Premium',
                          child: Text('Business Premium')),
                      DropdownMenuItem(
                          value: 'Free', child: Text('Free')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedPlan = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  // Override date
                  TextField(
                    onChanged: (v) => _overrideDate = v,
                    decoration: InputDecoration(
                      labelText: 'New Renewal Date',
                      hintText: 'e.g. Jun 15, 2026',
                      labelStyle: const TextStyle(
                          fontSize: 13, color: AppColors.secondary),
                      hintStyle: const TextStyle(
                          fontSize: 13, color: AppColors.tertiary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Reason
                  TextField(
                    onChanged: (v) => _reason = v,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Reason',
                      hintText: 'Reason for override...',
                      labelStyle: const TextStyle(
                          fontSize: 13, color: AppColors.secondary),
                      hintStyle: const TextStyle(
                          fontSize: 13, color: AppColors.tertiary),
                      filled: true,
                      fillColor: AppColors.background,
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
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Apply Override',
                          style: TextStyle(
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
                  const Text('History',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 12),
                  _timelineEntry(
                    'Subscription created',
                    s['startDate'] as String,
                    AppColors.green,
                  ),
                  _timelineEntry(
                    'Payment processed - ${s['price']}',
                    s['startDate'] as String,
                    AppColors.teal,
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
                  const Text('Notes',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'No admin notes yet.',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.tertiary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
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
                  fontSize: 13, color: AppColors.secondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal)),
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
                color: AppColors.divider,
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
                        color: AppColors.charcoal)),
                Text(date,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.tertiary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
