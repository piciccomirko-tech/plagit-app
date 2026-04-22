/// Typed business-side candidate profile model.
///
/// Used by the business candidate profile flow to replace raw
/// `Map<String, dynamic>` payload handling with a stable contract.
library;

import 'package:plagit/core/mock/mock_data.dart';

class BusinessCandidateProfile {
  final String id;
  final String name;
  final String initials;
  final String? role;
  final String? location;
  final String? experience;
  final List<String> languages;
  final String? jobType;
  final String? bio;
  final List<String> skills;
  final bool verified;

  const BusinessCandidateProfile({
    required this.id,
    required this.name,
    required this.initials,
    this.role,
    this.location,
    this.experience,
    this.languages = const [],
    this.jobType,
    this.bio,
    this.skills = const [],
    this.verified = false,
  });

  factory BusinessCandidateProfile.fromJson(Map<String, dynamic> json) {
    final name =
        json['name']?.toString() ??
        json['candidateName']?.toString() ??
        json['candidate_name']?.toString() ??
        '';
    final role =
        json['role']?.toString() ??
        json['currentRole']?.toString() ??
        json['current_role']?.toString() ??
        json['headline']?.toString();
    final bio =
        json['bio']?.toString() ??
        json['summary']?.toString() ??
        json['about']?.toString();

    return BusinessCandidateProfile(
      id:
          json['id']?.toString() ??
          json['candidateId']?.toString() ??
          json['candidate_id']?.toString() ??
          '',
      name: name,
      initials:
          json['initials']?.toString() ??
          json['candidateInitials']?.toString() ??
          json['candidate_initials']?.toString() ??
          _deriveInitials(name),
      role: role,
      location: json['location']?.toString(),
      experience:
          json['experience']?.toString() ??
          json['experience_years']?.toString(),
      languages: _parseStringList(
        json['languages'] ?? json['spoken_languages'],
      ),
      jobType:
          json['jobType']?.toString() ??
          json['job_type']?.toString() ??
          json['employmentType']?.toString() ??
          json['employment_type']?.toString(),
      bio: bio,
      skills: _parseStringList(
        json['skills'] ?? json['tags'] ?? json['top_skills'],
      ),
      verified: _parseBool(
        json['verified'] ?? json['isVerified'] ?? json['is_verified'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initials': initials,
        'role': role,
        'location': location,
        'experience': experience,
        'languages': languages,
        'jobType': jobType,
        'bio': bio,
        'skills': skills,
        'verified': verified,
      };

  static BusinessCandidateProfile mockForId(String candidateId) {
    final applicant = MockData.businessApplicants.cast<Map<String, dynamic>?>()
        .firstWhere(
          (a) =>
              a?['candidateId']?.toString() == candidateId ||
              a?['id']?.toString() == candidateId,
          orElse: () => null,
        );
    final quickPlug =
        MockData.quickPlugCandidates.cast<Map<String, dynamic>?>().firstWhere(
              (c) => c?['id']?.toString() == candidateId,
              orElse: () => null,
            );

    final merged = <String, dynamic>{
      if (quickPlug != null) ...quickPlug,
      if (applicant != null) ...applicant,
      'id':
          applicant?['candidateId']?.toString() ??
          quickPlug?['id']?.toString() ??
          candidateId,
      'name':
          applicant?['name']?.toString() ??
          applicant?['candidateName']?.toString() ??
          quickPlug?['name']?.toString() ??
          'Mock Candidate',
      'initials':
          applicant?['initials']?.toString() ??
          applicant?['candidateInitials']?.toString() ??
          quickPlug?['initials']?.toString(),
      'role':
          applicant?['role']?.toString() ?? quickPlug?['role']?.toString(),
      'location':
          applicant?['location']?.toString() ??
          quickPlug?['location']?.toString(),
      'experience':
          applicant?['experience']?.toString() ??
          quickPlug?['experience']?.toString(),
      'languages': applicant?['languages'],
      'job_type': applicant?['availability']?.toString(),
      'bio':
          applicant?['bio']?.toString() ?? quickPlug?['summary']?.toString(),
      'skills': applicant?['languages'] ?? quickPlug?['tags'],
      'verified':
          applicant?['verified'] ?? quickPlug?['verified'] ?? false,
    };

    return BusinessCandidateProfile.fromJson(merged);
  }

  static List<String> _parseStringList(Object? value) {
    if (value is List) {
      return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(RegExp(r'[\n,]+'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }

  static bool _parseBool(Object? value) {
    return switch (value) {
      bool b => b,
      num n => n != 0,
      String s =>
        s.toLowerCase() == 'true' || s == '1' || s.toLowerCase() == 'yes',
      _ => false,
    };
  }

  static String _deriveInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    final list = parts.take(2).toList();
    if (list.isEmpty) return '?';
    if (list.length == 1) return list.first[0].toUpperCase();
    return '${list.first[0]}${list.last[0]}'.toUpperCase();
  }
}
