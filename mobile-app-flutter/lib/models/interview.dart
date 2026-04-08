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
    // Backend sends scheduled_at as ISO datetime; split into date + time
    final scheduledAt = json['scheduled_at'] as String?;
    String dateStr = json['date'] as String? ?? '';
    String timeStr = json['time'] as String? ?? '';
    if (scheduledAt != null && scheduledAt.isNotEmpty) {
      final dt = DateTime.tryParse(scheduledAt);
      if (dt != null) {
        dateStr = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        timeStr = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    return Interview(
      id: json['id']?.toString() ?? '',
      jobTitle: json['job_title'] as String? ?? json['jobTitle'] as String? ?? '',
      company: json['business_name'] as String? ?? json['company'] as String? ?? '',
      date: dateStr,
      time: timeStr,
      format: InterviewFormat.fromString(
          json['interview_type'] as String? ?? json['format'] as String? ?? ''),
      status: InterviewStatus.fromString(json['status'] as String? ?? ''),
      link: json['meeting_link'] as String? ?? json['link'] as String?,
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
