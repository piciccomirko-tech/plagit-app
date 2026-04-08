import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';

class AdminAuditDetailView extends StatelessWidget {
  final String auditId;
  const AdminAuditDetailView({super.key, required this.auditId});

  Map<String, dynamic>? get _entry {
    try {
      return MockData.adminAuditLog
          .firstWhere((a) => a['id'] == auditId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = _entry;
    if (a == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
            onPressed: () => context.pop(),
          ),
          title: const Text('Audit Detail'),
        ),
        body: const Center(child: Text('Entry not found')),
      );
    }

    final action = a['action'] as String;
    final (IconData icon, Color color) = _actionStyle(action);
    final (String prev, String next) = _changeText(action);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: const Text('Audit Detail',
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
            // Info card
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('Admin', a['admin'] as String),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Action',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.secondary)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 12, color: color),
                            const SizedBox(width: 4),
                            Text(action,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: color)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _detailRow(
                      'Timestamp', a['timestamp'] as String),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Target: ',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.secondary)),
                      GestureDetector(
                        onTap: () {
                          // Navigate based on targetType
                          final targetType = a['targetType'] as String;
                          if (targetType == 'Candidate') {
                            // Would navigate to candidate
                          } else if (targetType == 'Business') {
                            // Would navigate to business
                          }
                        },
                        child: Text(a['target'] as String,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal,
                                decoration: TextDecoration.underline)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Type: ${a['targetType']}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.tertiary)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Changes section
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Changes',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(prev,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.red,
                                decoration:
                                    TextDecoration.lineThrough)),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward,
                            size: 16, color: AppColors.tertiary),
                        const SizedBox(width: 10),
                        Text(next,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.green)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Reason
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reason',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal)),
                  const SizedBox(height: 8),
                  Text(a['reason'] as String,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondary,
                          height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // IP Address
            _card(
              child: const Text('IP Address: 192.168.1.xxx',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.tertiary)),
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
    return Row(
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
    );
  }

  (IconData, Color) _actionStyle(String action) {
    switch (action) {
      case 'Verified':
        return (Icons.check, AppColors.green);
      case 'Suspended':
        return (Icons.block, AppColors.red);
      case 'Featured':
        return (Icons.star, AppColors.amber);
      case 'Override':
        return (Icons.edit, AppColors.purple);
      case 'Resolved':
        return (Icons.check_circle, AppColors.teal);
      default:
        return (Icons.info, AppColors.secondary);
    }
  }

  (String, String) _changeText(String action) {
    switch (action) {
      case 'Verified':
        return ('Unverified', 'Verified');
      case 'Suspended':
        return ('Active', 'Suspended');
      case 'Featured':
        return ('Standard', 'Featured');
      case 'Override':
        return ('Previous Status', 'Overridden');
      case 'Resolved':
        return ('Open', 'Resolved');
      default:
        return ('Previous', 'Updated');
    }
  }
}
