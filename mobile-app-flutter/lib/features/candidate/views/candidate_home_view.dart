import 'package:flutter/material.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/features/candidate/views/candidate_dashboard_tab.dart';
import 'package:plagit/features/candidate/views/candidate_jobs_tab.dart';
import 'package:plagit/features/candidate/views/candidate_applications_tab.dart';
import 'package:plagit/features/candidate/views/candidate_quick_plug_view.dart';
import 'package:plagit/features/candidate/views/candidate_profile_tab.dart';

class CandidateHomeView extends StatefulWidget {
  const CandidateHomeView({super.key});

  @override
  State<CandidateHomeView> createState() => _CandidateHomeViewState();
}

class _CandidateHomeViewState extends State<CandidateHomeView> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    CandidateDashboardTab(),
    CandidateJobsTab(),
    CandidateApplicationsTab(),
    CandidateQuickPlugView(),
    CandidateProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Row(
              children: List.generate(5, (i) {
                final active = _currentIndex == i;
                final isPurple = i == 3;
                const icons = [
                  [Icons.home_outlined, Icons.home],
                  [Icons.work_outline, Icons.work],
                  [Icons.description_outlined, Icons.description],
                  [Icons.bolt_outlined, Icons.bolt],
                  [Icons.person_outline, Icons.person],
                ];
                const labels = [
                  'Home',
                  'Jobs',
                  'Applied',
                  'Quick Plug',
                  'Profile',
                ];
                final color = isPurple
                    ? (active
                        ? AppColors.purple
                        : AppColors.purple.withValues(alpha: 0.5))
                    : (active ? AppColors.teal : AppColors.tertiary);

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _currentIndex = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            active ? icons[i][1] : icons[i][0],
                            size: 22,
                            color: color,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w400,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
