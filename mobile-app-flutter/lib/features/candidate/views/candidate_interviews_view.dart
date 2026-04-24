import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';
import 'package:plagit/models/interview.dart';
import 'package:plagit/providers/candidate_providers.dart';

class CandidateInterviewsView extends StatefulWidget {
  const CandidateInterviewsView({super.key});

  @override
  State<CandidateInterviewsView> createState() =>
      _CandidateInterviewsViewState();
}

class _CandidateInterviewsViewState extends State<CandidateInterviewsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateInterviewsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateInterviewsProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.localizedInterviewsTitle(),
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
              children: _interviewFilters.map((label) {
                final selected = provider.filter == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () =>
                        context.read<CandidateInterviewsProvider>().setFilter(label),
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
                        l10n.localizedInterviewFilter(label),
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

          // Content — three-state
          Expanded(
            child: _buildContent(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CandidateInterviewsProvider provider) {
    // Loading state
    if (provider.loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.teal));
    }

    // Error state
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.red),
            const SizedBox(height: 12),
            Text(
              provider.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.secondary),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.read<CandidateInterviewsProvider>().load(),
              child: Text(
                AppLocalizations.of(context).retry,
                style: const TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Content state
    final interviews = provider.interviews;

    if (interviews.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: interviews.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final interview = interviews[index];
        return _InterviewCard(interview: interview);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 56, color: AppColors.tertiary),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).localizedNoInterviewsYet(),
            style: const TextStyle(
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

const _interviewFilters = ['Upcoming', 'Past', 'All'];

class _InterviewCard extends StatelessWidget {
  final Interview interview;
  const _InterviewCard({required this.interview});

  @override
  Widget build(BuildContext context) {
    final company = interview.company;
    final hue = MockData.companyHue(company);
    final avatarColor =
        HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.5).toColor();
    final isVideo = interview.format == InterviewFormat.video;

    return GestureDetector(
      onTap: () => context.push('/candidate/interview/${interview.id}'),
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
                        interview.jobTitle,
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
                  '${interview.date}  \u2022  ${interview.time}',
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
                    AppLocalizations.of(context)
                        .localizedInterviewFormatLabel(interview.format),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                StatusBadge(
                  status: AppLocalizations.of(context)
                      .localizedInterviewStatusLabel(interview.status),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension _CandidateInterviewsL10n on AppLocalizations {
  String localizedInterviewsTitle() => _lang(
        en: 'Interviews',
        it: 'Colloqui',
        ar: 'المقابلات',
      );

  String localizedInterviewFilter(String filter) {
    return switch (filter) {
      'Upcoming' => _lang(en: 'Upcoming', it: 'In arrivo', ar: 'القادمة'),
      'Past' => _lang(en: 'Past', it: 'Passate', ar: 'السابقة'),
      'All' => _lang(en: 'All', it: 'Tutte', ar: 'الكل'),
      _ => filter,
    };
  }

  String localizedNoInterviewsYet() => _lang(
        en: 'No interviews yet',
        it: 'Nessun colloquio ancora',
        ar: 'لا توجد مقابلات بعد',
      );

  String localizedInterviewStatusLabel(InterviewStatus status) {
    return switch (status) {
      InterviewStatus.confirmed => _lang(
          en: 'Confirmed',
          it: 'Confermato',
          ar: 'تم التأكيد',
        ),
      InterviewStatus.invited => _lang(
          en: 'Invited',
          it: 'Invitato',
          ar: 'تمت الدعوة',
        ),
      InterviewStatus.completed => _lang(
          en: 'Completed',
          it: 'Completato',
          ar: 'مكتملة',
        ),
      InterviewStatus.noShow => _lang(
          en: 'No Show',
          it: 'Assente',
          ar: 'لم يحضر',
        ),
      InterviewStatus.cancelled => _lang(
          en: 'Cancelled',
          it: 'Annullato',
          ar: 'ألغيت',
        ),
    };
  }

  String localizedInterviewFormatLabel(InterviewFormat format) {
    return switch (format) {
      InterviewFormat.video => _lang(en: 'Video', it: 'Video', ar: 'فيديو'),
      InterviewFormat.inPerson => _lang(
          en: 'In Person',
          it: 'Di persona',
          ar: 'حضوري',
        ),
      InterviewFormat.phone => _lang(
          en: 'Phone',
          it: 'Telefono',
          ar: 'هاتفي',
        ),
    };
  }

  String _lang({
    required String en,
    required String it,
    required String ar,
  }) {
    return switch (localeName.split('_').first) {
      'it' => it,
      'ar' => ar,
      _ => en,
    };
  }
}
