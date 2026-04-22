/// Typed applicant model — represents a candidate who applied to a business job.
///
/// Used on the business side to review and manage incoming applications.
library;

import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

// -----------------------------------------
// ApplicantStatus
// -----------------------------------------

/// Status of an applicant in the business hiring pipeline.
enum ApplicantStatus {
  applied,
  shortlisted,
  underReview,
  interviewInvited,
  interviewScheduled,
  hired,
  rejected,
  withdrawn;

  /// Canonical English label — used for API filter values and color mapping.
  String get displayName => switch (this) {
        applied => 'Applied',
        shortlisted => 'Shortlisted',
        underReview => 'Under Review',
        interviewInvited => 'Interview Invited',
        interviewScheduled => 'Interview Scheduled',
        hired => 'Hired',
        rejected => 'Rejected',
        withdrawn => 'Withdrawn',
      };

  /// Localized label for UI display.
  String localizedLabel(AppLocalizations l) => switch (this) {
        applied => l.statusApplied,
        shortlisted => _fallbackLabel(
          l,
          en: 'Shortlisted',
          it: 'In shortlist',
          ar: 'في القائمة المختصرة',
        ),
        underReview => _fallbackLabel(
          l,
          en: 'Under Review',
          it: 'In revisione',
          ar: 'قيد المراجعة',
        ),
        interviewInvited => _fallbackLabel(
          l,
          en: 'Interview Invited',
          it: 'Invito al colloquio',
          ar: 'دعوة للمقابلة',
        ),
        interviewScheduled => _fallbackLabel(
          l,
          en: 'Interview Scheduled',
          it: 'Colloquio fissato',
          ar: 'موعد مقابلة محدد',
        ),
        hired => l.statusHired,
        rejected => l.statusRejected,
        withdrawn => _fallbackLabel(
          l,
          en: 'Withdrawn',
          it: 'Ritirata',
          ar: 'تم السحب',
        ),
      };

  /// Parse a string into the enum value. Falls back to [applied].
  static ApplicantStatus fromString(String s) {
    final lower = s
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_-]+'), '');
    return switch (lower) {
      'applied' => applied,
      'shortlisted' => shortlisted,
      'underreview' => underReview,
      'interviewinvited' => interviewInvited,
      'interviewscheduled' => interviewScheduled,
      'interview' => interviewScheduled,
      'hired' => hired,
      'rejected' => rejected,
      'withdrawn' => withdrawn,
      _ => applied,
    };
  }

  static bool matchesFilter(ApplicantStatus status, String filter) {
    final normalized = filter
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_-]+'), '');
    return switch (normalized) {
      '' || 'all' => true,
      'applied' => status == applied,
      'shortlisted' => status == shortlisted,
      'underreview' => status == underReview,
      'interview' =>
        status == interviewInvited || status == interviewScheduled,
      'interviewinvited' => status == interviewInvited,
      'interviewscheduled' => status == interviewScheduled,
      'rejected' => status == rejected,
      'hired' => status == hired,
      'withdrawn' => status == withdrawn,
      _ => status.displayName.toLowerCase() == filter.toLowerCase(),
    };
  }

  static String _fallbackLabel(
    AppLocalizations l, {
    required String en,
    required String it,
    required String ar,
  }) {
    if (l.localeName.startsWith('it')) return it;
    if (l.localeName.startsWith('ar')) return ar;
    return en;
  }
}

// -----------------------------------------
// Applicant
// -----------------------------------------

/// A candidate who has applied to one of the business's jobs.
class Applicant {
  final String id;
  final String? candidateId;
  final String name;
  final String initials;
  final String role;
  final String jobId;
  final String? jobTitle;
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
    this.candidateId,
    required this.name,
    required this.initials,
    required this.role,
    required this.jobId,
    this.jobTitle,
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
    final name =
        json['name']?.toString() ??
        json['candidateName']?.toString() ??
        json['candidate_name']?.toString() ??
        '';
    final role =
        json['role']?.toString() ??
        json['applied_role']?.toString() ??
        json['jobTitle']?.toString() ??
        json['job_title']?.toString() ??
        '';
    return Applicant(
      id: json['id']?.toString() ?? '',
      candidateId:
          json['candidateId']?.toString() ??
          json['candidate_id']?.toString(),
      name: name,
      initials:
          json['initials']?.toString() ??
          json['candidateInitials']?.toString() ??
          json['candidate_initials']?.toString() ??
          _deriveInitials(name),
      role: role,
      jobId:
          json['jobId']?.toString() ??
          json['job_id']?.toString() ??
          '',
      jobTitle:
          json['jobTitle']?.toString() ??
          json['job_title']?.toString() ??
          role,
      status: ApplicantStatus.fromString(
        json['status']?.toString() ?? 'Applied',
      ),
      date:
          json['date']?.toString() ??
          json['appliedAt']?.toString() ??
          json['applied_at']?.toString() ??
          json['createdAt']?.toString() ??
          json['created_at']?.toString() ??
          '',
      experience:
          json['experience']?.toString() ??
          json['experience_years']?.toString() ??
          '',
      location: json['location']?.toString() ?? '',
      verified: _parseVerified(
        json['verified'] ?? json['isVerified'] ?? json['is_verified'],
      ),
      bio: json['bio']?.toString(),
      languages: _parseStringList(json['languages']),
      availability:
          json['availability']?.toString() ??
          json['availability_type']?.toString(),
      salaryExpectation:
          json['salaryExpectation']?.toString() ??
          json['salary_expectation']?.toString(),
      interviewDate:
          json['interviewDate']?.toString() ??
          json['interview_date']?.toString(),
      interviewType:
          json['interviewType']?.toString() ??
          json['interview_type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'candidateId': candidateId,
        'name': name,
        'initials': initials,
        'role': role,
        'jobId': jobId,
        'jobTitle': jobTitle,
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

  static String _deriveInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return '';
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  static bool _parseVerified(Object? value) {
    return switch (value) {
      bool b => b,
      num n => n != 0,
      String s => switch (s.trim().toLowerCase()) {
          'true' || '1' || 'verified' => true,
          _ => false,
        },
      _ => false,
    };
  }

  static List<String>? _parseStringList(Object? value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return null;
  }
}
