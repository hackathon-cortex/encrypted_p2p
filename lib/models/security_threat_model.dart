enum ThreatSeverity {
  critical,
  high,
  medium,
  low,
  secure,
}

enum ThreatType {
  failedAuth,
  unknownDevice,
  tamperedPacket,
  unencryptedChannel,
  suspiciousRelay,
  sosBroadcast,
  keyMismatch,
}

class SecurityThreatModel {
  final String id;
  final String title;
  final String description;
  final ThreatSeverity severity;
  final ThreatType threatType;
  final DateTime timestamp;
  final bool isResolved;
  final String? sourceIp;
  final String? deviceName;
  final String? status;
  final String? detectionTime;
  final String? resolutionAction;
  final DateTime? resolvedAt;

  SecurityThreatModel({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.threatType,
    required this.timestamp,
    this.isResolved = false,
    this.sourceIp,
    this.deviceName,
    this.status,
    this.detectionTime,
    this.resolutionAction,
    this.resolvedAt,
  });

  SecurityThreatModel copyWith({
    String? id,
    String? title,
    String? description,
    ThreatSeverity? severity,
    ThreatType? threatType,
    DateTime? timestamp,
    bool? isResolved,
    String? sourceIp,
    String? deviceName,
    String? status,
    String? detectionTime,
    String? resolutionAction,
    DateTime? resolvedAt,
  }) {
    return SecurityThreatModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      threatType: threatType ?? this.threatType,
      timestamp: timestamp ?? this.timestamp,
      isResolved: isResolved ?? this.isResolved,
      sourceIp: sourceIp ?? this.sourceIp,
      deviceName: deviceName ?? this.deviceName,
      status: status ?? this.status,
      detectionTime: detectionTime ?? this.detectionTime,
      resolutionAction: resolutionAction ?? this.resolutionAction,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}
