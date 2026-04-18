import 'package:flutter/material.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/views/home/worker_home_view.dart';
import 'package:plagit/features/candidate/views/candidate_jobs_tab.dart';
import 'package:plagit/features/candidate/views/candidate_quick_plug_view.dart';
import 'package:plagit/features/candidate/views/candidate_profile_tab.dart';

class CandidateHomeView extends StatefulWidget {
  const CandidateHomeView({super.key});

  @override
  State<CandidateHomeView> createState() => _CandidateHomeViewState();
}

class _CandidateHomeViewState extends State<CandidateHomeView> {
  int _currentIndex = 0;

  static const _homeIndex = 0;
  static const _jobsIndex = 1;
  static const _quickPlugIndex = 2;
  static const _profileIndex = 3;

  final List<Widget> _tabs = const [
    WorkerHomeView(),
    CandidateJobsTab(),
    CandidateQuickPlugView(),
    CandidateProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Material(
        color: Colors.white,
        elevation: 8,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildTab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', index: _homeIndex),
                  _buildTab(icon: Icons.work_outline, activeIcon: Icons.work, label: 'Jobs', index: _jobsIndex),
                  _buildCenterAction(),
                  _buildTab(icon: Icons.bolt_outlined, activeIcon: Icons.bolt, label: 'Quick Plug', index: _quickPlugIndex, isPurple: true),
                  _buildTab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', index: _profileIndex),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool isPurple = false,
  }) {
    final active = _currentIndex == index;
    final color = isPurple
        ? (active ? AppColors.purple : AppColors.purple.withValues(alpha: 0.5))
        : (active ? AppColors.teal : AppColors.tertiary);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(active ? activeIcon : icon, size: 22, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterAction() {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _currentIndex = _quickPlugIndex),
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.teal, AppColors.darkTeal],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 24, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
