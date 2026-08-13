import '../models/personnel_model.dart';

class PersonnelService {
  final List<PersonnelModel> _personnel = [];

  List<PersonnelModel> get personnel => List.unmodifiable(_personnel);
  List<PersonnelModel> get onlinePersonnel => _personnel.where((p) => p.isOnline).toList();
  List<PersonnelModel> get emergencyContacts => _personnel.where((p) => p.isEmergencyContact).toList();

  PersonnelService() {
    _seedPersonnel();
  }

  void _seedPersonnel() {
    final now = DateTime.now();

    _personnel.addAll([
      PersonnelModel(
        id: 'p_01',
        callsign: 'Aegis-1',
        fullName: 'Sarah Khan',
        role: 'Security Officer',
        department: 'Cyber Defense',
        clearanceLevel: 'Level 4 - Top Secret',
        isOnline: true,
        publicKeyFingerprint: 'SHA256:7F9A:2B3C:8D4E:1F5A:6C7B:8E9F:0A1B',
        isEmergencyContact: true,
        statusNote: 'Monitoring perimeter firewall',
        deviceName: 'CORTEX Secure Workstation',
        lastSeen: now,
        ipAddress: '10.0.1.14',
      ),
      PersonnelModel(
        id: 'p_02',
        callsign: 'Ghost-4',
        fullName: 'Daniel Lee',
        role: 'Field Operator',
        department: 'Special Operations',
        clearanceLevel: 'Level 3 - Secret',
        isOnline: true,
        publicKeyFingerprint: 'SHA256:3D8E:1A7F:9C4B:2E6A:5F0D:4B8C:7A2E',
        isEmergencyContact: true,
        statusNote: 'Mobile Patrol Alpha',
        deviceName: 'Tactical Android Terminal',
        lastSeen: now.subtract(const Duration(minutes: 2)),
        ipAddress: '10.0.3.88',
      ),
      PersonnelModel(
        id: 'p_03',
        callsign: 'Cipher-7',
        fullName: 'Elena Rostova',
        role: 'Cyber Specialist',
        department: 'Cryptography Division',
        clearanceLevel: 'Level 5 - Command Core',
        isOnline: true,
        publicKeyFingerprint: 'SHA256:5B2A:8F1C:4E7D:9A3B:0C6E:2F8A:1D4C',
        isEmergencyContact: true,
        statusNote: 'Running key exchange audit',
        deviceName: 'Linux Security Rig',
        lastSeen: now.subtract(const Duration(minutes: 10)),
        ipAddress: '10.0.1.29',
      ),
      PersonnelModel(
        id: 'p_04',
        callsign: 'Titan-2',
        fullName: 'Marcus Vance',
        role: 'Operator',
        department: 'Tactical Recon',
        clearanceLevel: 'Level 3 - Secret',
        isOnline: false,
        publicKeyFingerprint: 'SHA256:1C9F:8E7A:3D5B:6A2E:4F0C:9B8D:7E1A',
        isEmergencyContact: false,
        statusNote: 'Offline - In transit',
        deviceName: 'Field Terminal 04',
        lastSeen: now.subtract(const Duration(hours: 4)),
        ipAddress: '10.0.2.10',
      ),
      PersonnelModel(
        id: 'p_05',
        callsign: 'Oracle-3',
        fullName: 'Rachel Thorne',
        role: 'Intelligence Analyst',
        department: 'Threat Intelligence',
        clearanceLevel: 'Level 4 - Top Secret',
        isOnline: true,
        publicKeyFingerprint: 'SHA256:8E4B:6C2A:1F9D:7A3E:5D0B:4F8C:2E1A',
        isEmergencyContact: false,
        statusNote: 'Analyzing telemetry anomalies',
        deviceName: 'Secure Terminal Lab 2',
        lastSeen: now.subtract(const Duration(minutes: 1)),
        ipAddress: '10.0.1.62',
      ),
      PersonnelModel(
        id: 'p_06',
        callsign: 'Sentry-9',
        fullName: 'Chen Wei',
        role: 'Personnel',
        department: 'Logistics & Comms',
        clearanceLevel: 'Level 2 - Confidential',
        isOnline: false,
        publicKeyFingerprint: 'SHA256:2A7E:9C1B:4F8D:3E5A:6D0C:1B8F:7A4E',
        isEmergencyContact: false,
        statusNote: 'Off-duty',
        deviceName: 'Mobile Node Charlie',
        lastSeen: now.subtract(const Duration(hours: 12)),
        ipAddress: '10.0.4.5',
      ),
    ]);
  }

  void toggleEmergencyContact(String id) {
    final idx = _personnel.indexWhere((p) => p.id == id);
    if (idx != -1) {
      _personnel[idx] = _personnel[idx].copyWith(
        isEmergencyContact: !_personnel[idx].isEmergencyContact,
      );
    }
  }

  PersonnelModel? getById(String id) {
    try {
      return _personnel.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
