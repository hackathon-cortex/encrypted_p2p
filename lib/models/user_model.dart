class UserModel {
  final String id;
  final String username;
  final String? fullName;
  final String? callsign;
  final String? role;
  final String? department;
  final String? clearanceLevel;
  final String? avatarUrl;
  final bool isOnline;
  final String? publicKeyFingerprint;
  final bool isMfaEnabled;
  final bool isBiometricEnabled;

  UserModel({
    required this.id,
    required this.username,
    this.fullName,
    this.callsign,
    this.role = 'Security Officer',
    this.department = 'Cyber Defense',
    this.clearanceLevel = 'Level 4 - Top Secret',
    this.avatarUrl,
    this.isOnline = true,
    this.publicKeyFingerprint = 'SHA256:7F9A:2B3C:8D4E:1F5A:6C7B:8E9F:0A1B',
    this.isMfaEnabled = true,
    this.isBiometricEnabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'callsign': callsign,
      'role': role,
      'department': department,
      'clearanceLevel': clearanceLevel,
      'avatarUrl': avatarUrl,
      'isOnline': isOnline,
      'publicKeyFingerprint': publicKeyFingerprint,
      'isMfaEnabled': isMfaEnabled,
      'isBiometricEnabled': isBiometricEnabled,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'],
      callsign: json['callsign'],
      role: json['role'] ?? 'Security Officer',
      department: json['department'] ?? 'Cyber Defense',
      clearanceLevel: json['clearanceLevel'] ?? 'Level 4 - Top Secret',
      avatarUrl: json['avatarUrl'],
      isOnline: json['isOnline'] ?? true,
      publicKeyFingerprint: json['publicKeyFingerprint'],
      isMfaEnabled: json['isMfaEnabled'] ?? true,
      isBiometricEnabled: json['isBiometricEnabled'] ?? true,
    );
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? fullName,
    String? callsign,
    String? role,
    String? department,
    String? clearanceLevel,
    String? avatarUrl,
    bool? isOnline,
    String? publicKeyFingerprint,
    bool? isMfaEnabled,
    bool? isBiometricEnabled,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      callsign: callsign ?? this.callsign,
      role: role ?? this.role,
      department: department ?? this.department,
      clearanceLevel: clearanceLevel ?? this.clearanceLevel,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      publicKeyFingerprint: publicKeyFingerprint ?? this.publicKeyFingerprint,
      isMfaEnabled: isMfaEnabled ?? this.isMfaEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
}