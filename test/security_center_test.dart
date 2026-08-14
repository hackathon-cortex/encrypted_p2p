import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:encrypted_p2p/core/state/app_state_provider.dart';
import 'package:encrypted_p2p/models/security_threat_model.dart';
import 'package:encrypted_p2p/screens/security/security_center_screen.dart';

void main() {
  group('Security Center & Threat Management Tests', () {
    late AppStateProvider state;

    setUp(() {
      state = AppStateProvider();
    });

    tearDown(() {
      state.dispose();
    });

    test('Initial Security Score is 84 and Status is PROTECTED — ACTION REQUIRED', () {
      expect(state.securityService.securityScore, 84);
      expect(state.securityService.securityStatusText, 'PROTECTED — ACTION REQUIRED');
      expect(state.securityService.activeThreats.length, 2);

      final threat1 = state.securityService.activeThreats.firstWhere((t) => t.id == 'thr_01');
      expect(threat1.title, 'Unknown Handshake Attempt');
      expect(threat1.severity, ThreatSeverity.high);
      expect(threat1.status, 'QUARANTINED');
      expect(threat1.sourceIp, '192.168.1.189');

      final threat2 = state.securityService.activeThreats.firstWhere((t) => t.id == 'thr_02');
      expect(threat2.title, 'Repeated Authentication Failure');
      expect(threat2.severity, ThreatSeverity.medium);
      expect(threat2.status, 'BLOCKED');
    });

    test('Security Threat Focus and Clear', () {
      expect(state.focusedThreatId, isNull);
      state.focusSecurityThreat('thr_01');
      expect(state.focusedThreatId, 'thr_01');
      expect(state.selectedNavigationIndex, 4);

      state.clearFocusedThreat();
      expect(state.focusedThreatId, isNull);
    });

    test('Key Rotation updates last rotation timestamp', () async {
      final initialRotation = state.securityService.formattedLastKeyRotation;
      await state.rotateEncryptionKeys();
      expect(state.securityService.lastKeyRotationTime, isNotNull);
      expect(state.securityService.formattedLastKeyRotation.isNotEmpty, true);
    });

    testWidgets('Security Center UI renders all critical sections properly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844)); // Standard phone size

      await tester.pumpWidget(
        AppStateScope(
          notifier: state,
          child: const MaterialApp(
            home: SecurityCenterScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Headers & Score
      expect(find.text('SECURITY CENTER'), findsOneWidget);
      expect(find.text('84'), findsOneWidget);
      expect(find.text('PROTECTED — ACTION REQUIRED'), findsOneWidget);
      expect(find.text('Your network is protected, but security events require attention.'), findsOneWidget);

      // Verify Supporting status indicators
      expect(find.text('4/4 Encrypted Peers'), findsOneWidget);
      expect(find.text('Firewall Active'), findsWidgets);
      expect(find.text('0 Unknown Active Peers'), findsOneWidget);
      expect(find.text('AES-256-GCM'), findsWidgets);

      // Verify Active Threats
      expect(find.text('ACTIVE THREATS'), findsOneWidget);
      expect(find.text('2 Threats Detected'), findsOneWidget);
      expect(find.text('Unknown Handshake Attempt'), findsOneWidget);
      expect(find.text('QUARANTINED'), findsOneWidget);
      expect(find.text('Repeated Authentication Failure'), findsOneWidget);
      expect(find.text('BLOCKED'), findsOneWidget);
      expect(find.text('VIEW DETAILS'), findsNWidgets(2));

      // Verify Network Security & Encryption
      expect(find.text('NETWORK SECURITY'), findsOneWidget);
      expect(find.text('ENCRYPTION & CRYPTOGRAPHY'), findsOneWidget);
      expect(find.text('SECURITY ACTIVITY'), findsOneWidget);
      expect(find.text('SECURITY ACTIONS'), findsOneWidget);

      // Verify Security Action Buttons
      expect(find.text('RUN SECURITY SCAN'), findsOneWidget);
      expect(find.text('ROTATE KEYS'), findsOneWidget);
      expect(find.text('TRUSTED NODES'), findsOneWidget);
      expect(find.text('VIEW AUDIT LOG'), findsOneWidget);
    });
  });
}
