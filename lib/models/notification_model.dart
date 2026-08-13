enum NotificationCategory {
  messages,
  calls,
  security,
  sos,
  files,
  devices,
  location,
  system,
}

enum NotificationPriority {
  urgent, // for SOS & Critical security breaches
  high,
  normal,
  low,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final NotificationPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final String? targetRoute;
  final Map<String, dynamic>? payload;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    this.priority = NotificationPriority.normal,
    required this.timestamp,
    this.isRead = false,
    this.targetRoute,
    this.payload,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    NotificationPriority? priority,
    DateTime? timestamp,
    bool? isRead,
    String? targetRoute,
    Map<String, dynamic>? payload,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute ?? this.targetRoute,
      payload: payload ?? this.payload,
    );
  }
}
