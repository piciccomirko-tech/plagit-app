import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

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
                    _featured ? 'Unfeature' : 'Feature',
                    AppColors.amber,
                    !_featured,
                    () => setState(() => _featured = !_featured),
                  ),
                ),
                const SizedBox(width: 6),
                // Pause
                Expanded(
                  child: _actionBtn('Pause', AppColors.amber, false, () {
                    _showConfirmDialog(
                        'Pause Job', 'Pause this job listing?', () {
                      setState(() => _job['status'] = 'Paused');
                    });
                  }),
                ),
                const SizedBox(width: 6),
                // Close
                Expanded(
                  child: _actionBtn('Close', AppColors.red, false, () {
                    _showConfirmDialog(
                        'Close Job', 'Close this job listing permanently?',
                        () {
                      setState(() => _job['status'] = 'Closed');
                    });
                  }),
                ),
                const SizedBox(width: 6),
                // Remove (text only)
                GestureDetector(
                  onTap: () {
                    _showConfirmDialog('Remove Job',
                        'Remove this job completely? This cannot be undone.',
                        () {
                      context.pop();
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Text('Remove',
                        style: TextStyle(
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
                  _jobInfoCard(j),
                  const SizedBox(height: 16),
                  // Applicants summary
                  _applicantsSummary(j),
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
                      child: const Text('View Applicants',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Moderation section
                  _moderationSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobInfoCard(Map<String, dynamic> j) {
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
          _infoRow(Icons.attach_money, 'Salary', j['salary'] as String),
          const SizedBox(height: 8),
          _infoRow(
              Icons.description_outlined, 'Contract', j['contract'] as String),
          const SizedBox(height: 8),
          _infoRow(
              Icons.location_on_outlined, 'Location', j['location'] as String),
          const SizedBox(height: 8),
          _infoRow(Icons.schedule, 'Posted', j['posted'] as String),
          const SizedBox(height: 8),
          _infoRow(Icons.people_outline, 'Applicants',
              '${j['applicants']}'),
          const SizedBox(height: 8),
          _infoRow(Icons.visibility, 'Views', '142'),
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
                      const Text('Featured',
                          style: TextStyle(
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
                  child: const Text('Urgent',
                      style: TextStyle(
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

  Widget _applicantsSummary(Map<String, dynamic> j) {
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
          const Text('Applicants Summary',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal)),
          const SizedBox(height: 12),
          Row(
            children: [
              _countChip('Total', '$total', AppColors.charcoal),
              const SizedBox(width: 8),
              _countChip('New', '${(total * 0.4).round()}', AppColors.teal),
              const SizedBox(width: 8),
              _countChip(
                  'Reviewed', '${(total * 0.3).round()}', AppColors.amber),
              const SizedBox(width: 8),
              _countChip(
                  'Shortlisted', '${(total * 0.2).round()}', AppColors.purple),
              const SizedBox(width: 8),
              _countChip(
                  'Rejected', '${(total * 0.1).round()}', AppColors.red),
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

  Widget _moderationSection() {
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
          const Text('Moderation',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal)),
          const SizedBox(height: 12),
          // Flag toggle
          Row(
            children: [
              Expanded(
                child: Text(_flagged ? 'This job is flagged' : 'Flag this job',
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            _flagged ? AppColors.red : AppColors.secondary)),
              ),
              Switch(
                value: _flagged,
                onChanged: (v) => setState(() => _flagged = v),
                activeColor: AppColors.red,
              ),
            ],
          ),
          if (_flagged) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _flagReasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Reason for flagging...',
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
      String title, String message, VoidCallback onConfirm) {
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
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.secondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Confirm',
                style: TextStyle(
                    color: AppColors.teal, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
