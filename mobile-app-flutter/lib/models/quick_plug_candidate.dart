/// Typed QuickPlug candidate model — represents a swipe-able candidate card.
///
/// Used in the business QuickPlug (Tinder-style) feature for rapid
/// candidate discovery and interest signalling.
library;

import 'package:plagit/core/mock/mock_data.dart';

// -----------------------------------------
// QuickPlugCandidate
// -----------------------------------------

/// A candidate card in the QuickPlug swipe deck.
class QuickPlugCandidate {
  final String id;
  final String name;
  final String initials;
  final String role;
  final String location;
  final String experience;
  final bool verified;
  final List<String> tags;
  final String summary;

  const QuickPlugCandidate({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    required this.location,
    required this.experience,
    this.verified = false,
    this.tags = const [],
    required this.summary,
  });

  // -- JSON serialisation --

  factory QuickPlugCandidate.fromJson(Map<String, dynamic> json) {
    String stringOf(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    bool boolOf(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        if (value is bool) return value;
        if (value is num) return value != 0;
        final lower = value.toString().trim().toLowerCase();
        if (lower == 'true' || lower == '1' || lower == 'yes') return true;
        if (lower == 'false' || lower == '0' || lower == 'no') return false;
      }
      return false;
    }

    List<String> stringListOf(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        if (value is List) {
          return value
              .map((e) => e?.toString().trim() ?? '')
              .where((e) => e.isNotEmpty)
              .toList();
        }
        final text = value.toString().trim();
        if (text.isEmpty) continue;
        return text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return const [];
    }

    String initialsFromName(String name) {
      final parts = name
          .split(RegExp(r'\s+'))
          .where((part) => part.trim().isNotEmpty)
          .toList();
      if (parts.isEmpty) return '';
      String takeFirst(String value) => value.isEmpty ? '' : value.substring(0, 1);
      if (parts.length == 1) {
        final word = parts.first;
        return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
      }
      return '${takeFirst(parts.first)}${takeFirst(parts.last)}'.toUpperCase();
    }

    final name = stringOf(const [
      'name',
      'candidateName',
      'candidate_name',
      'fullName',
      'full_name',
    ]);
    final initials = stringOf(const [
      'initials',
      'candidateInitials',
      'candidate_initials',
    ]);

    return QuickPlugCandidate(
      id: stringOf(const ['id', 'candidateId', 'candidate_id']),
      name: name,
      initials: initials.isNotEmpty ? initials : initialsFromName(name),
      role: stringOf(const [
        'role',
        'headline',
        'currentRole',
        'current_role',
        'jobTitle',
        'job_title',
      ]),
      location: stringOf(const ['location', 'city', 'candidateLocation', 'candidate_location']),
      experience: stringOf(const [
        'experience',
        'experienceLabel',
        'experience_label',
        'yearsExperience',
        'years_experience',
      ]),
      verified: boolOf(const ['verified', 'isVerified', 'is_verified']),
      tags: stringListOf(const ['tags', 'skills', 'topSkills', 'top_skills']),
      summary: stringOf(const ['summary', 'bio', 'about', 'profileSummary', 'profile_summary']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'initials': initials,
        'role': role,
        'location': location,
        'experience': experience,
        'verified': verified,
        'tags': tags,
        'summary': summary,
      };

  // -- Mock factory --

  /// Returns all mock QuickPlug candidates as typed instances.
  static List<QuickPlugCandidate> mockAll() =>
      MockData.quickPlugCandidates
          .map((c) => QuickPlugCandidate.fromJson(c))
          .toList();
}
