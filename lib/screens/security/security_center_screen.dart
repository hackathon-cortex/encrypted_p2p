import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_badge.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/tactical/security_gauge.dart';

class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({super.key});

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> {

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final securityScore = appState.securityService.securityScore;
    final statusText = appState.securityService.securityStatusText;
    final activeThreats = appState.securityService.activeThreats;
    final allThreats = appState.securityService.threats;
    final isScanning = appState.securityService.isScanning;
    final scanProgress = appState.securityService.scanProgress;
    final failedLogins = appState.securityService.failedLoginAttempts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'SECURITY CENTER',
        subtitle: 'PERIMETER DEFENSE • REAL-TIME THREAT RADAR',
        leading: Builder(
          builder: (ctx) {
            final isMobile = MediaQuery.of(context).size.width < 800;
            if (isMobile) {
              return IconButton(
                icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Security Score & Scan trigger
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;

                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security Score Card
                    Expanded(
                      flex: isWide ? 4 : 0,
                      child: CortexCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SecurityGauge(
                              score: securityScore,
                              statusText: statusText,
                              size: 140,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Last full scan: ${appState.securityService.lastScanTime.hour.toString().padLeft(2, "0")}:${appState.securityService.lastScanTime.minute.toString().padLeft(2, "0")}',
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                            ),
                            const SizedBox(height: 12),
                            if (isScanning) ...[
                              LinearProgressIndicator(
                                value: scanProgress,
                                backgroundColor: AppColors.surfaceElevated,
                                color: AppColors.primaryLight,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'SCANNING RELAY NODES... ${(scanProgress * 100).toInt()}%',
                                style: const TextStyle(color: AppColors.accentCyan, fontSize: 10, fontFamily: 'monospace'),
                              ),
                            ] else ...[
                              CortexButton(
                                text: 'RUN FULL PERIMETER SCAN',
                                icon: Icons.radar_rounded,
                                isSmall: true,
                                onPressed: () {
                                  appState.runSecurityScan();
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),

                    // Diagnostic Breakdown
                    Expanded(
                      flex: isWide ? 6 : 0,
                      child: Column(
                        children: [
                          _SecuritySpecCard(
                            icon: Icons.vpn_key_rounded,
                            title: 'ASYMMETRIC CIPHER SUITE',
                            value: 'AES-256-GCM + Curve25519 (ECDH)',
                            status: 'HARDENED',
                            statusColor: AppColors.success,
                          ),
                          const SizedBox(height: 10),
                          _SecuritySpecCard(
                            icon: Icons.hub_rounded,
                            title: 'P2P MESH NODE RELAY',
                            value: '${appState.webSocketService.connectedPeersCount} Relays Connected • Zero-Trust Policy',
                            status: 'SYNCHRONIZED',
                            statusColor: AppColors.success,
                          ),
                          const SizedBox(height: 10),
                          _SecuritySpecCard(
                            icon: Icons.lock_person_rounded,
                            title: 'FAILED AUTH CHALLENGES',
                            value: '$failedLogins Invalid attempts recorded',
                            status: failedLogins > 0 ? 'ALERT' : 'SECURE',
                            statusColor: failedLogins > 0 ? AppColors.warning : AppColors.success,
                          ),
                          const SizedBox(height: 10),
                          _SecuritySpecCard(
                            icon: Icons.fingerprint_rounded,
                            title: 'IDENTITY & BIOMETRICS',
                            value: 'Hardware Biometric + TOTP 2FA Required',
                            status: 'ACTIVE',
                            statusColor: AppColors.success,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),

            // SECTION 2: Active Threats Monitoring & Mitigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('ACTIVE THREAT MONITOR', style: AppTypography.titleMedium),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: activeThreats.isNotEmpty ? AppColors.warning.withValues(alpha: 0.2) : AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${activeThreats.length} THREATS',
                        style: TextStyle(
                          color: activeThreats.isNotEmpty ? AppColors.warning : AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    // Ask AI Sentinel to analyze threats
                    appState.setNavigationIndex(8);
                  },
                  icon: const Icon(Icons.smart_toy_outlined, size: 16),
                  label: const Text('AI Analysis', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (activeThreats.isEmpty)
              CortexCard(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 38),
                      const SizedBox(height: 10),
                      const Text('Perimeter Secure', style: AppTypography.titleMedium),
                      const SizedBox(height: 4),
                      Text('No active threats or quarantined relays detected.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              )
            else
              ...activeThreats.map((threat) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: CortexCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.warning.withValues(alpha: 0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CortexBadge.severity(threat.severity),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                threat.title,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(threat.description, style: AppTypography.bodyMedium),
                        if (threat.sourceIp != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Source IP: ${threat.sourceIp} | Device: ${threat.deviceName ?? "Unknown"}',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'monospace'),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CortexButton(
                              text: 'QUARANTINE & RESOLVE',
                              icon: Icons.shield_rounded,
                              isSmall: true,
                              onPressed: () {
                                appState.resolveThreat(threat.id, 'Quarantined source IP and rotated session tokens');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 28),

            // SECTION 3: Security Timeline
            const Text('SECURITY TIMELINE & INCIDENT HISTORY', style: AppTypography.titleMedium),
            const SizedBox(height: 12),

            CortexCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: allThreats.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: item.isResolved ? AppColors.success : AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    ),
                                  ),
                                  Text(
                                    item.isResolved ? 'RESOLVED' : 'ACTIVE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: item.isResolved ? AppColors.success : AppColors.warning,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(item.description, style: AppTypography.bodySmall),
                              if (item.resolutionAction != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Action: ${item.resolutionAction}',
                                  style: const TextStyle(color: AppColors.accentCyan, fontSize: 11),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecuritySpecCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String status;
  final Color statusColor;

  const _SecuritySpecCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return CortexCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Icon(icon, color: AppColors.primaryLight, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
