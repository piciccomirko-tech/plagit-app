import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/config/app_theme.dart';

/// Match feedback sheet — mirrors MatchFeedbackView.swift.
class MatchFeedbackView extends StatefulWidget {
  final String matchId;
  final bool isBusiness;

  const MatchFeedbackView({
    super.key,
    required this.matchId,
    this.isBusiness = false,
  });

  @override
  State<MatchFeedbackView> createState() => _MatchFeedbackViewState();
}

class _MatchFeedbackViewState extends State<MatchFeedbackView> {
  bool? _wasRelevant;
  bool? _roleAccurate;
  bool? _jobTypeAccurate;
  bool _isSending = false;
  bool _sent = false;

  bool get _hasAnyAnswer => _wasRelevant != null || _roleAccurate != null || _jobTypeAccurate != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              // Drag indicator
              Container(
                width: 36, height: 5,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Header
              const Icon(Icons.auto_awesome, size: 28, color: AppColors.teal),
              const SizedBox(height: AppSpacing.sm),
              const Text('Quick Feedback', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.charcoal)),
              const SizedBox(height: AppSpacing.xs),
              const Text('Help us improve your matches', style: TextStyle(fontSize: 13, color: AppColors.secondary)),
              const SizedBox(height: AppSpacing.xxl),
              // Questions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    _buildFeedbackRow('Was this match relevant?', _wasRelevant, (v) => setState(() => _wasRelevant = v)),
                    const SizedBox(height: AppSpacing.lg),
                    _buildFeedbackRow('Was the role accurate?', _roleAccurate, (v) => setState(() => _roleAccurate = v)),
                    const SizedBox(height: AppSpacing.lg),
                    _buildFeedbackRow('Was the job type correct?', _jobTypeAccurate, (v) => setState(() => _jobTypeAccurate = v)),
                  ],
                ),
              ),
              if (_sent) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle, size: 16, color: AppColors.online),
                    SizedBox(width: AppSpacing.sm),
                    Text('Thanks for your feedback!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.online)),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
                          alignment: Alignment.center,
                          child: const Text('Skip', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.secondary)),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: GestureDetector(
                        onTap: _hasAnyAnswer && !_isSending ? _submit : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          decoration: BoxDecoration(
                            color: _hasAnyAnswer ? AppColors.teal : AppColors.teal.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          alignment: Alignment.center,
                          child: _isSending
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Submit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackRow(String question, bool? selection, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontSize: 15, color: AppColors.charcoal)),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildFeedbackButton('Yes', selection == true, AppColors.online, () => onChanged(true)),
              const SizedBox(width: AppSpacing.md),
              _buildFeedbackButton('No', selection == false, AppColors.urgent, () => onChanged(false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackButton(String label, bool isSelected, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: isSelected ? color.withValues(alpha: 0.3) : AppColors.border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 14, color: isSelected ? color : AppColors.secondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isSelected ? color : AppColors.secondary)),
          ],
        ),
      ),
    );
  }

  void _submit() {
    setState(() => _isSending = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() { _isSending = false; _sent = true; });
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) context.pop();
        });
      }
    });
  }
}
