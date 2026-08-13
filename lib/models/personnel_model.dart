class PersonnelModel {
  final String id;
  final String callsign;
  final String fullName;
  final String role;
  final String department;
  final String clearanceLevel;
  final bool isOnline;
  final String publicKeyFingerprint;
  final bool isEmergencyContact;
  final String statusNote;
  final String deviceName;
  final DateTime lastSeen;
  final String? avatarUrl;
  final String? ipAddress;

  PersonnelModel({
    required this.id,
    required this.callsign,
    required this.fullName,
    required this.role,
    required this.department,
    required this.clearanceLevel,
    this.isOnline = false,
    required this.publicKeyFingerprint,
    this.isEmergencyContact = false,
    this.statusNote = 'Stationary',
    this.deviceName = 'Field Terminal',
    required this.lastSeen,
    this.avatarUrl,
    this.ipAddress,
  });

  PersonnelModel copyWith({
    String? id,
    String? callsign,
    String? fullName,
    String? role,
    String? department,
    String? clearanceLevel,
    bool? isOnline,
    String? publicKeyFingerprint,
    bool? isEmergencyContact,
    String? statusNote,
    String? deviceName,
    DateTime? lastSeen,
    String? avatarUrl,
    String? ipAddress,
  }) {
    return PersonnelModel(
      id: id ?? this.id,
      callsign: callsign ?? this.callsign,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      department: department ?? this.department,
      clearanceLevel: clearanceLevel ?? this.clearanceLevel,
      isOnline: isOnline ?? this.isOnline,
      publicKeyFingerprint: publicKeyFingerprint ?? this.publicKeyFingerprint,
      isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
      statusNote: statusNote ?? this.statusNote,
      deviceName: deviceName ?? this.deviceName,
      lastSeen: lastSeen ?? this.lastSeen,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ipAddress: ipAddress ?? this.ipAddress,
    );
  }
}
