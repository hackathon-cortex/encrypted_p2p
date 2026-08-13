import '../models/device_model.dart';

class DeviceService {
  final List<DeviceModel> _devices = [];

  List<DeviceModel> get devices => List.unmodifiable(_devices);
  List<DeviceModel> get trustedDevices => _devices.where((d) => d.trustStatus == DeviceTrustStatus.trusted).toList();

  DeviceService() {
    _seedDevices();
  }

  void _seedDevices() {
    final now = DateTime.now();

    _devices.addAll([
      DeviceModel(
        id: 'dev_01',
        name: 'CORTEX Master Command Station',
        platform: DevicePlatformType.windows,
        ipAddress: '10.0.1.10',
        hardwareFingerprint: 'F8:4D:89:BC:A1:04',
        lastActive: now,
        isCurrentDevice: true,
        trustStatus: DeviceTrustStatus.trusted,
        sessionToken: 'CTX-SES-99428-SEC',
        cipherSuite: 'AES-256-GCM / Curve25519 (ECDH)',
        locationTag: 'Primary Command Center',
      ),
      DeviceModel(
        id: 'dev_02',
        name: 'Tactical Recon Mobile',
        platform: DevicePlatformType.android,
        ipAddress: '10.0.3.45',
        hardwareFingerprint: '92:FA:11:0B:44:8C',
        lastActive: now.subtract(const Duration(minutes: 14)),
        isCurrentDevice: false,
        trustStatus: DeviceTrustStatus.trusted,
        sessionToken: 'CTX-SES-44102-SEC',
        cipherSuite: 'AES-256-GCM / Curve25519',
        locationTag: 'Field Sector Alpha',
      ),
      DeviceModel(
        id: 'dev_03',
        name: 'Cryptographic Core Lab Terminal',
        platform: DevicePlatformType.linux,
        ipAddress: '10.0.1.29',
        hardwareFingerprint: '4E:7D:9A:3B:0C:6E',
        lastActive: now.subtract(const Duration(hours: 3)),
        isCurrentDevice: false,
        trustStatus: DeviceTrustStatus.trusted,
        sessionToken: 'CTX-SES-88219-SEC',
        cipherSuite: 'ChaCha20-Poly1305 / X25519',
        locationTag: 'Secure Server Vault',
      ),
      DeviceModel(
        id: 'dev_04',
        name: 'Unrecognized Mobile Node',
        platform: DevicePlatformType.android,
        ipAddress: '192.168.1.189',
        hardwareFingerprint: '3C:0A:9F:5E:6B:8D',
        lastActive: now.subtract(const Duration(minutes: 35)),
        isCurrentDevice: false,
        trustStatus: DeviceTrustStatus.quarantined,
        sessionToken: 'CTX-SES-QUARANTINED',
        cipherSuite: 'UNVERIFIED-CIPHER',
        locationTag: 'External Gateway Relay',
      ),
    ]);
  }

  void trustDevice(String deviceId) {
    final idx = _devices.indexWhere((d) => d.id == deviceId);
    if (idx != -1) {
      _devices[idx] = _devices[idx].copyWith(trustStatus: DeviceTrustStatus.trusted);
    }
  }

  void quarantineDevice(String deviceId) {
    final idx = _devices.indexWhere((d) => d.id == deviceId);
    if (idx != -1) {
      _devices[idx] = _devices[idx].copyWith(
        trustStatus: DeviceTrustStatus.quarantined,
        sessionToken: 'CTX-SES-REVOKED',
      );
    }
  }

  void revokeSession(String deviceId) {
    final idx = _devices.indexWhere((d) => d.id == deviceId);
    if (idx != -1) {
      _devices[idx] = _devices[idx].copyWith(
        trustStatus: DeviceTrustStatus.untrusted,
        sessionToken: 'CTX-SES-TERMINATED',
      );
    }
  }

  void removeDevice(String deviceId) {
    _devices.removeWhere((d) => d.id == deviceId && !d.isCurrentDevice);
  }
}
