enum SosStatus {
  idle,
  countdown,
  active,
  resolved,
  cancelled,
}

class SosIncidentModel {
  final String id;
  final String triggeredById;
  final String triggeredByName;
  final String callsign;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final SosStatus status;
  final List<String> emergencyContactsNotified;
  final DateTime? resolvedAt;
  final String? resolutionNotes;
  final String? resolvedBy;

  SosIncidentModel({
    required this.id,
    required this.triggeredById,
    required this.triggeredByName,
    required this.callsign,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.status = SosStatus.idle,
    this.emergencyContactsNotified = const [],
    this.resolvedAt,
    this.resolutionNotes,
    this.resolvedBy,
  });

  SosIncidentModel copyWith({
    String? id,
    String? triggeredById,
    String? triggeredByName,
    String? callsign,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    SosStatus? status,
    List<String>? emergencyContactsNotified,
    DateTime? resolvedAt,
    String? resolutionNotes,
    String? resolvedBy,
  }) {
    return SosIncidentModel(
      id: id ?? this.id,
      triggeredById: triggeredById ?? this.triggeredById,
      triggeredByName: triggeredByName ?? this.triggeredByName,
      callsign: callsign ?? this.callsign,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      emergencyContactsNotified:
          emergencyContactsNotified ?? this.emergencyContactsNotified,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }
}
