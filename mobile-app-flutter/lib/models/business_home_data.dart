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
    final profileJson =
        (json['profile'] ?? json['business']) as Map<String, dynamic>?;
    final stats = (json['stats'] as Map<String, dynamic>?) ?? const {};
    final nextInterviewJson =
        (json['nextInterview'] ?? json['next_interview']) as Map<String, dynamic>?;
    return BusinessHomeData(
      profile: BusinessProfile.fromJson(profileJson ?? const {}),
      activeJobs: (json['activeJobs'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(BusinessJob.fromJson)
              .toList() ??
          [],
      recentApplicants: (json['recentApplicants'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(Applicant.fromJson)
              .toList() ??
          [],
      recommendedCandidates: (json['recommendedCandidates'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(QuickPlugCandidate.fromJson)
              .toList() ??
          [],
      nextInterview: nextInterviewJson != null
          ? BusinessInterview.fromJson(nextInterviewJson)
          : null,
      recentConversations: (json['recentConversations'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(BusinessConversation.fromJson)
              .toList() ??
          [],
      totalApplicants: (json['totalApplicants'] ?? stats['total_applicants']) as int? ?? 0,
      interviewCount: (json['interviewCount'] ?? stats['interviews']) as int? ?? 0,
      hiredCount: (json['hiredCount'] ?? stats['hired']) as int? ?? 0,
      unreadMessages: (json['unreadMessages'] ?? json['unread_messages']) as int? ?? 0,
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
