import 'package:flutter_test/flutter_test.dart';
import 'package:encrypted_p2p/core/state/app_state_provider.dart';
import 'package:encrypted_p2p/models/call_session_model.dart';
import 'package:encrypted_p2p/models/file_item_model.dart';
import 'package:encrypted_p2p/models/security_threat_model.dart';
import 'package:encrypted_p2p/services/location_service.dart';

void main() {
  group('CORTEX Core State & Feature Tests', () {
    late AppStateProvider state;

    setUp(() {
      state = AppStateProvider();
    });

    tearDown(() {
      state.dispose();
    });

    test('Initial Authentication State & Login Flow', () async {
      expect(state.authService.isLoggedIn, false);
      expect(state.authService.isMfaRequired, true);

      // Perform login
      final success = await state.login('vanguard', 'pass1234');
      expect(success, true);
      expect(state.authService.isMfaVerified, false);

      // Verify MFA code challenge
      final mfaSuccess = await state.verifyMfa('123456');
      expect(mfaSuccess, true);
      expect(state.authService.isLoggedIn, true);
      expect(state.authService.currentUser?.callsign, 'Vanguard-1');
    });

    test('Secure Chat Message Sending & E2EE Flag', () async {
      await state.login('vanguard', 'pass1234');
      await state.verifyMfa('123456');

      final initialCount = state.chatService.messages.length;
      await state.sendChatMessage(message: 'Alpha node perimeter secured.');

      expect(state.chatService.messages.length, initialCount + 1);
      final lastMsg = state.chatService.messages.last;
      expect(lastMsg.message, 'Alpha node perimeter secured.');
      expect(lastMsg.isEncrypted, true);
    });

    test('Security Threat Mitigation & Health Score Recalculation', () {
      final initialScore = state.securityService.securityScore;
      final threatsCount = state.securityService.activeThreats.length;
      expect(threatsCount, greaterThan(0));

      final firstThreatId = state.securityService.activeThreats.first.id;
      state.resolveThreat(firstThreatId, 'Mitigated via firewall rule');

      expect(state.securityService.activeThreats.length, threatsCount - 1);
      expect(state.securityService.securityScore, greaterThanOrEqualTo(initialScore));
    });

    test('Secure File Encryption & Transmission', () async {
      final initialFiles = state.fileService.files.length;
      await state.sendFile(
        fileName: 'Mission_Recon.pdf',
        fileSize: 4500000,
        recipientId: 'p_01',
        recipientName: 'Sarah Khan',
        permission: FileAccessPermission.oneTimeDownload,
        expiry: const Duration(hours: 12),
      );

      expect(state.fileService.files.length, initialFiles + 1);
      final newFile = state.fileService.files.first;
      expect(newFile.name, contains('Mission_Recon.pdf'));
      expect(newFile.hashSha256.isNotEmpty, true);
    });

    test('Emergency SOS Activation, Cryptographic Payload & Resolution Workflow', () async {
      await state.login('alex_vanguard', 'pass1234');
      await state.verifyMfa('123456');
      expect(state.sosService.isSosActive, false);

      // Verify emergency contacts are loaded
      final contacts = state.personnelService.emergencyContacts;
      expect(contacts.isNotEmpty, true);

      // Activate SOS
      state.triggerSos();
      expect(state.sosService.isSosActive, true);
      expect(state.sosService.activeIncident, isNotNull);

      final incident = state.sosService.activeIncident!;
      expect(incident.triggeredByName, contains('Alex'));
      expect(incident.payload, isNotNull);

      final payload = incident.payload!;
      expect(payload.cipherSuite, 'AES-256-GCM');
      expect(payload.payloadHash.startsWith('SHA256:'), true);
      expect(payload.encryptedData.startsWith('CORTEX-ENC:'), true);
      expect(payload.emergencyContacts.length, contacts.length);
      expect(payload.locationPermissionGranted, true);
      expect(payload.latitude, isNotNull);
      expect(payload.deviceId.isNotEmpty, true);

      // Check Critical Security Threat creation
      final sosThreats = state.securityService.threats.where((t) => t.threatType == ThreatType.sosBroadcast);
      expect(sosThreats.isNotEmpty, true);

      // Resolve SOS with debrief notes
      state.resolveSos('Sector clear, all tactical units report green.');
      expect(state.sosService.isSosActive, false);
      expect(state.sosService.activeIncident, isNull);
      expect(state.sosService.sosHistory.length, greaterThan(0));

      final latestHistory = state.sosService.sosHistory.first;
      expect(latestHistory.resolutionNotes, 'Sector clear, all tactical units report green.');
      expect(latestHistory.resolvedBy, contains('Alex Morgan'));
    });

    test('Emergency SOS with Location Permission Denied handles gracefully', () async {
      await state.login('vanguard', 'pass1234');
      await state.verifyMfa('123456');

      // Set location permission to denied
      state.locationService.setPermissionState(LocationPermissionState.denied);
      expect(state.locationService.hasLocationPermission, false);

      // Trigger SOS without location permission
      state.triggerSos();
      expect(state.sosService.isSosActive, true);
      final payload = state.sosService.activeIncident!.payload!;
      expect(payload.locationPermissionGranted, false);
      expect(payload.latitude, isNull);
      expect(payload.longitude, isNull);
      expect(payload.locationStatus, contains('Denied'));

      state.cancelSos();
      expect(state.sosService.isSosActive, false);
    });

    test('Live Location Sharing Policy & Emergency Stop', () {
      expect(state.locationService.isLocationSharingEnabled, true);

      // Emergency stop
      state.emergencyStopLocationSharing();
      expect(state.locationService.isLocationSharingEnabled, false);
    });

    test('AI Security Assistant State-Aware Query Processing', () async {
      await state.queryAiAssistant('Explain my security score');
      final messages = state.aiAssistantService.messages;
      expect(messages.length, greaterThanOrEqualTo(2));
      expect(messages.last.isUser, false);
    });

    test('Voice & Video Call Session Management', () {
      state.startCall(
        peerId: 'p_02',
        peerName: 'Marcus Vance',
        peerCallsign: 'Cipher-9',
        callType: CallType.voice,
      );

      expect(state.callService.activeCall, isNotNull);
      expect(state.callService.activeCall?.peerName, 'Marcus Vance');

      state.endCall();
      expect(state.callService.activeCall, isNull);
    });
  });
}
