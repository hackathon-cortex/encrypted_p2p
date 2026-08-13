import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SecurityGauge extends StatelessWidget {
  final int score;
  final double size;
  final String statusText;
  final bool showDetails;

  const SecurityGauge({
    super.key,
    required this.score,
    this.size = 140,
    required this.statusText,
    this.showDetails = true,
  });

  Color get scoreColor {
    if (score >= 90) return AppColors.success;
    if (score >= 75) return AppColors.primaryLight;
    if (score >= 50) return AppColors.warning;
    return AppColors.critical;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _SecurityGaugePainter(
                  score: score,
                  scoreColor: scoreColor,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.0,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'HEALTH SCORE',
                    style: TextStyle(
                      fontSize: size * 0.07,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDetails) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: scoreColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SecurityGaugePainter extends CustomPainter {
  final int score;
  final Color scoreColor;

  _SecurityGaugePainter({
    required this.score,
    required this.scoreColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = -math.pi * 1.25;
    const sweepTotal = math.pi * 1.5;

    // Track Background
    final trackPaint = Paint()
      ..color = AppColors.surfaceHighlight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepTotal,
      false,
      trackPaint,
    );

    // Active Score Arc
    final activeSweep = sweepTotal * (score / 100.0).clamp(0.0, 1.0);
    final activePaint = Paint()
      ..color = scoreColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      activeSweep,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SecurityGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.scoreColor != scoreColor;
  }
}
