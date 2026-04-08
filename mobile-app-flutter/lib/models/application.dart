/// Typed application model — mirrors Swift ApplicationDTO.
///
/// Replaces all raw `Map<String, dynamic>` application usage.
library;

import 'package:plagit/core/mock/mock_data.dart';

// ─────────────────────────────────────────────
// ApplicationStatus
// ─────────────────────────────────────────────

/// Every lifecycle state a candidate application can be in.
enum ApplicationStatus {
  applied,
  underReview,
  shortlisted,
  interviewScheduled,
  rejected,
  withdrawn,
  hired;

  /// Human-readable label for UI display.
  String get displayName => switch (this) {
        applied => 'Applied',
        underReview => 'Under Review',
        shortlisted => 'Shortlisted',
        interviewScheduled => 'Interview Scheduled',
        rejected => 'Rejected',
        withdrawn => 'Withdrawn',
        hired => 'Hired',
      };

  /// Parse a display-name or camelCase string into the enum value.
  ///
  /// Falls back to [applied] for unrecognised values.
  static ApplicationStatus fromString(String s) {
    final lower = s.toLowerCase().replaceAll(' ', '');
    return switch (lower) {
      'applied' => applied,
      'underreview' => underReview,
      'shortlisted' => shortlisted,
      'interviewscheduled' => interviewScheduled,
      'rejected' => rejected,
      'withdrawn' => withdrawn,
      'hired' => hired,
      _ => applied,
    };
  }
}

// ─────────────────────────────────────────────
// Application
// ─────────────────────────────────────────────

/// A candidate's application to a job.
class Application {
  final String id;
  final String jobTitle;
  final String company;
  final String location;
  final ApplicationStatus status;
  final String date;
  final String? salary;
  final String? interviewDate;
  final String? interviewType;

  const Application({
    required this.id,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.status,
    required this.date,
    this.salary,
    this.interviewDate,
    this.interviewType,
  });

  // ── JSON serialisation ──

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id']?.toString() ?? '',
      jobTitle: json['job_title'] as String? ?? json['jobTitle'] as String? ?? '',
      company: json['business_name'] as String? ?? json['company'] as String? ?? '',
      location: json['job_location'] as String? ?? json['location'] as String? ?? '',
      status: ApplicationStatus.fromString(json['status'] as String? ?? ''),
      date: json['applied_at'] as String? ?? json['date'] as String? ?? json['created_at'] as String? ?? '',
      salary: json['salary'] as String?,
      interviewDate: json['interview_date'] as String? ?? json['interviewDate'] as String?,
      interviewType: json['interview_type'] as String? ?? json['employment_type'] as String? ?? json['interviewType'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobTitle': jobTitle,
        'company': company,
        'location': location,
        'status': status.displayName,
        'date': date,
        'salary': salary,
        'interviewDate': interviewDate,
        'interviewType': interviewType,
      };

  // ── Mock factory ──

  /// Returns all mock applications as typed [Application] instances.
  static List<Application> mockAll() =>
      MockData.applications.map((a) => Application.fromJson(a)).toList();
}
