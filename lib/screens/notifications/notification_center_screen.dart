import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/notification_model.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_card.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  NotificationCategory? _selectedCategory;

  void _handleNotificationTap(NotificationModel notif) {
    final appState = AppStateProvider.of(context);
    appState.notificationService.markAsRead(notif.id);

    // Deep navigation based on category / route
    switch (notif.category) {
      case NotificationCategory.messages:
        appState.setNavigationIndex(1); // Chat tab
        break;
      case NotificationCategory.files:
        appState.setNavigationIndex(2); // Files tab
        break;
      case NotificationCategory.calls:
        appState.setNavigationIndex(3); // Calls tab
        break;
      case NotificationCategory.security:
        final threatId = notif.payload?['threatId'] as String? ?? 'thr_01';
        appState.focusSecurityThreat(threatId);
        break;
      case NotificationCategory.sos:
        appState.setNavigationIndex(7); // SOS tab
        break;
      case NotificationCategory.location:
        appState.setNavigationIndex(6); // Location tab
        break;
      case NotificationCategory.devices:
        appState.setNavigationIndex(11); // Devices tab
        break;
      case NotificationCategory.system:
        appState.setNavigationIndex(0); // Dashboard tab
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final allNotifs = appState.notificationService.notifications;
    final unreadCount = appState.notificationService.unreadCount;

    final filtered = allNotifs.where((n) {
      if (_selectedCategory != null && n.category != _selectedCategory) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'NOTIFICATION CENTER',
        subtitle: '$unreadCount UNREAD ALERTS • PRIORITY DISPATCH',
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                appState.notificationService.markAllAsRead();
                setState(() {});
              },
              child: const Text('Mark all read', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Alerts'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                      color: _selectedCategory == null ? Colors.white : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(width: 6),
                  ...NotificationCategory.values.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(cat.name.toUpperCase()),
                        selected: isSel,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.white : AppColors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Notifications List
            if (filtered.isEmpty)
              CortexCard(
                padding: const EdgeInsets.all(28),
                child: const Center(
                  child: Text('No alerts or notifications in this category.', style: AppTypography.bodyMedium),
                ),
              )
            else
              ...filtered.map((notif) {
                final isUrgent = notif.priority == NotificationPriority.urgent;
                final isHigh = notif.priority == NotificationPriority.high;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: CortexCard(
                    padding: const EdgeInsets.all(14),
                    borderColor: isUrgent
                        ? AppColors.critical
                        : (isHigh ? AppColors.warning.withValues(alpha: 0.6) : AppColors.border),
                    backgroundColor: notif.isRead
                        ? AppColors.surface
                        : (isUrgent ? AppColors.critical.withValues(alpha: 0.1) : AppColors.surfaceElevated),
                    onTap: () => _handleNotificationTap(notif),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isUrgent
                                ? AppColors.critical.withValues(alpha: 0.2)
                                : (isHigh ? AppColors.warning.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.15)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            isUrgent
                                ? Icons.warning_rounded
                                : (notif.category == NotificationCategory.messages
                                    ? Icons.chat_bubble_outline_rounded
                                    : (notif.category == NotificationCategory.files
                                        ? Icons.folder_outlined
                                        : Icons.notifications_active_outlined)),
                            color: isUrgent ? AppColors.critical : (isHigh ? AppColors.warning : AppColors.primaryLight),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif.title,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${notif.timestamp.hour.toString().padLeft(2, "0")}:${notif.timestamp.minute.toString().padLeft(2, "0")}',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(notif.message, style: AppTypography.bodySmall),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    notif.category.name.toUpperCase(),
                                    style: const TextStyle(fontSize: 9, color: AppColors.accentCyan, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Tap to view ➔',
                                    style: TextStyle(fontSize: 10, color: AppColors.primaryLight.withValues(alpha: 0.8)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                          onPressed: () {
                            appState.notificationService.deleteNotification(notif.id);
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
