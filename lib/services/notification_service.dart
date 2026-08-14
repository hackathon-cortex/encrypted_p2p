import '../models/notification_model.dart';

class NotificationService {
  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  int get urgentCount => _notifications.where((n) => !n.isRead && n.priority == NotificationPriority.urgent).length;

  NotificationService() {
    _seedNotifications();
  }

  void _seedNotifications() {
    final now = DateTime.now();

    _notifications.addAll([
      NotificationModel(
        id: 'notif_01',
        title: 'New Encrypted Payload Received',
        message: 'Sarah Khan shared Sector4_Briefing.cortex.enc (4.2 MB).',
        category: NotificationCategory.files,
        priority: NotificationPriority.normal,
        timestamp: now.subtract(const Duration(minutes: 5)),
        targetRoute: '/file-share',
      ),
      NotificationModel(
        id: 'notif_02',
        title: 'Security Alert: Unknown Handshake Attempt',
        message: 'Unrecognized client from IP 192.168.1.189 quarantined by perimeter firewall.',
        category: NotificationCategory.security,
        priority: NotificationPriority.high,
        timestamp: now.subtract(const Duration(minutes: 35)),
        targetRoute: '/security',
        payload: {'threatId': 'thr_01'},
      ),
      NotificationModel(
        id: 'notif_03',
        title: 'Mesh Node Synchronized',
        message: 'Ghost-4 (Daniel Lee) joined tactical P2P mesh relay.',
        category: NotificationCategory.system,
        priority: NotificationPriority.low,
        timestamp: now.subtract(const Duration(hours: 1)),
        targetRoute: '/personnel',
        isRead: true,
      ),
      NotificationModel(
        id: 'notif_04',
        title: 'Tactical Location Active',
        message: 'Location sharing enabled for Squadron Alpha.',
        category: NotificationCategory.location,
        priority: NotificationPriority.low,
        timestamp: now.subtract(const Duration(hours: 2)),
        targetRoute: '/live-location',
        isRead: true,
      ),
    ]);
  }

  void addNotification({
    required String title,
    required String message,
    required NotificationCategory category,
    NotificationPriority priority = NotificationPriority.normal,
    String? targetRoute,
    Map<String, dynamic>? payload,
  }) {
    final newNotif = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      category: category,
      priority: priority,
      timestamp: DateTime.now(),
      targetRoute: targetRoute,
      payload: payload,
    );
    _notifications.insert(0, newNotif);
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
  }

  void clearAll() {
    _notifications.clear();
  }

  List<NotificationModel> getByCategory(NotificationCategory category) {
    return _notifications.where((n) => n.category == category).toList();
  }
}
