import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/location_model.dart';

class RadarMapView extends StatefulWidget {
  final TacticalLocationModel userLocation;
  final List<TacticalLocationModel> peerLocations;
  final ValueChanged<TacticalLocationModel>? onSelectPeer;
  final bool isSharing;

  const RadarMapView({
    super.key,
    required this.userLocation,
    required this.peerLocations,
    this.onSelectPeer,
    this.isSharing = true,
  });

  @override
  State<RadarMapView> createState() => _RadarMapViewState();
}

class _RadarMapViewState extends State<RadarMapView> with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;
  double _zoom = 1.0;
  Offset _panOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF060B12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Interactive Pan & Zoom Area
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _panOffset += details.delta;
                });
              },
              child: AnimatedBuilder(
                animation: _sweepController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _TacticalRadarPainter(
                      sweepAngle: _sweepController.value * 2 * math.pi,
                      zoom: _zoom,
                      panOffset: _panOffset,
                      userLocation: widget.userLocation,
                      peerLocations: widget.peerLocations,
                      isSharing: widget.isSharing,
                    ),
                  );
                },
              ),
            ),

            // Top Telemetry Header
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 0.8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.isSharing ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.isSharing ? 'RADAR ACTIVE • 10Hz' : 'BEACON MUTED',
                          style: TextStyle(
                            color: widget.isSharing ? AppColors.success : AppColors.error,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'LAT: ${widget.userLocation.latitude.toStringAsFixed(4)}° N | LNG: ${widget.userLocation.longitude.toStringAsFixed(4)}° W',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Radar Controls (Zoom In, Zoom Out, Reset, Center)
            Positioned(
              bottom: 12,
              right: 12,
              child: Column(
                children: [
                  _RadarControlBtn(
                    icon: Icons.add,
                    tooltip: 'Zoom In',
                    onTap: () {
                      setState(() {
                        _zoom = (_zoom * 1.25).clamp(0.5, 3.0);
                      });
                    },
                  ),
                  const SizedBox(height: 6),
                  _RadarControlBtn(
                    icon: Icons.remove,
                    tooltip: 'Zoom Out',
                    onTap: () {
                      setState(() {
                        _zoom = (_zoom / 1.25).clamp(0.5, 3.0);
                      });
                    },
                  ),
                  const SizedBox(height: 6),
                  _RadarControlBtn(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Recenter',
                    onTap: () {
                      setState(() {
                        _panOffset = Offset.zero;
                        _zoom = 1.0;
                      });
                    },
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

class _RadarControlBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RadarControlBtn({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 0.8),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 18),
        ),
      ),
    );
  }
}

class _TacticalRadarPainter extends CustomPainter {
  final double sweepAngle;
  final double zoom;
  final Offset panOffset;
  final TacticalLocationModel userLocation;
  final List<TacticalLocationModel> peerLocations;
  final bool isSharing;

  _TacticalRadarPainter({
    required this.sweepAngle,
    required this.zoom,
    required this.panOffset,
    required this.userLocation,
    required this.peerLocations,
    required this.isSharing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 + panOffset.dx, size.height / 2 + panOffset.dy);
    final maxRadius = math.min(size.width, size.height) * 0.45 * zoom;

    final gridPaint = Paint()
      ..color = const Color(0xFF16233B)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final axisPaint = Paint()
      ..color = const Color(0xFF1E3A5F)
      ..strokeWidth = 1.0;

    // Draw background grid lines
    const gridStep = 40.0;
    for (double x = 0; x < size.width; x += gridStep) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridStep) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw concentric radar range rings
    final ringPaint = Paint()
      ..color = const Color(0xFF1D3557).withValues(alpha: 0.8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final ringFills = [0.25, 0.5, 0.75, 1.0];
    for (final fraction in ringFills) {
      final r = maxRadius * fraction;
      canvas.drawCircle(center, r, ringPaint);
    }

    // Radar crosshairs
    canvas.drawLine(Offset(center.dx - maxRadius, center.dy), Offset(center.dx + maxRadius, center.dy), axisPaint);
    canvas.drawLine(Offset(center.dx, center.dy - maxRadius), Offset(center.dx, center.dy + maxRadius), axisPaint);

    // Radar Sweep Cone
    if (isSharing) {
      final sweepPaint = Paint()
        ..shader = SweepGradient(
          startAngle: 0.0,
          endAngle: math.pi / 2,
          colors: [
            AppColors.accentCyan.withValues(alpha: 0.0),
            AppColors.accentCyan.withValues(alpha: 0.25),
          ],
          transform: GradientRotation(sweepAngle - math.pi / 2),
        ).createShader(Rect.fromCircle(center: center, radius: maxRadius));

      canvas.drawCircle(center, maxRadius, sweepPaint);

      // Sweep leading line
      final sweepLinePaint = Paint()
        ..color = AppColors.accentCyan
        ..strokeWidth = 1.5;
      final sweepEnd = Offset(
        center.dx + maxRadius * math.cos(sweepAngle),
        center.dy + maxRadius * math.sin(sweepAngle),
      );
      canvas.drawLine(center, sweepEnd, sweepLinePaint);
    }

    // Draw Peer Markers (Sarah, Daniel, Elena, Rachel)
    // Scale coordinate differences to canvas pixels
    for (final peer in peerLocations) {
      final latDiff = (peer.latitude - userLocation.latitude) * 15000 * zoom;
      final lngDiff = (peer.longitude - userLocation.longitude) * 15000 * zoom;
      final peerOffset = Offset(center.dx + lngDiff, center.dy - latDiff);

      // Draw peer marker dot
      final peerDot = Paint()..color = AppColors.primaryLight;
      canvas.drawCircle(peerOffset, 5.0, peerDot);

      // Draw peer ring
      final peerRing = Paint()
        ..color = AppColors.primaryLight.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(peerOffset, 10.0, peerRing);

      // Text label for callsign
      final textSpan = TextSpan(
        text: peer.callsign,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(peerOffset.dx + 12, peerOffset.dy - 6));
    }

    // Draw User Marker (Center)
    final userDot = Paint()..color = isSharing ? AppColors.accentCyan : AppColors.error;
    canvas.drawCircle(center, 7.0, userDot);

    final userAura = Paint()
      ..color = (isSharing ? AppColors.accentCyan : AppColors.error).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, 14.0, userAura);

    // User Label
    final userSpan = TextSpan(
      text: '${userLocation.callsign} (YOU)',
      style: const TextStyle(
        color: AppColors.accentCyan,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
    final userTextPainter = TextPainter(
      text: userSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    userTextPainter.paint(canvas, Offset(center.dx - userTextPainter.width / 2, center.dy + 18));
  }

  @override
  bool shouldRepaint(covariant _TacticalRadarPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.zoom != zoom ||
        oldDelegate.panOffset != panOffset ||
        oldDelegate.isSharing != isSharing;
  }
}
