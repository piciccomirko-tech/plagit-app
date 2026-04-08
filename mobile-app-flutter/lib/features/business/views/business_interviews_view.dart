import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:plagit/core/theme/app_colors.dart';
import 'package:plagit/core/widgets/status_badge.dart';
import 'package:plagit/models/business_interview.dart';
import 'package:plagit/providers/business_providers.dart';

/// Standalone business interviews screen (pushed from dashboard).
class BusinessInterviewsView extends StatefulWidget {
  const BusinessInterviewsView({super.key});

  @override
  State<BusinessInterviewsView> createState() => _BusinessInterviewsViewState();
}

class _BusinessInterviewsViewState extends State<BusinessInterviewsView> {
  String _filter = 'Upcoming';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessInterviewsProvider>().load();
    });
  }

  Color _avatarColor(String name) {
    final hue = (name.hashCode % 360).abs().toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.55, 0.45).toColor();
  }

  Color _formatColor(String format) {
    switch (format) {
      case 'Video':
        return AppColors.purple;
      case 'In Person':
        return AppColors.teal;
      case 'Phone':
        return AppColors.amber;
      default:
        return AppColors.secondary;
    }
  }

  List<BusinessInterview> _applyLocalFilter(
      List<BusinessInterview> all, String filter) {
    switch (filter) {
      case 'Upcoming':
        return all
            .where((i) => i.status == 'Confirmed' || i.status == 'Invited')
            .toList();
      case 'Past':
        return all.where((i) => i.status == 'Completed').toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BusinessInterviewsProvider>();

    // Loading state
    if (provider.loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Interviews',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.teal),
        ),
      );
    }

    // Error state
    if (provider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Interviews',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.charcoal),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(provider.error!, style: const TextStyle(color: AppColors.secondary)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.read<BusinessInterviewsProvider>().load(),
                child: const Text('Retry', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    }

    // Content
    final interviews = _applyLocalFilter(provider.interviews, _filter);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28, color: AppColors.charcoal),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Interviews',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.charcoal,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => context.push('/business/schedule-interview'),
            child: const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: ['Upcoming', 'Past', 'All'].map((label) {
                final selected = _filter == label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = label),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.teal : Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        border: selected
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : AppColors.secondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Interview list
          Expanded(
            child: interviews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, size: 48, color: AppColors.tertiary),
                        const SizedBox(height: 12),
                        const Text(
                          'No interviews scheduled',
                          style: TextStyle(fontSize: 15, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: interviews.length,
                    itemBuilder: (context, index) {
                      final iv = interviews[index];

                      return GestureDetector(
                        onTap: () => context.push('/business/interview/${iv.id}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [AppColors.cardShadow],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Candidate row
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _avatarColor(iv.candidateName),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      iv.candidateInitials,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          iv.candidateName,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.charcoal,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          iv.jobTitle,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Date + time
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${iv.date} \u00B7 ${iv.time}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Format pill + status badge
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _formatColor(iv.format),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      iv.format,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  StatusBadge(status: iv.status),
                                ],
                              ),
                            ],
                          ),
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
