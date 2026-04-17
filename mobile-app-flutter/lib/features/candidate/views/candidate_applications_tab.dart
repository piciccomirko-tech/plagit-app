import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/models/application.dart';
import 'package:plagit/providers/candidate_providers.dart';
import 'package:plagit/core/widgets/directional_chevron.dart';

class CandidateApplicationsTab extends StatefulWidget {
  const CandidateApplicationsTab({super.key});

  @override
  State<CandidateApplicationsTab> createState() =>
      _CandidateApplicationsTabState();
}

class _CandidateApplicationsTabState extends State<CandidateApplicationsTab> {
  static const _filters = [
    'All',
    'Applied',
    'Under Review',
    'Interview Scheduled',
    'Shortlisted',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CandidateApplicationsProvider>().load();
    });
  }

  Color _avatarColor(String name) {
    final hue = (name.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1, hue, 0.55, 0.50).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CandidateApplicationsProvider>();

    // Loading state
    if (provider.loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'My Applications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.teal)),
      );
    }

    // Error state
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'My Applications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.charcoal,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0.5,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.error!,
                style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<CandidateApplicationsProvider>().load(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = provider.applications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Applications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.charcoal,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter tab bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: _filters.map((f) {
                  final selected = provider.filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => provider.setFilter(f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.teal : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: selected
                                ? AppColors.teal
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              '${filtered.length} application${filtered.length == 1 ? '' : 's'}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Application list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_outlined,
                            size: 56, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        Text(
                          'No applications found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final app = filtered[i];
                      return _ApplicationCard(
                        app: app,
                        avatarColor: _avatarColor(app.company),
                        onTap: () => context.push(
                          '/candidate/application/${app.id}',
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

class _ApplicationCard extends StatelessWidget {
  final Application app;
  final Color avatarColor;
  final VoidCallback onTap;

  const _ApplicationCard({
    required this.app,
    required this.avatarColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final initial = app.company.isNotEmpty ? app.company[0] : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: AppColors.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + company
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.jobTitle,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.charcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${app.company} \u00B7 ${app.location}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: app.status.displayName),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Applied ${app.date}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.tertiary,
                  ),
                ),
                const Spacer(),
                const ForwardChevron(size: 20, color: AppColors.tertiary,),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
