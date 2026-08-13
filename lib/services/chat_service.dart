import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatService {
  final List<ConversationModel> _conversations = [];
  final Map<String, List<MessageModel>> _conversationMessages = {};
  String? _activeConversationId;

  List<ConversationModel> get conversations => List.unmodifiable(_conversations);
  String? get activeConversationId => _activeConversationId;

  ChatService() {
    _seedDemoData();
  }

  void _seedDemoData() {
    final now = DateTime.now();

    // Group conversation
    final groupConvo = ConversationModel(
      id: 'grp_alpha_command',
      title: 'Squadron Alpha Command',
      subtitle: 'Encrypted tactical mesh',
      isGroup: true,
      participantIds: ['usr_cortex_01', 'p_01', 'p_02', 'p_03'],
      updatedAt: now.subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      isPinned: true,
      securityBadge: 'E2EE MESH AES-256',
    );

    // Direct conversations
    final sarahConvo = ConversationModel(
      id: 'dm_sarah_khan',
      title: 'Sarah Khan',
      subtitle: 'Security Officer • Online',
      isGroup: false,
      participantIds: ['usr_cortex_01', 'p_01'],
      updatedAt: now.subtract(const Duration(minutes: 12)),
      unreadCount: 1,
      isPinned: true,
      isOnline: true,
      securityBadge: 'E2EE ECDH-P256',
    );

    final danielConvo = ConversationModel(
      id: 'dm_daniel_lee',
      title: 'Daniel Lee',
      subtitle: 'Field Operator • Mobile Node',
      isGroup: false,
      participantIds: ['usr_cortex_01', 'p_02'],
      updatedAt: now.subtract(const Duration(hours: 1)),
      unreadCount: 0,
      isOnline: true,
      securityBadge: 'E2EE AES-256-GCM',
    );

    final elenaConvo = ConversationModel(
      id: 'dm_elena_rostova',
      title: 'Elena Rostova',
      subtitle: 'Cyber Specialist • Terminal 4',
      isGroup: false,
      participantIds: ['usr_cortex_01', 'p_03'],
      updatedAt: now.subtract(const Duration(hours: 3)),
      unreadCount: 0,
      isOnline: false,
      securityBadge: 'E2EE ChaCha20',
    );

    _conversations.addAll([groupConvo, sarahConvo, danielConvo, elenaConvo]);

    // Seed messages for group
    _conversationMessages[groupConvo.id] = [
      MessageModel(
        id: 'm_grp_1',
        senderId: 'p_01',
        senderName: 'Sarah Khan',
        message: 'Tactical security perimeter established around Sector 4.',
        timestamp: now.subtract(const Duration(minutes: 25)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: 'm_grp_2',
        senderId: 'p_02',
        senderName: 'Daniel Lee',
        message: 'Telemetry telemetry links are active. P2P relay synchronized.',
        timestamp: now.subtract(const Duration(minutes: 18)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: 'm_grp_3',
        senderId: 'usr_cortex_01',
        senderName: 'Alex Morgan (You)',
        message: 'Affirmative. Maintain encrypted radio silence on unverified channels.',
        timestamp: now.subtract(const Duration(minutes: 10)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: 'm_grp_4',
        senderId: 'p_01',
        senderName: 'Sarah Khan',
        message: 'Encrypted mission briefing payload shared.',
        timestamp: now.subtract(const Duration(minutes: 5)),
        status: MessageStatus.delivered,
        attachmentType: MessageAttachmentType.file,
        attachmentName: 'Sector4_Briefing.cortex.enc',
        attachmentSize: '4.2 MB',
      ),
    ];

    // Seed messages for Sarah Khan
    _conversationMessages[sarahConvo.id] = [
      MessageModel(
        id: 'm_sk_1',
        senderId: 'p_01',
        senderName: 'Sarah Khan',
        message: 'Commander, I have completed the security audit on Node Delta.',
        timestamp: now.subtract(const Duration(minutes: 30)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: 'm_sk_2',
        senderId: 'usr_cortex_01',
        senderName: 'Alex Morgan (You)',
        message: 'Were there any unauthorized cryptographic handshakes detected?',
        timestamp: now.subtract(const Duration(minutes: 20)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: 'm_sk_3',
        senderId: 'p_01',
        senderName: 'Sarah Khan',
        message: 'None. Key exchange hashes matched the primary registry.',
        timestamp: now.subtract(const Duration(minutes: 12)),
        status: MessageStatus.delivered,
      ),
    ];

    // Seed messages for Daniel Lee
    _conversationMessages[danielConvo.id] = [
      MessageModel(
        id: 'm_dl_1',
        senderId: 'p_02',
        senderName: 'Daniel Lee',
        message: 'Patrol beacon active. Location telemetry streaming to Live Map.',
        timestamp: now.subtract(const Duration(hours: 1)),
        status: MessageStatus.read,
      ),
      MessageModel(
        id: 'm_dl_2',
        senderId: 'usr_cortex_01',
        senderName: 'Alex Morgan (You)',
        message: 'Acknowledged. Keep beacon interval at 10 seconds.',
        timestamp: now.subtract(const Duration(minutes: 55)),
        status: MessageStatus.read,
      ),
    ];

    // Seed messages for Elena Rostova
    _conversationMessages[elenaConvo.id] = [
      MessageModel(
        id: 'm_er_1',
        senderId: 'p_03',
        senderName: 'Elena Rostova',
        message: 'AI Sentinel neural threat rules have been updated with latest signatures.',
        timestamp: now.subtract(const Duration(hours: 3)),
        status: MessageStatus.read,
      ),
    ];
  }

  void setActiveConversation(String? id) {
    _activeConversationId = id;
    if (id != null) {
      final index = _conversations.indexWhere((c) => c.id == id);
      if (index != -1) {
        _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      }
    }
  }

  List<MessageModel> getMessagesForConversation(String conversationId) {
    return _conversationMessages[conversationId] ?? [];
  }

  // Backward compatibility for existing screens
  List<MessageModel> get messages {
    if (_activeConversationId != null) {
      return _conversationMessages[_activeConversationId] ?? [];
    }
    return _conversationMessages['grp_alpha_command'] ?? [];
  }

  Future<void> sendMessage({
    required String senderId,
    required String message,
    String? senderName,
    String? conversationId,
    MessageAttachmentType attachmentType = MessageAttachmentType.none,
    String? attachmentName,
    String? attachmentSize,
    String? attachmentUrl,
    String? replyToMessageId,
    String? replyToText,
  }) async {
    if (message.trim().isEmpty && attachmentType == MessageAttachmentType.none) return;

    final targetId = conversationId ?? _activeConversationId ?? 'grp_alpha_command';

    final newMessage = MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName ?? 'You',
      message: message.trim(),
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      attachmentType: attachmentType,
      attachmentName: attachmentName,
      attachmentSize: attachmentSize,
      attachmentUrl: attachmentUrl,
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
      isEncrypted: true,
    );

    if (!_conversationMessages.containsKey(targetId)) {
      _conversationMessages[targetId] = [];
    }
    _conversationMessages[targetId]!.add(newMessage);

    // Update conversation last message & timestamp
    final convoIndex = _conversations.indexWhere((c) => c.id == targetId);
    if (convoIndex != -1) {
      _conversations[convoIndex] = _conversations[convoIndex].copyWith(
        lastMessage: newMessage,
        updatedAt: DateTime.now(),
      );
    }
  }

  void deleteMessage(String conversationId, String messageId) {
    if (_conversationMessages.containsKey(conversationId)) {
      _conversationMessages[conversationId]!.removeWhere((m) => m.id == messageId);
    }
  }

  void togglePinMessage(String conversationId, String messageId) {
    if (_conversationMessages.containsKey(conversationId)) {
      final list = _conversationMessages[conversationId]!;
      final idx = list.indexWhere((m) => m.id == messageId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(isPinned: !list[idx].isPinned);
      }
    }
  }

  void toggleMuteConversation(String conversationId) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(isMuted: !_conversations[idx].isMuted);
    }
  }

  void togglePinConversation(String conversationId) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx != -1) {
      _conversations[idx] = _conversations[idx].copyWith(isPinned: !_conversations[idx].isPinned);
    }
  }

  Future<List<MessageModel>> getMessages() async {
    return messages;
  }

  void clearMessages() {
    if (_activeConversationId != null && _conversationMessages.containsKey(_activeConversationId)) {
      _conversationMessages[_activeConversationId]!.clear();
    }
  }
}