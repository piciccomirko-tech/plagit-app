import 'package:flutter/material.dart';
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
  int _i = 0;

  static const _teal = Color(0xFF2BB8B0);
  static const _purple = Color(0xFF8F59F5);
  static const _tertiary = Color(0xFF9EA0AD);

  final _tabs = const [
    CandidateDashboardTab(),
    CandidateJobsTab(),
    CandidateApplicationsTab(),
    CandidateMessagesTab(), // Connect tab
    CandidateProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _i, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Row(children: List.generate(5, (i) {
              final active = _i == i;
              final isPurple = i == 3; // Connect tab
              final icons = const [
                [Icons.home_outlined, Icons.home],
                [Icons.work_outline, Icons.work],
                [Icons.description_outlined, Icons.description],
                [Icons.bolt_outlined, Icons.bolt],
                [Icons.person_outline, Icons.person],
              ];
              final labels = const ['Home', 'Jobs', 'Applied', 'Connect', 'Profile'];
              final color = isPurple
                  ? (active ? _purple : _purple.withValues(alpha: 0.5))
                  : (active ? _teal : _tertiary);

              return Expanded(child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _i = i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(active ? icons[i][1] : icons[i][0], size: 22, color: color),
                    const SizedBox(height: 3),
                    Text(labels[i], style: TextStyle(
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      color: color,
                    )),
                  ]),
                ),
              ));
            })),
          ),
        ),
      ),
    );
  }
}
