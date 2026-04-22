/// Typed business job model — represents a job posted by a business.
///
/// Distinct from `Job` (candidate-side) which includes company info.
/// This model focuses on the business's own listing management.
library;

import 'package:plagit/core/mock/mock_data.dart';
import 'package:plagit/l10n/generated/app_localizations.dart';

// -----------------------------------------
// BusinessJobStatus
// -----------------------------------------

/// Status of a business-posted job.
enum BusinessJobStatus {
  active,
  draft,
  paused,
  closed;

  /// Canonical English label — used as API key and for StatusBadge color match.
  String get displayName => switch (this) {
        active => 'Active',
        draft => 'Draft',
        paused => 'Paused',
        closed => 'Closed',
      };

  /// Localized label for UI rendering.
  String localizedLabel(AppLocalizations l) => switch (this) {
        active => _fallbackLabel(
          l,
          en: 'Active',
          it: 'Attivo',
          ar: 'نشط',
        ),
        draft => _fallbackLabel(
          l,
          en: 'Draft',
          it: 'Bozza',
          ar: 'مسودة',
        ),
        paused => _fallbackLabel(
          l,
          en: 'Paused',
          it: 'In pausa',
          ar: 'متوقف مؤقتا',
        ),
        closed => l.statusClosed,
      };

  /// Parse a string into the enum value. Falls back to [draft].
  static BusinessJobStatus fromString(String s) {
    final lower = s
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s_-]+'), '');
    return switch (lower) {
      'active' => active,
      'draft' => draft,
      'paused' => paused,
      'closed' => closed,
      _ => draft,
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
    final title =
        json['title']?.toString() ??
        json['jobTitle']?.toString() ??
        json['job_title']?.toString() ??
        '';
    return BusinessJob(
      id: json['id']?.toString() ?? '',
      title: title,
      contract:
          json['contract']?.toString() ??
          json['contractType']?.toString() ??
          json['contract_type']?.toString() ??
          '',
      salary:
          json['salary']?.toString() ??
          json['salaryRange']?.toString() ??
          json['salary_range']?.toString() ??
          '',
      applicants:
          (json['applicants'] as num?)?.toInt() ??
          (json['applicantsCount'] as num?)?.toInt() ??
          (json['applicants_count'] as num?)?.toInt() ??
          (json['applicantCount'] as num?)?.toInt() ??
          (json['applicant_count'] as num?)?.toInt() ??
          0,
      status: BusinessJobStatus.fromString(
        json['status']?.toString() ?? 'Draft',
      ),
      urgent: _parseBool(
        json['urgent'] ?? json['isUrgent'] ?? json['is_urgent'],
      ),
      featured: _parseBool(
        json['featured'] ?? json['isFeatured'] ?? json['is_featured'],
      ),
      location: json['location']?.toString() ?? '',
      posted:
          json['posted']?.toString() ??
          json['postedAt']?.toString() ??
          json['posted_at']?.toString() ??
          json['createdAt']?.toString() ??
          json['created_at']?.toString() ??
          '',
      views:
          (json['views'] as num?)?.toInt() ??
          (json['viewsCount'] as num?)?.toInt() ??
          (json['views_count'] as num?)?.toInt() ??
          0,
      saves:
          (json['saves'] as num?)?.toInt() ??
          (json['savesCount'] as num?)?.toInt() ??
          (json['saves_count'] as num?)?.toInt() ??
          0,
      description: json['description']?.toString(),
      requirements: _parseStringList(
        json['requirements'] ?? json['job_requirements'],
      ),
      benefits: _parseStringList(
        json['benefits'] ?? json['job_benefits'],
      ),
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

  static bool _parseBool(Object? value) {
    return switch (value) {
      bool b => b,
      num n => n != 0,
      String s =>
        s.toLowerCase() == 'true' || s == '1' || s.toLowerCase() == 'yes',
      _ => false,
    };
  }

  static List<String>? _parseStringList(Object? value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(RegExp(r'\s*,\s*'))
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return null;
  }
}
