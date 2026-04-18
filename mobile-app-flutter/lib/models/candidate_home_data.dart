/// Composite model for the candidate home/dashboard screen.
///
/// Mirrors Swift CandidateHomeDTO — bundles profile, featured jobs,
/// nearby jobs, application stats, next interview, and unread count
/// into a single fetch result.
library;

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
    // Backend sends 'user', mock sends 'profile'
    final profileJson = json['user'] as Map<String, dynamic>?
        ?? json['profile'] as Map<String, dynamic>?
        ?? {};

    // Backend sends nested 'applications_summary', mock sends flat fields
    final appSummary = json['applications_summary'] as Map<String, dynamic>?
        ?? json['applicationsSummary'] as Map<String, dynamic>?;

    // Backend may not include featured/nearby jobs — those come from separate endpoints
    final featuredList = json['featured_jobs'] as List<dynamic>?
        ?? json['featuredJobs'] as List<dynamic>?;
    final nearbyList = json['nearby_jobs'] as List<dynamic>?
        ?? json['nearbyJobs'] as List<dynamic>?;

    // Next interview may be absent
    final nextInterviewJson = json['next_interview'] as Map<String, dynamic>?
        ?? json['nextInterview'] as Map<String, dynamic>?;

    return CandidateHomeData(
      profile: CandidateProfile.fromJson(profileJson),
      featuredJobs: featuredList
              ?.map((j) => Job.fromJson(j as Map<String, dynamic>))
              .toList() ??
          [],
      nearbyJobs: nearbyList
              ?.map((j) => Job.fromJson(j as Map<String, dynamic>))
              .toList() ??
          [],
      totalApplications: appSummary?['total'] as int?
          ?? json['totalApplications'] as int? ?? 0,
      underReviewCount: appSummary?['under_review'] as int?
          ?? appSummary?['underReview'] as int?
          ?? json['underReviewCount'] as int? ?? 0,
      interviewCount: appSummary?['interview'] as int?
          ?? json['interviewCount'] as int? ?? 0,
      offerCount: appSummary?['offer'] as int?
          ?? json['offerCount'] as int? ?? 0,
      nextInterview: nextInterviewJson != null
          ? Interview.fromJson(nextInterviewJson)
          : null,
      unreadMessages: json['unread_messages'] as int?
          ?? json['unreadMessages'] as int? ?? 0,
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
  /// Builds a mock home payload.
  ///
  /// Stats (1 applied / 0 review / 1 interview / 0 offer) and the
  /// "Senior Chef · 15 APR · 17:39 · Video · Confirmed" next interview
  /// match the Candidate Home reference screenshot (2026-04-14).
  static CandidateHomeData mock() {
    final allJobs = Job.mockAll();

    const nextInterview = Interview(
      id: 'mock_next_senior_chef',
      jobTitle: 'Senior Chef',
      company: 'The Ritz',
      date: '15 APR',
      time: '17:39',
      format: InterviewFormat.video,
      status: InterviewStatus.confirmed,
    );

    return CandidateHomeData(
      profile: CandidateProfile.mock(),
      featuredJobs: allJobs.where((j) => j.featured).toList(),
      nearbyJobs: allJobs.where((j) => j.location == 'London').toList(),
      totalApplications: 1,
      underReviewCount: 0,
      interviewCount: 1,
      offerCount: 0,
      nextInterview: nextInterview,
      unreadMessages: 1,
    );
  }
}
