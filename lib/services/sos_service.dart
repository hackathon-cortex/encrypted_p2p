import 'dart:convert';
import '../models/sos_incident_model.dart';
import 'encryption_service.dart';

class SosService {
  SosStatus _status = SosStatus.idle;
  SosIncidentModel? _activeIncident;
  final List<SosIncidentModel> _sosHistory = [];
  double _countdownProgress = 0.0; // 0.0 to 1.0

  SosStatus get status => _status;
  SosIncidentModel? get activeIncident => _activeIncident;
  List<SosIncidentModel> get sosHistory => List.unmodifiable(_sosHistory);
  double get countdownProgress => _countdownProgress;
  bool get isSosActive => _status == SosStatus.active;

  SosService() {
    _seedHistory();
  }

  void _seedHistory() {
    final now = DateTime.now();
    final pastIncident = SosIncidentModel(
      id: 'sos_hist_01',
      triggeredById: 'p_02',
      triggeredByName: 'Daniel Lee',
      callsign: 'Ghost-4',
      timestamp: now.subtract(const Duration(days: 3)),
      latitude: 37.7758,
      longitude: -122.4182,
      status: SosStatus.resolved,
      emergencyContactsNotified: ['Alex Morgan', 'Sarah Khan'],
      resolvedAt: now.subtract(const Duration(days: 3, hours: -1)),
      resolvedBy: 'Alex Morgan',
      resolutionNotes: 'Drill test completed. Tactical comms verified.',
      payload: SosAlertPayload(
        incidentId: 'sos_hist_01',
        senderId: 'p_02',
        senderName: 'Daniel Lee',
        callsign: 'Ghost-4',
        role: 'Field Operator',
        clearanceLevel: 'Level 3 - Secret',
        timestamp: now.subtract(const Duration(days: 3)),
        latitude: 37.7758,
        longitude: -122.4182,
        altitude: 129.0,
        accuracyMeters: 4.5,
        locationPermissionGranted: true,
        locationStatus: 'GPS Locked (High Accuracy)',
        deviceId: 'dev_02',
        deviceName: 'Tactical Recon Mobile',
        deviceHardwareFingerprint: '92:FA:11:0B:44:8C',
        deviceIp: '10.0.3.45',
        platform: 'Android Tactical Node',
        status: SosStatus.resolved,
        emergencyContacts: ['Alex Morgan', 'Sarah Khan'],
        connectedPeersCount: 3,
        deliveryStatus: SosDeliveryStatus.delivered,
        cipherSuite: 'AES-256-GCM',
        payloadHash: 'SHA256:7F9A2B3C8D4E1F5A6C7B8E9F0A1B2C3D',
        encryptedData: 'CORTEX-ENC:ZXllc29ubHlfc29zX2FjdGl2YXRlZF9jb29yZHM=',
      ),
    );

    _sosHistory.add(pastIncident);
  }

  void setCountdownProgress(double progress) {
    _countdownProgress = progress.clamp(0.0, 1.0);
    if (progress > 0 && progress < 1.0) {
      _status = SosStatus.countdown;
    } else if (progress <= 0) {
      if (_status == SosStatus.countdown) {
        _status = SosStatus.idle;
      }
    }
  }

  SosIncidentModel triggerSos({
    required String triggeredById,
    required String triggeredByName,
    required String callsign,
    String role = 'Commander',
    String clearanceLevel = 'Level 5 - Command Core',
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracyMeters,
    bool locationPermissionGranted = true,
    String locationStatus = 'GPS Geolocation Active',
    String deviceId = 'dev_01',
    String deviceName = 'CORTEX Master Command Station',
    String deviceHardwareFingerprint = 'F8:4D:89:BC:A1:04',
    String deviceIp = '10.0.1.10',
    String platform = 'Android Node',
    int connectedPeersCount = 4,
    bool isMeshConnected = true,
    List<String> emergencyContacts = const ['Sarah Khan', 'Daniel Lee', 'Elena Rostova'],
    EncryptionService? encryptionService,
  }) {
    _status = SosStatus.active;
    _countdownProgress = 1.0;

    final incidentId = 'sos_${DateTime.now().millisecondsSinceEpoch}';
    final timestamp = DateTime.now();

    final enc = encryptionService ?? EncryptionService();
    final cipher = enc.activeCipherSuite;

    final rawPayloadString = jsonEncode({
      'incident_id': incidentId,
      'triggered_by': triggeredByName,
      'callsign': callsign,
      'role': role,
      'clearance': clearanceLevel,
      'timestamp': timestamp.toIso8601String(),
      'lat': latitude,
      'lng': longitude,
      'alt': altitude,
      'accuracy': accuracyMeters,
      'gps_permission': locationPermissionGranted,
      'device_id': deviceId,
      'device_name': deviceName,
      'device_fingerprint': deviceHardwareFingerprint,
      'device_ip': deviceIp,
      'contacts': emergencyContacts,
      'status': 'ACTIVE_DISTRESS',
    });

    final encryptedData = enc.encrypt(rawPayloadString);
    final payloadHash = 'SHA256:${enc.generateSha256Checksum(rawPayloadString).substring(0, 32).toUpperCase()}';

    final deliveryStatus = isMeshConnected && connectedPeersCount > 0
        ? SosDeliveryStatus.delivered
        : (isMeshConnected ? SosDeliveryStatus.noMeshPeers : SosDeliveryStatus.offlineQueued);

    final payload = SosAlertPayload(
      incidentId: incidentId,
      senderId: triggeredById,
      senderName: triggeredByName,
      callsign: callsign,
      role: role,
      clearanceLevel: clearanceLevel,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      accuracyMeters: accuracyMeters,
      locationPermissionGranted: locationPermissionGranted,
      locationStatus: locationStatus,
      deviceId: deviceId,
      deviceName: deviceName,
      deviceHardwareFingerprint: deviceHardwareFingerprint,
      deviceIp: deviceIp,
      platform: platform,
      status: SosStatus.active,
      emergencyContacts: emergencyContacts,
      connectedPeersCount: connectedPeersCount,
      deliveryStatus: deliveryStatus,
      cipherSuite: cipher,
      payloadHash: payloadHash,
      encryptedData: encryptedData,
    );

    _activeIncident = SosIncidentModel(
      id: incidentId,
      triggeredById: triggeredById,
      triggeredByName: triggeredByName,
      callsign: callsign,
      timestamp: timestamp,
      latitude: latitude ?? 37.7749,
      longitude: longitude ?? -122.4194,
      status: SosStatus.active,
      emergencyContactsNotified: emergencyContacts,
      payload: payload,
    );

    return _activeIncident!;
  }

  void resolveSos({
    required String resolvedBy,
    required String resolutionNotes,
  }) {
    if (_activeIncident != null) {
      final updatedPayload = _activeIncident!.payload?.copyWith(
        status: SosStatus.resolved,
      );

      final resolved = _activeIncident!.copyWith(
        status: SosStatus.resolved,
        resolvedAt: DateTime.now(),
        resolvedBy: resolvedBy,
        resolutionNotes: resolutionNotes,
        payload: updatedPayload,
      );
      _sosHistory.insert(0, resolved);
      _activeIncident = null;
    }
    _status = SosStatus.idle;
    _countdownProgress = 0.0;
  }

  void cancelSos() {
    _status = SosStatus.idle;
    _countdownProgress = 0.0;
    _activeIncident = null;
  }
}
