/// Typed interview model — mirrors Swift InterviewDTO.
///
/// Replaces all raw `Map<String, dynamic>` interview usage.
library;

import 'package:plagit/core/mock/mock_data.dart';

// ─────────────────────────────────────────────
// InterviewFormat
// ─────────────────────────────────────────────

/// How the interview will be conducted.
enum InterviewFormat {
  video,
  inPerson,
  phone;

  String get displayName => switch (this) {
        video => 'Video',
        inPerson => 'In Person',
        phone => 'Phone',
      };

  /// Parse a display-name string into the enum value.
  static InterviewFormat fromString(String s) {
    final lower = s.toLowerCase().replaceAll(' ', '');
    return switch (lower) {
      'video' => video,
      'inperson' => inPerson,
      'phone' => phone,
      _ => video,
    };
  }
}

// ─────────────────────────────────────────────
// InterviewStatus
// ─────────────────────────────────────────────

/// Current state of a scheduled interview.
enum InterviewStatus {
  confirmed,
  invited,
  completed,
  noShow,
  cancelled;

  String get displayName => switch (this) {
        confirmed => 'Confirmed',
        invited => 'Invited',
        completed => 'Completed',
        noShow => 'No Show',
        cancelled => 'Cancelled',
      };

  /// Parse a display-name string into the enum value.
  static InterviewStatus fromString(String s) {
    final lower = s.toLowerCase().replaceAll(' ', '');
    return switch (lower) {
      'confirmed' => confirmed,
      'invited' => invited,
      'completed' => completed,
      'noshow' => noShow,
      'cancelled' || 'canceled' => cancelled,
      _ => invited,
    };
  }
}

// ─────────────────────────────────────────────
// Interview
// ─────────────────────────────────────────────

/// A scheduled interview for the candidate.
class Interview {
  final String id;
  final String jobTitle;
  final String company;
  final String date;
  final String time;
  final InterviewFormat format;
  final InterviewStatus status;
  final String? link;
  final String? location;
  final String? notes;

  const Interview({
    required this.id,
    required this.jobTitle,
    required this.company,
    required this.date,
    required this.time,
    required this.format,
    required this.status,
    this.link,
    this.location,
    this.notes,
  });

  // ── JSON serialisation ──

  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      id: json['id']?.toString() ?? '',
      jobTitle: json['jobTitle'] as String? ?? '',
      company: json['company'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      format: InterviewFormat.fromString(json['format'] as String? ?? ''),
      status: InterviewStatus.fromString(json['status'] as String? ?? ''),
      link: json['link'] as String?,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'jobTitle': jobTitle,
        'company': company,
        'date': date,
        'time': time,
        'format': format.displayName,
        'status': status.displayName,
        'link': link,
        'location': location,
        'notes': notes,
      };

  // ── Mock factory ──

  /// Returns all mock interviews as typed [Interview] instances.
  static List<Interview> mockAll() =>
      MockData.interviews.map((i) => Interview.fromJson(i)).toList();
}
