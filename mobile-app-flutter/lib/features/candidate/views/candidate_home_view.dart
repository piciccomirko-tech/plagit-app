import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/features/candidate/views/candidate_dashboard_tab.dart';
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

  // 4 real tabs: Home, Jobs, Quick Plug, Profile.
  // The center slot in the nav is a floating "+" action, not a tab.
  final List<Widget> _tabs = const [
    CandidateDashboardTab(),
    CandidateJobsTab(),
    CandidateQuickPlugView(),
    CandidateProfileTab(),
  ];

  // Mapping between visual slot index (0..4, with 2 = "+" action)
  // and the tab index in [_tabs] (0..3).
  int? _tabIndexForSlot(int slot) {
    switch (slot) {
      case 0:
        return 0; // Home
      case 1:
        return 1; // Jobs
      case 2:
        return null; // +  (action, not a tab)
      case 3:
        return 2; // Quick Plug
      case 4:
        return 3; // Profile
    }
    return null;
  }

  void _onSlotTap(int slot) {
    if (slot == 2) {
      _showQuickActions();
      return;
    }
    final tab = _tabIndexForSlot(slot);
    if (tab != null) {
      setState(() => _currentIndex = tab);
    }
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Quick actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.charcoal,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _QuickAction(
                  icon: Icons.search,
                  label: 'Find Jobs',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    context.push('/candidate/nearby');
                  },
                ),
                _QuickAction(
                  icon: Icons.description_outlined,
                  label: 'My Applications',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    context.push('/candidate/applications');
                  },
                ),
                _QuickAction(
                  icon: Icons.event_available,
                  label: 'Interviews',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    context.push('/candidate/interviews');
                  },
                ),
                _QuickAction(
                  icon: Icons.forum_outlined,
                  label: 'Community',
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    context.push('/feed');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _tabs[_currentIndex],
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        tabIndexForSlot: _tabIndexForSlot,
        onSlotTap: _onSlotTap,
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final int? Function(int slot) tabIndexForSlot;
  final void Function(int slot) onSlotTap;

  const _BottomNav({
    required this.currentIndex,
    required this.tabIndexForSlot,
    required this.onSlotTap,
  });

  @override
  Widget build(BuildContext context) {
    const icons = [
      [Icons.home_outlined, Icons.home],
      [Icons.work_outline, Icons.work],
      null, // + slot
      [Icons.bolt_outlined, Icons.bolt],
      [Icons.person_outline, Icons.person],
    ];
    const labels = ['Home', 'Jobs', '', 'Quick Plug', 'Profile'];

    return Material(
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
              children: List.generate(5, (i) {
              if (i == 2) {
                // "+" action button — bigger, teal, elevated
                return Expanded(
                  child: Center(
                    child: GestureDetector(
                      onTap: () => onSlotTap(i),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.teal, AppColors.darkTeal],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 26),
                      ),
                    ),
                  ),
                );
              }

              final tab = tabIndexForSlot(i);
              final active = tab != null && currentIndex == tab;
              final isPurple = i == 3;
              final color = isPurple
                  ? (active ? AppColors.purple : AppColors.purple.withValues(alpha: 0.5))
                  : (active ? AppColors.teal : AppColors.tertiary);

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSlotTap(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          active ? icons[i]![1] : icons[i]![0],
                          size: 22,
                          color: color,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.teal, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.charcoal,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.tertiary),
          ],
        ),
      ),
    );
  }
}
