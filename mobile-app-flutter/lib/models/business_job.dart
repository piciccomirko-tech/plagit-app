/// Typed business job model — represents a job posted by a business.
///
/// Distinct from `Job` (candidate-side) which includes company info.
/// This model focuses on the business's own listing management.
library;

import 'package:plagit/core/mock/mock_data.dart';

// -----------------------------------------
// BusinessJobStatus
// -----------------------------------------

/// Status of a business-posted job.
enum BusinessJobStatus {
  active,
  draft,
  paused,
  closed;

  /// Human-readable label for UI display.
  String get displayName => switch (this) {
        active => 'Active',
        draft => 'Draft',
        paused => 'Paused',
        closed => 'Closed',
      };

  /// Parse a string into the enum value. Falls back to [draft].
  static BusinessJobStatus fromString(String s) {
    final lower = s.toLowerCase();
    return switch (lower) {
      'active' => active,
      'draft' => draft,
      'paused' => paused,
      'closed' => closed,
      _ => draft,
    };
  }
}

// -----------------------------------------
// BusinessJob
// -----------------------------------------

/// A job listing owned by the business.
class BusinessJob {
  final String id;
  final String title;
  final String contract;
  final String salary;
  final int applicants;
  final BusinessJobStatus status;
  final bool urgent;
  final bool featured;
  final String location;
  final String posted;
  final int views;
  final int saves;
  final String? description;
  final List<String>? requirements;
  final List<String>? benefits;

  const BusinessJob({
    required this.id,
    required this.title,
    required this.contract,
    required this.salary,
    this.applicants = 0,
    this.status = BusinessJobStatus.draft,
    this.urgent = false,
    this.featured = false,
    required this.location,
    required this.posted,
    this.views = 0,
    this.saves = 0,
    this.description,
    this.requirements,
    this.benefits,
  });

  // -- JSON serialisation --

  factory BusinessJob.fromJson(Map<String, dynamic> json) {
    return BusinessJob(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      contract: json['contract'] as String? ?? '',
      salary: json['salary'] as String? ?? '',
      applicants: json['applicants'] as int? ?? 0,
      status: BusinessJobStatus.fromString(json['status'] as String? ?? 'Draft'),
      urgent: json['urgent'] as bool? ?? false,
      featured: json['featured'] as bool? ?? false,
      location: json['location'] as String? ?? '',
      posted: json['posted'] as String? ?? '',
      views: json['views'] as int? ?? 0,
      saves: json['saves'] as int? ?? 0,
      description: json['description'] as String?,
      requirements: (json['requirements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      benefits: (json['benefits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'contract': contract,
        'salary': salary,
        'applicants': applicants,
        'status': status.displayName,
        'urgent': urgent,
        'featured': featured,
        'location': location,
        'posted': posted,
        'views': views,
        'saves': saves,
        'description': description,
        'requirements': requirements,
        'benefits': benefits,
      };

  // -- Mock factory --

  /// Returns all mock business jobs as typed [BusinessJob] instances.
  static List<BusinessJob> mockAll() =>
      MockData.businessJobs.map((j) => BusinessJob.fromJson(j)).toList();
}
