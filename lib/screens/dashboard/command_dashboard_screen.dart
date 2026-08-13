import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_badge.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';

class CommandDashboardScreen extends StatefulWidget {
  const CommandDashboardScreen({super.key});

  @override
  State<CommandDashboardScreen> createState() => _CommandDashboardScreenState();
}

class _CommandDashboardScreenState extends State<CommandDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _orbitAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _orbitAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _orbitController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final user = appState.authService.currentUser;
    final activeThreats = appState.securityService.activeThreats;
    final isSos = appState.sosService.isSosActive;
    final isCallActive = appState.callService.hasActiveCall;
    final peersCount = appState.webSocketService.connectedPeersCount;
    final isMeshConnected = appState.webSocketService.isConnected;
    final onlineCount = appState.personnelService.onlinePersonnel.length;
    final recentLogs = appState.auditService.logs.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'CORTEX',
        subtitle: 'LOCAL SECURITY NETWORK',
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── SOS Emergency Banner ───────────────────────────────
            if (isSos) ...[
              _EmergencyBanner(appState: appState),
              const SizedBox(height: 12),
            ],

            // ─── Active Call Banner ──────────────────────────────────
            if (isCallActive) ...[
              _ActiveCallBanner(appState: appState),
              const SizedBox(height: 12),
            ],

            // ─── 3D Hero Node Card ───────────────────────────────────
            _NodeHeroCard(
              pulseAnimation: _pulseAnimation,
              orbitAnimation: _orbitAnimation,
              isSos: isSos,
              peersCount: peersCount,
              isMeshConnected: isMeshConnected,
              activeThreats: activeThreats.length,
              userName: user?.callsign ?? 'Vanguard-1',
              securityScore: appState.securityService.securityScore,
            ),

            const SizedBox(height: 16),

            // ─── Quick Status Strip ──────────────────────────────────
            _QuickStatusStrip(
              peersCount: peersCount,
              isMeshConnected: isMeshConnected,
              onlinePersonnel: onlineCount,
              activeThreats: activeThreats.length,
            ),

            const SizedBox(height: 20),

            // ─── Quick Actions ───────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('QUICK ACTIONS', style: AppTypography.titleMedium),
                CortexBadge.encrypted(isSmall: true),
              ],
            ),
            const SizedBox(height: 12),

            _QuickActionsGrid(appState: appState),

            const SizedBox(height: 20),

            // ─── Network Status Panel ────────────────────────────────
            const Text('NETWORK STATUS', style: AppTypography.titleMedium),
            const SizedBox(height: 10),
            _NetworkStatusPanel(
              appState: appState,
              isMeshConnected: isMeshConnected,
              peersCount: peersCount,
            ),

            const SizedBox(height: 20),

            // ─── Recent Activity ─────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RECENT ACTIVITY', style: AppTypography.titleMedium),
                TextButton(
                  onPressed: () => appState.setNavigationIndex(9),
                  child: const Text('View All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            CortexCard(
              padding: const EdgeInsets.all(4),
              child: Column(
                children: recentLogs.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                            child: Text(
                              'No activity recorded yet.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                            ),
                          ),
                        )
                      ]
                    : recentLogs.asMap().entries.map((entry) {
                        final log = entry.value;
                        final isLast = entry.key == recentLogs.length - 1;
                        return _ActivityRow(log: log, isLast: isLast);
                      }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3D NODE HERO CARD
// ─────────────────────────────────────────────────────────────────────────────
class _NodeHeroCard extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final Animation<double> orbitAnimation;
  final bool isSos;
  final int peersCount;
  final bool isMeshConnected;
  final int activeThreats;
  final String userName;
  final int securityScore;

  const _NodeHeroCard({
    required this.pulseAnimation,
    required this.orbitAnimation,
    required this.isSos,
    required this.peersCount,
    required this.isMeshConnected,
    required this.activeThreats,
    required this.userName,
    required this.securityScore,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isSos
        ? AppColors.critical
        : activeThreats > 0
            ? AppColors.warning
            : AppColors.success;
    final statusLabel = isSos
        ? 'SOS ACTIVE'
        : activeThreats > 0
            ? 'THREAT DETECTED'
            : 'SYSTEM SECURE';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative 3D tilt background rings
          Positioned(
            right: -20,
            top: -20,
            child: _Ring3D(
              size: 160,
              color: AppColors.primary.withValues(alpha: 0.06),
              strokeWidth: 30,
            ),
          ),
          Positioned(
            right: 20,
            top: 20,
            child: _Ring3D(
              size: 90,
              color: AppColors.primary.withValues(alpha: 0.09),
              strokeWidth: 16,
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top: status dot + label
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: pulseAnimation,
                      builder: (context, _) {
                        return Transform.scale(
                          scale: pulseAnimation.value,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 3D Orbit Node Visualizer + Device Info side by side
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 3D orbit canvas
                    SizedBox(
                      width: 96,
                      height: 96,
                      child: AnimatedBuilder(
                        animation: orbitAnimation,
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _OrbitNodePainter(
                              angle: orbitAnimation.value,
                              peersCount: peersCount,
                              statusColor: statusColor,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Device info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'This Device',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DeviceStatusPill(
                            icon: Icons.shield_rounded,
                            label: 'Protected',
                            color: AppColors.success,
                          ),
                          const SizedBox(height: 6),
                          _DeviceStatusPill(
                            icon: Icons.hub_rounded,
                            label: '$peersCount Connected Peer${peersCount != 1 ? "s" : ""}',
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 6),
                          _DeviceStatusPill(
                            icon: Icons.lock_rounded,
                            label: 'AES-256 Encrypted',
                            color: AppColors.primaryDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 14),

                // Bottom: Health Score bar
                Row(
                  children: [
                    const Text(
                      'SECURITY SCORE',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$securityScore / 100',
                      style: TextStyle(
                        color: securityScore >= 75 ? AppColors.success : AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: securityScore / 100.0,
                    backgroundColor: AppColors.surfaceElevated,
                    color: securityScore >= 75 ? AppColors.success : AppColors.warning,
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceStatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _DeviceStatusPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ORBIT NODE CUSTOM PAINTER (3D-style)
// ─────────────────────────────────────────────────────────────────────────────
class _OrbitNodePainter extends CustomPainter {
  final double angle;
  final int peersCount;
  final Color statusColor;

  _OrbitNodePainter({
    required this.angle,
    required this.peersCount,
    required this.statusColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rx = size.width / 2 - 8;
    final ry = rx * 0.35; // ellipse squish for 3D feel

    // Draw elliptical orbit ring
    final ringPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: rx * 2, height: ry * 2),
      ringPaint,
    );

    // Center node (this device)
    final centerGlow = Paint()
      ..color = statusColor.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(center, 22, centerGlow);

    final centerFill = Paint()..color = AppColors.surface;
    canvas.drawCircle(center, 18, centerFill);

    final centerBorder = Paint()
      ..color = statusColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 18, centerBorder);

    // Shield icon text simulation (small dot inside)
    final dotPaint = Paint()..color = statusColor;
    canvas.drawCircle(center, 5, dotPaint);

    // Orbiting peer nodes
    final count = peersCount.clamp(1, 6);
    for (int i = 0; i < count; i++) {
      final theta = angle + (2 * math.pi / count) * i;
      final px = center.dx + rx * math.cos(theta);
      final py = center.dy + ry * math.sin(theta);
      final peerPos = Offset(px, py);

      // Connector line
      final linePaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.25)
        ..strokeWidth = 0.8;
      canvas.drawLine(center, peerPos, linePaint);

      // Peer node circle
      final peerGlow = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(peerPos, 9, peerGlow);

      final peerFill = Paint()..color = AppColors.surfaceElevated;
      canvas.drawCircle(peerPos, 7, peerFill);

      final peerBorder = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(peerPos, 7, peerBorder);

      final peerDot = Paint()..color = AppColors.primary;
      canvas.drawCircle(peerPos, 2.5, peerDot);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitNodePainter old) =>
      old.angle != angle || old.peersCount != peersCount;
}

// ─────────────────────────────────────────────────────────────────────────────
// DECORATIVE 3D RING
// ─────────────────────────────────────────────────────────────────────────────
class _Ring3D extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  const _Ring3D({required this.size, required this.color, required this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(0.5)
        ..rotateZ(-0.3),
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: strokeWidth),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK STATUS STRIP
// ─────────────────────────────────────────────────────────────────────────────
class _QuickStatusStrip extends StatelessWidget {
  final int peersCount;
  final bool isMeshConnected;
  final int onlinePersonnel;
  final int activeThreats;

  const _QuickStatusStrip({
    required this.peersCount,
    required this.isMeshConnected,
    required this.onlinePersonnel,
    required this.activeThreats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatusChip(
            icon: Icons.wifi_tethering_rounded,
            label: isMeshConnected ? 'Mesh Active' : 'Offline',
            color: isMeshConnected ? AppColors.success : AppColors.textMuted,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusChip(
            icon: Icons.people_rounded,
            label: '$onlinePersonnel Online',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatusChip(
            icon: Icons.radar_rounded,
            label: activeThreats > 0 ? '$activeThreats Threats' : 'Secure',
            color: activeThreats > 0 ? AppColors.warning : AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatusChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTIONS GRID
// ─────────────────────────────────────────────────────────────────────────────
class _QuickActionsGrid extends StatelessWidget {
  final AppStateProvider appState;
  const _QuickActionsGrid({required this.appState});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionDef(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Secure\nChat',
        color: AppColors.primary,
        onTap: () => appState.setNavigationIndex(1),
      ),
      _ActionDef(
        icon: Icons.warning_amber_rounded,
        label: 'Emergency\nSOS',
        color: AppColors.critical,
        onTap: () => appState.setNavigationIndex(7),
      ),
      _ActionDef(
        icon: Icons.shield_outlined,
        label: 'Security\nCenter',
        color: AppColors.primaryDark,
        onTap: () => appState.setNavigationIndex(4),
      ),
      _ActionDef(
        icon: Icons.people_rounded,
        label: 'Personnel',
        color: AppColors.primary,
        onTap: () => appState.setNavigationIndex(5),
      ),
      _ActionDef(
        icon: Icons.folder_outlined,
        label: 'Share\nFile',
        color: AppColors.primaryLight,
        onTap: () => appState.setNavigationIndex(2),
      ),
      _ActionDef(
        icon: Icons.smart_toy_outlined,
        label: 'AI\nSentinel',
        color: AppColors.primaryDark,
        onTap: () => appState.setNavigationIndex(8),
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: actions.map((a) => _ActionCard(def: a)).toList(),
    );
  }
}

class _ActionDef {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionDef({required this.icon, required this.label, required this.color, required this.onTap});
}

class _ActionCard extends StatefulWidget {
  final _ActionDef def;
  const _ActionCard({required this.def});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _hoverCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final def = widget.def;
    return GestureDetector(
      onTapDown: (_) => _hoverCtrl.forward(),
      onTapUp: (_) {
        _hoverCtrl.reverse();
        def.onTap();
      },
      onTapCancel: () => _hoverCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: def.color.withValues(alpha: 0.07),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              const BoxShadow(
                color: Color(0x08000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 3D layered icon container
              Stack(
                alignment: Alignment.center,
                children: [
                  // Shadow layer (offset, gives 3D depth)
                  Transform.translate(
                    offset: const Offset(2, 3),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: def.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  // Main icon container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: def.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: def.color.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Icon(def.icon, color: def.color, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                def.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NETWORK STATUS PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _NetworkStatusPanel extends StatelessWidget {
  final AppStateProvider appState;
  final bool isMeshConnected;
  final int peersCount;

  const _NetworkStatusPanel({
    required this.appState,
    required this.isMeshConnected,
    required this.peersCount,
  });

  @override
  Widget build(BuildContext context) {
    return CortexCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _NetworkRow(
            dot: true,
            dotColor: isMeshConnected ? AppColors.success : AppColors.textMuted,
            label: 'Local network ${isMeshConnected ? "active" : "disconnected"}',
            trailing: isMeshConnected ? 'P2P MESH' : 'OFFLINE',
            trailingColor: isMeshConnected ? AppColors.success : AppColors.textMuted,
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          _NetworkRow(
            dot: true,
            dotColor: peersCount > 0 ? AppColors.primary : AppColors.textMuted,
            label: 'Peer discovery enabled',
            trailing: '$peersCount node${peersCount != 1 ? "s" : ""}',
            trailingColor: AppColors.primary,
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),
          _NetworkRow(
            dot: true,
            dotColor: AppColors.success,
            label: 'End-to-end encryption active',
            trailing: 'AES-256-GCM',
            trailingColor: AppColors.primaryDark,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: CortexButton.outline(
              text: 'VIEW SECURITY CENTER',
              icon: Icons.shield_outlined,
              isSmall: true,
              onPressed: () => appState.setNavigationIndex(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkRow extends StatelessWidget {
  final bool dot;
  final Color dotColor;
  final String label;
  final String trailing;
  final Color trailingColor;

  const _NetworkRow({
    required this.dot,
    required this.dotColor,
    required this.label,
    required this.trailing,
    required this.trailingColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (dot) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: trailingColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            trailing,
            style: TextStyle(
              color: trailingColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVITY ROW
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityRow extends StatelessWidget {
  final dynamic log;
  final bool isLast;
  const _ActivityRow({required this.log, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border, width: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 4),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.eventType,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  log.description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMERGENCY BANNERS
// ─────────────────────────────────────────────────────────────────────────────
class _EmergencyBanner extends StatelessWidget {
  final AppStateProvider appState;
  const _EmergencyBanner({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.critical.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.critical, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded, color: AppColors.critical, size: 26),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EMERGENCY SOS ACTIVE',
                  style: TextStyle(
                    color: AppColors.critical,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Distress beacon broadcasting. Emergency contacts alerted.',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 11),
                ),
              ],
            ),
          ),
          CortexButton.destructive(
            text: 'VIEW',
            isSmall: true,
            onPressed: () => appState.setNavigationIndex(7),
          ),
        ],
      ),
    );
  }
}

class _ActiveCallBanner extends StatelessWidget {
  final AppStateProvider appState;
  const _ActiveCallBanner({required this.appState});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight, width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.call_rounded, color: AppColors.success, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE CALL: ${appState.callService.activeCall?.peerName ?? "Peer"}',
                  style: AppTypography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Duration: ${appState.callService.activeCall?.formattedDuration ?? "00:00"} • Encrypted SRTP',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          CortexButton(
            text: 'OPEN',
            isSmall: true,
            onPressed: () => appState.setNavigationIndex(3),
          ),
        ],
      ),
    );
  }
}
