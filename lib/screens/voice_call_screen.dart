import 'package:flutter/material.dart';

import '../utils/colors.dart';

class VoiceCallScreen extends StatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        title: const Text(
          'Voice Call',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          const Spacer(),

          const CircleAvatar(
            radius: 58,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.person_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'Cortex User',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Calling...',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            '00:00',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),

          const Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CallButton(
                icon: isMuted
                    ? Icons.mic_off_rounded
                    : Icons.mic_rounded,
                label: 'Mute',
                active: isMuted,
                onTap: () {
                  setState(() {
                    isMuted = !isMuted;
                  });
                },
              ),
              const SizedBox(width: 22),
              _CallButton(
                icon: isSpeakerOn
                    ? Icons.volume_up_rounded
                    : Icons.volume_down_rounded,
                label: 'Speaker',
                active: isSpeakerOn,
                onTap: () {
                  setState(() {
                    isSpeakerOn = !isSpeakerOn;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 28),

          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.call_end_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          const SizedBox(height: 35),
        ],
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: active
                  ? AppColors.primary
                  : AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: 23,
            ),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}