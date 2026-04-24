/// Typed job model — mirrors Swift FeaturedJobDTO + JobDetailDTO.
///
/// Replaces all raw `Map<String, dynamic>` job usage on the candidate side.
library;

import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/models/employment.dart';
export 'package:plagit/models/employment.dart';

/// A hospitality job listing.
class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String salary;
  final String contract; // 'Full-time' | 'Part-time' | 'Zero Hours' | 'Temporary'
  final bool featured;
  final bool urgent;
  final String? description;
  final List<String>? requirements;
  final List<String>? benefits;
  final String? distance;
  final String? shift;
  final String? postedDate;
  final int? applicantCount;
  final int? views;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.contract,
    this.featured = false,
    this.urgent = false,
    this.description,
    this.requirements,
    this.benefits,
    this.distance,
    this.shift,
    this.postedDate,
    this.applicantCount,
    this.views,
  });

  // ── JSON serialisation ──

  factory Job.fromJson(Map<String, dynamic> json) {
    // requirements/benefits: backend sends String, mock sends List<String>
    List<String>? parseStringOrList(dynamic raw) {
      if (raw is List) return raw.cast<String>();
      if (raw is String && raw.isNotEmpty) return raw.split('\n').where((s) => s.trim().isNotEmpty).toList();
      return null;
    }

    final business = json['business'] as Map<String, dynamic>?;
    final employer = json['employer'] as Map<String, dynamic>?;

    return Job(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      company: json['business_name'] as String?
          ?? json['company_name'] as String?
          ?? json['company'] as String?
          ?? business?['name'] as String?
          ?? employer?['name'] as String?
          ?? '',
      location: json['location'] as String? ?? '',
      salary: json['salary'] as String? ?? json['salaryRange'] as String? ?? '',
      contract: json['employment_type'] as String?
          ?? json['job_type'] as String?
          ?? json['contract'] as String?
          ?? json['contractType'] as String? ?? '',
      featured: json['is_featured'] as bool? ?? json['featured'] as bool? ?? false,
      urgent: json['is_urgent'] as bool? ?? json['urgent'] as bool? ?? false,
      description: json['description'] as String?,
      requirements: parseStringOrList(json['requirements']),
      benefits: parseStringOrList(json['benefits']),
      distance: json['distance'] as String?,
      shift: json['shift_hours'] as String? ?? json['shift'] as String?,
      postedDate: json['created_at'] as String?
          ?? json['postedDate'] as String?
          ?? json['posted'] as String?,
      applicantCount: json['applicant_count'] as int?
          ?? json['applicantCount'] as int?
          ?? json['applicants'] as int?,
      views: json['views'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'company': company,
        'location': location,
        'salary': salary,
        'contract': contract,
        'featured': featured,
        'urgent': urgent,
        'description': description,
        'requirements': requirements,
        'benefits': benefits,
        'distance': distance,
        'shift': shift,
        'postedDate': postedDate,
        'applicantCount': applicantCount,
        'views': views,
      };

  // ── Employment / compensation derivatives ──

  /// Typed employment type derived from the raw [contract] string.
  EmploymentType get employmentType => EmploymentType.fromString(contract);

  /// Human-readable employment label (e.g. "Full-time", "Casual").
  String get employmentLabel => employmentType.label;

  /// Typed compensation parsed from the legacy [salary] string
  /// (e.g. "£25,000/year", "£12/hr"). Structured fields (min/max,
  /// hourly, monthly) are populated best-effort — use
  /// [compensationDisplay] or [Compensation.displayLocalized] for
  /// the pre-formatted summary.
  Compensation get compensation =>
      Compensation.fromLegacy(salary, employmentType);

  /// Short single-line compensation summary parsed from the legacy [salary]
  /// string. Falls back to the raw salary string if it cannot be parsed
  /// into a structured figure.
  String get compensationDisplay {
    final parsed = compensation.display;
    return parsed == '—' ? salary : parsed;
  }

  /// Gallery of venue images for the job. Currently not carried on
  /// [Job] itself — returns an empty list so list tiles fall back
  /// cleanly to the initials placeholder.
  List<String> get venueImages => const [];

  // ── Mock factories ──

  /// Returns a single mock job by [index] (0-based) from [MockData.jobs].
  static Job mock(int index) {
    assert(index >= 0 && index < MockData.jobs.length,
        'Index out of range for MockData.jobs');
    return Job.fromJson(MockData.jobs[index]);
  }

  /// Returns all mock jobs as typed [Job] instances.
  static List<Job> mockAll() =>
      MockData.jobs.map((j) => Job.fromJson(j)).toList();
}
