/// Composite model for the candidate home/dashboard screen.
///
/// Mirrors Swift CandidateHomeDTO — bundles profile, featured jobs,
/// nearby jobs, application stats, next interview, and unread count
/// into a single fetch result.
library;

import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/models/candidate_profile.dart';
import 'package:plagit/models/interview.dart';
import 'package:plagit/models/job.dart';

class CandidateHomeData {
  final CandidateProfile profile;
  final List<Job> featuredJobs;
  final List<Job> nearbyJobs;
  final int totalApplications;
  final int underReviewCount;
  final int interviewCount;
  final int offerCount;
  final Interview? nextInterview;
  final int unreadMessages;

  const CandidateHomeData({
    required this.profile,
    required this.featuredJobs,
    required this.nearbyJobs,
    required this.totalApplications,
    required this.underReviewCount,
    required this.interviewCount,
    required this.offerCount,
    this.nextInterview,
    required this.unreadMessages,
  });

  // ── JSON serialisation ──

  factory CandidateHomeData.fromJson(Map<String, dynamic> json) {
    return CandidateHomeData(
      profile: CandidateProfile.fromJson(
          json['profile'] as Map<String, dynamic>),
      featuredJobs: (json['featuredJobs'] as List<dynamic>?)
              ?.map((j) => Job.fromJson(j as Map<String, dynamic>))
              .toList() ??
          [],
      nearbyJobs: (json['nearbyJobs'] as List<dynamic>?)
              ?.map((j) => Job.fromJson(j as Map<String, dynamic>))
              .toList() ??
          [],
      totalApplications: json['totalApplications'] as int? ?? 0,
      underReviewCount: json['underReviewCount'] as int? ?? 0,
      interviewCount: json['interviewCount'] as int? ?? 0,
      offerCount: json['offerCount'] as int? ?? 0,
      nextInterview: json['nextInterview'] != null
          ? Interview.fromJson(json['nextInterview'] as Map<String, dynamic>)
          : null,
      unreadMessages: json['unreadMessages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'profile': profile.toJson(),
        'featuredJobs': featuredJobs.map((j) => j.toJson()).toList(),
        'nearbyJobs': nearbyJobs.map((j) => j.toJson()).toList(),
        'totalApplications': totalApplications,
        'underReviewCount': underReviewCount,
        'interviewCount': interviewCount,
        'offerCount': offerCount,
        'nextInterview': nextInterview?.toJson(),
        'unreadMessages': unreadMessages,
      };

  // ── Mock factory ──

  /// Builds a mock home payload from [MockData].
  static CandidateHomeData mock() {
    final allJobs = Job.mockAll();
    final interviews = Interview.mockAll();
    final totalUnread = MockData.conversations
        .fold<int>(0, (sum, c) => sum + ((c['unread'] as int?) ?? 0));

    return CandidateHomeData(
      profile: CandidateProfile.mock(),
      featuredJobs: allJobs.where((j) => j.featured).toList(),
      nearbyJobs: allJobs.where((j) => j.location == 'London').toList(),
      totalApplications: MockData.applications.length,
      underReviewCount: MockData.applications
          .where((a) => a['status'] == 'Under Review')
          .length,
      interviewCount: MockData.interviews.length,
      offerCount: 0,
      nextInterview: interviews.isNotEmpty ? interviews.first : null,
      unreadMessages: totalUnread,
    );
  }
}
