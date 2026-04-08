import 'package:flutter/material.dart';
import 'package:plagit/config/app_theme.dart';
import 'package:plagit/features/business/views/business_dashboard_tab.dart';
import 'package:plagit/features/business/views/business_jobs_tab.dart';
import 'package:plagit/features/business/views/business_interviews_tab.dart';
import 'package:plagit/features/business/views/business_messages_tab.dart';
import 'package:plagit/features/business/views/business_profile_tab.dart';

/// Root business view with 5 bottom tabs — mirrors BusinessHomeView.swift.
class BusinessHomeView extends StatefulWidget {
  const BusinessHomeView({super.key});

  @override
  State<BusinessHomeView> createState() => _BusinessHomeViewState();
}

class _BusinessHomeViewState extends State<BusinessHomeView> {
  int _currentIndex = 0;

  final _tabs = const [
    BusinessDashboardTab(),
    BusinessJobsTab(),
    BusinessInterviewsTab(),
    BusinessMessagesTab(),
    BusinessProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.cardBackground,
        indicatorColor: AppColors.indigo.withValues(alpha: 0.10),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: AppColors.indigo), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.work_outline), selectedIcon: Icon(Icons.work, color: AppColors.indigo), label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.event_outlined), selectedIcon: Icon(Icons.event, color: AppColors.indigo), label: 'Interviews'),
          NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat, color: AppColors.indigo), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.store_outlined), selectedIcon: Icon(Icons.store, color: AppColors.indigo), label: 'Profile'),
        ],
      ),
    );
  }
}
