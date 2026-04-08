import 'package:flutter/material.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/features/business/views/business_dashboard_tab.dart';
import 'package:plagit/features/business/views/business_jobs_view.dart';
import 'package:plagit/features/business/views/business_applicants_view.dart';
import 'package:plagit/features/business/views/business_quick_plug_view.dart';
import 'package:plagit/features/business/views/business_profile_view.dart';

class BusinessHomeView extends StatefulWidget {
  const BusinessHomeView({super.key});

  @override
  State<BusinessHomeView> createState() => _BusinessHomeViewState();
}

class _BusinessHomeViewState extends State<BusinessHomeView> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    BusinessDashboardTab(),
    BusinessJobsView(),
    BusinessApplicantsView(),
    BusinessQuickPlugView(),
    BusinessProfileView(),
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
                  [Icons.people_outline, Icons.people],
                  [Icons.bolt_outlined, Icons.bolt],
                  [Icons.business_outlined, Icons.business],
                ];
                const labels = [
                  'Home',
                  'Jobs',
                  'Applicants',
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
