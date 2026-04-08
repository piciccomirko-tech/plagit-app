import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/core/widgets/job_card.dart';
import 'package:plagit/core/widgets/empty_state.dart';

class SavedJobsView extends StatefulWidget {
  const SavedJobsView({super.key});

  @override
  State<SavedJobsView> createState() => _SavedJobsViewState();
}

class _SavedJobsViewState extends State<SavedJobsView> {
  late Set<String> _savedIds;

  @override
  void initState() {
    super.initState();
    _savedIds = Set<String>.from(MockData.savedJobIds);
  }

  List<Map<String, dynamic>> get _savedJobs {
    return MockData.jobs
        .where((j) => _savedIds.contains(j['id'] as String))
        .toList()
        .cast<Map<String, dynamic>>();
  }

  void _confirmRemove(String jobId) {
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
              setState(() => _savedIds.remove(jobId));
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
    final jobs = _savedJobs;

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
              '${_savedIds.length} saved jobs',
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
                      final jobId = job['id'] as String;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: JobCard(
                          job: job,
                          showSave: true,
                          saved: true,
                          onTap: () => context.push(
                            '/candidate/job/$jobId',
                          ),
                          onSave: () => _confirmRemove(jobId),
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
