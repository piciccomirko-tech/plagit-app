/// Notification types for the admin mobile flow.
enum AdminNotificationType {
  businessPendingApproval,
  newReport,
  urgentMessage,
  suspiciousActivity,
  interviewIssue,
  paymentIssue,
  systemAlert,
}

/// A single admin notification.
class AdminNotification {
  final String id;
  final AdminNotificationType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? actionRoute;

  const AdminNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.actionRoute,
  });

  String get typeLabel => switch (type) {
    AdminNotificationType.businessPendingApproval => 'Approval',
    AdminNotificationType.newReport => 'Report',
    AdminNotificationType.urgentMessage => 'Urgent',
    AdminNotificationType.suspiciousActivity => 'Security',
    AdminNotificationType.interviewIssue => 'Interview',
    AdminNotificationType.paymentIssue => 'Payment',
    AdminNotificationType.systemAlert => 'System',
  };

  factory AdminNotification.fromJson(Map<String, dynamic> json) {
    return AdminNotification(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      type: _parseType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] as bool? ?? false,
      actionRoute: json['action_route'] as String?,
    );
  }

  static AdminNotificationType _parseType(String? t) {
    return switch (t) {
      'business_pending_approval' => AdminNotificationType.businessPendingApproval,
      'new_report' => AdminNotificationType.newReport,
      'urgent_message' => AdminNotificationType.urgentMessage,
      'suspicious_activity' => AdminNotificationType.suspiciousActivity,
      'interview_issue' => AdminNotificationType.interviewIssue,
      'payment_issue' => AdminNotificationType.paymentIssue,
      'system_alert' => AdminNotificationType.systemAlert,
      _ => AdminNotificationType.systemAlert,
    };
  }
}
