enum FileTransferStatus {
  encrypted,
  transferring,
  completed,
  failed,
  expired,
}

enum FileAccessPermission {
  readOnly,
  oneTimeDownload,
  restrictedClearance,
  fullAccess,
}

class FileItemModel {
  final String id;
  final String name;
  final int sizeBytes;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final String hashSha256;
  final String encryptionAlgorithm;
  final FileTransferStatus status;
  final double progress; // 0.0 to 1.0
  final DateTime timestamp;
  final Duration expiryDuration;
  final bool isRevoked;
  final String mimeType;
  final String? localPath;
  final FileAccessPermission accessPermission;

  FileItemModel({
    required this.id,
    required this.name,
    required this.sizeBytes,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.hashSha256,
    this.encryptionAlgorithm = 'AES-256-GCM',
    this.status = FileTransferStatus.completed,
    this.progress = 1.0,
    required this.timestamp,
    this.expiryDuration = const Duration(hours: 24),
    this.isRevoked = false,
    this.mimeType = 'application/octet-stream',
    this.localPath,
    this.accessPermission = FileAccessPermission.readOnly,
  });

  bool get isExpired {
    return isRevoked || DateTime.now().difference(timestamp) > expiryDuration;
  }

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  FileItemModel copyWith({
    String? id,
    String? name,
    int? sizeBytes,
    String? senderId,
    String? senderName,
    String? recipientId,
    String? recipientName,
    String? hashSha256,
    String? encryptionAlgorithm,
    FileTransferStatus? status,
    double? progress,
    DateTime? timestamp,
    Duration? expiryDuration,
    bool? isRevoked,
    String? mimeType,
    String? localPath,
    FileAccessPermission? accessPermission,
  }) {
    return FileItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      hashSha256: hashSha256 ?? this.hashSha256,
      encryptionAlgorithm: encryptionAlgorithm ?? this.encryptionAlgorithm,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      timestamp: timestamp ?? this.timestamp,
      expiryDuration: expiryDuration ?? this.expiryDuration,
      isRevoked: isRevoked ?? this.isRevoked,
      mimeType: mimeType ?? this.mimeType,
      localPath: localPath ?? this.localPath,
      accessPermission: accessPermission ?? this.accessPermission,
    );
  }
}
