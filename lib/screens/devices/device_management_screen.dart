import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/device_model.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/common/cortex_modal.dart';

class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({super.key});

  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  void _showDeviceDetails(DeviceModel device) {
    final appState = AppStateProvider.of(context);

    CortexModal.showBottomSheet(
      context: context,
      title: device.name,
      subtitle: '${device.platform.name.toUpperCase()} • ${device.locationTag}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DeviceMetaRow(label: 'HARDWARE FINGERPRINT', value: device.hardwareFingerprint, isCode: true),
          _DeviceMetaRow(label: 'IP ADDRESS', value: device.ipAddress, isCode: true),
          _DeviceMetaRow(label: 'SESSION TOKEN', value: device.sessionToken, isCode: true),
          _DeviceMetaRow(label: 'CIPHER SUITE', value: device.cipherSuite),
          _DeviceMetaRow(label: 'LAST ACTIVE', value: '${device.lastActive.hour.toString().padLeft(2, "0")}:${device.lastActive.minute.toString().padLeft(2, "0")} today'),
          _DeviceMetaRow(
            label: 'TRUST STATE',
            value: device.trustStatus.name.toUpperCase(),
            valueColor: device.trustStatus == DeviceTrustStatus.trusted
                ? AppColors.success
                : (device.trustStatus == DeviceTrustStatus.quarantined ? AppColors.error : AppColors.warning),
          ),
          const SizedBox(height: 20),
          if (!device.isCurrentDevice) ...[
            if (device.trustStatus != DeviceTrustStatus.trusted)
              CortexButton(
                text: 'AUTHORIZE & TRUST NODE',
                icon: Icons.verified_user_outlined,
                isSmall: true,
                onPressed: () {
                  Navigator.pop(context);
                  appState.trustDevice(device.id);
                },
              ),
            const SizedBox(height: 10),
            if (device.trustStatus != DeviceTrustStatus.quarantined)
              CortexButton.destructive(
                text: 'QUARANTINE & REVOKE SESSION',
                icon: Icons.block_rounded,
                isSmall: true,
                onPressed: () {
                  Navigator.pop(context);
                  appState.quarantineDevice(device.id);
                },
              ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryLight, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_rounded, color: AppColors.primaryLight, size: 20),
                  SizedBox(width: 10),
                  Text('This is your current master command terminal.', style: TextStyle(color: AppColors.textPrimary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final devices = appState.deviceService.devices;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'DEVICE MANAGEMENT',
        subtitle: '${devices.length} REGISTERED HARDWARE NODES • ZERO-TRUST',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Devices Roster
            const Text('REGISTERED HARDWARE TERMINALS', style: AppTypography.titleMedium),
            const SizedBox(height: 12),

            ...devices.map((device) {
              final isTrusted = device.trustStatus == DeviceTrustStatus.trusted;
              final isQuarantined = device.trustStatus == DeviceTrustStatus.quarantined;

              IconData platformIcon = Icons.computer_rounded;
              if (device.platform == DevicePlatformType.android || device.platform == DevicePlatformType.ios) {
                platformIcon = Icons.phone_android_rounded;
              } else if (device.platform == DevicePlatformType.linux) {
                platformIcon = Icons.terminal_rounded;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: CortexCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: isQuarantined ? AppColors.error.withValues(alpha: 0.5) : AppColors.border,
                  onTap: () => _showDeviceDetails(device),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isQuarantined
                              ? AppColors.error.withValues(alpha: 0.15)
                              : (device.isCurrentDevice ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceElevated),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isQuarantined ? AppColors.error : AppColors.border,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          platformIcon,
                          color: isQuarantined ? AppColors.error : (device.isCurrentDevice ? AppColors.primaryLight : AppColors.textSecondary),
                          size: 22,
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
                                  device.name,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                if (device.isCurrentDevice) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('THIS DEVICE', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'IP: ${device.ipAddress} • ${device.locationTag}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              device.cipherSuite,
                              style: const TextStyle(color: AppColors.accentCyan, fontSize: 10, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isTrusted
                              ? AppColors.success.withValues(alpha: 0.15)
                              : (isQuarantined ? AppColors.error.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          device.trustStatus.name.toUpperCase(),
                          style: TextStyle(
                            color: isTrusted ? AppColors.success : (isQuarantined ? AppColors.error : AppColors.warning),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
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

class _DeviceMetaRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isCode;

  const _DeviceMetaRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isCode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
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
