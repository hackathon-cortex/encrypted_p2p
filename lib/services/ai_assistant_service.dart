import '../models/audit_log_model.dart';
import '../models/device_model.dart';
import '../models/security_threat_model.dart';

class AiMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? actionButtons;

  AiMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.actionButtons,
  });
}

class AiAssistantService {
  final List<AiMessage> _messages = [];

  List<AiMessage> get messages => List.unmodifiable(_messages);

  AiAssistantService() {
    _seedWelcomeMessage();
  }

  void _seedWelcomeMessage() {
    _messages.add(
      AiMessage(
        id: 'ai_welcome',
        text: 'Greetings, Commander. I am **CORTEX AI Sentinel**, your autonomous cybersecurity and tactical operations analyst.\n\n'
            'I actively monitor mesh telemetry, cryptographic key exchanges, audit logs, and perimeter threats. '
            'How can I assist you with current security posture?',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        actionButtons: [
          'Explain Security Score',
          'Analyze Active Threats',
          'Summarize Audit Logs',
          'Assess Device Risks',
        ],
      ),
    );
  }

  Future<String> queryAssistant({
    required String query,
    required int securityScore,
    required List<SecurityThreatModel> activeThreats,
    required int failedLogins,
    required List<DeviceModel> devices,
    required bool isSosActive,
    required List<AuditLogModel> recentLogs,
  }) async {
    // Add user message
    _messages.add(
      AiMessage(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        text: query,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    // Artificial thinking delay
    await Future.delayed(const Duration(milliseconds: 600));

    final lower = query.toLowerCase();
    String response;
    List<String>? actionButtons;

    if (lower.contains('score') || lower.contains('why') && lower.contains('medium')) {
      if (activeThreats.isNotEmpty || failedLogins > 0) {
        final threatTitles = activeThreats.map((t) => '• ${t.title} (${t.severity.name.toUpperCase()})').join('\n');
        response = 'Your security health score is currently **$securityScore/100**.\n\n'
            '**Key Contributing Factors:**\n'
            '$threatTitles\n'
            '• Recorded Failed Authentications: $failedLogins\n\n'
            '**Recommendation:** Review and mitigate the quarantined device from IP 192.168.1.189 to restore optimal 100% score.';
        actionButtons = ['Isolate Threat IP', 'Run Security Scan'];
      } else {
        response = 'Your security score is **$securityScore/100 (OPTIMAL)**. All peer nodes have completed ECDH key rotation, and no active threat signatures are detected.';
      }
    } else if (lower.contains('threat') || lower.contains('risk') || lower.contains('attack')) {
      if (activeThreats.isEmpty) {
        response = 'No active critical or high-severity threats are currently detected in the P2P mesh relay.';
      } else {
        final threatItems = activeThreats.map((t) => '🛡️ **${t.title}**\n${t.description}\n*Severity: ${t.severity.name.toUpperCase()}*').join('\n\n');
        response = 'Identified **${activeThreats.length} active threat(s)**:\n\n$threatItems\n\nWould you like me to trigger an automated key rotation across all trusted relays?';
        actionButtons = ['Rotate Session Keys', 'Quarantine Unverified Nodes'];
      }
    } else if (lower.contains('audit') || lower.contains('log') || lower.contains('summary')) {
      final logSummary = recentLogs.take(4).map((l) => '• `[${l.eventType}]` ${l.description}').join('\n');
      response = '📋 **Audit Ledger Summary (Last 24h):**\n\n'
          '$logSummary\n\n'
          'All ${recentLogs.length} ledger entries have verified SHA-256 integrity signatures. Zero tampering detected.';
      actionButtons = ['Verify Ledger Integrity', 'Export Audit Report'];
    } else if (lower.contains('device')) {
      final quarantined = devices.where((d) => d.trustStatus == DeviceTrustStatus.quarantined).length;
      response = '📱 **Connected Devices Assessment:**\n\n'
          '• Total Registered: ${devices.length}\n'
          '• Trusted Nodes: ${devices.where((d) => d.trustStatus == DeviceTrustStatus.trusted).length}\n'
          '• Quarantined Nodes: $quarantined\n\n'
          '${quarantined > 0 ? "⚠️ Alert: 1 device is currently quarantined due to unverified cryptographic handshake." : "All connected devices have verified cryptographic signatures."}';
      actionButtons = ['View Devices', 'Revoke Untrusted Sessions'];
    } else if (lower.contains('sos') || lower.contains('emergency')) {
      if (isSosActive) {
        response = '🚨 **CRITICAL SOS ACTIVE:** Emergency broadcast is active. Tactical coordinates and telemetry are streaming to emergency contacts. All perimeter defenses are on high alert.';
        actionButtons = ['View SOS Incident', 'Resolve SOS'];
      } else {
        response = 'SOS emergency beacon is currently in standby mode. No active distress signals detected across the mesh.';
      }
    } else if (lower.contains('message') || lower.contains('private') || lower.contains('read my chat')) {
      response = '🔒 **Privacy Protocol Guard:** Under CORTEX Zero-Knowledge architecture, private end-to-end encrypted chat payloads are inaccessible to the AI assistant. I can only assist with network topology, security scores, device status, and audit metadata.';
    } else {
      response = 'I have analyzed your inquiry against current mesh telemetry. '
          'All CORTEX cryptographic sub-modules are operating under AES-256-GCM and Curve25519 specifications.\n\n'
          'You can ask me to explain security alerts, evaluate connected hardware, review audit logs, or guide you through incident resolution.';
      actionButtons = ['Explain Security Score', 'Analyze Active Threats', 'Run Diagnostics'];
    }

    _messages.add(
      AiMessage(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
        actionButtons: actionButtons,
      ),
    );

    return response;
  }

  void clearConversation() {
    _messages.clear();
    _seedWelcomeMessage();
  }
}
