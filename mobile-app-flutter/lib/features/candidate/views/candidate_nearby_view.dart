import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/job_card.dart';
import 'package:plagit/core/widgets/empty_state.dart';
import 'package:plagit/models/job.dart';

class CandidateNearbyView extends StatefulWidget {
  const CandidateNearbyView({super.key});

  @override
  State<CandidateNearbyView> createState() => _CandidateNearbyViewState();
}

class _CandidateNearbyViewState extends State<CandidateNearbyView> {
  int _selectedRadius = 5;
  final List<int> _radii = [1, 5, 10, 25];

  // Mock distances for London jobs
  final Map<String, String> _mockDistances = {
    '1': '0.5 mi',
    '3': '1.2 mi',
    '5': '2.8 mi',
    '6': '4.1 mi',
    '8': '5.3 mi',
  };

  List<Job> get _allLondonJobs =>
      Job.mockAll().where((j) => j.location == 'London').toList();

  List<Job> get _filteredJobs {
    final londonJobs = _allLondonJobs;
    if (_selectedRadius == 1) {
      // Only show first 2 jobs when radius is 1mi
      return londonJobs.take(2).toList();
    }
    return londonJobs;
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _filteredJobs;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Nearby Jobs',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: AppColors.charcoal),
            onPressed: () => context.push('/candidate/nearby-map'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Radius selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: _radii.map((r) {
                final selected = _selectedRadius == r;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedRadius = r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.teal : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: selected
                            ? null
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        '$r mi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Job count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '${jobs.length} jobs within $_selectedRadius miles',
              style: const TextStyle(fontSize: 13, color: AppColors.secondary),
            ),
          ),

          // Job list or empty state
          Expanded(
            child: jobs.isEmpty
                ? EmptyState(
                    icon: Icons.location_off,
                    title: 'No jobs in this radius',
                    subtitle: 'Try expanding your search radius',
                    buttonLabel: 'Expand Radius',
                    onTap: () => setState(() => _selectedRadius = 5),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      final distance = _mockDistances[job.id] ?? '${(index + 1) * 1.1} mi';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Distance label
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 4,
                                bottom: 6,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.near_me,
                                    size: 13,
                                    color: AppColors.teal,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    distance,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            JobCard(
                              job: job.toJson(),
                              onTap: () => context.push(
                                '/candidate/job/${job.id}',
                              ),
                            ),
                          ],
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
