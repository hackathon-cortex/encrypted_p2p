import 'package:flutter/material.dart';
import '../../core/state/app_state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/personnel_model.dart';
import '../../widgets/common/cortex_app_bar.dart';
import '../../widgets/common/cortex_badge.dart';
import '../../widgets/common/cortex_button.dart';
import '../../widgets/common/cortex_card.dart';
import '../../widgets/common/cortex_modal.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});

  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _departmentFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showPersonnelDossier(PersonnelModel person) {
    final appState = AppStateProvider.of(context);

    CortexModal.showBottomSheet(
      context: context,
      title: person.fullName.toUpperCase(),
      subtitle: '${person.callsign} • ${person.role}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary,
                child: Text(
                  person.fullName.substring(0, 1),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(person.fullName, style: AppTypography.titleLarge),
                    const SizedBox(height: 2),
                    Text(person.department, style: const TextStyle(color: AppColors.accentCyan, fontSize: 12)),
                    const SizedBox(height: 4),
                    CortexBadge.online(isOnline: person.isOnline),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DossierRow(label: 'SECURITY CLEARANCE', value: person.clearanceLevel),
          _DossierRow(label: 'TACTICAL ROLE', value: person.role),
          _DossierRow(label: 'ASSIGNED DEVICE', value: person.deviceName),
          _DossierRow(label: 'IP ADDRESS', value: person.ipAddress ?? '10.0.1.14', isCode: true),
          _DossierRow(label: 'PUBLIC KEY FINGERPRINT', value: person.publicKeyFingerprint, isCode: true),
          _DossierRow(label: 'STATUS NOTE', value: person.statusNote),
          const SizedBox(height: 16),
          // Emergency Contact Toggle
          StatefulBuilder(
            builder: (ctx, setInternalState) {
              return SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Designate as Emergency Contact', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                subtitle: const Text('Will receive SOS distress coordinates broadcast', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                value: person.isEmergencyContact,
                activeThumbColor: AppColors.primaryLight,
                onChanged: (val) {
                  appState.personnelService.toggleEmergencyContact(person.id);
                  setInternalState(() {});
                  setState(() {});
                },
              );
            },
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CortexButton(
                  text: 'MESSAGE',
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () {
                    Navigator.pop(context);
                    appState.setNavigationIndex(1); // Chat tab
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CortexButton.outline(
                  text: 'CALL',
                  icon: Icons.call_outlined,
                  onPressed: () {
                    Navigator.pop(context);
                    appState.startCall(peerId: person.id, peerName: person.fullName, peerCallsign: person.callsign);
                    appState.setNavigationIndex(3); // Call tab
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
    final personnel = appState.personnelService.personnel;

    final filtered = personnel.where((p) {
      if (_departmentFilter != 'All' && _departmentFilter != 'Emergency' && p.department != _departmentFilter) {
        return false;
      }
      if (_departmentFilter == 'Emergency' && !p.isEmergencyContact) return false;
      if (_searchController.text.trim().isNotEmpty) {
        final q = _searchController.text.toLowerCase();
        return p.fullName.toLowerCase().contains(q) ||
            p.callsign.toLowerCase().contains(q) ||
            p.role.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CortexAppBar(
        title: 'PERSONNEL & CONTACTS',
        subtitle: 'TACTICAL ROSTER • CLEARANCE HIERARCHY',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search personnel by callsign, name, role...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 14),

            // Department Filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'All',
                  'Emergency',
                  'Central Command',
                  'Cyber Defense',
                  'Special Operations',
                  'Cryptography Division',
                  'Threat Intelligence',
                ].map((dep) {
                  final isSel = _departmentFilter == dep;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(dep),
                      selected: isSel,
                      onSelected: (_) => setState(() => _departmentFilter = dep),
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
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Personnel Roster Cards
            ...filtered.map((person) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: CortexCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () => _showPersonnelDossier(person),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: person.isOnline ? AppColors.primary : AppColors.surfaceHighlight,
                            child: Text(
                              person.fullName.substring(0, 1),
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (person.isOnline)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 11,
                                height: 11,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.surface, width: 2),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(person.fullName, style: AppTypography.titleMedium),
                                if (person.isEmergencyContact) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.shield_rounded, size: 14, color: AppColors.critical),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${person.callsign} • ${person.role} • ${person.clearanceLevel.split(" - ").first}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              person.statusNote,
                              style: const TextStyle(color: AppColors.accentCyan, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryLight, size: 20),
                        tooltip: 'Message',
                        onPressed: () => appState.setNavigationIndex(1),
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_outlined, color: AppColors.success, size: 20),
                        tooltip: 'Call',
                        onPressed: () {
                          appState.startCall(peerId: person.id, peerName: person.fullName, peerCallsign: person.callsign);
                          appState.setNavigationIndex(3);
                        },
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

class _DossierRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCode;

  const _DossierRow({required this.label, required this.value, this.isCode = false});

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
                color: AppColors.textPrimary,
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
