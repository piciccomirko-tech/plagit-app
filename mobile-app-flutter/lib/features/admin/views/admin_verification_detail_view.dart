import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/providers/admin_providers.dart';

class AdminVerificationDetailView extends StatefulWidget {
  final String verificationId;
  const AdminVerificationDetailView({super.key, required this.verificationId});
  @override
  State<AdminVerificationDetailView> createState() => _AdminVerificationDetailViewState();
}

class _AdminVerificationDetailViewState extends State<AdminVerificationDetailView> {
  final _noteController = TextEditingController();

  Map<String, dynamic> get _verification {
    return MockData.adminVerificationQueue.firstWhere(
      (v) => v['id'] == widget.verificationId,
      orElse: () => MockData.adminVerificationQueue.first,
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final v = _verification;
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
                    child: const Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Text(
                        v['name'] as String,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                      ),
                      Text(
                        l.adminSectionVerificationReview,
                        style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                      ),
                    ],
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
                    // Profile summary
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.adminSectionProfileSummary,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.teal.withValues(alpha: 0.1),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  v['initials'] as String,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.teal),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v['name'] as String,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        StatusBadge(status: v['type'] as String),
                                        const SizedBox(width: 8),
                                        StatusBadge(status: v['status'] as String),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 8),
                          _detailRow(l.adminFieldSubmitted, v['submitted'] as String),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Documents
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.adminSectionDocuments,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 16),
                          _documentCard(
                            l: l,
                            icon: Icons.badge,
                            title: l.adminDocTitleIdDocument,
                            subtitle: l.adminDocSubtitleIdDocument,
                          ),
                          const SizedBox(height: 12),
                          _documentCard(
                            l: l,
                            icon: Icons.description,
                            title: (v['type'] as String) == 'Candidate' ? l.adminDocTitleCv : l.adminDocTitleRegistration,
                            subtitle: (v['type'] as String) == 'Candidate'
                                ? l.adminDocSubtitleCv
                                : l.adminDocSubtitleRegistration,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Decision
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.adminStatusDecision,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showApproveDialog(l),
                                  icon: const Icon(Icons.check_circle, size: 18),
                                  label: Text(l.adminActionApprove, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _showRejectDialog(l),
                                  icon: const Icon(Icons.cancel, size: 18),
                                  label: Text(l.adminActionReject, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Notes
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppColors.cardDecoration,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.adminTabNotes,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.charcoal),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              hintText: l.adminPlaceholderAddNote,
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
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_noteController.text.isNotEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(l.adminSnackbarNoteSaved)),
                                  );
                                  _noteController.clear();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(l.adminActionSaveNote),
                            ),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.secondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.charcoal)),
        ],
      ),
    );
  }

  Widget _documentCard({
    required AppLocalizations l,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.teal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.charcoal)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.tertiary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.adminSnackbarViewingDocument(title))),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l.adminActionViewDocument,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.teal),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.adminDialogApproveVerificationTitle),
        content: Text(l.adminDialogApproveVerificationBody(_verification['name'] as String)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.adminActionCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await context.read<AdminActionsProvider>().approveVerification(_verification['id'] as String);
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.adminSnackbarVerificationApproved), backgroundColor: AppColors.green),
                );
                context.pop();
              }
            },
            child: Text(l.adminActionApprove),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(AppLocalizations l) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.adminDialogRejectVerificationTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.adminDialogRejectVerificationBody(_verification['name'] as String)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: l.adminPlaceholderRejectionReason,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.adminActionCancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await context.read<AdminActionsProvider>().rejectVerification(_verification['id'] as String);
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.adminSnackbarVerificationRejected), backgroundColor: AppColors.red),
                );
                context.pop();
              }
            },
            child: Text(l.adminActionReject, style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
