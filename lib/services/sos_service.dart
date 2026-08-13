import '../models/sos_incident_model.dart';

class SosService {
  SosStatus _status = SosStatus.idle;
  SosIncidentModel? _activeIncident;
  final List<SosIncidentModel> _sosHistory = [];
  double _countdownProgress = 0.0; // 0.0 to 1.0

  SosStatus get status => _status;
  SosIncidentModel? get activeIncident => _activeIncident;
  List<SosIncidentModel> get sosHistory => List.unmodifiable(_sosHistory);
  double get countdownProgress => _countdownProgress;
  bool get isSosActive => _status == SosStatus.active;

  SosService() {
    _seedHistory();
  }

  void _seedHistory() {
    final now = DateTime.now();
    _sosHistory.add(
      SosIncidentModel(
        id: 'sos_hist_01',
        triggeredById: 'p_02',
        triggeredByName: 'Daniel Lee',
        callsign: 'Ghost-4',
        timestamp: now.subtract(const Duration(days: 3)),
        latitude: 37.7758,
        longitude: -122.4182,
        status: SosStatus.resolved,
        emergencyContactsNotified: ['Alex Morgan', 'Sarah Khan'],
        resolvedAt: now.subtract(const Duration(days: 3, hours: -1)),
        resolvedBy: 'Alex Morgan',
        resolutionNotes: 'Drill test completed. Tactical comms verified.',
      ),
    );
  }

  void setCountdownProgress(double progress) {
    _countdownProgress = progress;
    if (progress > 0 && progress < 1.0) {
      _status = SosStatus.countdown;
    } else if (progress <= 0) {
      if (_status == SosStatus.countdown) {
        _status = SosStatus.cancelled;
      }
    }
  }

  SosIncidentModel triggerSos({
    required String triggeredById,
    required String triggeredByName,
    required String callsign,
    double latitude = 37.7749,
    double longitude = -122.4194,
    List<String> emergencyContacts = const ['Sarah Khan', 'Daniel Lee', 'Elena Rostova'],
  }) {
    _status = SosStatus.active;
    _countdownProgress = 1.0;

    _activeIncident = SosIncidentModel(
      id: 'sos_${DateTime.now().millisecondsSinceEpoch}',
      triggeredById: triggeredById,
      triggeredByName: triggeredByName,
      callsign: callsign,
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      status: SosStatus.active,
      emergencyContactsNotified: emergencyContacts,
    );

    return _activeIncident!;
  }

  void resolveSos({
    required String resolvedBy,
    required String resolutionNotes,
  }) {
    if (_activeIncident != null) {
      final resolved = _activeIncident!.copyWith(
        status: SosStatus.resolved,
        resolvedAt: DateTime.now(),
        resolvedBy: resolvedBy,
        resolutionNotes: resolutionNotes,
      );
      _sosHistory.insert(0, resolved);
      _activeIncident = null;
    }
    _status = SosStatus.idle;
    _countdownProgress = 0.0;
  }

  void cancelSos() {
    _status = SosStatus.idle;
    _countdownProgress = 0.0;
    _activeIncident = null;
  }
}
