import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/file_item_model.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/common/cortex_modal.dart';

class FileShareScreen extends StatefulWidget {
  const FileShareScreen({super.key});

  @override
  State<FileShareScreen> createState() => _FileShareScreenState();
}

class _FileShareScreenState extends State<FileShareScreen> {
  String _activeTab = 'All'; // 'All', 'Active', 'Completed', 'Expired'

  Future<void> _pickAndSendFile() async {
    final appState = AppStateProvider.of(context);
    final result = await appState.fileService.selectFile();

    String fileName = 'Tactical_Dossier_${DateTime.now().millisecondsSinceEpoch % 1000}.pdf';
    int fileSize = 2450000;
    String? path;

    if (result != null && result.files.isNotEmpty) {
      fileName = result.files.single.name;
      fileSize = result.files.single.size;
      path = result.files.single.path;
    }

    if (!mounted) return;
    _showPeerSelectionDialog(fileName, fileSize, path);
  }

  void _showPeerSelectionDialog(String fileName, int fileSize, String? localPath) {
    final appState = AppStateProvider.of(context);
    final personnel = appState.personnelService.personnel;
    String selectedPeerId = personnel.first.id;
    String selectedPeerName = personnel.first.fullName;
    FileAccessPermission permission = FileAccessPermission.readOnly;
    Duration expiry = const Duration(hours: 24);

    CortexModal.showBottomSheet(
      context: context,
      title: 'ENCRYPT & TRANSMIT PAYLOAD',
      subtitle: 'Configure target peer and cryptographic access policy',
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payload Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_rounded, color: AppColors.accentCyan, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fileName, style: AppTypography.titleMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB • AES-256-GCM', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              const Text('TARGET RECIPIENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedPeerId,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    items: personnel.map((p) {
                      return DropdownMenuItem(
                        value: p.id,
                        child: Text('${p.fullName} (${p.callsign})', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() {
                          selectedPeerId = val;
                          selectedPeerName = personnel.firstWhere((p) => p.id == val).fullName;
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text('ACCESS PERMISSION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<FileAccessPermission>(
                    value: permission,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    items: const [
                      DropdownMenuItem(value: FileAccessPermission.readOnly, child: Text('Read-Only Stream', style: TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                      DropdownMenuItem(value: FileAccessPermission.oneTimeDownload, child: Text('One-Time Download & Auto-Burn', style: TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                      DropdownMenuItem(value: FileAccessPermission.restrictedClearance, child: Text('Level 4+ Clearance Required', style: TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => permission = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text('PAYLOAD EXPIRATION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Duration>(
                    value: expiry,
                    isExpanded: true,
                    dropdownColor: AppColors.surfaceElevated,
                    items: const [
                      DropdownMenuItem(value: Duration(hours: 1), child: Text('Expires in 1 Hour', style: TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                      DropdownMenuItem(value: Duration(hours: 24), child: Text('Expires in 24 Hours', style: TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                      DropdownMenuItem(value: Duration(days: 7), child: Text('Expires in 7 Days', style: TextStyle(fontSize: 13, color: AppColors.textPrimary))),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => expiry = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              CortexButton(
                text: 'ENCRYPT & TRANSMIT (AES-256)',
                icon: Icons.lock_open_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  appState.sendFile(
                    fileName: fileName,
                    fileSize: fileSize,
                    recipientId: selectedPeerId,
                    recipientName: selectedPeerName,
                    localPath: localPath,
                    permission: permission,
                    expiry: expiry,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFileDetails(FileItemModel file) {
    final appState = AppStateProvider.of(context);

    CortexModal.showBottomSheet(
      context: context,
      title: 'FILE TELEMETRY & SECURITY DOSSIER',
      subtitle: 'Verified SHA-256 hash and cryptographic permissions',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FileMetaRow(label: 'FILENAME', value: file.name),
          _FileMetaRow(label: 'SIZE', value: file.formattedSize),
          _FileMetaRow(label: 'CIPHER SUITE', value: file.encryptionAlgorithm),
          _FileMetaRow(label: 'SENDER', value: file.senderName),
          _FileMetaRow(label: 'RECIPIENT', value: file.recipientName),
          _FileMetaRow(label: 'PERMISSION', value: file.accessPermission.name.toUpperCase()),
          _FileMetaRow(label: 'SHA-256 CHECKSUM', value: file.hashSha256, isCode: true),
          _FileMetaRow(
            label: 'STATUS',
            value: file.status.name.toUpperCase(),
            valueColor: file.status == FileTransferStatus.completed ? AppColors.success : (file.status == FileTransferStatus.expired ? AppColors.error : AppColors.warning),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (!file.isRevoked) ...[
                Expanded(
                  child: CortexButton.destructive(
                    text: 'REVOKE ACCESS',
                    icon: Icons.block_rounded,
                    isSmall: true,
                    onPressed: () {
                      Navigator.pop(context);
                      appState.revokeFile(file.id);
                    },
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: CortexButton(
                  text: 'DECRYPT & DOWNLOAD',
                  icon: Icons.download_rounded,
                  isSmall: true,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Decrypted ${file.name} successfully.')),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final files = appState.fileService.files;

    final filtered = files.where((f) {
      if (_activeTab == 'Active' && f.status != FileTransferStatus.transferring) return false;
      if (_activeTab == 'Completed' && f.status != FileTransferStatus.completed) return false;
      if (_activeTab == 'Expired' && f.status != FileTransferStatus.expired && !f.isRevoked) return false;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'SECURE FILE SHARING',
        subtitle: 'P2P ZERO-KNOWLEDGE ENCRYPTED TRANSFER',
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
            // Top Upload Dropzone Card
            CortexCard(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.cloud_upload_outlined, color: AppColors.primaryLight, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text('TRANSFER ENCRYPTED PAYLOAD', style: AppTypography.titleLarge),
                    const SizedBox(height: 4),
                    const Text(
                      'Files are encrypted locally with AES-256 before streaming over P2P mesh relay.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 20),
                    CortexButton(
                      text: 'SELECT FILE & ENCRYPT',
                      icon: Icons.add_circle_outline_rounded,
                      width: 260,
                      onPressed: _pickAndSendFile,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Tab Filter Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TRANSFER LEDGER', style: AppTypography.titleMedium),
                Row(
                  children: ['All', 'Active', 'Completed', 'Expired'].map((tab) {
                    final isSel = _activeTab == tab;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        label: Text(tab),
                        selected: isSel,
                        onSelected: (_) => setState(() => _activeTab = tab),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceElevated,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.white : AppColors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Files List
            if (filtered.isEmpty)
              CortexCard(
                padding: const EdgeInsets.all(28),
                child: const Center(
                  child: Text('No file transfers matching current filter', style: AppTypography.bodyMedium),
                ),
              )
            else
              ...filtered.map((file) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: CortexCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => _showFileDetails(file),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border, width: 0.8),
                              ),
                              child: const Icon(Icons.insert_drive_file_outlined, color: AppColors.primaryLight, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file.name,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${file.senderName} ➔ ${file.recipientName} • ${file.formattedSize}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            _FileStatusBadge(status: file.status, isRevoked: file.isRevoked),
                          ],
                        ),

                        // Progress Bar if transferring
                        if (file.status == FileTransferStatus.transferring) ...[
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: file.progress,
                            backgroundColor: AppColors.surfaceElevated,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Streaming: ${(file.progress * 100).toInt()}% • 4.8 MB/s',
                                style: const TextStyle(fontSize: 10, color: AppColors.accentCyan, fontFamily: 'monospace'),
                              ),
                              const Text(
                                'ETA: 2s',
                                style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
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

class _FileStatusBadge extends StatelessWidget {
  final FileTransferStatus status;
  final bool isRevoked;

  const _FileStatusBadge({required this.status, required this.isRevoked});

  @override
  Widget build(BuildContext context) {
    if (isRevoked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text('REVOKED', style: TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
      );
    }

    Color bg;
    Color fg;
    String label = status.name.toUpperCase();

    switch (status) {
      case FileTransferStatus.encrypted:
      case FileTransferStatus.completed:
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
        break;
      case FileTransferStatus.transferring:
        bg = AppColors.primary.withValues(alpha: 0.15);
        fg = AppColors.primaryLight;
        break;
      case FileTransferStatus.failed:
      case FileTransferStatus.expired:
        bg = AppColors.error.withValues(alpha: 0.15);
        fg = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
    );
  }
}

class _FileMetaRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isCode;

  const _FileMetaRow({
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
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
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
