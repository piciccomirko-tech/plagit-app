/// Typed applicant model — represents a candidate who applied to a business job.
///
/// Used on the business side to review and manage incoming applications.
library;

import 'package:plagit/core/mock/mock_data.dart';

// -----------------------------------------
// ApplicantStatus
// -----------------------------------------

/// Status of an applicant in the business hiring pipeline.
enum ApplicantStatus {
  applied,
  shortlisted,
  underReview,
  interviewScheduled,
  rejected;

  /// Human-readable label for UI display.
  String get displayName => switch (this) {
        applied => 'Applied',
        shortlisted => 'Shortlisted',
        underReview => 'Under Review',
        interviewScheduled => 'Interview Scheduled',
        rejected => 'Rejected',
      };

  /// Parse a string into the enum value. Falls back to [applied].
  static ApplicantStatus fromString(String s) {
    final lower = s.toLowerCase().replaceAll(' ', '');
    return switch (lower) {
      'applied' => applied,
      'shortlisted' => shortlisted,
      'underreview' => underReview,
      'interviewscheduled' => interviewScheduled,
      'rejected' => rejected,
      _ => applied,
    };
  }
}

// -----------------------------------------
// Applicant
// -----------------------------------------

/// A candidate who has applied to one of the business's jobs.
class Applicant {
  final String id;
  final String name;
  final String initials;
  final String role;
  final String jobId;
  final ApplicantStatus status;
  final String date;
  final String experience;
  final String location;
  final bool verified;
  final String? bio;
  final List<String>? languages;
  final String? availability;
  final String? salaryExpectation;
  final String? interviewDate;
  final String? interviewType;

  const Applicant({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    required this.jobId,
    this.status = ApplicantStatus.applied,
    required this.date,
    required this.experience,
    required this.location,
    this.verified = false,
    this.bio,
    this.languages,
    this.availability,
    this.salaryExpectation,
    this.interviewDate,
    this.interviewType,
  });

  // -- JSON serialisation --

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      role: json['role'] as String? ?? '',
      jobId: json['jobId'] as String? ?? '',
      status: ApplicantStatus.fromString(json['status'] as String? ?? 'Applied'),
      date: json['date'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      location: json['location'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
      bio: json['bio'] as String?,
      languages: (json['languages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      availability: json['availability'] as String?,
      salaryExpectation: json['salaryExpectation'] as String?,
      interviewDate: json['interviewDate'] as String?,
      interviewType: json['interviewType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initials': initials,
        'role': role,
        'jobId': jobId,
        'status': status.displayName,
        'date': date,
        'experience': experience,
        'location': location,
        'verified': verified,
        'bio': bio,
        'languages': languages,
        'availability': availability,
        'salaryExpectation': salaryExpectation,
        'interviewDate': interviewDate,
        'interviewType': interviewType,
      };

  // -- Mock factory --

  /// Returns all mock applicants as typed [Applicant] instances.
  static List<Applicant> mockAll() =>
      MockData.businessApplicants.map((a) => Applicant.fromJson(a)).toList();
}
