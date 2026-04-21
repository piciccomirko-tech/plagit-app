/// Typed notification model — mirrors Swift NotificationDTO.
///
/// Replaces all raw `Map<String, dynamic>` notification usage.
library;

import 'package:plagit/core/mock/mock_data.dart';

/// A single notification for the candidate.
///
/// Not `const` because [read] is mutable (toggled when the user opens it).
class NotificationItem {
  final String id;
  final String title;
  final String time;
  final String type; // 'jobs' | 'applications' | 'messages'
  final String? destinationRoute;
  bool read;
  final String icon;

  NotificationItem({
    required this.id,
    required this.title,
    required this.time,
    required this.type,
    this.destinationRoute,
    this.read = false,
    required this.icon,
  });

  // ── JSON serialisation ──

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      time: json['created_at'] as String? ?? json['time'] as String? ?? '',
      type: json['notification_type'] as String? ?? json['type'] as String? ?? 'in_app',
      destinationRoute: json['destination_route'] as String? ??
          json['destinationRoute'] as String?,
      read: json['is_read'] as bool? ?? json['read'] as bool? ?? false,
      icon: json['icon'] as String? ?? json['linked_entity'] as String? ?? 'notifications',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'time': time,
        'type': type,
        'destination_route': destinationRoute,
        'read': read,
        'icon': icon,
      };

  /// Returns a copy with optional field overrides.
  NotificationItem copyWith({bool? read, String? destinationRoute}) {
    return NotificationItem(
      id: id,
      title: title,
      time: time,
      type: type,
      destinationRoute: destinationRoute ?? this.destinationRoute,
      read: read ?? this.read,
      icon: icon,
    );
  }

  // ── Mock factory ──

  /// Returns all mock notifications as typed [NotificationItem] instances.
  static List<NotificationItem> mockAll() =>
      MockData.notifications
          .map((n) => NotificationItem.fromJson(n))
          .toList();
}
