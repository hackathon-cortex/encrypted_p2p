import 'message_model.dart';

class ConversationModel {
  final String id;
  final String title;
  final String? subtitle;
  final bool isGroup;
  final List<String> participantIds;
  final String? avatarUrl;
  final MessageModel? lastMessage;
  final int unreadCount;
  final bool isPinned;
  final bool isMuted;
  final bool isOnline;
  final DateTime updatedAt;
  final String? securityBadge;

  ConversationModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.isGroup = false,
    this.participantIds = const [],
    this.avatarUrl,
    this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    this.isOnline = false,
    required this.updatedAt,
    this.securityBadge = 'E2EE AES-256',
  });

  ConversationModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    bool? isGroup,
    List<String>? participantIds,
    String? avatarUrl,
    MessageModel? lastMessage,
    int? unreadCount,
    bool? isPinned,
    bool? isMuted,
    bool? isOnline,
    DateTime? updatedAt,
    String? securityBadge,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      isGroup: isGroup ?? this.isGroup,
      participantIds: participantIds ?? this.participantIds,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      isOnline: isOnline ?? this.isOnline,
      updatedAt: updatedAt ?? this.updatedAt,
      securityBadge: securityBadge ?? this.securityBadge,
    );
  }
}
