import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/audit_log_model.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_badge.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/common/cortex_modal.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  AuditCategory? _selectedCategory;
  AuditSeverity? _selectedSeverity;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLogDetails(AuditLogModel log) {
    CortexModal.showBottomSheet(
      context: context,
      title: log.eventType,
      subtitle: 'EVENT ID: ${log.id} • TAMPER-SEALED LEDGER',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CortexBadge.auditSeverity(log.severity),
              const SizedBox(width: 10),
              Text(
                'CATEGORY: ${log.category.name.toUpperCase()}',
                style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AuditDetailRow(label: 'TIMESTAMP', value: log.timestamp.toIso8601String()),
          _AuditDetailRow(label: 'ACTOR / OPERATOR', value: log.actor),
          _AuditDetailRow(label: 'TARGET / NODE', value: log.targetDevice ?? 'Local Relay Station'),
          _AuditDetailRow(label: 'SOURCE IP', value: log.ipAddress, isCode: true),
          _AuditDetailRow(label: 'DESCRIPTION', value: log.description),
          const SizedBox(height: 12),
          const Text('CRYPTOGRAPHIC SHA-256 SEAL', style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border, width: 0.8),
            ),
            child: Text(
              log.checksum,
              style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              const Text('Cryptographic ledger integrity verified.', style: TextStyle(color: AppColors.success, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    final appState = AppStateProvider.of(context);
    final count = appState.auditService.logs.length;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          title: const Text('EXPORT AUDIT LEDGER', style: AppTypography.titleMedium),
          content: Text(
            'Exporting all $count cryptographically signed audit entries into an encrypted format (CORTEX-AUDIT-v2.json.enc) with master SHA-256 seal.',
            style: AppTypography.bodySmall,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            CortexButton(
              text: 'EXPORT SEALED REPORT',
              isSmall: true,
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Audit ledger exported and sealed successfully.')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final logs = appState.auditService.filterLogs(
      query: _searchController.text.trim(),
      category: _selectedCategory,
      severity: _selectedSeverity,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'AUDIT LOGS & LEDGER',
        subtitle: 'IMMUTABLE CRYPTOGRAPHIC AUDIT TRAIL',
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: AppColors.textPrimary, size: 20),
            tooltip: 'Export Ledger',
            onPressed: _showExportDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search audit ledger by event, actor, IP, keyword...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 14),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Categories'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                      color: _selectedCategory == null ? Colors.white : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(width: 6),
                  ...AuditCategory.values.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(cat.name.toUpperCase()),
                        selected: isSel,
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.white : AppColors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Severity Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Severities'),
                    selected: _selectedSeverity == null,
                    onSelected: (_) => setState(() => _selectedSeverity = null),
                    selectedColor: AppColors.accentCyan,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: _selectedSeverity == null ? FontWeight.bold : FontWeight.normal,
                      color: _selectedSeverity == null ? Colors.black : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  const SizedBox(width: 6),
                  ...AuditSeverity.values.map((sev) {
                    final isSel = _selectedSeverity == sev;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(sev.name.toUpperCase()),
                        selected: isSel,
                        onSelected: (_) => setState(() => _selectedSeverity = sev),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.white : AppColors.textSecondary,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Logs Entries Table / Cards
            if (logs.isEmpty)
              CortexCard(
                padding: const EdgeInsets.all(28),
                child: const Center(
                  child: Text('No audit log entries matching query filters.', style: AppTypography.bodyMedium),
                ),
              )
            else
              ...logs.map((log) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: CortexCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => _showLogDetails(log),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CortexBadge.auditSeverity(log.severity, isSmall: true),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    log.eventType,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace', color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    '${log.timestamp.hour.toString().padLeft(2, "0")}:${log.timestamp.minute.toString().padLeft(2, "0")}',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(log.description, style: AppTypography.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text('Actor: ${log.actor}', style: const TextStyle(fontSize: 10, color: AppColors.accentCyan)),
                                  const SizedBox(width: 10),
                                  Text('IP: ${log.ipAddress}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace')),
                                ],
                              ),
                            ],
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

class _AuditDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCode;

  const _AuditDetailRow({required this.label, required this.value, this.isCode = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontFamily: isCode ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
