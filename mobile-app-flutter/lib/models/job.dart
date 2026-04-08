/// Typed job model — mirrors Swift FeaturedJobDTO + JobDetailDTO.
///
/// Replaces all raw `Map<String, dynamic>` job usage on the candidate side.
library;

import 'package:plagit/core/mock/mock_data.dart';

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
    return Job(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      location: json['location'] as String? ?? '',
      salary: json['salary'] as String? ?? json['salaryRange'] as String? ?? '',
      contract:
          json['contract'] as String? ?? json['contractType'] as String? ?? '',
      featured: json['featured'] as bool? ?? false,
      urgent: json['urgent'] as bool? ?? false,
      description: json['description'] as String?,
      requirements: (json['requirements'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      benefits: (json['benefits'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      distance: json['distance'] as String?,
      shift: json['shift'] as String?,
      postedDate: json['postedDate'] as String? ?? json['posted'] as String?,
      applicantCount: json['applicantCount'] as int? ?? json['applicants'] as int?,
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
