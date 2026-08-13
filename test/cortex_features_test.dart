import 'package:flutter_test/flutter_test.dart';
import 'package:encrypted_p2p/core/state/app_state_provider.dart';
import 'package:encrypted_p2p/models/call_session_model.dart';
import 'package:encrypted_p2p/models/file_item_model.dart';

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

    test('Emergency SOS Activation & Resolution Workflow', () async {
      await state.login('vanguard', 'pass1234');
      await state.verifyMfa('123456');
      expect(state.sosService.isSosActive, false);

      // Activate SOS
      state.triggerSos();
      expect(state.sosService.isSosActive, true);
      expect(state.sosService.activeIncident, isNotNull);

      // Resolve SOS
      state.resolveSos('Sector clear, all units report green.');
      expect(state.sosService.isSosActive, false);
      expect(state.sosService.sosHistory.length, greaterThan(0));
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
