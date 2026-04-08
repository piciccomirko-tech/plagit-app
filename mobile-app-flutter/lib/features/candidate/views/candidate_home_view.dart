import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/candidate/views/candidate_dashboard_tab.dart';
import 'package:plagit/features/candidate/views/candidate_jobs_tab.dart';
import 'package:plagit/features/candidate/views/candidate_applications_tab.dart';
import 'package:plagit/features/candidate/views/candidate_messages_tab.dart';
import 'package:plagit/features/candidate/views/candidate_profile_tab.dart';

class CandidateHomeView extends StatefulWidget {
  const CandidateHomeView({super.key});

  @override
  State<CandidateHomeView> createState() => _CandidateHomeViewState();
}

class _CandidateHomeViewState extends State<CandidateHomeView> {
  int _currentIndex = 0;

  final _tabs = const [
    CandidateDashboardTab(),
    CandidateJobsTab(),
    CandidateApplicationsTab(),
    CandidateMessagesTab(),
    CandidateProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -3))],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Row(
              children: List.generate(5, (i) {
                final isActive = _currentIndex == i;
                final icons = const [
                  [Icons.home_outlined, Icons.home],
                  [Icons.work_outline, Icons.work],
                  [Icons.description_outlined, Icons.description],
                  [Icons.chat_outlined, Icons.chat],
                  [Icons.person_outline, Icons.person],
                ];
                final labels = const ['Home', 'Find Work', 'Applied', 'Messages', 'Profile'];
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _currentIndex = i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(
                          isActive ? icons[i][1] : icons[i][0],
                          size: 22,
                          color: isActive ? AppColors.teal : AppColors.tertiary,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive ? AppColors.teal : AppColors.tertiary,
                          ),
                        ),
                      ]),
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
