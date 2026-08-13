import 'dart:async';
import 'package:flutter/material.dart';

import '../../models/audit_log_model.dart';
import '../../models/call_session_model.dart';
import '../../models/file_item_model.dart';
import '../../models/message_model.dart';
import '../../models/notification_model.dart';
import '../../models/security_threat_model.dart';
import '../../models/user_model.dart';
import '../../services/ai_assistant_service.dart';
import '../../services/audit_service.dart';
import '../../services/auth_service.dart';
import '../../services/call_service.dart';
import '../../services/chat_service.dart';
import '../../services/device_service.dart';
import '../../services/encryption_service.dart';
import '../../services/file_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../services/personnel_service.dart';
import '../../services/security_service.dart';
import '../../services/settings_service.dart';
import '../../services/sos_service.dart';
import '../../services/websocket_service.dart';

class AppStateProvider extends ChangeNotifier {
  bool _isDisposed = false;

  // Services
  final AuthService authService = AuthService();
  final ChatService chatService = ChatService();
  final EncryptionService encryptionService = EncryptionService();
  final FileService fileService = FileService();
  final WebSocketService webSocketService = WebSocketService();
  final CallService callService = CallService();
  final SecurityService securityService = SecurityService();
  final SosService sosService = SosService();
  final PersonnelService personnelService = PersonnelService();
  final LocationService locationService = LocationService();
  final AiAssistantService aiAssistantService = AiAssistantService();
  final AuditService auditService = AuditService();
  final NotificationService notificationService = NotificationService();
  final DeviceService deviceService = DeviceService();
  final SettingsService settingsService = SettingsService();

  // Active navigation tab index in MainNavigationShell
  int _selectedNavigationIndex = 0;
  int get selectedNavigationIndex => _selectedNavigationIndex;

  // Root Scaffold Key for reliable drawer opening across all sub-screens
  final GlobalKey<ScaffoldState> rootScaffoldKey = GlobalKey<ScaffoldState>();

  void openDrawer() {
    rootScaffoldKey.currentState?.openDrawer();
  }

  void setNavigationIndex(int index) {
    _selectedNavigationIndex = index;
    notifyListeners();
  }

  // --- AUTHENTICATION ACTIONS ---
  Future<bool> login(String username, String password) async {
    final success = await authService.login(username: username, password: password);
    if (success) {
      auditService.logEvent(
        eventType: 'USER_AUTHENTICATED',
        severity: AuditSeverity.info,
        category: AuditCategory.auth,
        actor: username,
        description: 'User $username authenticated successfully into CORTEX.',
      );
      notifyListeners();
    } else {
      securityService.recordFailedLogin();
      auditService.logEvent(
        eventType: 'AUTH_FAILED',
        severity: AuditSeverity.medium,
        category: AuditCategory.auth,
        actor: username,
        description: 'Failed login attempt for username $username.',
      );
      notifyListeners();
    }
    return success;
  }

  Future<bool> verifyMfa(String code) async {
    final success = await authService.verifyMfa(code);
    if (success) {
      auditService.logEvent(
        eventType: 'MFA_VERIFIED',
        severity: AuditSeverity.info,
        category: AuditCategory.auth,
        actor: authService.currentUser?.username ?? 'user',
        description: 'Multi-factor authentication challenge verified.',
      );
    }
    notifyListeners();
    return success;
  }

  Future<bool> authenticateBiometric() async {
    final success = await authService.authenticateWithBiometrics();
    if (success) {
      auditService.logEvent(
        eventType: 'BIOMETRIC_AUTH_SUCCESS',
        severity: AuditSeverity.info,
        category: AuditCategory.auth,
        actor: authService.currentUser?.username ?? 'user',
        description: 'Hardware biometric authentication verified.',
      );
    }
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    final user = authService.currentUser?.username ?? 'user';
    await authService.logout();
    auditService.logEvent(
      eventType: 'USER_LOGOUT',
      severity: AuditSeverity.info,
      category: AuditCategory.auth,
      actor: user,
      description: 'Session terminated. User logged out.',
    );
    notifyListeners();
  }

  // --- CHAT ACTIONS ---
  Future<void> sendChatMessage({
    required String message,
    String? conversationId,
    MessageAttachmentType attachmentType = MessageAttachmentType.none,
    String? attachmentName,
    String? attachmentSize,
    String? attachmentUrl,
    String? replyToMessageId,
    String? replyToText,
  }) async {
    final user = authService.currentUser;
    final senderId = user?.id ?? 'usr_cortex_01';
    final senderName = user?.fullName ?? 'Commander Alex';

    await chatService.sendMessage(
      senderId: senderId,
      senderName: senderName,
      message: message,
      conversationId: conversationId,
      attachmentType: attachmentType,
      attachmentName: attachmentName,
      attachmentSize: attachmentSize,
      attachmentUrl: attachmentUrl,
      replyToMessageId: replyToMessageId,
      replyToText: replyToText,
    );

    auditService.logEvent(
      eventType: 'MESSAGE_SENT_E2EE',
      severity: AuditSeverity.info,
      category: AuditCategory.comms,
      actor: user?.username ?? 'user',
      description: 'End-to-end encrypted packet transmitted across P2P mesh.',
    );

    notifyListeners();
  }

  void deleteChatMessage(String conversationId, String messageId) {
    chatService.deleteMessage(conversationId, messageId);
    auditService.logEvent(
      eventType: 'MESSAGE_DELETED',
      severity: AuditSeverity.info,
      category: AuditCategory.comms,
      actor: authService.currentUser?.username ?? 'user',
      description: 'Message deleted from encrypted local ledger.',
    );
    notifyListeners();
  }

  void togglePinChatMessage(String conversationId, String messageId) {
    chatService.togglePinMessage(conversationId, messageId);
    notifyListeners();
  }

  void toggleMuteConversation(String conversationId) {
    chatService.toggleMuteConversation(conversationId);
    notifyListeners();
  }

  // --- FILE SHARING ACTIONS ---
  Future<void> sendFile({
    required String fileName,
    required int fileSize,
    required String recipientId,
    required String recipientName,
    String? localPath,
    FileAccessPermission permission = FileAccessPermission.readOnly,
    Duration expiry = const Duration(hours: 24),
  }) async {
    final user = authService.currentUser;
    final file = await fileService.sendFile(
      fileName: fileName,
      fileSize: fileSize,
      senderId: user?.id ?? 'usr_cortex_01',
      senderName: user?.fullName ?? 'Alex Morgan',
      recipientId: recipientId,
      recipientName: recipientName,
      localPath: localPath,
      permission: permission,
      expiry: expiry,
    );

    auditService.logEvent(
      eventType: 'FILE_ENCRYPTED_OUTGOING',
      severity: AuditSeverity.info,
      category: AuditCategory.files,
      actor: user?.username ?? 'user',
      targetDevice: recipientName,
      description: 'Encrypted file ${file.name} queued for transmission to $recipientName.',
    );

    notificationService.addNotification(
      title: 'File Encrypted & Queued',
      message: 'Transferring ${file.name} to $recipientName via P2P relay.',
      category: NotificationCategory.files,
      targetRoute: '/file-share',
    );

    notifyListeners();

    // Simulate animated upload progress
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      final currentFile = fileService.files.firstWhere((f) => f.id == file.id);
      final newProgress = currentFile.progress + 0.3;
      if (newProgress >= 1.0) {
        fileService.updateTransferProgress(file.id, 1.0);
        timer.cancel();
        if (!_isDisposed) notifyListeners();
      } else {
        fileService.updateTransferProgress(file.id, newProgress);
        if (!_isDisposed) notifyListeners();
      }
    });
  }

  void revokeFile(String fileId) {
    fileService.revokeFileAccess(fileId);
    auditService.logEvent(
      eventType: 'FILE_ACCESS_REVOKED',
      severity: AuditSeverity.medium,
      category: AuditCategory.files,
      actor: authService.currentUser?.username ?? 'user',
      description: 'Access permission revoked for file ID $fileId.',
    );
    notifyListeners();
  }

  // --- CALL ACTIONS ---
  void startCall({
    required String peerId,
    required String peerName,
    required String peerCallsign,
    CallType callType = CallType.voice,
  }) {
    callService.startOutgoingCall(
      peerId: peerId,
      peerName: peerName,
      peerCallsign: peerCallsign,
      callType: callType,
    );

    auditService.logEvent(
      eventType: 'ENCRYPTED_CALL_INITIATED',
      severity: AuditSeverity.info,
      category: AuditCategory.comms,
      actor: authService.currentUser?.username ?? 'user',
      targetDevice: peerName,
      description: 'Encrypted ${callType.name.toUpperCase()} call handshake initiated with $peerName.',
    );

    notifyListeners();
  }

  void endCall() {
    final active = callService.activeCall;
    callService.endCall();

    if (active != null) {
      auditService.logEvent(
        eventType: 'CALL_ENDED',
        severity: AuditSeverity.info,
        category: AuditCategory.comms,
        actor: authService.currentUser?.username ?? 'user',
        targetDevice: active.peerName,
        description: 'Call ended. Duration: ${active.formattedDuration}. Cipher: ${active.cipherSuite}.',
      );
    }

    notifyListeners();
  }

  // --- SOS EMERGENCY ACTIONS ---
  void triggerSos() {
    final user = authService.currentUser;
    final loc = locationService.myLocation;
    final hasLocPermission = locationService.hasLocationPermission;
    final currentDevice = deviceService.devices.firstWhere(
      (d) => d.isCurrentDevice,
      orElse: () => deviceService.devices.isNotEmpty ? deviceService.devices.first : throw StateError('No device found'),
    );

    final emergencyContactNames = personnelService.emergencyContacts.map((p) => '${p.fullName} (${p.callsign})').toList();

    final incident = sosService.triggerSos(
      triggeredById: user?.id ?? 'usr_cortex_01',
      triggeredByName: user?.fullName ?? 'Alex Morgan',
      callsign: user?.callsign ?? 'Vanguard-1',
      role: user?.role ?? 'Commander',
      clearanceLevel: user?.clearanceLevel ?? 'Level 5 - Command Core',
      latitude: hasLocPermission ? loc.latitude : null,
      longitude: hasLocPermission ? loc.longitude : null,
      altitude: hasLocPermission ? loc.altitude : null,
      accuracyMeters: hasLocPermission ? loc.accuracyMeters : null,
      locationPermissionGranted: hasLocPermission,
      locationStatus: hasLocPermission ? 'GPS Geolocation Active (±${loc.accuracyMeters}m)' : 'Location Permission Denied',
      deviceId: currentDevice.id,
      deviceName: currentDevice.name,
      deviceHardwareFingerprint: currentDevice.hardwareFingerprint,
      deviceIp: currentDevice.ipAddress,
      platform: currentDevice.platform.name.toUpperCase(),
      connectedPeersCount: webSocketService.connectedPeersCount,
      isMeshConnected: webSocketService.isConnected,
      emergencyContacts: emergencyContactNames,
      encryptionService: encryptionService,
    );

    // Broadcast across P2P WebSocket mesh if connected
    if (webSocketService.isConnected) {
      webSocketService.sendMessage(incident.payload?.encryptedData ?? 'SOS_BROADCAST');
    }

    // Create Critical Security Threat
    securityService.addThreat(
      title: 'CRITICAL EMERGENCY SOS ACTIVATED',
      description: 'Emergency distress beacon activated by ${incident.triggeredByName} (${incident.callsign}). Geolocation: ${hasLocPermission ? "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}" : "GPS coordinates unavailable (permission denied)"}.',
      severity: ThreatSeverity.critical,
      threatType: ThreatType.sosBroadcast,
    );

    // Urgent Notification
    notificationService.addNotification(
      title: '🚨 EMERGENCY SOS ACTIVE',
      message: 'Distress signal broadcasting to all tactical units and emergency contacts.',
      category: NotificationCategory.sos,
      priority: NotificationPriority.urgent,
      targetRoute: '/sos',
    );

    // Critical Audit Log
    auditService.logEvent(
      eventType: 'CRITICAL_SOS_BROADCAST',
      severity: AuditSeverity.critical,
      category: AuditCategory.sos,
      actor: user?.username ?? 'user',
      targetDevice: currentDevice.name,
      description: 'Emergency SOS beacon broadcasting. Telemetry: Lat ${hasLocPermission ? loc.latitude : "N/A"}, Lng ${hasLocPermission ? loc.longitude : "N/A"}. Digest: ${incident.payload?.payloadHash ?? "N/A"}.',
    );

    notifyListeners();
  }

  void resolveSos(String notes) {
    final user = authService.currentUser;
    sosService.resolveSos(
      resolvedBy: user?.fullName ?? 'Commander Alex Morgan',
      resolutionNotes: notes,
    );

    // Resolve corresponding threat
    final sosThreats = securityService.threats.where((t) => t.threatType == ThreatType.sosBroadcast && !t.isResolved);
    for (final threat in sosThreats) {
      securityService.resolveThreat(threat.id, 'SOS incident resolved: $notes');
    }

    auditService.logEvent(
      eventType: 'SOS_INCIDENT_RESOLVED',
      severity: AuditSeverity.info,
      category: AuditCategory.sos,
      actor: user?.username ?? 'user',
      description: 'Emergency SOS deactivated. Debrief: $notes',
    );

    notificationService.addNotification(
      title: 'SOS Incident Resolved',
      message: 'Emergency beacon stood down by Commander.',
      category: NotificationCategory.sos,
      priority: NotificationPriority.normal,
      targetRoute: '/sos',
    );

    notifyListeners();
  }

  void cancelSos() {
    sosService.cancelSos();
    auditService.logEvent(
      eventType: 'SOS_CANCELLED',
      severity: AuditSeverity.info,
      category: AuditCategory.sos,
      actor: authService.currentUser?.username ?? 'user',
      description: 'Emergency SOS cancelled by user before dispatch resolution.',
    );
    notifyListeners();
  }

  // --- SECURITY ACTIONS ---
  void resolveThreat(String threatId, String resolutionAction) {
    securityService.resolveThreat(threatId, resolutionAction);
    auditService.logEvent(
      eventType: 'THREAT_RESOLVED',
      severity: AuditSeverity.info,
      category: AuditCategory.security,
      actor: authService.currentUser?.username ?? 'user',
      description: 'Security threat $threatId resolved: $resolutionAction.',
    );
    notifyListeners();
  }

  Future<void> runSecurityScan() async {
    await securityService.runSecurityScan((progress) {
      notifyListeners();
    });

    auditService.logEvent(
      eventType: 'FULL_SECURITY_SCAN_COMPLETED',
      severity: AuditSeverity.info,
      category: AuditCategory.security,
      actor: authService.currentUser?.username ?? 'user',
      description: 'Diagnostic perimeter scan completed across mesh relays. Integrity verified.',
    );

    notifyListeners();
  }

  // --- DEVICE ACTIONS ---
  void trustDevice(String deviceId) {
    deviceService.trustDevice(deviceId);
    auditService.logEvent(
      eventType: 'DEVICE_TRUSTED',
      severity: AuditSeverity.info,
      category: AuditCategory.device,
      actor: authService.currentUser?.username ?? 'user',
      description: 'Device $deviceId marked as trusted node in cryptographic registry.',
    );
    notifyListeners();
  }

  void quarantineDevice(String deviceId) {
    deviceService.quarantineDevice(deviceId);
    auditService.logEvent(
      eventType: 'DEVICE_QUARANTINED',
      severity: AuditSeverity.high,
      category: AuditCategory.device,
      actor: authService.currentUser?.username ?? 'user',
      description: 'Device $deviceId isolated and quarantined from P2P relay.',
    );
    notifyListeners();
  }

  void revokeDeviceSession(String deviceId) {
    deviceService.revokeSession(deviceId);
    auditService.logEvent(
      eventType: 'DEVICE_SESSION_REVOKED',
      severity: AuditSeverity.medium,
      category: AuditCategory.device,
      actor: authService.currentUser?.username ?? 'user',
      description: 'Cryptographic session token revoked for device $deviceId.',
    );
    notifyListeners();
  }

  // --- LOCATION ACTIONS ---
  void toggleLocationSharing(bool enabled) {
    locationService.toggleLocationSharing(enabled);
    auditService.logEvent(
      eventType: enabled ? 'LOCATION_SHARING_ENABLED' : 'LOCATION_SHARING_DISABLED',
      severity: AuditSeverity.info,
      category: AuditCategory.location,
      actor: authService.currentUser?.username ?? 'user',
      description: enabled
          ? 'Tactical location broadcasting enabled for ${locationService.sharingAudience}.'
          : 'Tactical location broadcast disabled by user.',
    );
    notifyListeners();
  }

  void emergencyStopLocationSharing() {
    locationService.emergencyStopSharing();
    auditService.logEvent(
      eventType: 'LOCATION_EMERGENCY_KILL',
      severity: AuditSeverity.medium,
      category: AuditCategory.location,
      actor: authService.currentUser?.username ?? 'user',
      description: 'Emergency kill-switch executed. All GPS and beacon telemetry dropped.',
    );
    notifyListeners();
  }

  // --- AI ASSISTANT ACTIONS ---
  Future<String> queryAiAssistant(String query) async {
    final response = await aiAssistantService.queryAssistant(
      query: query,
      securityScore: securityService.securityScore,
      activeThreats: securityService.activeThreats,
      failedLogins: securityService.failedLoginAttempts,
      devices: deviceService.devices,
      isSosActive: sosService.isSosActive,
      recentLogs: auditService.logs,
    );
    notifyListeners();
    return response;
  }

  // --- SETTINGS ACTIONS ---
  void updateUserSettings(UserModel user) {
    authService.updateProfile(user);
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  static AppStateProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    if (scope == null) {
      throw FlutterError('AppStateScope not found in context.');
    }
    return scope.notifier!;
  }
}

class AppStateScope extends InheritedNotifier<AppStateProvider> {
  const AppStateScope({
    super.key,
    required AppStateProvider notifier,
    required super.child,
  }) : super(notifier: notifier);
}
