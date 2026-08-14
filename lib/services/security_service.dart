import '../models/security_threat_model.dart';

class SecurityService {
  final List<SecurityThreatModel> _threats = [];
  bool _isScanning = false;
  double _scanProgress = 0.0;
  DateTime _lastScanTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 8, 15);
  DateTime _lastKeyRotationTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9, 42);
  int _failedLoginAttempts = 0;

  List<SecurityThreatModel> get threats => List.unmodifiable(_threats);
  List<SecurityThreatModel> get activeThreats => _threats.where((t) => !t.isResolved).toList();
  bool get isScanning => _isScanning;
  double get scanProgress => _scanProgress;
  DateTime get lastScanTime => _lastScanTime;
  DateTime get lastKeyRotationTime => _lastKeyRotationTime;
  int get failedLoginAttempts => _failedLoginAttempts;

  String get formattedLastScanTime {
    final h = _lastScanTime.hour.toString().padLeft(2, '0');
    final m = _lastScanTime.minute.toString().padLeft(2, '0');
    return 'Today • $h:$m';
  }

  String get formattedLastKeyRotation {
    final h = _lastKeyRotationTime.hour.toString().padLeft(2, '0');
    final m = _lastKeyRotationTime.minute.toString().padLeft(2, '0');
    return 'Today • $h:$m';
  }

  SecurityService() {
    _seedThreats();
  }

  void _seedThreats() {
    final now = DateTime.now();

    _threats.addAll([
      SecurityThreatModel(
        id: 'thr_01',
        title: 'Unknown Handshake Attempt',
        description: 'An unrecognized client attempted to establish a secure peer connection.',
        severity: ThreatSeverity.high,
        threatType: ThreatType.unknownDevice,
        timestamp: DateTime(now.year, now.month, now.day, 14, 32),
        sourceIp: '192.168.1.189',
        deviceName: 'Unrecognized Mobile Relay',
        status: 'QUARANTINED',
        detectionTime: 'Today • 14:32',
      ),
      SecurityThreatModel(
        id: 'thr_02',
        title: 'Repeated Authentication Failure',
        description: 'Multiple invalid authentication challenges detected and origin IP blocked by gateway firewall.',
        severity: ThreatSeverity.medium,
        threatType: ThreatType.failedAuth,
        timestamp: DateTime(now.year, now.month, now.day, 12, 18),
        sourceIp: '10.0.4.12',
        deviceName: 'Field Terminal Beta',
        status: 'BLOCKED',
        detectionTime: 'Today • 12:18',
      ),
      SecurityThreatModel(
        id: 'thr_03',
        title: 'Outdated Session Key Detected',
        description: 'Node Delta was operating with an encryption key older than policy limit.',
        severity: ThreatSeverity.low,
        threatType: ThreatType.keyMismatch,
        timestamp: now.subtract(const Duration(days: 1)),
        isResolved: true,
        status: 'RESOLVED',
        detectionTime: 'Yesterday • 18:20',
        resolutionAction: 'Rotated session keys and updated ECDH cache',
        resolvedAt: now.subtract(const Duration(hours: 20)),
      ),
    ]);
  }

  int get securityScore {
    int score = 100;
    for (final threat in activeThreats) {
      switch (threat.severity) {
        case ThreatSeverity.critical:
          score -= 30;
          break;
        case ThreatSeverity.high:
          score -= 10;
          break;
        case ThreatSeverity.medium:
          score -= 6;
          break;
        case ThreatSeverity.low:
          score -= 4;
          break;
        case ThreatSeverity.secure:
          break;
      }
    }
    score -= (_failedLoginAttempts > 2 ? (_failedLoginAttempts - 2) * 2 : 0);
    if (score < 10) score = 10;
    if (score > 100) score = 100;
    return score;
  }

  String get securityStatusText {
    final score = securityScore;
    if (score == 100) return 'OPTIMAL SECURE';
    if (score >= 80) return 'PROTECTED — ACTION REQUIRED';
    if (score >= 50) return 'ELEVATED THREAT';
    return 'CRITICAL BREACH RISK';
  }

  void resolveThreat(String threatId, String resolutionAction) {
    final idx = _threats.indexWhere((t) => t.id == threatId);
    if (idx != -1) {
      _threats[idx] = _threats[idx].copyWith(
        isResolved: true,
        status: 'RESOLVED',
        resolutionAction: resolutionAction,
        resolvedAt: DateTime.now(),
      );
    }
  }

  void rotateKeys() {
    _lastKeyRotationTime = DateTime.now();
  }

  void addThreat({
    required String title,
    required String description,
    required ThreatSeverity severity,
    required ThreatType threatType,
    String? sourceIp,
    String? deviceName,
    String? status,
    String? detectionTime,
  }) {
    final newThreat = SecurityThreatModel(
      id: 'thr_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      severity: severity,
      threatType: threatType,
      timestamp: DateTime.now(),
      sourceIp: sourceIp,
      deviceName: deviceName,
      status: status ?? 'QUARANTINED',
      detectionTime: detectionTime ?? 'Just now',
    );
    _threats.insert(0, newThreat);
  }

  void recordFailedLogin() {
    _failedLoginAttempts++;
  }

  void resetFailedLogins() {
    _failedLoginAttempts = 0;
  }

  Future<void> runSecurityScan(Function(double) onProgress) async {
    _isScanning = true;
    _scanProgress = 0.0;

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      _scanProgress = i / 10.0;
      onProgress(_scanProgress);
    }

    _isScanning = false;
    _lastScanTime = DateTime.now();
  }
}
