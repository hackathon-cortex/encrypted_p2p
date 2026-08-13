import '../models/audit_log_model.dart';
import 'encryption_service.dart';

class AuditService {
  final List<AuditLogModel> _logs = [];
  final EncryptionService _encryptionService = EncryptionService();

  List<AuditLogModel> get logs => List.unmodifiable(_logs);

  AuditService() {
    _seedAuditLogs();
  }

  void _seedAuditLogs() {
    final now = DateTime.now();

    _logs.addAll([
      AuditLogModel(
        id: 'aud_101',
        eventType: 'USER_AUTHENTICATED',
        severity: AuditSeverity.info,
        category: AuditCategory.auth,
        actor: 'commander_alex',
        targetDevice: 'CORTEX Master Terminal',
        timestamp: now.subtract(const Duration(hours: 1)),
        ipAddress: '10.0.1.10',
        description: 'Commander Alex Morgan successfully authenticated via biometric MFA.',
        checksum: _encryptionService.generateSha256Checksum('aud_101:USER_AUTHENTICATED'),
      ),
      AuditLogModel(
        id: 'aud_102',
        eventType: 'KEY_EXCHANGE_VERIFIED',
        severity: AuditSeverity.info,
        category: AuditCategory.mesh,
        actor: 'SYSTEM_MESH',
        targetDevice: 'Node Aegis-1 (Sarah Khan)',
        timestamp: now.subtract(const Duration(minutes: 50)),
        ipAddress: '10.0.1.14',
        description: 'ECDH Curve25519 handshake established with 256-bit symmetric session key.',
        checksum: _encryptionService.generateSha256Checksum('aud_102:KEY_EXCHANGE_VERIFIED'),
      ),
      AuditLogModel(
        id: 'aud_103',
        eventType: 'FILE_ENCRYPTED_TRANSFER',
        severity: AuditSeverity.info,
        category: AuditCategory.files,
        actor: 'commander_alex',
        targetDevice: 'Sarah Khan (Aegis-1)',
        timestamp: now.subtract(const Duration(minutes: 45)),
        ipAddress: '10.0.1.10',
        description: 'File Operation_Vanguard_Tactical_Plan.pdf.enc transferred with SHA-256 verification.',
        checksum: _encryptionService.generateSha256Checksum('aud_103:FILE_ENCRYPTED_TRANSFER'),
      ),
      AuditLogModel(
        id: 'aud_104',
        eventType: 'UNRECOGNIZED_HANDSHAKE_ATTEMPT',
        severity: AuditSeverity.medium,
        category: AuditCategory.security,
        actor: 'UNKNOWN_CLIENT',
        targetDevice: 'Relay Node Beta',
        timestamp: now.subtract(const Duration(minutes: 35)),
        ipAddress: '192.168.1.189',
        description: 'Unrecognized client signature attempted P2P relay handshake. Connection quarantined.',
        checksum: _encryptionService.generateSha256Checksum('aud_104:UNRECOGNIZED_HANDSHAKE_ATTEMPT'),
      ),
      AuditLogModel(
        id: 'aud_105',
        eventType: 'LOCATION_TELEMETRY_ENABLED',
        severity: AuditSeverity.info,
        category: AuditCategory.location,
        actor: 'commander_alex',
        targetDevice: 'CORTEX Master Terminal',
        timestamp: now.subtract(const Duration(minutes: 30)),
        ipAddress: '10.0.1.10',
        description: 'Tactical location beacon activated for audience: Squadron Alpha.',
        checksum: _encryptionService.generateSha256Checksum('aud_105:LOCATION_TELEMETRY_ENABLED'),
      ),
      AuditLogModel(
        id: 'aud_106',
        eventType: 'FAILED_PIN_CHALLENGE',
        severity: AuditSeverity.low,
        category: AuditCategory.auth,
        actor: 'field_operator_beta',
        targetDevice: 'Field Terminal Beta',
        timestamp: now.subtract(const Duration(hours: 2)),
        ipAddress: '10.0.4.12',
        description: '2 invalid MFA PIN verification attempts recorded on Field Terminal Beta.',
        checksum: _encryptionService.generateSha256Checksum('aud_106:FAILED_PIN_CHALLENGE'),
      ),
    ]);
  }

  void logEvent({
    required String eventType,
    required AuditSeverity severity,
    required AuditCategory category,
    required String actor,
    String? targetDevice,
    required String description,
    String ipAddress = '10.0.1.10',
    Map<String, dynamic>? metadata,
  }) {
    final id = 'aud_${DateTime.now().millisecondsSinceEpoch}';
    final checksum = _encryptionService.generateSha256Checksum('$id:$eventType:$actor:$description');

    final newLog = AuditLogModel(
      id: id,
      eventType: eventType,
      severity: severity,
      category: category,
      actor: actor,
      targetDevice: targetDevice,
      timestamp: DateTime.now(),
      ipAddress: ipAddress,
      description: description,
      checksum: checksum,
      metadata: metadata,
    );

    _logs.insert(0, newLog);
  }

  List<AuditLogModel> filterLogs({
    String? query,
    AuditCategory? category,
    AuditSeverity? severity,
  }) {
    return _logs.where((log) {
      if (category != null && log.category != category) return false;
      if (severity != null && log.severity != severity) return false;
      if (query != null && query.trim().isNotEmpty) {
        final q = query.toLowerCase();
        return log.eventType.toLowerCase().contains(q) ||
            log.description.toLowerCase().contains(q) ||
            log.actor.toLowerCase().contains(q) ||
            log.ipAddress.contains(q);
      }
      return true;
    }).toList();
  }
}
