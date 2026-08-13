class AppConstants {
  static const String appName = 'CORTEX';
  static const String appTagline = 'Secure Communications & Command Platform';
  static const String appVersion = '1.0.0-SECURE';
  static const String meshProtocol = 'CORTEX-P2P-v2.4';
  static const String defaultCipher = 'AES-256-GCM + Curve25519';

  static const int messageMaxLength = 5000;
  static const int usernameMaxLength = 30;
  static const int groupNameMaxLength = 50;

  // Roles
  static const String roleAdmin = 'Admin';
  static const String roleCommander = 'Commander';
  static const String roleSecurityOfficer = 'Security Officer';
  static const String roleOperator = 'Operator';
  static const String rolePersonnel = 'Personnel';
  static const String roleEmergencyContact = 'Emergency Contact';

  // Clearance Levels
  static const String clearanceLevel1 = 'Level 1 - Restricted';
  static const String clearanceLevel2 = 'Level 2 - Confidential';
  static const String clearanceLevel3 = 'Level 3 - Secret';
  static const String clearanceLevel4 = 'Level 4 - Top Secret';
  static const String clearanceLevel5 = 'Level 5 - Command Core';
}
