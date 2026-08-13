import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_badge.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/tactical/security_gauge.dart';

class CommandDashboardScreen extends StatelessWidget {
  const CommandDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final user = appState.authService.currentUser;
    final securityScore = appState.securityService.securityScore;
    final securityStatusText = appState.securityService.securityStatusText;
    final onlineCount = appState.personnelService.onlinePersonnel.length;
    final totalPersonnel = appState.personnelService.personnel.length;
    final activeThreats = appState.securityService.activeThreats;
    final isSos = appState.sosService.isSosActive;
    final trustedDevicesCount = appState.deviceService.trustedDevices.length;
    final recentFiles = appState.fileService.files.take(2).toList();
    final recentLogs = appState.auditService.logs.take(4).toList();
    final isCallActive = appState.callService.hasActiveCall;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'COMMAND DASHBOARD',
        subtitle: 'TACTICAL NODE: ${user?.callsign ?? "Vanguard-1"} • MESH SYNCHRONIZED',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active SOS Critical Banner if triggered
            if (isSos) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.critical.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.critical, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_rounded, color: AppColors.critical, size: 28),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EMERGENCY SOS DISTRESS ACTIVE',
                            style: TextStyle(
                              color: AppColors.critical,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Distress coordinates are broadcasting. Emergency contacts alerted.',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    CortexButton.destructive(
                      text: 'VIEW SOS',
                      isSmall: true,
                      onPressed: () {
                        appState.setNavigationIndex(7); // SOS tab
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Active Call Banner if call is ongoing
            if (isCallActive) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryLight, width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.call_rounded, color: AppColors.success, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ACTIVE CALL: ${appState.callService.activeCall?.peerName ?? "Peer"}',
                            style: AppTypography.titleMedium,
                          ),
                          Text(
                            'Duration: ${appState.callService.activeCall?.formattedDuration ?? "00:00"} • Encrypted SRTP',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    CortexButton(
                      text: 'OPEN CALL',
                      isSmall: true,
                      onPressed: () {
                        appState.setNavigationIndex(3); // Calls tab
                      },
                    ),
                  ],
                ),
              ),
            ],

            // SECTION 1: Status & Health Metrics Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;

                final securityCard = CortexCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('SECURITY POSTURE', style: AppTypography.titleMedium),
                          CortexBadge.encrypted(isSmall: true),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SecurityGauge(
                        score: securityScore,
                        statusText: securityStatusText,
                        size: 130,
                      ),
                      const SizedBox(height: 14),
                      CortexButton.outline(
                        text: 'SECURITY CENTER',
                        icon: Icons.shield_outlined,
                        isSmall: true,
                        onPressed: () {
                          appState.setNavigationIndex(4); // Security tab
                        },
                      ),
                    ],
                  ),
                );

                final telemetryGrid = Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.people_rounded,
                            iconColor: AppColors.primaryLight,
                            title: 'ONLINE PERSONNEL',
                            value: '$onlineCount / $totalPersonnel',
                            subtitle: 'Units Active',
                            onTap: () => appState.setNavigationIndex(5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.hub_rounded,
                            iconColor: AppColors.accentCyan,
                            title: 'P2P MESH NODES',
                            value: '${appState.webSocketService.connectedPeersCount} Relays',
                            subtitle: 'Latency: ${appState.webSocketService.networkLatency}',
                            onTap: () => appState.setNavigationIndex(6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.shield_outlined,
                            iconColor: activeThreats.isNotEmpty ? AppColors.warning : AppColors.success,
                            title: 'ACTIVE THREATS',
                            value: '${activeThreats.length}',
                            subtitle: activeThreats.isNotEmpty ? 'Mitigation Needed' : 'Perimeter Secure',
                            onTap: () => appState.setNavigationIndex(4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.devices_rounded,
                            iconColor: AppColors.primaryLight,
                            title: 'TRUSTED DEVICES',
                            value: '$trustedDevicesCount Nodes',
                            subtitle: 'AES-256 Validated',
                            onTap: () => appState.setNavigationIndex(11),
                          ),
                        ),
                      ],
                    ),
                  ],
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: securityCard),
                      const SizedBox(width: 16),
                      Expanded(flex: 6, child: telemetryGrid),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      securityCard,
                      const SizedBox(height: 16),
                      telemetryGrid,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // SECTION 2: Quick Action Launchers
            const Text('QUICK ACTIONS', style: AppTypography.titleMedium),
            const SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                final count = constraints.maxWidth > 900 ? 6 : (constraints.maxWidth > 600 ? 3 : 2);
                final width = (constraints.maxWidth - (count - 1) * 12) / count;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _QuickActionTile(
                      width: width,
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Secure Chat',
                      color: AppColors.primary,
                      onTap: () => appState.setNavigationIndex(1),
                    ),
                    _QuickActionTile(
                      width: width,
                      icon: Icons.folder_outlined,
                      label: 'Share File',
                      color: AppColors.accentCyan,
                      onTap: () => appState.setNavigationIndex(2),
                    ),
                    _QuickActionTile(
                      width: width,
                      icon: Icons.call_outlined,
                      label: 'Start Call',
                      color: AppColors.success,
                      onTap: () => appState.setNavigationIndex(3),
                    ),
                    _QuickActionTile(
                      width: width,
                      icon: Icons.warning_amber_rounded,
                      label: 'Emergency SOS',
                      color: AppColors.critical,
                      onTap: () => appState.setNavigationIndex(7),
                    ),
                    _QuickActionTile(
                      width: width,
                      icon: Icons.location_on_outlined,
                      label: 'Live Location',
                      color: AppColors.info,
                      onTap: () => appState.setNavigationIndex(6),
                    ),
                    _QuickActionTile(
                      width: width,
                      icon: Icons.smart_toy_outlined,
                      label: 'AI Sentinel',
                      color: AppColors.accentIndigo,
                      onTap: () => appState.setNavigationIndex(8),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // SECTION 3: Real-Time Stream & Recent Files Split
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;

                final auditStreamCard = CortexCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('RECENT AUDIT STREAM', style: AppTypography.titleMedium),
                          TextButton(
                            onPressed: () => appState.setNavigationIndex(9), // Audit tab
                            child: const Text('View All', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...recentLogs.map((log) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CortexBadge.auditSeverity(log.severity, isSmall: true),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.eventType,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
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
                      }),
                    ],
                  ),
                );

                final recentFilesCard = CortexCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('RECENT PAYLOADS', style: AppTypography.titleMedium),
                          TextButton(
                            onPressed: () => appState.setNavigationIndex(2), // Files tab
                            child: const Text('Files', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...recentFiles.map((file) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border, width: 0.8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.insert_drive_file_outlined, color: AppColors.primaryLight, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      file.name,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${file.formattedSize} • SHA-256',
                                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: auditStreamCard),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: recentFilesCard),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      auditStreamCard,
                      const SizedBox(height: 16),
                      recentFilesCard,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CortexCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final double width;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.width,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CortexCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
