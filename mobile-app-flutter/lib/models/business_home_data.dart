/// Composite model for the business home/dashboard screen.
///
/// Mirrors Swift BusinessHomeDTO — bundles profile, active jobs,
/// recent applicants, recommended candidates, next interview, and
/// conversation data into a single fetch result.
library;

import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/models/applicant.dart';
import 'package:plagit/models/business_conversation.dart';
import 'package:plagit/models/business_interview.dart';
import 'package:plagit/models/business_job.dart';
import 'package:plagit/models/business_profile.dart';
import 'package:plagit/models/quick_plug_candidate.dart';

class BusinessHomeData {
  final BusinessProfile profile;
  final List<BusinessJob> activeJobs;
  final List<Applicant> recentApplicants;
  final List<QuickPlugCandidate> recommendedCandidates;
  final BusinessInterview? nextInterview;
  final List<BusinessConversation> recentConversations;
  final int totalApplicants;
  final int interviewCount;
  final int hiredCount;
  final int unreadMessages;

  const BusinessHomeData({
    required this.profile,
    required this.activeJobs,
    required this.recentApplicants,
    required this.recommendedCandidates,
    this.nextInterview,
    required this.recentConversations,
    required this.totalApplicants,
    required this.interviewCount,
    this.hiredCount = 0,
    required this.unreadMessages,
  });

  // -- JSON serialisation --

  factory BusinessHomeData.fromJson(Map<String, dynamic> json) {
    return BusinessHomeData(
      profile: BusinessProfile.fromJson(
          json['profile'] as Map<String, dynamic>),
      activeJobs: (json['activeJobs'] as List<dynamic>?)
              ?.map((j) => BusinessJob.fromJson(j as Map<String, dynamic>))
              .toList() ??
          [],
      recentApplicants: (json['recentApplicants'] as List<dynamic>?)
              ?.map((a) => Applicant.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
      recommendedCandidates: (json['recommendedCandidates'] as List<dynamic>?)
              ?.map((c) =>
                  QuickPlugCandidate.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      nextInterview: json['nextInterview'] != null
          ? BusinessInterview.fromJson(
              json['nextInterview'] as Map<String, dynamic>)
          : null,
      recentConversations: (json['recentConversations'] as List<dynamic>?)
              ?.map((c) =>
                  BusinessConversation.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      totalApplicants: json['totalApplicants'] as int? ?? 0,
      interviewCount: json['interviewCount'] as int? ?? 0,
      hiredCount: json['hiredCount'] as int? ?? 0,
      unreadMessages: json['unreadMessages'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'profile': profile.toJson(),
        'activeJobs': activeJobs.map((j) => j.toJson()).toList(),
        'recentApplicants':
            recentApplicants.map((a) => a.toJson()).toList(),
        'recommendedCandidates':
            recommendedCandidates.map((c) => c.toJson()).toList(),
        'nextInterview': nextInterview?.toJson(),
        'recentConversations':
            recentConversations.map((c) => c.toJson()).toList(),
        'totalApplicants': totalApplicants,
        'interviewCount': interviewCount,
        'hiredCount': hiredCount,
        'unreadMessages': unreadMessages,
      };

  // -- Mock factory --

  /// Builds a mock home payload from [MockData].
  static BusinessHomeData mock() {
    final allJobs = BusinessJob.mockAll();
    final activeJobs =
        allJobs.where((j) => j.status == BusinessJobStatus.active).toList();
    final allApplicants = Applicant.mockAll();
    final interviews = BusinessInterview.mockAll();
    final conversations = BusinessConversation.mockAll();
    final totalUnread = MockData.businessConversations
        .fold<int>(0, (sum, c) => sum + ((c['unread'] as int?) ?? 0));

    return BusinessHomeData(
      profile: BusinessProfile.mock(),
      activeJobs: activeJobs,
      recentApplicants: allApplicants.take(3).toList(),
      recommendedCandidates: QuickPlugCandidate.mockAll().take(3).toList(),
      nextInterview: interviews.isNotEmpty ? interviews.first : null,
      recentConversations: conversations,
      totalApplicants: allApplicants.length,
      interviewCount: interviews.length,
      hiredCount: 0,
      unreadMessages: totalUnread,
    );
  }
}
