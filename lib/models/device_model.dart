enum DevicePlatformType {
  windows,
  android,
  linux,
  ios,
  macos,
  embedded,
}

enum DeviceTrustStatus {
  trusted,
  pending,
  untrusted,
  quarantined,
}

class DeviceModel {
  final String id;
  final String name;
  final DevicePlatformType platform;
  final String ipAddress;
  final String hardwareFingerprint;
  final DateTime lastActive;
  final bool isCurrentDevice;
  final DeviceTrustStatus trustStatus;
  final String sessionToken;
  final String cipherSuite;
  final String locationTag;

  DeviceModel({
    required this.id,
    required this.name,
    required this.platform,
    required this.ipAddress,
    required this.hardwareFingerprint,
    required this.lastActive,
    this.isCurrentDevice = false,
    this.trustStatus = DeviceTrustStatus.trusted,
    required this.sessionToken,
    this.cipherSuite = 'AES-256-GCM / Curve25519',
    this.locationTag = 'Primary Sector',
  });

  bool get isTrusted => trustStatus == DeviceTrustStatus.trusted;
  bool get isQuarantined => trustStatus == DeviceTrustStatus.quarantined;

  DeviceModel copyWith({
    String? id,
    String? name,
    DevicePlatformType? platform,
    String? ipAddress,
    String? hardwareFingerprint,
    DateTime? lastActive,
    bool? isCurrentDevice,
    DeviceTrustStatus? trustStatus,
    String? sessionToken,
    String? cipherSuite,
    String? locationTag,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      ipAddress: ipAddress ?? this.ipAddress,
      hardwareFingerprint: hardwareFingerprint ?? this.hardwareFingerprint,
      lastActive: lastActive ?? this.lastActive,
      isCurrentDevice: isCurrentDevice ?? this.isCurrentDevice,
      trustStatus: trustStatus ?? this.trustStatus,
      sessionToken: sessionToken ?? this.sessionToken,
      cipherSuite: cipherSuite ?? this.cipherSuite,
      locationTag: locationTag ?? this.locationTag,
    );
  }
}
