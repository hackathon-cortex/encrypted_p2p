import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/sos_incident_model.dart';
import '../../services/location_service.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_badge.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/common/cortex_modal.dart';
import '../../widgets/common/cortex_text_field.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> with TickerProviderStateMixin {
  double _holdProgress = 0.0;
  Timer? _holdTimer;
  bool _isHolding = false;

  // Active elapsed timer
  Timer? _elapsedTimer;
  Duration _elapsedDuration = Duration.zero;

  // Pulsing Beacon Animation Controller
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _elapsedTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startHolding() {
    setState(() {
      _isHolding = true;
      _holdProgress = 0.0;
    });

    _holdTimer?.cancel();
    const intervalMs = 40;
    const totalMs = 2600.0; // 2.6 seconds hold requirement
    const step = intervalMs / totalMs;

    _holdTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_holdProgress + step >= 1.0) {
        timer.cancel();
        setState(() {
          _holdProgress = 1.0;
        });
        _triggerSos();
      } else {
        setState(() {
          _holdProgress += step;
        });
      }
    });
  }

  void _cancelHolding() {
    if (_holdProgress < 1.0) {
      _holdTimer?.cancel();
      setState(() {
        _isHolding = false;
        _holdProgress = 0.0;
      });
    }
  }

  void _triggerSos() {
    _holdTimer?.cancel();
    final appState = AppStateProvider.of(context);
    appState.triggerSos();

    setState(() {
      _isHolding = false;
      _holdProgress = 0.0;
      _elapsedDuration = Duration.zero;
    });

    _startElapsedTimer();
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsedDuration += const Duration(seconds: 1);
      });
    });
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showCancelConfirmationDialog() {
    final notesController = TextEditingController(text: 'Situation secured. Tactical perimeter stabilized.');

    CortexModal.showBottomSheet(
      context: context,
      title: 'CANCEL SOS / STAND DOWN',
      subtitle: 'Confirmation required to stand down distress beacon',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.4), width: 1),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Cancelling will stand down distress broadcasting to all emergency contacts and mesh peers.',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CortexTextField(
            controller: notesController,
            labelText: 'DEBRIEF & RESOLUTION NOTES',
            hintText: 'Enter incident resolution summary...',
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CortexButton.outline(
                  text: 'KEEP ACTIVE',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CortexButton.destructive(
                  text: 'CONFIRM CANCEL',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                    final appState = AppStateProvider.of(context);
                    appState.resolveSos(notesController.text.trim());
                    _elapsedTimer?.cancel();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRawPayloadViewer(SosAlertPayload payload) {
    CortexModal.showBottomSheet(
      context: context,
      title: 'RAW SOS ALERT PAYLOAD',
      subtitle: 'Cryptographically signed & encrypted telemetry packet',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CIPHERTEXT PACKET (AES-256-GCM)', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: SelectableText(
              payload.encryptedData,
              style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 16),
          const Text('DECRYPTED TELEMETRY PAYLOAD (JSON)', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: SelectableText(
              payload.toJsonString(),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(label: 'PAYLOAD HASH (SHA-256)', value: payload.payloadHash, isCode: true),
          _InfoRow(label: 'CIPHER SUITE', value: payload.cipherSuite),
          _InfoRow(label: 'DEVICE FINGERPRINT', value: payload.deviceHardwareFingerprint, isCode: true),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isSosActive = appState.sosService.isSosActive;
    final activeIncident = appState.sosService.activeIncident;
    final history = appState.sosService.sosHistory;
    final emergencyContacts = appState.personnelService.emergencyContacts;
    final loc = appState.locationService.myLocation;
    final hasLocPermission = appState.locationService.hasLocationPermission;
    final locPermissionState = appState.locationService.permissionState;
    final isMeshConnected = appState.webSocketService.isConnected;
    final connectedPeers = appState.webSocketService.connectedPeersCount;

    if (isSosActive && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isSosActive && _pulseController.isAnimating) {
      _pulseController.stop();
    }

    return Scaffold(
      backgroundColor: isSosActive ? const Color(0xFF14080B) : AppColors.background,
      appBar: CortexAppBar(
        title: 'EMERGENCY SOS',
        subtitle: isSosActive ? '🚨 DISTRESS BEACON ACTIVE • BROADCASTING' : 'TACTICAL DISTRESS BEACON • P2P MESH',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==========================================
            // STATE 1: ACTIVE SOS DISTRESS STATE
            // ==========================================
            if (isSosActive) ...[
              // Pulsating Distress Header Banner
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.critical.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.critical, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.critical.withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 52, color: AppColors.critical),
                      const SizedBox(height: 10),
                      const Text(
                        'SOS ACTIVATED',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.critical,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ACTIVE DURATION: ${_formatDuration(_elapsedDuration)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isMeshConnected ? AppColors.success.withValues(alpha: 0.2) : AppColors.warning.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isMeshConnected ? AppColors.success : AppColors.warning,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isMeshConnected
                              ? 'P2P MESH BROADCASTING • $connectedPeers RELAYS ACTIVE'
                              : 'MESH OFFLINE • PACKET QUEUED IN LOCAL BUFFER',
                          style: TextStyle(
                            color: isMeshConnected ? AppColors.success : AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Emergency Alert Payload Details Card
              CortexCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('EMERGENCY ALERT PAYLOAD', style: AppTypography.titleMedium),
                        if (activeIncident?.payload != null)
                          TextButton.icon(
                            icon: const Icon(Icons.code_rounded, size: 16),
                            label: const Text('View Payload', style: TextStyle(fontSize: 12)),
                            onPressed: () => _showRawPayloadViewer(activeIncident!.payload!),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _InfoRow(
                      label: 'DISTRESS ID',
                      value: activeIncident?.id ?? 'N/A',
                      isCode: true,
                    ),
                    _InfoRow(
                      label: 'INITIATED BY',
                      value: '${activeIncident?.triggeredByName ?? "Commander Alex"} (${activeIncident?.callsign ?? "Vanguard-1"})',
                    ),
                    _InfoRow(
                      label: 'ACTIVATION TIME',
                      value: activeIncident != null
                          ? '${activeIncident.timestamp.hour.toString().padLeft(2, '0')}:${activeIncident.timestamp.minute.toString().padLeft(2, '0')}:${activeIncident.timestamp.second.toString().padLeft(2, '0')} UTC'
                          : 'N/A',
                    ),

                    // Location Status Row
                    if (hasLocPermission) ...[
                      _InfoRow(
                        label: 'GPS COORDINATES',
                        value: '${loc.latitude.toStringAsFixed(6)}° N, ${loc.longitude.toStringAsFixed(6)}° W',
                        isCode: true,
                        valueColor: AppColors.accentCyan,
                      ),
                      _InfoRow(
                        label: 'ACCURACY / ALTITUDE',
                        value: '±${loc.accuracyMeters}m (GPS Locked) • ${loc.altitude}m MSL',
                      ),
                      _InfoRow(
                        label: 'TACTICAL SECTOR',
                        value: loc.sector,
                      ),
                    ] else ...[
                      _InfoRow(
                        label: 'GEOLOCATION STATUS',
                        value: 'Location Permission Denied (Coordinates Omitted)',
                        valueColor: AppColors.error,
                      ),
                    ],

                    _InfoRow(
                      label: 'DELIVERY STATUS',
                      value: activeIncident?.payload?.deliveryStatus == SosDeliveryStatus.delivered
                          ? 'Delivered to $connectedPeers connected P2P mesh nodes'
                          : (isMeshConnected ? 'Transmitting across mesh relays...' : 'Offline spooler queued'),
                      valueColor: isMeshConnected ? AppColors.success : AppColors.warning,
                    ),
                    _InfoRow(
                      label: 'CIPHER SUITE',
                      value: activeIncident?.payload?.cipherSuite ?? 'AES-256-GCM / SHA-256',
                      isCode: true,
                    ),
                    _InfoRow(
                      label: 'CRYPTOGRAPHIC DIGEST',
                      value: activeIncident?.payload?.payloadHash ?? 'SHA256:AUTHENTICATED',
                      isCode: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Emergency Contacts Notified
              CortexCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('DISPATCHED EMERGENCY CONTACTS', style: AppTypography.titleMedium),
                        Text(
                          '${emergencyContacts.length} Assigned',
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (emergencyContacts.isEmpty)
                      const Text(
                        'No emergency contacts configured. Manage contacts in Personnel module.',
                        style: AppTypography.bodySmall,
                      )
                    else
                      ...emergencyContacts.map((contact) {
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
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  contact.fullName.substring(0, 1),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${contact.fullName} (${contact.callsign})',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                    ),
                                    Text(
                                      '${contact.role} • ${contact.department}',
                                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (contact.isOnline && isMeshConnected)
                                      ? AppColors.success.withValues(alpha: 0.15)
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  contact.isOnline && isMeshConnected ? 'RELAY ALERTED' : 'OFFLINE QUEUED',
                                  style: TextStyle(
                                    color: contact.isOnline && isMeshConnected ? AppColors.success : AppColors.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Safety Action: Cancel / Stand Down SOS with confirmation dialog
              CortexButton.destructive(
                text: 'CANCEL SOS / STAND DOWN BEACON',
                icon: Icons.cancel_outlined,
                onPressed: _showCancelConfirmationDialog,
              ),

              const SizedBox(height: 12),
              const Text(
                'Requires incident debrief confirmation to stand down.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ]

            // ==========================================
            // STATE 2: READY / STANDBY SOS STATE
            // ==========================================
            else ...[
              const SizedBox(height: 8),

              // Status & Permission Alert if permission denied
              if (!hasLocPermission) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.5), width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_off_rounded, color: AppColors.warning, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LOCATION PERMISSION REQUIRED',
                              style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              locPermissionState == LocationPermissionState.permanentlyDenied
                                  ? 'Location is permanently denied in settings.'
                                  : 'Enable location for distress GPS beacon capture.',
                              style: const TextStyle(color: AppColors.textPrimary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      CortexButton(
                        text: 'ENABLE',
                        isSmall: true,
                        onPressed: () {
                          appState.locationService.requestLocationPermission();
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // Prominent Instruction
              const Text(
                'EMERGENCY SOS DISTRESS SYSTEM',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Press and hold to activate emergency mode.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 32),

              // Prominent Circular Press-and-Hold Button with Progress Ring
              GestureDetector(
                onTapDown: (_) => _startHolding(),
                onTapUp: (_) => _cancelHolding(),
                onTapCancel: () => _cancelHolding(),
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer Glow Pulsing Ring
                      if (_isHolding)
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.critical.withValues(alpha: 0.15 + (_holdProgress * 0.3)),
                          ),
                        ),

                      // Progress Ring
                      SizedBox(
                        width: 196,
                        height: 196,
                        child: CircularProgressIndicator(
                          value: _holdProgress,
                          strokeWidth: 8,
                          backgroundColor: AppColors.surfaceElevated,
                          color: AppColors.critical,
                        ),
                      ),

                      // Center Interactive Emergency Button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: _isHolding ? 154 : 164,
                        height: _isHolding ? 154 : 164,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFDC2626),
                              Color(0xFF991B1B),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.critical.withValues(alpha: _isHolding ? 0.75 : 0.4),
                              blurRadius: _isHolding ? 36 : 20,
                              spreadRadius: _isHolding ? 8 : 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.warning_rounded, color: Colors.white, size: 48),
                              const SizedBox(height: 6),
                              Text(
                                _isHolding
                                    ? (_holdProgress > 0.85 ? 'ACTIVATING...' : '${(3 - (_holdProgress * 3)).ceil()}s')
                                    : 'HOLD SOS',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Tactical Telemetry Badges Ribbon
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _StatusChip(
                    icon: hasLocPermission ? Icons.gps_fixed_rounded : Icons.gps_off_rounded,
                    label: hasLocPermission ? 'GPS LOCKED' : 'GPS DENIED',
                    color: hasLocPermission ? AppColors.accentCyan : AppColors.warning,
                  ),
                  _StatusChip(
                    icon: Icons.hub_rounded,
                    label: isMeshConnected ? '$connectedPeers PEER RELAYS' : 'OFFLINE',
                    color: isMeshConnected ? AppColors.success : AppColors.error,
                  ),
                  _StatusChip(
                    icon: Icons.security_rounded,
                    label: 'AES-256 ARMED',
                    color: AppColors.primaryLight,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                'Holding the button for 3 seconds transmits an authenticated distress packet with your live coordinates and cryptographic signature across the P2P mesh.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),

              const SizedBox(height: 28),

              // Emergency Dispatch Contacts Preview
              CortexCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('DESIGNATED EMERGENCY CONTACTS', style: AppTypography.titleMedium),
                        TextButton(
                          onPressed: () => appState.setNavigationIndex(5), // Personnel tab
                          child: const Text('Manage', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (emergencyContacts.isEmpty)
                      const Text(
                        'No emergency contacts configured. Tap Manage to designate personnel.',
                        style: AppTypography.bodySmall,
                      )
                    else
                      ...emergencyContacts.map((contact) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.shield_rounded, size: 16, color: AppColors.critical),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${contact.fullName} (${contact.callsign}) • ${contact.role}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                ),
                              ),
                              CortexBadge.online(isOnline: contact.isOnline),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Historical SOS Incidents Ledger
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('PAST SOS INCIDENT AUDIT LOGS', style: AppTypography.titleMedium),
              ),
              const SizedBox(height: 12),

              if (history.isEmpty)
                CortexCard(
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: Text('No previous SOS activations recorded.', style: AppTypography.bodySmall),
                  ),
                )
              else
                ...history.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: CortexCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'INCIDENT: ${item.callsign} (${item.triggeredByName})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text('STAND DOWN / RESOLVED', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coordinates: ${item.latitude.toStringAsFixed(4)}° N, ${item.longitude.toStringAsFixed(4)}° W',
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontFamily: 'monospace'),
                          ),
                          if (item.resolutionNotes != null) ...[
                            const SizedBox(height: 4),
                            Text('Debrief: ${item.resolutionNotes}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCode;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isCode = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 12,
                fontFamily: isCode ? 'monospace' : null,
                fontWeight: isCode ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
