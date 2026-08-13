import 'dart:convert';

enum SosStatus {
  idle,
  countdown,
  active,
  resolved,
  cancelled,
}

enum SosDeliveryStatus {
  broadcasting,
  delivered,
  offlineQueued,
  noMeshPeers,
  failed,
}

class SosAlertPayload {
  final String incidentId;
  final String senderId;
  final String senderName;
  final String callsign;
  final String role;
  final String clearanceLevel;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? accuracyMeters;
  final bool locationPermissionGranted;
  final String locationStatus;
  final String deviceId;
  final String deviceName;
  final String deviceHardwareFingerprint;
  final String deviceIp;
  final String platform;
  final SosStatus status;
  final List<String> emergencyContacts;
  final int connectedPeersCount;
  final SosDeliveryStatus deliveryStatus;
  final String cipherSuite;
  final String payloadHash;
  final String encryptedData;

  SosAlertPayload({
    required this.incidentId,
    required this.senderId,
    required this.senderName,
    required this.callsign,
    required this.role,
    required this.clearanceLevel,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.altitude,
    this.accuracyMeters,
    required this.locationPermissionGranted,
    required this.locationStatus,
    required this.deviceId,
    required this.deviceName,
    required this.deviceHardwareFingerprint,
    required this.deviceIp,
    required this.platform,
    this.status = SosStatus.active,
    this.emergencyContacts = const [],
    required this.connectedPeersCount,
    required this.deliveryStatus,
    required this.cipherSuite,
    required this.payloadHash,
    required this.encryptedData,
  });

  Map<String, dynamic> toMap() {
    return {
      'incident_id': incidentId,
      'sender_id': senderId,
      'sender_name': senderName,
      'callsign': callsign,
      'role': role,
      'clearance_level': clearanceLevel,
      'timestamp': timestamp.toIso8601String(),
      'coordinates': {
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'accuracy_meters': accuracyMeters,
        'permission_granted': locationPermissionGranted,
        'status': locationStatus,
      },
      'device': {
        'id': deviceId,
        'name': deviceName,
        'fingerprint': deviceHardwareFingerprint,
        'ip': deviceIp,
        'platform': platform,
      },
      'status': status.name,
      'emergency_contacts': emergencyContacts,
      'p2p_mesh': {
        'connected_peers': connectedPeersCount,
        'delivery_status': deliveryStatus.name,
      },
      'security': {
        'cipher_suite': cipherSuite,
        'payload_hash': payloadHash,
      },
    };
  }

  String toJsonString() {
    return const JsonEncoder.withIndent('  ').convert(toMap());
  }

  SosAlertPayload copyWith({
    String? incidentId,
    String? senderId,
    String? senderName,
    String? callsign,
    String? role,
    String? clearanceLevel,
    DateTime? timestamp,
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracyMeters,
    bool? locationPermissionGranted,
    String? locationStatus,
    String? deviceId,
    String? deviceName,
    String? deviceHardwareFingerprint,
    String? deviceIp,
    String? platform,
    SosStatus? status,
    List<String>? emergencyContacts,
    int? connectedPeersCount,
    SosDeliveryStatus? deliveryStatus,
    String? cipherSuite,
    String? payloadHash,
    String? encryptedData,
  }) {
    return SosAlertPayload(
      incidentId: incidentId ?? this.incidentId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      callsign: callsign ?? this.callsign,
      role: role ?? this.role,
      clearanceLevel: clearanceLevel ?? this.clearanceLevel,
      timestamp: timestamp ?? this.timestamp,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      locationPermissionGranted:
          locationPermissionGranted ?? this.locationPermissionGranted,
      locationStatus: locationStatus ?? this.locationStatus,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      deviceHardwareFingerprint:
          deviceHardwareFingerprint ?? this.deviceHardwareFingerprint,
      deviceIp: deviceIp ?? this.deviceIp,
      platform: platform ?? this.platform,
      status: status ?? this.status,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      connectedPeersCount: connectedPeersCount ?? this.connectedPeersCount,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      cipherSuite: cipherSuite ?? this.cipherSuite,
      payloadHash: payloadHash ?? this.payloadHash,
      encryptedData: encryptedData ?? this.encryptedData,
    );
  }
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
  final SosAlertPayload? payload;

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
    this.payload,
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
    SosAlertPayload? payload,
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
      payload: payload ?? this.payload,
    );
  }
}
