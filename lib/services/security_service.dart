import '../models/security_threat_model.dart';

class SecurityService {
  final List<SecurityThreatModel> _threats = [];
  bool _isScanning = false;
  double _scanProgress = 0.0;
  DateTime _lastScanTime = DateTime.now().subtract(const Duration(hours: 6));
  int _failedLoginAttempts = 1;

  List<SecurityThreatModel> get threats => List.unmodifiable(_threats);
  List<SecurityThreatModel> get activeThreats => _threats.where((t) => !t.isResolved).toList();
  bool get isScanning => _isScanning;
  double get scanProgress => _scanProgress;
  DateTime get lastScanTime => _lastScanTime;
  int get failedLoginAttempts => _failedLoginAttempts;

  SecurityService() {
    _seedThreats();
  }

  void _seedThreats() {
    final now = DateTime.now();

    _threats.addAll([
      SecurityThreatModel(
        id: 'thr_01',
        title: 'Unrecognized Device Connection Attempt',
        description: 'Connection attempt from IP 192.168.1.189 using unrecognized client fingerprint.',
        severity: ThreatSeverity.medium,
        threatType: ThreatType.unknownDevice,
        timestamp: now.subtract(const Duration(minutes: 35)),
        sourceIp: '192.168.1.189',
        deviceName: 'Unknown Android Client',
      ),
      SecurityThreatModel(
        id: 'thr_02',
        title: 'Failed Security Verification Challenge',
        description: '2 invalid MFA PIN verification attempts recorded on Command Terminal.',
        severity: ThreatSeverity.low,
        threatType: ThreatType.failedAuth,
        timestamp: now.subtract(const Duration(hours: 2)),
        sourceIp: '10.0.4.12',
        deviceName: 'Field Terminal Beta',
      ),
      SecurityThreatModel(
        id: 'thr_03',
        title: 'Outdated Session Key Detected',
        description: 'Node Delta was operating with an encryption key older than policy limit.',
        severity: ThreatSeverity.low,
        threatType: ThreatType.keyMismatch,
        timestamp: now.subtract(const Duration(days: 1)),
        isResolved: true,
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
          score -= 20;
          break;
        case ThreatSeverity.medium:
          score -= 10;
          break;
        case ThreatSeverity.low:
          score -= 4;
          break;
        case ThreatSeverity.secure:
          break;
      }
    }
    score -= (_failedLoginAttempts * 2);
    if (score < 10) score = 10;
    if (score > 100) score = 100;
    return score;
  }

  String get securityStatusText {
    final score = securityScore;
    if (score >= 90) return 'OPTIMAL SECURE';
    if (score >= 75) return 'PROTECTED - MINOR ALERTS';
    if (score >= 50) return 'ELEVATED THREAT';
    return 'CRITICAL BREACH RISK';
  }

  void resolveThreat(String threatId, String resolutionAction) {
    final idx = _threats.indexWhere((t) => t.id == threatId);
    if (idx != -1) {
      _threats[idx] = _threats[idx].copyWith(
        isResolved: true,
        resolutionAction: resolutionAction,
        resolvedAt: DateTime.now(),
      );
    }
  }

  void addThreat({
    required String title,
    required String description,
    required ThreatSeverity severity,
    required ThreatType threatType,
    String? sourceIp,
    String? deviceName,
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
      await Future.delayed(const Duration(milliseconds: 150));
      _scanProgress = i / 10.0;
      onProgress(_scanProgress);
    }

    _isScanning = false;
    _lastScanTime = DateTime.now();
  }
}
