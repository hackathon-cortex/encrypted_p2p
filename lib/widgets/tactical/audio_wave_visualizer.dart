import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AudioWaveVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color barColor;
  final int barCount;
  final double height;

  const AudioWaveVisualizer({
    super.key,
    this.isPlaying = true,
    this.barColor = AppColors.accentCyan,
    this.barCount = 20,
    this.height = 40,
  });

  @override
  State<AudioWaveVisualizer> createState() => _AudioWaveVisualizerState();
}

class _AudioWaveVisualizerState extends State<AudioWaveVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.barCount, (index) {
              final progress = _controller.value;
              final phase = (index / widget.barCount) * 2 * math.pi;
              final factor = widget.isPlaying
                  ? (math.sin(progress * 2 * math.pi + phase).abs() * 0.75 + 0.25)
                  : 0.15;
              final barH = widget.height * factor;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 3.5,
                height: barH,
                decoration: BoxDecoration(
                  color: widget.barColor.withValues(alpha: widget.isPlaying ? 0.9 : 0.4),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
