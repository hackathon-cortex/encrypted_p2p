import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/common/cortex_modal.dart';
import '../../widgets/common/cortex_text_field.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showPasswordDialog() {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();

    CortexModal.showBottomSheet(
      context: context,
      title: 'UPDATE PASSPHRASE',
      subtitle: 'Re-encrypt your local master vault',
      child: Column(
        children: [
          CortexTextField(controller: oldPass, labelText: 'CURRENT PASSPHRASE', obscureText: true),
          const SizedBox(height: 14),
          CortexTextField(controller: newPass, labelText: 'NEW SECURITY PASSPHRASE', obscureText: true),
          const SizedBox(height: 20),
          CortexButton(
            text: 'UPDATE & RE-ENCRYPT VAULT',
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Master passphrase updated successfully.')),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPublicKeyDialog() {
    final appState = AppStateProvider.of(context);
    final user = appState.authService.currentUser;

    CortexModal.showBottomSheet(
      context: context,
      title: 'EXPORT PUBLIC KEY & CIPHER CERT',
      subtitle: 'Public cryptographic identity for P2P key exchange',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PUBLIC KEY FINGERPRINT (SHA-256):', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Text(
              user?.publicKeyFingerprint ?? 'SHA256:4A9C:7E2F:1D8B:3C0A:9F5E:6B8D:2E1A',
              style: const TextStyle(color: AppColors.accentCyan, fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 16),
          const Text('CURVE25519 PUBLIC POINT (ECDH):', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: const Text(
              '3d:4b:9e:1f:8a:7c:2b:5d:0e:9f:1a:8c:6e:3f:7b:2a\n0f:8e:1d:4c:9b:2a:5f:7e:3d:1c:8a:9f:6b:4e:2d:0a',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 20),
          CortexButton(
            text: 'COPY TO CLIPBOARD',
            icon: Icons.copy_rounded,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Public key fingerprint copied.')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final user = appState.authService.currentUser;
    final settings = appState.settingsService;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'SETTINGS & CONFIGURATION',
        subtitle: 'PREFERENCES • CRYPTOGRAPHY • ZERO-TRUST',
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
            // SECTION 1: ACCOUNT & PROFILE
            const _SectionHeader(title: 'OPERATOR ACCOUNT & DOSSIER'),
            CortexCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user?.fullName?.substring(0, 1) ?? 'A',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.fullName ?? 'Alex Morgan', style: AppTypography.titleLarge),
                            const SizedBox(height: 2),
                            Text(
                              '${user?.callsign ?? "Vanguard-1"} • ${user?.role ?? "Commander"}',
                              style: const TextStyle(color: AppColors.accentCyan, fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.clearanceLevel ?? 'Level 5 - Command Core',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _SettingsActionTile(
                    icon: Icons.key_rounded,
                    title: 'Export Public Key / Fingerprint',
                    subtitle: 'SHA-256 and Curve25519 exchange keys',
                    onTap: _showPublicKeyDialog,
                  ),
                  _SettingsActionTile(
                    icon: Icons.password_rounded,
                    title: 'Change Master Passphrase',
                    subtitle: 'Re-encrypt local database vault',
                    onTap: _showPasswordDialog,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SECTION 2: PRIVACY
            const _SectionHeader(title: 'PRIVACY & TELEMETRY'),
            CortexCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Stealth Mode', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    subtitle: const Text('Hide online presence from unauthorized relays', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    value: settings.stealthMode,
                    activeThumbColor: AppColors.primaryLight,
                    onChanged: (val) {
                      setState(() => settings.updatePrivacy(stealthMode: val));
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Broadcast Online Presence', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    subtitle: const Text('Send periodic heartbeats to trusted squadron peers', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    value: settings.broadcastOnlinePresence,
                    activeThumbColor: AppColors.primaryLight,
                    onChanged: (val) {
                      setState(() => settings.updatePrivacy(broadcastOnlinePresence: val));
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Send Message Read Receipts', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    subtitle: const Text('Display double checkmarks when message is decrypted', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    value: settings.sendReadReceipts,
                    activeThumbColor: AppColors.primaryLight,
                    onChanged: (val) {
                      setState(() => settings.updatePrivacy(sendReadReceipts: val));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SECTION 3: SECURITY & CRYPTOGRAPHY
            const _SectionHeader(title: 'SECURITY & HARDENING'),
            CortexCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Multi-Factor Authentication (MFA)', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    subtitle: const Text('Require 6-digit TOTP challenge on login', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    value: settings.mfaEnabled,
                    activeThumbColor: AppColors.primaryLight,
                    onChanged: (val) {
                      setState(() => settings.updateSecurity(mfaEnabled: val));
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Biometric Hardware Unlock', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    subtitle: const Text('Fingerprint or Face unlock where supported', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    value: settings.biometricsEnabled,
                    activeThumbColor: AppColors.primaryLight,
                    onChanged: (val) {
                      setState(() => settings.updateSecurity(biometricsEnabled: val));
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Auto-Lock Session Timeout', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    subtitle: Text('Current: ${settings.autoLockTimeout}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    trailing: DropdownButton<String>(
                      value: settings.autoLockTimeout,
                      dropdownColor: AppColors.surfaceElevated,
                      underline: const SizedBox.shrink(),
                      items: const [
                        DropdownMenuItem(value: '1 minute', child: Text('1 min')),
                        DropdownMenuItem(value: '5 minutes', child: Text('5 mins')),
                        DropdownMenuItem(value: '15 minutes', child: Text('15 mins')),
                        DropdownMenuItem(value: 'Never', child: Text('Never')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => settings.updateSecurity(autoLockTimeout: val));
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  _SettingsActionTile(
                    icon: Icons.devices_rounded,
                    title: 'Manage Trusted Hardware Nodes',
                    subtitle: 'Inspect authorized devices & sessions',
                    onTap: () => appState.setNavigationIndex(11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SECTION 4: NOTIFICATIONS
            const _SectionHeader(title: 'ALERT & NOTIFICATION PREFERENCES'),
            CortexCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Urgent SOS Siren Override', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    subtitle: const Text('Play critical audible siren even in Do-Not-Disturb mode', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    value: settings.emergencySosOverride,
                    activeThumbColor: AppColors.critical,
                    onChanged: (val) {
                      setState(() => settings.updateNotifications(emergencySosOverride: val));
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Security Alerts & Threat Warnings', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    subtitle: const Text('Instant notification when unknown relay connects', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    value: settings.securityAlerts,
                    activeThumbColor: AppColors.primaryLight,
                    onChanged: (val) {
                      setState(() => settings.updateNotifications(securityAlerts: val));
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Message & Call Chimes', style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    subtitle: const Text('Audio notifications for new incoming comms', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    value: settings.messageNotifications,
                    activeThumbColor: AppColors.primaryLight,
                    onChanged: (val) {
                      setState(() => settings.updateNotifications(messageNotifications: val));
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // SECTION 5: ABOUT & PROTOCOL SPECIFICATIONS
            const _SectionHeader(title: 'ABOUT CORTEX & LICENSES'),
            CortexCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CORTEX Secure Platform',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      Text(
                        AppConstants.appVersion,
                        style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Decentralized peer-to-peer encrypted communications and command architecture. Designed for zero-knowledge privacy, tamper-evident audit trails, and tactical situational awareness.',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mesh Protocol: CORTEX-P2P-v2.4 | SRTP-AES-GCM-256 | Curve25519',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Logout Action Button
            CortexButton.destructive(
              text: 'TERMINATE SESSION & LOGOUT',
              icon: Icons.logout_rounded,
              onPressed: () {
                appState.logout();
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Icon(icon, color: AppColors.primaryLight, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
      onTap: onTap,
    );
  }
}
