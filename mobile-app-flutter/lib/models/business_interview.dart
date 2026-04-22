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
    final scheduledAt =
        json['scheduled_at'] as String? ?? json['scheduledAt'] as String?;
    var dateStr = json['date']?.toString() ?? '';
    var timeStr = json['time']?.toString() ?? '';

    if (scheduledAt != null && scheduledAt.isNotEmpty) {
      final dt = DateTime.tryParse(scheduledAt);
      if (dt != null) {
        dateStr = _formatDate(dt);
        timeStr = _formatTime(dt);
      }
    }

    final candidateName =
        json['candidateName']?.toString() ??
        json['candidate_name']?.toString() ??
        '';
    final format =
        _normalizeFormat(
          json['format']?.toString() ??
              json['type']?.toString() ??
              json['interview_type']?.toString(),
        ) ??
        'Video';
    final status = _normalizeStatus(json['status']?.toString()) ?? 'Invited';

    return BusinessInterview(
      id: json['id']?.toString() ?? '',
      candidateName: candidateName,
      candidateInitials:
          json['candidateInitials']?.toString() ??
          json['candidate_initials']?.toString() ??
          _deriveInitials(candidateName),
      candidateId:
          json['candidateId']?.toString() ??
          json['candidate_id']?.toString() ??
          '',
      jobTitle:
          json['jobTitle']?.toString() ?? json['job_title']?.toString() ?? '',
      date: dateStr,
      time: timeStr,
      format: format,
      status: status,
      link: json['link']?.toString() ?? json['meeting_link']?.toString(),
      location: json['location']?.toString(),
      notes: json['notes']?.toString(),
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
  static List<BusinessInterview> mockAll() => MockData.businessInterviews
      .map((i) => BusinessInterview.fromJson(i))
      .toList();

  static String _deriveInitials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    if (parts.isEmpty) return '';
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  static String? _normalizeFormat(String? raw) {
    final value = raw?.trim().toLowerCase().replaceAll('_', ' ');
    return switch (value) {
      'video' => 'Video',
      'in person' => 'In Person',
      'inperson' => 'In Person',
      'phone' => 'Phone',
      _ => raw,
    };
  }

  static String? _normalizeStatus(String? raw) {
    final value = raw
        ?.trim()
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll('-', '');
    return switch (value) {
      'confirmed' => 'Confirmed',
      'invited' || 'upcoming' => 'Invited',
      'completed' => 'Completed',
      'noshow' => 'No Show',
      'cancelled' || 'canceled' => 'Cancelled',
      _ => raw,
    };
  }

  static String _formatDate(DateTime dt) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${weekdays[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day} ${dt.year}';
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
