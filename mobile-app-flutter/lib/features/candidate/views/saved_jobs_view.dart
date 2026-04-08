import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/job_card.dart';
import 'package:plagit/core/widgets/empty_state.dart';
import 'package:plagit/models/job.dart';
import 'package:plagit/providers/candidate_providers.dart';

class SavedJobsView extends StatelessWidget {
  const SavedJobsView({super.key});

  void _confirmRemove(BuildContext context, CandidateJobsProvider provider, String jobId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove from saved?'),
        content: const Text(
          'This job will be removed from your saved list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.secondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.toggleSave(jobId);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CandidateJobsProvider>(
      builder: (context, provider, _) {
        final savedIds = provider.savedIds;
        final allJobs = Job.mockAll();
        final jobs = allJobs.where((j) => savedIds.contains(j.id)).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Saved Jobs',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.charcoal,
              ),
            ),
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  '${savedIds.length} saved jobs',
                  style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                ),
              ),

              // List or empty state
              Expanded(
                child: jobs.isEmpty
                    ? EmptyState(
                        icon: Icons.favorite_border,
                        title: 'No saved jobs yet',
                        subtitle: 'Browse jobs and save the ones you like',
                        buttonLabel: 'Browse Jobs',
                        onTap: () => context.pop(),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: jobs.length,
                        itemBuilder: (context, index) {
                          final job = jobs[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: JobCard(
                              job: job.toJson(),
                              showSave: true,
                              saved: true,
                              onTap: () => context.push(
                                '/candidate/job/${job.id}',
                              ),
                              onSave: () => _confirmRemove(context, provider, job.id),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
