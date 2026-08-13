class SettingsService {
  // Privacy Settings
  bool stealthMode = false;
  bool broadcastOnlinePresence = true;
  bool sendReadReceipts = true;
  bool allowLocationSharingByDefault = true;

  // Security Settings
  bool mfaEnabled = true;
  bool biometricsEnabled = true;
  String autoLockTimeout = '5 minutes'; // '1 minute', '5 minutes', '15 minutes', 'Never'
  String activeCipherSuite = 'AES-256-GCM / Curve25519';
  String keyRotationPeriod = '24 hours'; // '6 hours', '12 hours', '24 hours', '7 days'

  // Notification Settings
  bool messageNotifications = true;
  bool callNotifications = true;
  bool securityAlerts = true;
  bool emergencySosOverride = true; // Plays high-priority alert even in silent mode
  bool vibrationFeedback = true;

  // Appearance
  String themeMode = 'Dark Cyber Navy'; // 'Dark Cyber Navy', 'Obsidian Black', 'Tactical Slate'
  bool compactLayout = false;

  void updatePrivacy({
    bool? stealthMode,
    bool? broadcastOnlinePresence,
    bool? sendReadReceipts,
    bool? allowLocationSharingByDefault,
  }) {
    if (stealthMode != null) this.stealthMode = stealthMode;
    if (broadcastOnlinePresence != null) this.broadcastOnlinePresence = broadcastOnlinePresence;
    if (sendReadReceipts != null) this.sendReadReceipts = sendReadReceipts;
    if (allowLocationSharingByDefault != null) this.allowLocationSharingByDefault = allowLocationSharingByDefault;
  }

  void updateSecurity({
    bool? mfaEnabled,
    bool? biometricsEnabled,
    String? autoLockTimeout,
    String? activeCipherSuite,
    String? keyRotationPeriod,
  }) {
    if (mfaEnabled != null) this.mfaEnabled = mfaEnabled;
    if (biometricsEnabled != null) this.biometricsEnabled = biometricsEnabled;
    if (autoLockTimeout != null) this.autoLockTimeout = autoLockTimeout;
    if (activeCipherSuite != null) this.activeCipherSuite = activeCipherSuite;
    if (keyRotationPeriod != null) this.keyRotationPeriod = keyRotationPeriod;
  }

  void updateNotifications({
    bool? messageNotifications,
    bool? callNotifications,
    bool? securityAlerts,
    bool? emergencySosOverride,
    bool? vibrationFeedback,
  }) {
    if (messageNotifications != null) this.messageNotifications = messageNotifications;
    if (callNotifications != null) this.callNotifications = callNotifications;
    if (securityAlerts != null) this.securityAlerts = securityAlerts;
    if (emergencySosOverride != null) this.emergencySosOverride = emergencySosOverride;
    if (vibrationFeedback != null) this.vibrationFeedback = vibrationFeedback;
  }

  void updateAppearance({
    String? themeMode,
    bool? compactLayout,
  }) {
    if (themeMode != null) this.themeMode = themeMode;
    if (compactLayout != null) this.compactLayout = compactLayout;
  }
}
