/// Typed business insights snapshot derived from business-side data sources.
///
/// This is the minimal analytics contract we can support coherently today
/// without inventing backend-only metrics that do not exist yet.
library;

import 'package:plagit/models/business_home_data.dart';
import 'package:plagit/models/business_job.dart';

class BusinessInsightsTopJob {
  final String id;
  final String title;
  final int applicants;
  final int views;
  final int saves;

  const BusinessInsightsTopJob({
    required this.id,
    required this.title,
    required this.applicants,
    required this.views,
    required this.saves,
  });

  factory BusinessInsightsTopJob.fromJob(BusinessJob job) {
    return BusinessInsightsTopJob(
      id: job.id,
      title: job.title,
      applicants: job.applicants,
      views: job.views,
      saves: job.saves,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'applicants': applicants,
        'views': views,
        'saves': saves,
      };
}

class BusinessInsights {
  final int activeJobsCount;
  final int totalApplicants;
  final int interviewCount;
  final int hiredCount;
  final int unreadMessages;
  final int totalJobViews;
  final int totalJobSaves;
  final BusinessInsightsTopJob? topPerformingJob;

  const BusinessInsights({
    required this.activeJobsCount,
    required this.totalApplicants,
    required this.interviewCount,
    required this.hiredCount,
    required this.unreadMessages,
    required this.totalJobViews,
    required this.totalJobSaves,
    this.topPerformingJob,
  });

  factory BusinessInsights.fromHomeData(BusinessHomeData data) {
    final activeJobs = data.activeJobs;
    final topJob = activeJobs.isEmpty
        ? null
        : (activeJobs.toList()
              ..sort((a, b) {
                final applicants = b.applicants.compareTo(a.applicants);
                if (applicants != 0) return applicants;
                final views = b.views.compareTo(a.views);
                if (views != 0) return views;
                return b.saves.compareTo(a.saves);
              }))
            .first;

    return BusinessInsights(
      activeJobsCount: activeJobs.length,
      totalApplicants: data.totalApplicants,
      interviewCount: data.interviewCount,
      hiredCount: data.hiredCount,
      unreadMessages: data.unreadMessages,
      totalJobViews: activeJobs.fold<int>(0, (sum, job) => sum + job.views),
      totalJobSaves: activeJobs.fold<int>(0, (sum, job) => sum + job.saves),
      topPerformingJob:
          topJob != null ? BusinessInsightsTopJob.fromJob(topJob) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'activeJobsCount': activeJobsCount,
        'totalApplicants': totalApplicants,
        'interviewCount': interviewCount,
        'hiredCount': hiredCount,
        'unreadMessages': unreadMessages,
        'totalJobViews': totalJobViews,
        'totalJobSaves': totalJobSaves,
        'topPerformingJob': topPerformingJob?.toJson(),
      };
}
