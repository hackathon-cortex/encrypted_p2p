enum MessageStatus { sending, sent, delivered, read }
enum MessageAttachmentType { none, image, file, voice, location, alert }

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final MessageStatus status;
  final MessageAttachmentType attachmentType;
  final String? attachmentName;
  final String? attachmentSize;
  final String? attachmentUrl;
  final String? replyToMessageId;
  final String? replyToText;
  final bool isPinned;
  final bool isEncrypted;

  MessageModel({
    required this.id,
    required this.senderId,
    this.senderName = 'Operator',
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.status = MessageStatus.delivered,
    this.attachmentType = MessageAttachmentType.none,
    this.attachmentName,
    this.attachmentSize,
    this.attachmentUrl,
    this.replyToMessageId,
    this.replyToText,
    this.isPinned = false,
    this.isEncrypted = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'status': status.name,
      'attachmentType': attachmentType.name,
      'attachmentName': attachmentName,
      'attachmentSize': attachmentSize,
      'attachmentUrl': attachmentUrl,
      'replyToMessageId': replyToMessageId,
      'replyToText': replyToText,
      'isPinned': isPinned,
      'isEncrypted': isEncrypted,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'Operator',
      message: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.delivered,
      ),
      attachmentType: MessageAttachmentType.values.firstWhere(
        (e) => e.name == json['attachmentType'],
        orElse: () => MessageAttachmentType.none,
      ),
      attachmentName: json['attachmentName'],
      attachmentSize: json['attachmentSize'],
      attachmentUrl: json['attachmentUrl'],
      replyToMessageId: json['replyToMessageId'],
      replyToText: json['replyToText'],
      isPinned: json['isPinned'] ?? false,
      isEncrypted: json['isEncrypted'] ?? true,
    );
  }

  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    MessageStatus? status,
    MessageAttachmentType? attachmentType,
    String? attachmentName,
    String? attachmentSize,
    String? attachmentUrl,
    String? replyToMessageId,
    String? replyToText,
    bool? isPinned,
    bool? isEncrypted,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
      attachmentType: attachmentType ?? this.attachmentType,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToText: replyToText ?? this.replyToText,
      isPinned: isPinned ?? this.isPinned,
      isEncrypted: isEncrypted ?? this.isEncrypted,
    );
  }
}