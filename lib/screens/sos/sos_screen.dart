import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
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

class _SosScreenState extends State<SosScreen> with SingleTickerProviderStateMixin {
  double _holdProgress = 0.0;
  Timer? _holdTimer;
  bool _isHolding = false;

  void _startHolding() {
    setState(() {
      _isHolding = true;
      _holdProgress = 0.0;
    });

    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _holdProgress += 0.05 / 3.0; // 3 seconds to complete (1.0)
        if (_holdProgress >= 1.0) {
          _holdProgress = 1.0;
          timer.cancel();
          _triggerSos();
        }
      });
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
    final appState = AppStateProvider.of(context);
    appState.triggerSos();
    setState(() {
      _isHolding = false;
      _holdProgress = 0.0;
    });
  }

  void _showResolveDialog() {
    final notesController = TextEditingController(text: 'Situation neutralized. Perimeter secure.');

    CortexModal.showBottomSheet(
      context: context,
      title: 'STAND DOWN & RESOLVE SOS',
      subtitle: 'Provide incident debrief notes for permanent audit record',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CortexTextField(
            controller: notesController,
            labelText: 'DEBRIEF RESOLUTION NOTES',
            hintText: 'Describe incident outcome...',
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          CortexButton(
            text: 'CONFIRM RESOLUTION & DEACTIVATE',
            icon: Icons.check_circle_rounded,
            onPressed: () {
              Navigator.pop(context);
              final appState = AppStateProvider.of(context);
              appState.resolveSos(notesController.text.trim());
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isSosActive = appState.sosService.isSosActive;
    final activeIncident = appState.sosService.activeIncident;
    final history = appState.sosService.sosHistory;
    final emergencyContacts = appState.personnelService.emergencyContacts;
    final loc = appState.locationService.myLocation;

    return Scaffold(
      backgroundColor: isSosActive ? const Color(0xFF14080B) : AppColors.background,
      appBar: CortexAppBar(
        title: 'EMERGENCY SOS',
        subtitle: isSosActive ? '🚨 CRITICAL DISTRESS ACTIVE' : 'TACTICAL DISTRESS BEACON',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isSosActive) ...[
              // ACTIVE SOS STATE BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.critical.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.critical, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 54, color: AppColors.critical),
                    const SizedBox(height: 12),
                    const Text(
                      'DISTRESS BEACON BROADCASTING',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.critical, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Triggered by: ${activeIncident?.triggeredByName ?? "Commander Alex"} (${activeIncident?.callsign ?? "Vanguard-1"})',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                    Text(
                      'Coordinates: ${loc.latitude.toStringAsFixed(4)}° N, ${loc.longitude.toStringAsFixed(4)}° W',
                      style: const TextStyle(color: AppColors.accentCyan, fontSize: 12, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Notified Contacts: ${emergencyContacts.map((c) => c.fullName).join(", ")}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                    const SizedBox(height: 20),
                    CortexButton(
                      text: 'RESOLVE & STAND DOWN SOS',
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: _showResolveDialog,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // INACTIVE / READY STATE: PRESS AND HOLD BUTTON
              const SizedBox(height: 10),

              const Text(
                'HOLD BUTTON FOR 3 SECONDS TO TRIGGER',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontFamily: 'monospace',
                ),
              ),

              const SizedBox(height: 28),

              // Interactive Press-and-Hold SOS Button
              GestureDetector(
                onTapDown: (_) => _startHolding(),
                onTapUp: (_) => _cancelHolding(),
                onTapCancel: () => _cancelHolding(),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Progress Ring
                    SizedBox(
                      width: 190,
                      height: 190,
                      child: CircularProgressIndicator(
                        value: _holdProgress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.surfaceElevated,
                        color: AppColors.critical,
                      ),
                    ),

                    // Main SOS Button Circle
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.critical,
                            AppColors.error.withValues(alpha: 0.8),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.critical.withValues(alpha: _isHolding ? 0.6 : 0.35),
                            blurRadius: _isHolding ? 32 : 18,
                            spreadRadius: _isHolding ? 6 : 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.warning_rounded, color: Colors.white, size: 44),
                            const SizedBox(height: 6),
                            Text(
                              _isHolding
                                  ? '${(3 - (_holdProgress * 3)).ceil()}s'
                                  : 'HOLD SOS',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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

              const SizedBox(height: 28),

              const Text(
                'Activation immediately relays GPS coordinates to all designated emergency personnel and triggers mesh-wide alert.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall,
              ),
            ],

            const SizedBox(height: 32),

            // Emergency Contacts Quick List
            CortexCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('EMERGENCY DISPATCH CONTACTS', style: AppTypography.titleMedium),
                      TextButton(
                        onPressed: () => appState.setNavigationIndex(5), // Personnel tab
                        child: const Text('Manage', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...emergencyContacts.map((contact) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, size: 16, color: AppColors.primaryLight),
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
              child: Text('PAST SOS INCIDENT LOGS', style: AppTypography.titleMedium),
            ),
            const SizedBox(height: 12),

            if (history.isEmpty)
              CortexCard(
                padding: const EdgeInsets.all(20),
                child: const Center(child: Text('No previous SOS activations recorded.', style: AppTypography.bodySmall)),
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
                              'INCIDENT: ${item.callsign}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('RESOLVED', style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold)),
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
        ),
      ),
    );
  }
}
