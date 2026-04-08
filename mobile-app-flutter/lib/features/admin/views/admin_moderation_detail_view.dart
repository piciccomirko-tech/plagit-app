import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
class AdminModerationDetailView extends StatefulWidget {
  final String reportId;
  const AdminModerationDetailView({super.key, required this.reportId});
  @override
  State<AdminModerationDetailView> createState() => _AdminModerationDetailViewState();
}

class _AdminModerationDetailViewState extends State<AdminModerationDetailView> {
  String _statusValue = 'Open';
  String _actionValue = 'None';
  final _noteController = TextEditingController();

  final _statusOptions = ['Open', 'In Review', 'Resolved'];
  final _actionOptions = ['None', 'Warning', 'Content Removed', 'Account Suspended'];

  Map<String, dynamic> get _report {
    return MockData.adminModerationReports.firstWhere(
      (r) => r['id'] == widget.reportId,
      orElse: () => MockData.adminModerationReports.first,
    );
  }

  @override
  void initState() {
    super.initState();
    _statusValue = _report['status'] as String;
    if (!_statusOptions.contains(_statusValue)) {
      _statusValue = 'Open';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return AppColors.red;
      case 'Medium':
        return AppColors.amber;
      case 'Low':
        return AppColors.secondary;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _report;
    final priorityColor = _priorityColor(r['priority'] as String);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.chevron_left, size: 24, color: AppColors.charcoal),
                  ),
                  const Spacer(),
                  const Text(
                    'Report Detail',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Report Information',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            r['title'] as String,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 12),
                          _infoRow('Type', r['entityType'] as String),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Priority', style: TextStyle(fontSize: 13, color: AppColors.secondary)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: priorityColor,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  r['priority'] as String,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _infoRow('Date', r['date'] as String),
                          const SizedBox(height: 8),
                          _infoRow('Reporter', 'Platform'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Entity', style: TextStyle(fontSize: 13, color: AppColors.secondary)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  // Navigate based on entity type
                                  final type = r['entityType'] as String;
                                  if (type == 'Job') {
                                    context.push('/admin/jobs/aj1');
                                  } else if (type == 'Business') {
                                    context.push('/admin/businesses/ab1');
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      r['entity'] as String,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.teal,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.open_in_new, size: 12, color: AppColors.teal),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Evidence section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Evidence',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Text(
                              r['description'] as String,
                              style: const TextStyle(fontSize: 14, color: AppColors.charcoal, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Admin decision
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin Decision',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 16),
                          // Status dropdown
                          const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _statusValue,
                                isExpanded: true,
                                items: _statusOptions.map((s) {
                                  return DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)));
                                }).toList(),
                                onChanged: (v) => setState(() => _statusValue = v!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Action dropdown
                          const Text('Action', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _actionValue,
                                isExpanded: true,
                                items: _actionOptions.map((a) {
                                  return DropdownMenuItem(value: a, child: Text(a, style: const TextStyle(fontSize: 14)));
                                }).toList(),
                                onChanged: (v) => setState(() => _actionValue = v!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Note
                          const Text('Note', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              hintText: 'Add decision notes...',
                              hintStyle: const TextStyle(fontSize: 14, color: AppColors.tertiary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.divider),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.divider),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            maxLines: 3,
                            style: const TextStyle(fontSize: 14, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Decision saved: $_statusValue / $_actionValue')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Save Decision', style: TextStyle(fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Audit trail
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Audit Trail',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 5),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.teal,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Report created by Platform auto-detection',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      r['date'] as String,
                                      style: const TextStyle(fontSize: 11, color: AppColors.tertiary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
      ],
    );
  }
}
