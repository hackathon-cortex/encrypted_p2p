enum AuditSeverity {
  critical,
  high,
  medium,
  low,
  info,
}

enum AuditCategory {
  auth,
  security,
  mesh,
  comms,
  files,
  location,
  sos,
  device,
  settings,
  system,
}

class AuditLogModel {
  final String id;
  final String eventType;
  final AuditSeverity severity;
  final AuditCategory category;
  final String actor;
  final String? targetDevice;
  final DateTime timestamp;
  final String ipAddress;
  final String description;
  final String checksum; // SHA-256 integrity seal
  final Map<String, dynamic>? metadata;

  AuditLogModel({
    required this.id,
    required this.eventType,
    required this.severity,
    required this.category,
    required this.actor,
    this.targetDevice,
    required this.timestamp,
    required this.ipAddress,
    required this.description,
    required this.checksum,
    this.metadata,
  });

  AuditLogModel copyWith({
    String? id,
    String? eventType,
    AuditSeverity? severity,
    AuditCategory? category,
    String? actor,
    String? targetDevice,
    DateTime? timestamp,
    String? ipAddress,
    String? description,
    String? checksum,
    Map<String, dynamic>? metadata,
  }) {
    return AuditLogModel(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      actor: actor ?? this.actor,
      targetDevice: targetDevice ?? this.targetDevice,
      timestamp: timestamp ?? this.timestamp,
      ipAddress: ipAddress ?? this.ipAddress,
      description: description ?? this.description,
      checksum: checksum ?? this.checksum,
      metadata: metadata ?? this.metadata,
    );
  }
}
