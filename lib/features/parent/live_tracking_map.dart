import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/student.dart';
import '../../data/services/mock_database.dart';

class LiveTrackingMap extends StatefulWidget {
  final String routeId;
  final String studentId;

  const LiveTrackingMap({
    super.key,
    required this.routeId,
    required this.studentId,
  });

  @override
  State<LiveTrackingMap> createState() => _LiveTrackingMapState();
}

class _LiveTrackingMapState extends State<LiveTrackingMap> {
  final MapController _mapController = MapController();
  bool _lockToBus = true;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<MockDatabase>(context);
    
    // Find matching route & student
    final routeIndex = db.routes.indexWhere((r) => r.id == widget.routeId);
    final studentIndex = db.students.indexWhere((s) => s.id == widget.studentId);
    
    if (routeIndex == -1 || studentIndex == -1) {
      return const Scaffold(body: Center(child: Text('Datos de monitoreo no disponibles.')));
    }

    final route = db.routes[routeIndex];
    final student = db.students[studentIndex];
    final busPosition = LatLng(route.currentLatitude, route.currentLongitude);

    // Dynamic centering on the bus
    if (_lockToBus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(busPosition, _mapController.camera.zoom);
      });
    }

    // Prepare markers
    List<Marker> markers = [
      // 1. Bus Marker
      Marker(
        point: busPosition,
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: const [
              BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: const Icon(
            Icons.directions_bus_filled,
            color: Colors.white,
            size: 26,
          ),
        ),
      ),
      // 2. Student Stop Marker
      Marker(
        point: LatLng(student.stopLatitude, student.stopLongitude),
        width: 45,
        height: 45,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4),
            ],
          ),
          child: const Icon(
            Icons.accessibility_new_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
      // 3. School Marker
      Marker(
        point: route.pathPoints.last,
        width: 45,
        height: 45,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.school,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    ];

    Color statusColor;
    String statusText;
    switch (student.status) {
      case StudentStatus.atHome:
        statusColor = AppColors.accent;
        statusText = 'En espera en parada';
        break;
      case StudentStatus.inRoute:
        statusColor = AppColors.warning;
        statusText = 'En ruta - A bordo';
        break;
      case StudentStatus.atSchool:
        statusColor = AppColors.success;
        statusText = 'Llegó al Colegio';
        break;
      case StudentStatus.absent:
        statusColor = AppColors.danger;
        statusText = 'Ausente hoy';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento en Vivo'),
        actions: [
          IconButton(
            icon: Icon(
              _lockToBus ? Icons.gps_fixed : Icons.gps_not_fixed,
              color: _lockToBus ? AppColors.accent : Colors.white70,
            ),
            onPressed: () => setState(() => _lockToBus = !_lockToBus),
          ),
        ],
      ),
      body: Stack(
        children: [
          // The Interactive Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: busPosition,
              initialZoom: 15.0,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  setState(() => _lockToBus = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tesis.transporte_escolar',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: route.pathPoints,
                    strokeWidth: 4.5,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                ],
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),

          // Floating Top Route Info Card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            route.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const Text(
                            'Actualización por satélite en tiempo real',
                            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'SEÑAL OK',
                        style: TextStyle(color: AppColors.success, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Child Status Detail Card
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: statusColor.withOpacity(0.15),
                          child: Icon(
                            student.status == StudentStatus.inRoute
                                ? Icons.directions_bus
                                : Icons.person,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                'Parada: ${student.stopName}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ubicación del Alumno:', style: TextStyle(fontSize: 13)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (student.status == StudentStatus.inRoute)
                      const Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 16, color: AppColors.textMuted),
                          SizedBox(width: 6),
                          Text(
                            'Tiempo estimado de arribo al colegio: ~10 minutos',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
