/// Minimal typed candidate contract for the business Matches feature.
///
/// Today Matches is derived from the existing applicants pipeline for a single
/// job, so it only exposes fields we can support coherently from applicant
/// data without inventing a separate matching engine.
library;

import 'package:plagit/models/applicant.dart';

class BusinessMatchCandidate {
  final String applicantId;
  final String candidateId;
  final String name;
  final String initials;
  final String role;
  final String location;
  final String experience;
  final bool verified;
  final ApplicantStatus status;

  const BusinessMatchCandidate({
    required this.applicantId,
    required this.candidateId,
    required this.name,
    required this.initials,
    required this.role,
    required this.location,
    required this.experience,
    required this.verified,
    required this.status,
  });

  factory BusinessMatchCandidate.fromApplicant(Applicant applicant) {
    return BusinessMatchCandidate(
      applicantId: applicant.id,
      candidateId: applicant.candidateId ?? applicant.id,
      name: applicant.name,
      initials: applicant.initials,
      role: applicant.role,
      location: applicant.location,
      experience: applicant.experience,
      verified: applicant.verified,
      status: applicant.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'applicantId': applicantId,
        'candidateId': candidateId,
        'name': name,
        'initials': initials,
        'role': role,
        'location': location,
        'experience': experience,
        'verified': verified,
        'status': status.displayName,
      };
}
