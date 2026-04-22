/// Minimal typed candidate contract for the business Nearby Talent feature.
///
/// Today this is derived from business home recommended candidates, so it only
/// exposes fields we can support coherently without inventing location-based
/// data such as true distance or relocation filters.
library;

import 'package:plagit/models/quick_plug_candidate.dart';

class BusinessNearbyTalentCandidate {
  final String id;
  final String name;
  final String initials;
  final String role;
  final String location;
  final String experience;
  final bool verified;
  final List<String> tags;
  final String summary;

  const BusinessNearbyTalentCandidate({
    required this.id,
    required this.name,
    required this.initials,
    required this.role,
    required this.location,
    required this.experience,
    required this.verified,
    this.tags = const [],
    required this.summary,
  });

  factory BusinessNearbyTalentCandidate.fromQuickPlugCandidate(
    QuickPlugCandidate candidate,
  ) {
    return BusinessNearbyTalentCandidate(
      id: candidate.id,
      name: candidate.name,
      initials: candidate.initials,
      role: candidate.role,
      location: candidate.location,
      experience: candidate.experience,
      verified: candidate.verified,
      tags: candidate.tags,
      summary: candidate.summary,
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
}
