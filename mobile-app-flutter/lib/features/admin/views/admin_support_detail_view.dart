import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class AdminSupportDetailView extends StatefulWidget {
  final String issueId;
  const AdminSupportDetailView({super.key, required this.issueId});
  @override
  State<AdminSupportDetailView> createState() =>
      _AdminSupportDetailViewState();
}

class _AdminSupportDetailViewState extends State<AdminSupportDetailView> {
  String _selectedStatus = 'Open';
  String _noteText = '';
  String _resolutionSummary = '';

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
    final s = _issue;
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
          title: const Text('Support Issue'),
        ),
        body: const Center(child: Text('Issue not found')),
      );
    }

    final priority = s['priority'] as String;
    final priorityColor =
        priority == 'High' ? AppColors.red : AppColors.amber;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: Text(s['title'] as String,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Category', 'Support'),
                  _detailRow('Priority', priority,
                      valueColor: priorityColor),
                  _detailRow('Created', s['created'] as String),
                  _detailRow('Updated', s['updated'] as String),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('User: ',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.secondary)),
                      GestureDetector(
                        onTap: () {},
                        child: Text(s['userName'] as String,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal,
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
                  const Text('Description',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 8),
                  Text(s['description'] as String,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondary,
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
                  const Text('Update Status',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
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
                                value: 'Open', child: Text('Open')),
                            DropdownMenuItem(
                                value: 'In Review',
                                child: Text('In Review')),
                            DropdownMenuItem(
                                value: 'Waiting',
                                child: Text('Waiting')),
                            DropdownMenuItem(
                                value: 'Resolved',
                                child: Text('Resolved')),
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Update',
                            style: TextStyle(
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
                  const Text('Notes',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 12),
                  // Mock note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
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
                                    color: AppColors.charcoal)),
                            const Spacer(),
                            Text(s['updated'] as String,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.tertiary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                            'Looking into this issue. Checking server logs for upload errors.',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.secondary)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Add note
                  TextField(
                    onChanged: (v) => _noteText = v,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: AppColors.tertiary),
                      filled: true,
                      fillColor: AppColors.background,
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
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Add Note',
                          style: TextStyle(
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
                  const Text('Resolution',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 12),
                  TextField(
                    onChanged: (v) => _resolutionSummary = v,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Resolution summary...',
                      hintStyle: const TextStyle(
                          fontSize: 13, color: AppColors.tertiary),
                      filled: true,
                      fillColor: AppColors.background,
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Mark Resolved',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
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

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.secondary)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.charcoal)),
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
            ? AppColors.purple.withValues(alpha: 0.10)
            : AppColors.teal.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(type,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isBusiness ? AppColors.purple : AppColors.teal)),
    );
  }
}
