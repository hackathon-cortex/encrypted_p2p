import '../models/location_model.dart';

class LocationService {
  bool _isLocationSharingEnabled = true;
  String _sharingAudience = 'Squadron Alpha'; // 'Squadron Alpha', 'Command Only', 'Custom'
  TacticalLocationModel _myLocation = TacticalLocationModel(
    userId: 'usr_cortex_01',
    userName: 'Alex Morgan',
    callsign: 'Vanguard-1',
    latitude: 37.7749,
    longitude: -122.4194,
    altitude: 142.0,
    accuracyMeters: 2.8,
    timestamp: DateTime.now(),
    isSharing: true,
    isOnline: true,
    batteryPercent: 94,
    sector: 'Command HQ • Sector 1',
  );

  final List<TacticalLocationModel> _peerLocations = [];

  bool get isLocationSharingEnabled => _isLocationSharingEnabled;
  String get sharingAudience => _sharingAudience;
  TacticalLocationModel get myLocation => _myLocation;
  List<TacticalLocationModel> get peerLocations => List.unmodifiable(_peerLocations);

  LocationService() {
    _seedPeerLocations();
  }

  void _seedPeerLocations() {
    final now = DateTime.now();

    _peerLocations.addAll([
      TacticalLocationModel(
        userId: 'p_01',
        userName: 'Sarah Khan',
        callsign: 'Aegis-1',
        latitude: 37.7762,
        longitude: -122.4178,
        altitude: 138.5,
        accuracyMeters: 3.1,
        timestamp: now.subtract(const Duration(seconds: 15)),
        sector: 'Sector Alpha-1',
        batteryPercent: 82,
      ),
      TacticalLocationModel(
        userId: 'p_02',
        userName: 'Daniel Lee',
        callsign: 'Ghost-4',
        latitude: 37.7725,
        longitude: -122.4230,
        altitude: 129.0,
        accuracyMeters: 4.5,
        timestamp: now.subtract(const Duration(seconds: 30)),
        sector: 'Sector Alpha-3',
        batteryPercent: 67,
      ),
      TacticalLocationModel(
        userId: 'p_03',
        userName: 'Elena Rostova',
        callsign: 'Cipher-7',
        latitude: 37.7780,
        longitude: -122.4210,
        altitude: 150.2,
        accuracyMeters: 2.2,
        timestamp: now.subtract(const Duration(seconds: 45)),
        sector: 'Crypt Lab • Sector 2',
        batteryPercent: 91,
      ),
      TacticalLocationModel(
        userId: 'p_05',
        userName: 'Rachel Thorne',
        callsign: 'Oracle-3',
        latitude: 37.7738,
        longitude: -122.4155,
        altitude: 135.0,
        accuracyMeters: 3.8,
        timestamp: now.subtract(const Duration(minutes: 1)),
        sector: 'Intel Outpost 4',
        batteryPercent: 78,
      ),
    ]);
  }

  void toggleLocationSharing(bool enabled) {
    _isLocationSharingEnabled = enabled;
    _myLocation = _myLocation.copyWith(
      isSharing: enabled,
      timestamp: DateTime.now(),
    );
  }

  void setSharingAudience(String audience) {
    _sharingAudience = audience;
  }

  void updateCoordinates({required double lat, required double lng}) {
    _myLocation = _myLocation.copyWith(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
    );
  }

  void emergencyStopSharing() {
    _isLocationSharingEnabled = false;
    _myLocation = _myLocation.copyWith(
      isSharing: false,
      timestamp: DateTime.now(),
    );
  }
}
