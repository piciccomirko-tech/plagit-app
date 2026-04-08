import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';

class CandidateInterviewsView extends StatefulWidget {
  const CandidateInterviewsView({super.key});

  @override
  State<CandidateInterviewsView> createState() =>
      _CandidateInterviewsViewState();
}

class _CandidateInterviewsViewState extends State<CandidateInterviewsView> {
  String _filter = 'Upcoming';

  List<Map<String, dynamic>> get _filteredInterviews {
    final all = MockData.interviews.cast<Map<String, dynamic>>();
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

  @override
  Widget build(BuildContext context) {
    final interviews = _filteredInterviews;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Interviews',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.charcoal),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: ['Upcoming', 'Past', 'All'].map((label) {
                final selected = _filter == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.teal : Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: selected
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: interviews.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: interviews.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final interview = interviews[index];
                      return _InterviewCard(interview: interview);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.calendar_today, size: 56, color: AppColors.tertiary),
          SizedBox(height: 16),
          Text(
            'No interviews yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InterviewCard extends StatelessWidget {
  final Map<String, dynamic> interview;
  const _InterviewCard({required this.interview});

  @override
  Widget build(BuildContext context) {
    final company = interview['company'] as String;
    final hue = MockData.companyHue(company);
    final avatarColor =
        HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.5).toColor();
    final isVideo = interview['format'] == 'Video';

    return GestureDetector(
      onTap: () => context.push('/candidate/interview/${interview['id']}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          children: [
            // Top row: avatar + role/company
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: avatarColor,
                  child: Text(
                    company[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interview['jobTitle'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      Text(
                        company,
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

            // Middle row: date + time
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 14, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  '${interview['date']}  \u2022  ${interview['time']}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom row: format pill + status badge
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: isVideo ? AppColors.purple : AppColors.teal,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    interview['format'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                StatusBadge(status: interview['status'] as String),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
