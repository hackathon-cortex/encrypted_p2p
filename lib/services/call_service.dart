import 'dart:async';
import '../models/call_session_model.dart';

class CallService {
  CallSessionModel? _activeCall;
  final List<CallSessionModel> _callHistory = [];
  Timer? _callDurationTimer;

  CallSessionModel? get activeCall => _activeCall;
  List<CallSessionModel> get callHistory => List.unmodifiable(_callHistory);
  bool get hasActiveCall => _activeCall != null && _activeCall!.state == CallState.active;
  bool get isRinging => _activeCall != null && (_activeCall!.state == CallState.outgoingRinging || _activeCall!.state == CallState.incomingRinging);

  CallService() {
    _seedCallHistory();
  }

  void _seedCallHistory() {
    final now = DateTime.now();

    _callHistory.addAll([
      CallSessionModel(
        id: 'call_h_01',
        peerId: 'p_01',
        peerName: 'Sarah Khan',
        peerCallsign: 'Aegis-1',
        callType: CallType.voice,
        state: CallState.ended,
        startTime: now.subtract(const Duration(hours: 1, minutes: 20)),
        durationSeconds: 342, // 05:42
        cipherSuite: 'SRTP-AES-GCM-256',
      ),
      CallSessionModel(
        id: 'call_h_02',
        peerId: 'p_02',
        peerName: 'Daniel Lee',
        peerCallsign: 'Ghost-4',
        callType: CallType.video,
        state: CallState.ended,
        startTime: now.subtract(const Duration(hours: 4)),
        durationSeconds: 780, // 13:00
        cipherSuite: 'SRTP-AES-GCM-256',
      ),
      CallSessionModel(
        id: 'call_h_03',
        peerId: 'p_03',
        peerName: 'Elena Rostova',
        peerCallsign: 'Cipher-7',
        callType: CallType.voice,
        state: CallState.missed,
        startTime: now.subtract(const Duration(days: 1)),
        durationSeconds: 0,
        cipherSuite: 'SRTP-AES-GCM-256',
      ),
    ]);
  }

  void startOutgoingCall({
    required String peerId,
    required String peerName,
    required String peerCallsign,
    String? peerAvatarUrl,
    CallType callType = CallType.voice,
  }) {
    _callDurationTimer?.cancel();

    _activeCall = CallSessionModel(
      id: 'call_${DateTime.now().millisecondsSinceEpoch}',
      peerId: peerId,
      peerName: peerName,
      peerCallsign: peerCallsign,
      peerAvatarUrl: peerAvatarUrl,
      callType: callType,
      isIncoming: false,
      state: CallState.outgoingRinging,
      startTime: DateTime.now(),
      durationSeconds: 0,
    );

    // Simulate peer pickup after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (_activeCall != null && _activeCall!.state == CallState.outgoingRinging) {
        _activeCall = _activeCall!.copyWith(state: CallState.active);
        _startTimer();
      }
    });
  }

  void triggerSimulatedIncomingCall({
    required String peerId,
    required String peerName,
    required String peerCallsign,
    CallType callType = CallType.voice,
  }) {
    _callDurationTimer?.cancel();

    _activeCall = CallSessionModel(
      id: 'call_inc_${DateTime.now().millisecondsSinceEpoch}',
      peerId: peerId,
      peerName: peerName,
      peerCallsign: peerCallsign,
      callType: callType,
      isIncoming: true,
      state: CallState.incomingRinging,
      startTime: DateTime.now(),
      durationSeconds: 0,
    );
  }

  void answerCall() {
    if (_activeCall != null) {
      _activeCall = _activeCall!.copyWith(state: CallState.active);
      _startTimer();
    }
  }

  void rejectCall() {
    if (_activeCall != null) {
      final ended = _activeCall!.copyWith(state: CallState.rejected);
      _callHistory.insert(0, ended);
      _activeCall = null;
      _callDurationTimer?.cancel();
    }
  }

  void endCall() {
    if (_activeCall != null) {
      final ended = _activeCall!.copyWith(state: CallState.ended);
      _callHistory.insert(0, ended);
      _activeCall = null;
      _callDurationTimer?.cancel();
    }
  }

  void toggleMute() {
    if (_activeCall != null) {
      _activeCall = _activeCall!.copyWith(isMuted: !_activeCall!.isMuted);
    }
  }

  void toggleSpeaker() {
    if (_activeCall != null) {
      _activeCall = _activeCall!.copyWith(isSpeakerOn: !_activeCall!.isSpeakerOn);
    }
  }

  void toggleCamera() {
    if (_activeCall != null) {
      _activeCall = _activeCall!.copyWith(isCameraOff: !_activeCall!.isCameraOff);
    }
  }

  void switchCamera() {
    if (_activeCall != null) {
      _activeCall = _activeCall!.copyWith(isFrontCamera: !_activeCall!.isFrontCamera);
    }
  }

  void _startTimer() {
    _callDurationTimer?.cancel();
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_activeCall != null && _activeCall!.state == CallState.active) {
        _activeCall = _activeCall!.copyWith(
          durationSeconds: _activeCall!.durationSeconds + 1,
        );
      }
    });
  }

  void dispose() {
    _callDurationTimer?.cancel();
  }
}
