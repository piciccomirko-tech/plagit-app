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
    return QuickPlugCandidate(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      role: json['role'] as String? ?? '',
      location: json['location'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      summary: json['summary'] as String? ?? '',
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
