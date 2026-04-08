import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

/// Standalone business interviews screen (pushed from dashboard).
class BusinessInterviewsView extends StatefulWidget {
  const BusinessInterviewsView({super.key});

  @override
  State<BusinessInterviewsView> createState() => _BusinessInterviewsViewState();
}

class _BusinessInterviewsViewState extends State<BusinessInterviewsView> {
  String _filter = 'Upcoming';

  List<Map<String, dynamic>> get _filtered {
    final all = MockData.businessInterviews
        .map((i) => Map<String, dynamic>.from(i))
        .toList();
    switch (_filter) {
      case 'Upcoming':
        return all
            .where((i) =>
                i['status'] == 'Confirmed' || i['status'] == 'Invited')
            .toList();
      case 'Past':
        return all.where((i) => i['status'] == 'Completed').toList();
      default:
        return all;
    }
  }

  Color _avatarColor(String name) {
    final hue = (name.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.45).toColor();
  }

  Color _formatColor(String format) {
    switch (format) {
      case 'Video':
        return AppColors.purple;
      case 'In Person':
        return AppColors.teal;
      case 'Phone':
        return AppColors.amber;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final interviews = _filtered;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Interviews',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.push('/business/schedule-interview'),
            child: const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: ['Upcoming', 'Past', 'All'].map((label) {
                final selected = _filter == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.teal : Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: selected
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Interview list
          Expanded(
            child: interviews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 48, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        const Text(
                          'No interviews scheduled',
                          style: TextStyle(fontSize: 15, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: interviews.length,
                    itemBuilder: (context, index) {
                      final iv = interviews[index];
                      final name = iv['candidateName'] as String? ?? '';
                      final initials = iv['candidateInitials'] as String? ?? '??';
                      final format = iv['format'] as String? ?? '';

                      return GestureDetector(
                        onTap: () => context.push('/business/interview/${iv['id']}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [AppColors.cardShadow],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Candidate row
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _avatarColor(name),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.charcoal,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          iv['jobTitle'] as String? ?? '',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Date + time
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${iv['date']} \u00B7 ${iv['time']}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Format pill + status badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _formatColor(format),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      format,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  StatusBadge(status: iv['status'] as String? ?? ''),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
