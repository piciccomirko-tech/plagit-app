/// Typed business interview model — represents an interview scheduled by the business.
///
/// Distinct from `Interview` (candidate-side) which includes company info.
/// This model focuses on the candidate being interviewed.
library;

import 'package:plagit/core/mock/mock_data.dart';

// -----------------------------------------
// BusinessInterview
// -----------------------------------------

/// An interview scheduled by the business with a candidate.
class BusinessInterview {
  final String id;
  final String candidateName;
  final String candidateInitials;
  final String candidateId;
  final String jobTitle;
  final String date;
  final String time;
  final String format; // 'Video' | 'In Person' | 'Phone'
  final String status; // 'Confirmed' | 'Invited' | 'Completed'
  final String? link;
  final String? location;
  final String? notes;

  const BusinessInterview({
    required this.id,
    required this.candidateName,
    required this.candidateInitials,
    required this.candidateId,
    required this.jobTitle,
    required this.date,
    required this.time,
    required this.format,
    required this.status,
    this.link,
    this.location,
    this.notes,
  });

  // -- JSON serialisation --

  factory BusinessInterview.fromJson(Map<String, dynamic> json) {
    return BusinessInterview(
      id: json['id'] as String? ?? '',
      candidateName: json['candidateName'] as String? ?? '',
      candidateInitials: json['candidateInitials'] as String? ?? '',
      candidateId: json['candidateId'] as String? ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      format: json['format'] as String? ?? 'Video',
      status: json['status'] as String? ?? 'Invited',
      link: json['link'] as String?,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'candidateName': candidateName,
        'candidateInitials': candidateInitials,
        'candidateId': candidateId,
        'jobTitle': jobTitle,
        'date': date,
        'time': time,
        'format': format,
        'status': status,
        'link': link,
        'location': location,
        'notes': notes,
      };

  // -- Mock factory --

  /// Returns all mock business interviews as typed [BusinessInterview] instances.
  static List<BusinessInterview> mockAll() =>
      MockData.businessInterviews
          .map((i) => BusinessInterview.fromJson(i))
          .toList();
}
