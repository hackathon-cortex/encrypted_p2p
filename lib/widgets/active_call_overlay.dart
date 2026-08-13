import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/call_session_model.dart';
import 'tactical/audio_wave_visualizer.dart';

class ActiveCallOverlay extends StatelessWidget {
  const ActiveCallOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final call = appState.callService.activeCall;

    if (call == null || call.state != CallState.active) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primaryLight, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                call.callType == CallType.video ? Icons.videocam_rounded : Icons.call_rounded,
                color: AppColors.primaryLight,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        call.peerName,
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        call.formattedDuration,
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Encrypted SRTP-AES-GCM • Minimized',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Wave
            const SizedBox(
              width: 50,
              child: AudioWaveVisualizer(
                isPlaying: true,
                barCount: 8,
                height: 20,
              ),
            ),
            const SizedBox(width: 10),
            // End call button
            IconButton(
              onPressed: () {
                appState.endCall();
              },
              icon: const Icon(Icons.call_end_rounded, color: AppColors.error, size: 22),
              tooltip: 'End Call',
            ),
          ],
        ),
      ),
    );
  }
}
