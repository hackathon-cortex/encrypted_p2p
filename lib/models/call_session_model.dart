enum CallType { voice, video }

enum CallState {
  idle,
  outgoingRinging,
  incomingRinging,
  connecting,
  active,
  held,
  ended,
  rejected,
  missed,
}

class CallSessionModel {
  final String id;
  final String peerId;
  final String peerName;
  final String peerCallsign;
  final String? peerAvatarUrl;
  final CallType callType;
  final bool isIncoming;
  final CallState state;
  final DateTime startTime;
  final int durationSeconds;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isCameraOff;
  final bool isFrontCamera;
  final String encryptionFingerprint;
  final String cipherSuite;

  CallSessionModel({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.peerCallsign,
    this.peerAvatarUrl,
    this.callType = CallType.voice,
    this.isIncoming = false,
    this.state = CallState.idle,
    required this.startTime,
    this.durationSeconds = 0,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isCameraOff = false,
    this.isFrontCamera = true,
    this.encryptionFingerprint = 'E2EE-ECDH-9A4B-2C1F',
    this.cipherSuite = 'SRTP-AES-GCM-256',
  });

  String get formattedDuration {
    final minutes = (durationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (durationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  CallSessionModel copyWith({
    String? id,
    String? peerId,
    String? peerName,
    String? peerCallsign,
    String? peerAvatarUrl,
    CallType? callType,
    bool? isIncoming,
    CallState? state,
    DateTime? startTime,
    int? durationSeconds,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isCameraOff,
    bool? isFrontCamera,
    String? encryptionFingerprint,
    String? cipherSuite,
  }) {
    return CallSessionModel(
      id: id ?? this.id,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      peerCallsign: peerCallsign ?? this.peerCallsign,
      peerAvatarUrl: peerAvatarUrl ?? this.peerAvatarUrl,
      callType: callType ?? this.callType,
      isIncoming: isIncoming ?? this.isIncoming,
      state: state ?? this.state,
      startTime: startTime ?? this.startTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      encryptionFingerprint: encryptionFingerprint ?? this.encryptionFingerprint,
      cipherSuite: cipherSuite ?? this.cipherSuite,
    );
  }
}
