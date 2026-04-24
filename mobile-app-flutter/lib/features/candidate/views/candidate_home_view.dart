import 'package:flutter/material.dart';

import 'package:plagit/features/candidate/views/candidate_dashboard_tab.dart';

/// Legacy candidate shell kept as a compatibility entry point.
///
/// The real candidate home is [CandidateDashboardTab], which is also the
/// screen mounted by `/candidate/home` in the router.
class CandidateHomeView extends StatelessWidget {
  const CandidateHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CandidateDashboardTab();
  }
}
