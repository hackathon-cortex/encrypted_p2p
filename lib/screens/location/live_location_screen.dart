import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/tactical/radar_map_view.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final isSharing = appState.locationService.isLocationSharingEnabled;
    final myLoc = appState.locationService.myLocation;
    final peerLocs = appState.locationService.peerLocations;
    final audience = appState.locationService.sharingAudience;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'TACTICAL LIVE LOCATION',
        subtitle: 'ENCRYPTED GEOLOCATION MESH • ZERO-CLOUD',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prominent Location Sharing Privacy Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSharing ? AppColors.success.withValues(alpha: 0.12) : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSharing ? AppColors.success.withValues(alpha: 0.4) : AppColors.border,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSharing ? Icons.location_on_rounded : Icons.location_off_rounded,
                    color: isSharing ? AppColors.success : AppColors.textMuted,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSharing ? 'LOCATION SHARING ACTIVE' : 'LOCATION BEACON MUTED',
                          style: TextStyle(
                            color: isSharing ? AppColors.success : AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSharing
                              ? 'Broadcasting encrypted coordinates to: $audience'
                              : 'No coordinates are being shared with mesh peers.',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isSharing,
                    activeThumbColor: AppColors.success,
                    onChanged: (val) {
                      appState.toggleLocationSharing(val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Interactive Radar Map Container
            SizedBox(
              height: 380,
              width: double.infinity,
              child: RadarMapView(
                userLocation: myLoc,
                peerLocations: peerLocs,
                isSharing: isSharing,
              ),
            ),

            const SizedBox(height: 20),

            // Telemetry & Sharing Policy Card
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;

                final coordsCard = CortexCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TACTICAL GPS TELEMETRY', style: AppTypography.titleMedium),
                      const SizedBox(height: 12),
                      _CoordRow(label: 'LATITUDE', value: '${myLoc.latitude.toStringAsFixed(6)}° N'),
                      _CoordRow(label: 'LONGITUDE', value: '${myLoc.longitude.toStringAsFixed(6)}° W'),
                      _CoordRow(label: 'ACCURACY', value: '±${myLoc.accuracyMeters} meters (GPS + GLONASS)'),
                      _CoordRow(label: 'ALTITUDE', value: '${myLoc.altitude}m MSL'),
                      _CoordRow(label: 'SECTOR ZONE', value: myLoc.sector),
                    ],
                  ),
                );

                final audienceCard = CortexCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('BROADCAST AUDIENCE', style: AppTypography.titleMedium),
                      const SizedBox(height: 10),
                      ...['Squadron Alpha', 'Command Only', 'Emergency Units'].map((aud) {
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            audience == aud ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: audience == aud ? AppColors.primaryLight : AppColors.textMuted,
                            size: 20,
                          ),
                          title: Text(aud, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                          onTap: isSharing
                              ? () {
                                  appState.locationService.setSharingAudience(aud);
                                  setState(() {});
                                }
                              : null,
                        );
                      }),
                      const SizedBox(height: 10),
                      if (isSharing)
                        CortexButton.destructive(
                          text: 'EMERGENCY STOP SHARING',
                          icon: Icons.location_off_rounded,
                          isSmall: true,
                          onPressed: () {
                            appState.emergencyStopLocationSharing();
                          },
                        ),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 6, child: coordsCard),
                      const SizedBox(width: 16),
                      Expanded(flex: 4, child: audienceCard),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      coordsCard,
                      const SizedBox(height: 16),
                      audienceCard,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Active Tracked Personnel in Sector
            const Text('TRACKED PERSONNEL IN SECTOR', style: AppTypography.titleMedium),
            const SizedBox(height: 12),

            ...peerLocs.map((peer) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: CortexCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: Text(peer.userName.substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${peer.userName} (${peer.callsign})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                            const SizedBox(height: 2),
                            Text('${peer.sector} • Battery: ${peer.batteryPercent}%', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          ],
                        ),
                      ),
                      Text(
                        '${peer.latitude.toStringAsFixed(4)}° N, ${peer.longitude.toStringAsFixed(4)}° W',
                        style: const TextStyle(color: AppColors.accentCyan, fontSize: 10, fontFamily: 'monospace'),
                      ),
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

class _CoordRow extends StatelessWidget {
  final String label;
  final String value;

  const _CoordRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
