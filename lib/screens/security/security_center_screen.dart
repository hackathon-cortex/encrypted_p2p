import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/device_model.dart';
import '../../models/security_threat_model.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_badge.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';

class SecurityCenterScreen extends StatefulWidget {
  const SecurityCenterScreen({super.key});

  @override
  State<SecurityCenterScreen> createState() => _SecurityCenterScreenState();
}

class _SecurityCenterScreenState extends State<SecurityCenterScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _threatKeyThr01 = GlobalKey();
  final GlobalKey _threatKeyThr02 = GlobalKey();

  late AnimationController _highlightController;
  late Animation<double> _highlightAnimation;
  String? _highlightedThreatId;
  Timer? _highlightTimer;

  @override
  void initState() {
    super.initState();
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _highlightAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _highlightController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeepLinkFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkDeepLinkFocus();
    });
  }

  void _checkDeepLinkFocus() {
    final appState = AppStateProvider.of(context);
    final focusedId = appState.focusedThreatId;
    if (focusedId != null) {
      setState(() {
        _highlightedThreatId = focusedId;
      });
      _highlightController.repeat(reverse: true);

      // Auto-scroll to target threat item
      final targetKey = focusedId == 'thr_01' ? _threatKeyThr01 : _threatKeyThr02;
      Future.delayed(const Duration(milliseconds: 250), () {
        if (targetKey.currentContext != null && mounted) {
          Scrollable.ensureVisible(
            targetKey.currentContext!,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOutCubic,
            alignment: 0.25,
          );
        }
      });

      // Stop highlight after 4 seconds
      _highlightTimer?.cancel();
      _highlightTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) {
          _highlightController.stop();
          setState(() {
            _highlightedThreatId = null;
          });
          appState.clearFocusedThreat();
        }
      });
    }
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _highlightController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showThreatDetailsModal(BuildContext context, SecurityThreatModel threat) {
    final isQuarantined = threat.status == 'QUARANTINED';
    final isBlocked = threat.status == 'BLOCKED';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: (isQuarantined ? AppColors.warning : AppColors.primary).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isQuarantined ? Icons.security_rounded : Icons.shield_outlined,
                      color: isQuarantined ? AppColors.warning : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          threat.title,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'EVENT ID: ${threat.id.toUpperCase()} • CONTAINED IN SECURE ENCLAVE',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  _buildContainmentTag(threat.status ?? 'CONTAINED'),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 16),

              // Threat Telemetry Details
              _buildDetailItem(Icons.info_outline_rounded, 'INCIDENT DESCRIPTION', threat.description),
              const SizedBox(height: 10),
              if (threat.sourceIp != null)
                _buildDetailItem(Icons.router_rounded, 'SOURCE IP ADDRESS', threat.sourceIp!, isCode: true),
              const SizedBox(height: 10),
              _buildDetailItem(Icons.access_time_rounded, 'DETECTION TIME', threat.detectionTime ?? 'Today • 14:32'),
              const SizedBox(height: 10),
              _buildDetailItem(
                Icons.check_circle_outline_rounded,
                'CONTAINMENT STATUS',
                isQuarantined
                    ? 'Quarantined by Perimeter Firewall. Connection dropped and client signature isolated.'
                    : (isBlocked
                        ? 'Blocked by Gateway Security Policy. Challenge attempts rejected.'
                        : 'Contained and monitored.'),
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  Expanded(
                    child: CortexButton.outline(
                      text: 'CLOSE',
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CortexButton(
                      text: 'RESOLVE & DISMISS',
                      icon: Icons.done_all_rounded,
                      onPressed: () {
                        AppStateProvider.of(context).resolveThreat(
                          threat.id,
                          'Verified and dismissed by Security Officer',
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Threat ${threat.id} resolved and logged.'),
                            backgroundColor: AppColors.primaryDark,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTrustedNodesModal(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final devices = appState.deviceService.devices;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text('TRUSTED NODES REGISTRY', style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${devices.where((d) => d.isTrusted).length} VERIFIED',
                      style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Cryptographically authorized hardware peer relays in mesh network.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  itemCount: devices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final d = devices[idx];
                    final isTrusted = d.isTrusted;
                    return CortexCard(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: isTrusted ? AppColors.surfaceElevated : AppColors.surface,
                      borderColor: isTrusted ? AppColors.border : AppColors.warning.withValues(alpha: 0.4),
                      child: Row(
                        children: [
                          Icon(
                            isTrusted ? Icons.verified_user_rounded : Icons.shield_outlined,
                            color: isTrusted ? AppColors.success : AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        d.name,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (d.isCurrentDevice)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('THIS NODE', style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'IP: ${d.ipAddress} • FP: ${d.hardwareFingerprint}',
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isTrusted ? 'TRUSTED' : 'QUARANTINED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isTrusted ? AppColors.success : AppColors.warning,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CortexButton.outline(
                  text: 'DISMISS',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {bool isCode = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    fontFamily: isCode ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainmentTag(String status) {
    final isQuarantined = status == 'QUARANTINED';
    final isBlocked = status == 'BLOCKED';
    final color = isQuarantined
        ? AppColors.warning
        : (isBlocked ? AppColors.error : AppColors.success);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isQuarantined ? Icons.shield_outlined : (isBlocked ? Icons.block_rounded : Icons.check_circle_outline_rounded),
            size: 11,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final securityScore = appState.securityService.securityScore;
    final activeThreats = appState.securityService.activeThreats;
    final isScanning = appState.securityService.isScanning;
    final scanProgress = appState.securityService.scanProgress;
    final lastRotationFormatted = appState.securityService.formattedLastKeyRotation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CortexAppBar(
        title: 'SECURITY CENTER',
        subtitle: 'PERIMETER DEFENSE • REAL-TIME THREAT RADAR',
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─────────────────────────────────────────────────────────────
            // 1. OVERALL SECURITY STATUS CARD & SCORE (Section 1 & 8)
            // ─────────────────────────────────────────────────────────────
            CortexCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Shield Icon + Score + Status Banner
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Large tactical Shield Icon Container
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.2),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.shield_rounded,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '$securityScore',
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const Text(
                                  ' / 100',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 0.8),
                              ),
                              child: const Text(
                                'PROTECTED — ACTION REQUIRED',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    'Your network is protected, but security events require attention.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),

                  // Score Explanation & Justification (Section 8)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'SYSTEM PROTECTED',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '2 SECURITY EVENTS REQUIRE REVIEW',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Visual Checklist Explaining 84/100
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 0.8),
                    ),
                    child: const Column(
                      children: [
                        _ScoreFactorRow(icon: Icons.check_circle_rounded, text: 'Protected infrastructure & perimeter defense', isPositive: true),
                        SizedBox(height: 4),
                        _ScoreFactorRow(icon: Icons.check_circle_rounded, text: '4/4 Encrypted peer connections verified', isPositive: true),
                        SizedBox(height: 4),
                        _ScoreFactorRow(icon: Icons.check_circle_rounded, text: 'Firewall rules active with zero leaks', isPositive: true),
                        SizedBox(height: 4),
                        _ScoreFactorRow(icon: Icons.warning_amber_rounded, text: '2 contained security events pending review (-16 pts)', isPositive: false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Supporting Status Indicators (Section 1)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatusChipPill(
                        icon: Icons.lock_outline_rounded,
                        label: '4/4 Encrypted Peers',
                        color: AppColors.primary,
                      ),
                      _StatusChipPill(
                        icon: Icons.shield_outlined,
                        label: 'Firewall Active',
                        color: AppColors.success,
                      ),
                      _StatusChipPill(
                        icon: Icons.radar_rounded,
                        label: '0 Unknown Active Peers',
                        color: AppColors.primaryDark,
                      ),
                      _StatusChipPill(
                        icon: Icons.vpn_key_rounded,
                        label: 'AES-256-GCM',
                        color: AppColors.primary,
                      ),
                    ],
                  ),

                  if (isScanning) ...[
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: scanProgress,
                        backgroundColor: AppColors.surfaceHighlight,
                        color: AppColors.primary,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'SCANNING MESH RELAYS... ${(scanProgress * 100).toInt()}%',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ─────────────────────────────────────────────────────────────
            // 2. ACTIVE THREATS CARD (Section 2 & 3)
            // ─────────────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'ACTIVE THREATS',
                    style: AppTypography.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: activeThreats.isNotEmpty
                        ? AppColors.warning.withValues(alpha: 0.15)
                        : AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: activeThreats.isNotEmpty ? AppColors.warning.withValues(alpha: 0.3) : AppColors.success.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${activeThreats.length} Threats Detected',
                    style: TextStyle(
                      color: activeThreats.isNotEmpty ? AppColors.warning : AppColors.success,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (activeThreats.isEmpty)
              CortexCard(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 36),
                      const SizedBox(height: 8),
                      const Text('All Threats Mitigated', style: AppTypography.titleMedium),
                      const SizedBox(height: 4),
                      const Text(
                        'Zero pending security events or quarantined relays.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...activeThreats.map((threat) {
                final isThr01 = threat.id == 'thr_01';
                final isHighlighted = _highlightedThreatId == threat.id;

                return AnimatedBuilder(
                  key: isThr01 ? _threatKeyThr01 : _threatKeyThr02,
                  animation: _highlightAnimation,
                  builder: (context, child) {
                    final borderHighlightColor = isHighlighted
                        ? Color.lerp(
                            AppColors.warning.withValues(alpha: 0.4),
                            AppColors.warning,
                            _highlightAnimation.value,
                          )!
                        : AppColors.border;

                    final bgHighlightColor = isHighlighted
                        ? Color.lerp(
                            AppColors.surface,
                            AppColors.warning.withValues(alpha: 0.08),
                            _highlightAnimation.value,
                          )!
                        : AppColors.surface;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: CortexCard(
                        padding: const EdgeInsets.all(16),
                        borderColor: borderHighlightColor,
                        backgroundColor: bgHighlightColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Threat Header: Severity + Title + Status Tag
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CortexBadge.severity(threat.severity, isSmall: true),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        threat.title,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Detection: ${threat.detectionTime ?? "Today • 14:32"}',
                                        style: const TextStyle(
                                          color: AppColors.textMuted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _buildContainmentTag(threat.status ?? 'QUARANTINED'),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Description
                            Text(
                              threat.description,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),

                            if (threat.sourceIp != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceElevated,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.router_rounded, size: 12, color: AppColors.textMuted),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Source: ${threat.sourceIp}',
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 12),

                            // Action footer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.shield_rounded, size: 13, color: AppColors.success),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Threat Contained',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.success.withValues(alpha: 0.9),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CortexButton.outline(
                                  text: 'VIEW DETAILS',
                                  icon: Icons.visibility_outlined,
                                  isSmall: true,
                                  onPressed: () => _showThreatDetailsModal(context, threat),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),

            const SizedBox(height: 14),

            // ─────────────────────────────────────────────────────────────
            // 4. NETWORK SECURITY SECTION (Section 4)
            // ─────────────────────────────────────────────────────────────
            const Text('NETWORK SECURITY', style: AppTypography.titleMedium),
            const SizedBox(height: 10),

            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _NetworkMetricCard(
                      width: cardWidth,
                      title: 'MESH NETWORK',
                      value: 'ACTIVE',
                      valueColor: AppColors.success,
                      icon: Icons.wifi_tethering_rounded,
                    ),
                    _NetworkMetricCard(
                      width: cardWidth,
                      title: 'CONNECTED PEERS',
                      value: '${appState.webSocketService.connectedPeersCount}',
                      valueColor: AppColors.primary,
                      icon: Icons.hub_rounded,
                    ),
                    _NetworkMetricCard(
                      width: cardWidth,
                      title: 'ENCRYPTED CONNECTIONS',
                      value: '${appState.webSocketService.connectedPeersCount} / 4',
                      valueColor: AppColors.success,
                      icon: Icons.lock_rounded,
                    ),
                    _NetworkMetricCard(
                      width: cardWidth,
                      title: 'FIREWALL',
                      value: 'ACTIVE',
                      valueColor: AppColors.success,
                      icon: Icons.shield_rounded,
                    ),
                    _NetworkMetricCard(
                      width: constraints.maxWidth,
                      title: 'UNKNOWN PEERS',
                      value: '0',
                      valueColor: AppColors.primaryDark,
                      icon: Icons.person_off_rounded,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 22),

            // ─────────────────────────────────────────────────────────────
            // 5. ENCRYPTION & CRYPTOGRAPHY (Section 5)
            // ─────────────────────────────────────────────────────────────
            const Text('ENCRYPTION & CRYPTOGRAPHY', style: AppTypography.titleMedium),
            const SizedBox(height: 10),

            CortexCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const _EncryptionSpecRow(
                    icon: Icons.vpn_key_rounded,
                    title: 'AES-256-GCM',
                    status: 'Active',
                    subtitle: 'Symmetric military-grade packet encryption',
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  const _EncryptionSpecRow(
                    icon: Icons.verified_rounded,
                    title: 'SHA-256',
                    status: 'Integrity verification',
                    subtitle: 'Cryptographic payload signature & tamper detection',
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  const _EncryptionSpecRow(
                    icon: Icons.sync_lock_rounded,
                    title: 'Secure Key Exchange',
                    status: 'Active',
                    subtitle: 'ECDH Curve25519 asymmetric handshake',
                  ),
                  const Divider(height: 16, color: AppColors.border),
                  _EncryptionSpecRow(
                    icon: Icons.update_rounded,
                    title: 'Last Key Rotation',
                    status: lastRotationFormatted,
                    subtitle: 'Automatic scheduled rotation policy active',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ─────────────────────────────────────────────────────────────
            // 6. SECURITY ACTIVITY / AUDIT LOG (Section 6)
            // ─────────────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'SECURITY ACTIVITY',
                    style: AppTypography.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => appState.setNavigationIndex(9),
                  child: const Text('Full Ledger', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            CortexCard(
              padding: const EdgeInsets.all(14),
              child: const Column(
                children: [
                  _ActivityTimelineRow(time: '14:32', description: 'Unknown handshake detected', isWarning: true, isLast: false),
                  _ActivityTimelineRow(time: '14:32', description: 'Client quarantined by perimeter firewall', isPositive: true, isLast: false),
                  _ActivityTimelineRow(time: '12:18', description: 'Secure peer authenticated via ECDH', isPositive: true, isLast: false),
                  _ActivityTimelineRow(time: '09:42', description: 'Encryption keys rotated across mesh nodes', isPositive: true, isLast: false),
                  _ActivityTimelineRow(time: '08:15', description: 'Security scan completed: Integrity verified', isPositive: true, isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ─────────────────────────────────────────────────────────────
            // 7. SECURITY ACTIONS (Section 7)
            // ─────────────────────────────────────────────────────────────
            const Text('SECURITY ACTIONS', style: AppTypography.titleMedium),
            const SizedBox(height: 10),

            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CortexButton(
                        text: 'RUN SECURITY SCAN',
                        icon: Icons.radar_rounded,
                        isLoading: isScanning,
                        isSmall: true,
                        onPressed: () async {
                          await appState.runSecurityScan();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Scan Complete: All 4 Relay Nodes Verified & Secure.'),
                                backgroundColor: AppColors.primaryDark,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CortexButton.outline(
                        text: 'ROTATE KEYS',
                        icon: Icons.sync_lock_rounded,
                        isSmall: true,
                        onPressed: () async {
                          await appState.rotateEncryptionKeys();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cryptographic keys rotated. ECDH session cache refreshed.'),
                                backgroundColor: AppColors.primaryDark,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CortexButton.outline(
                        text: 'TRUSTED NODES',
                        icon: Icons.verified_user_outlined,
                        isSmall: true,
                        onPressed: () => _showTrustedNodesModal(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CortexButton.outline(
                        text: 'VIEW AUDIT LOG',
                        icon: Icons.receipt_long_outlined,
                        isSmall: true,
                        onPressed: () => appState.setNavigationIndex(9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ScoreFactorRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isPositive;

  const _ScoreFactorRow({
    required this.icon,
    required this.text,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPositive ? AppColors.success : AppColors.warning;
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isPositive ? FontWeight.w500 : FontWeight.w600,
              color: isPositive ? AppColors.textPrimary : AppColors.warning,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatusChipPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChipPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.22), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkMetricCard extends StatelessWidget {
  final double width;
  final String title;
  final String value;
  final Color valueColor;
  final IconData icon;

  const _NetworkMetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: CortexCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _EncryptionSpecRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final String subtitle;

  const _EncryptionSpecRow({
    required this.icon,
    required this.title,
    required this.status,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityTimelineRow extends StatelessWidget {
  final String time;
  final String description;
  final bool isPositive;
  final bool isWarning;
  final bool isLast;

  const _ActivityTimelineRow({
    required this.time,
    required this.description,
    this.isPositive = false,
    this.isWarning = false,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isWarning
        ? AppColors.warning
        : (isPositive ? AppColors.success : AppColors.primary);

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
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
