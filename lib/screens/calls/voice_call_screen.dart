import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/call_session_model.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_badge.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/tactical/audio_wave_visualizer.dart';

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final activeCall = appState.callService.activeCall;
    final callHistory = appState.callService.callHistory;
    final personnel = appState.personnelService.personnel;

    // If there is an active call, show the active call interface
    if (activeCall != null && (activeCall.state == CallState.active || activeCall.state == CallState.outgoingRinging)) {
      return _ActiveCallInterface(call: activeCall);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'SECURE COMMUNICATIONS',
        subtitle: 'SRTP-AES-GCM-256 • ZERO-LOG CALLING',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Speed Dial Personnel
            const Text('TACTICAL SPEED DIAL', style: AppTypography.titleMedium),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: personnel.map((p) {
                  return Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    child: CortexCard(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: p.isOnline ? AppColors.primary : AppColors.surfaceHighlight,
                            child: Text(
                              p.fullName.substring(0, 1),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            p.fullName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            p.callsign,
                            style: const TextStyle(fontSize: 10, color: AppColors.accentCyan, fontFamily: 'monospace'),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _CallMiniBtn(
                                icon: Icons.call,
                                tooltip: 'Voice Call',
                                onTap: () {
                                  appState.startCall(peerId: p.id, peerName: p.fullName, peerCallsign: p.callsign);
                                },
                              ),
                              const SizedBox(width: 8),
                              _CallMiniBtn(
                                icon: Icons.videocam_rounded,
                                tooltip: 'Video Call',
                                onTap: () {
                                  appState.startCall(peerId: p.id, peerName: p.fullName, peerCallsign: p.callsign, callType: CallType.video);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 28),

            // Call Simulation Trigger for Testing
            CortexCard(
              padding: const EdgeInsets.all(16),
              borderColor: AppColors.primaryLight.withValues(alpha: 0.4),
              child: Row(
                children: [
                  const Icon(Icons.ring_volume_rounded, color: AppColors.accentCyan, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('INCOMING CALL SIMULATION', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        Text('Trigger test encrypted call from Commander / Field Unit', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  CortexButton.outline(
                    text: 'SIMULATE INCOMING',
                    isSmall: true,
                    onPressed: () {
                      _showIncomingCallDialog(context);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Call History Ledger
            const Text('ENCRYPTED CALL LOG', style: AppTypography.titleMedium),
            const SizedBox(height: 12),

            if (callHistory.isEmpty)
              CortexCard(
                padding: const EdgeInsets.all(24),
                child: const Center(child: Text('No call logs recorded.', style: AppTypography.bodyMedium)),
              )
            else
              ...callHistory.map((session) {
                final isMissed = session.state == CallState.missed || session.state == CallState.rejected;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: CortexCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isMissed ? AppColors.error.withValues(alpha: 0.15) : AppColors.success.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isMissed
                                ? Icons.call_missed_rounded
                                : (session.isIncoming ? Icons.call_received_rounded : Icons.call_made_rounded),
                            color: isMissed ? AppColors.error : AppColors.success,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.peerName,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              ),
                              Text(
                                '${session.peerCallsign} • ${session.callType.name.toUpperCase()} CALL',
                                style: const TextStyle(fontSize: 10, color: AppColors.accentCyan, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              session.formattedDuration,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: AppColors.textPrimary),
                            ),
                            const Text(
                              'SRTP-256',
                              style: TextStyle(fontSize: 9, color: AppColors.textMuted, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _showIncomingCallDialog(BuildContext context) {
    final appState = AppStateProvider.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person_rounded, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('Sarah Khan (Aegis-1)', style: AppTypography.titleLarge),
              const SizedBox(height: 4),
              const Text('INCOMING ENCRYPTED VOICE CALL...', style: TextStyle(color: AppColors.accentCyan, fontSize: 11, fontFamily: 'monospace')),
              const SizedBox(height: 12),
              CortexBadge.encrypted(isSmall: true),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline
                  IconButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.call_end_rounded, color: AppColors.error, size: 36),
                    tooltip: 'Decline',
                  ),
                  // Accept
                  IconButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      appState.startCall(
                        peerId: 'p_01',
                        peerName: 'Sarah Khan',
                        peerCallsign: 'Aegis-1',
                      );
                    },
                    icon: const Icon(Icons.call_rounded, color: AppColors.success, size: 36),
                    tooltip: 'Accept',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveCallInterface extends StatelessWidget {
  final CallSessionModel call;

  const _ActiveCallInterface({required this.call});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isRinging = call.state == CallState.outgoingRinging;

    return Scaffold(
      backgroundColor: const Color(0xFF06090E),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Minimize and Encryption details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 28),
                    tooltip: 'Minimize Call',
                    onPressed: () {
                      // Navigate to dashboard while keeping call alive in overlay
                      appState.setNavigationIndex(0);
                    },
                  ),
                  Column(
                    children: [
                      CortexBadge.encrypted(isSmall: true),
                      const SizedBox(height: 2),
                      Text(
                        call.cipherSuite,
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const SizedBox(width: 48), // Balancer
                ],
              ),
            ),

            const Spacer(),

            // Video preview simulation or Avatar
            if (call.callType == CallType.video && !call.isCameraOff) ...[
              Container(
                width: 220,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam_rounded, size: 48, color: AppColors.primaryLight),
                      const SizedBox(height: 12),
                      Text(call.peerName, style: AppTypography.titleMedium),
                      const SizedBox(height: 4),
                      const Text('Encrypted 1080p Stream', style: TextStyle(color: AppColors.accentCyan, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Audio Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 28,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.person_rounded, size: 64, color: AppColors.primaryLight),
                ),
              ),
            ],

            const SizedBox(height: 24),

            Text(call.peerName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(call.peerCallsign, style: const TextStyle(fontSize: 13, color: AppColors.accentCyan, fontFamily: 'monospace')),

            const SizedBox(height: 16),

            // Ringing state or Active Duration with Waveform
            if (isRinging) ...[
              const Text('NEGOTIATING CRYPTOGRAPHIC HANDSHAKE...', style: TextStyle(color: AppColors.accentCyan, fontSize: 11, fontFamily: 'monospace')),
            ] else ...[
              Text(
                call.formattedDuration,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: AppColors.success),
              ),
              const SizedBox(height: 12),
              const SizedBox(
                width: 180,
                child: AudioWaveVisualizer(isPlaying: true, height: 28),
              ),
            ],

            const Spacer(),

            // In-Call Controls Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _CallActionBtn(
                    icon: call.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    label: 'Mute',
                    isActive: call.isMuted,
                    onTap: () => appState.callService.toggleMute(),
                  ),
                  _CallActionBtn(
                    icon: call.isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                    label: 'Speaker',
                    isActive: call.isSpeakerOn,
                    onTap: () => appState.callService.toggleSpeaker(),
                  ),
                  if (call.callType == CallType.video) ...[
                    _CallActionBtn(
                      icon: call.isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                      label: 'Camera',
                      isActive: !call.isCameraOff,
                      onTap: () => appState.callService.toggleCamera(),
                    ),
                    _CallActionBtn(
                      icon: Icons.flip_camera_ios_rounded,
                      label: 'Flip',
                      isActive: false,
                      onTap: () => appState.callService.switchCamera(),
                    ),
                  ],
                  // End Call Button
                  GestureDetector(
                    onTap: () => appState.endCall(),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.error, blurRadius: 16, offset: Offset(0, 4)),
                        ],
                      ),
                      child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CallMiniBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _CallMiniBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16, color: AppColors.primaryLight),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}

class _CallActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CallActionBtn({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderLight, width: 1),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }
}
