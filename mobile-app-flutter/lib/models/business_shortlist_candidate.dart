/// Minimal typed candidate contract for the business Shortlist feature.
///
/// Today Shortlist is derived from existing applicants whose status is already
/// `shortlisted`, so this model only exposes fields we can support coherently
/// from the applicants pipeline without inventing separate shortlist metadata.
library;

import 'package:plagit/models/applicant.dart';

class BusinessShortlistCandidate {
  final String applicantId;
  final String candidateId;
  final String name;
  final String initials;
  final String role;
  final String location;
  final String experience;
  final bool verified;
  final String? jobTitle;

  const BusinessShortlistCandidate({
    required this.applicantId,
    required this.candidateId,
    required this.name,
    required this.initials,
    required this.role,
    required this.location,
    required this.experience,
    required this.verified,
    this.jobTitle,
  });

  factory BusinessShortlistCandidate.fromApplicant(Applicant applicant) {
    return BusinessShortlistCandidate(
      applicantId: applicant.id,
      candidateId: applicant.candidateId ?? applicant.id,
      name: applicant.name,
      initials: applicant.initials,
      role: applicant.role,
      location: applicant.location,
      experience: applicant.experience,
      verified: applicant.verified,
      jobTitle: applicant.jobTitle,
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
        'jobTitle': jobTitle,
      };
}
