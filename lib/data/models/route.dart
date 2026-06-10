import 'package:latlong2/latlong.dart';

class SchoolRoute {
  final String id;
  final String name;
  final String driverId;
  final String driverName;
  final List<String> studentIds;
  final List<LatLng> pathPoints;
  final bool isActive;
  final double currentLatitude;
  final double currentLongitude;

  SchoolRoute({
    required this.id,
    required this.name,
    required this.driverId,
    required this.driverName,
    required this.studentIds,
    required this.pathPoints,
    required this.isActive,
    required this.currentLatitude,
    required this.currentLongitude,
  });

  SchoolRoute copyWith({
    String? id,
    String? name,
    String? driverId,
    String? driverName,
    List<String>? studentIds,
    List<LatLng>? pathPoints,
    bool? isActive,
    double? currentLatitude,
    double? currentLongitude,
  }) {
    return SchoolRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      studentIds: studentIds ?? this.studentIds,
      pathPoints: pathPoints ?? this.pathPoints,
      isActive: isActive ?? this.isActive,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }

  factory SchoolRoute.fromJson(Map<String, dynamic> json) {
    var pointsJson = json['pathPoints'] as List<dynamic>? ?? [];
    List<LatLng> points = pointsJson.map((p) {
      return LatLng(
        (p['lat'] as num).toDouble(),
        (p['lng'] as num).toDouble(),
      );
    }).toList();

    return SchoolRoute(
      id: json['id'] as String,
      name: json['name'] as String,
      driverId: json['driverId'] as String,
      driverName: json['driverName'] as String,
      studentIds: List<String>.from(json['studentIds'] as List<dynamic>? ?? []),
      pathPoints: points,
      isActive: json['isActive'] as bool? ?? false,
      currentLatitude: (json['currentLatitude'] as num).toDouble(),
      currentLongitude: (json['currentLongitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'driverId': driverId,
      'driverName': driverName,
      'studentIds': studentIds,
      'pathPoints': pathPoints.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'isActive': isActive,
      'currentLatitude': currentLatitude,
      'currentLongitude': currentLongitude,
    };
  }
}
