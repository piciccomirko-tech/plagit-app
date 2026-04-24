import 'package:flutter/material.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/features/business/views/business_dashboard_tab.dart';
import 'package:plagit/features/business/views/business_jobs_view.dart';
import 'package:plagit/features/business/views/business_quick_plug_view.dart';
import 'package:plagit/features/business/views/business_profile_view.dart';
import 'package:plagit/features/business/views/post_job_view.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

extension _BusinessHomeL10nX on AppLocalizations {
  String _local({
    required String en,
    required String it,
    required String ar,
  }) {
    if (localeName.startsWith('it')) return it;
    if (localeName.startsWith('ar')) return ar;
    return en;
  }

  String get businessHomeTabHome => _local(
        en: 'Home',
        it: 'Home',
        ar: 'الرئيسية',
      );

  String get businessHomeTabJobs => jobs;

  String get businessHomeTabQuickPlug => _local(
        en: 'Quick Plug',
        it: 'Quick Plug',
        ar: 'كويك بلج',
      );

  String get businessHomeTabProfile => _local(
        en: 'Profile',
        it: 'Profilo',
        ar: 'الملف',
      );
}

class BusinessHomeView extends StatefulWidget {
  const BusinessHomeView({super.key});

  @override
  State<BusinessHomeView> createState() => _BusinessHomeViewState();
}

class _BusinessHomeViewState extends State<BusinessHomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final tabs = [
      const BusinessDashboardTab(),
      const BusinessJobsView(),
      BusinessQuickPlugView(
        onBackToHome: () => setState(() => _currentIndex = 0),
      ),
      const BusinessProfileView(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: Material(
        color: Colors.white,
        elevation: 10,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 4, 6, 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildNavTab(
                    icon: Icons.home,
                    label: l.businessHomeTabHome,
                    active: _currentIndex == 0,
                    color: _currentIndex == 0
                        ? AppColors.teal
                        : AppColors.tertiary,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                  _buildNavTab(
                    icon: Icons.work_outline,
                    label: l.businessHomeTabJobs,
                    active: _currentIndex == 1,
                    color: _currentIndex == 1
                        ? AppColors.teal
                        : AppColors.tertiary,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                  _buildCenterPlus(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PostJobView()),
                    ),
                  ),
                  _buildNavTab(
                    icon: Icons.bolt,
                    label: l.businessHomeTabQuickPlug,
                    active: _currentIndex == 2,
                    color: _currentIndex == 2
                        ? AppColors.purple
                        : AppColors.purple.withValues(alpha: 0.68),
                    onTap: () => setState(() => _currentIndex = 2),
                  ),
                  _buildNavTab(
                    icon: Icons.person_outline,
                    label: l.businessHomeTabProfile,
                    active: _currentIndex == 3,
                    color: _currentIndex == 3
                        ? AppColors.teal
                        : AppColors.tertiary,
                    onTap: () => setState(() => _currentIndex = 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavTab({
    required IconData icon,
    required String label,
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
                height: 1.05,
                letterSpacing: active ? -0.1 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterPlus({required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, -2),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.teal.withValues(alpha: 0.24),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
