class TacticalLocationModel {
  final String userId;
  final String userName;
  final String callsign;
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracyMeters;
  final DateTime timestamp;
  final bool isSharing;
  final bool isOnline;
  final int batteryPercent;
  final String sector;
  final bool isEmergency;

  TacticalLocationModel({
    required this.userId,
    required this.userName,
    required this.callsign,
    required this.latitude,
    required this.longitude,
    this.altitude = 124.5,
    this.accuracyMeters = 3.2,
    required this.timestamp,
    this.isSharing = true,
    this.isOnline = true,
    this.batteryPercent = 88,
    this.sector = 'Sector Alpha-4',
    this.isEmergency = false,
  });

  TacticalLocationModel copyWith({
    String? userId,
    String? userName,
    String? callsign,
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracyMeters,
    DateTime? timestamp,
    bool? isSharing,
    bool? isOnline,
    int? batteryPercent,
    String? sector,
    bool? isEmergency,
  }) {
    return TacticalLocationModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      callsign: callsign ?? this.callsign,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracyMeters: accuracyMeters ?? this.accuracyMeters,
      timestamp: timestamp ?? this.timestamp,
      isSharing: isSharing ?? this.isSharing,
      isOnline: isOnline ?? this.isOnline,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      sector: sector ?? this.sector,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }
}
