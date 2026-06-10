import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/student.dart';
import '../../data/services/mock_database.dart';

class ActiveRouteMap extends StatefulWidget {
  final String routeId;

  const ActiveRouteMap({super.key, required this.routeId});

  @override
  State<ActiveRouteMap> createState() => _ActiveRouteMapState();
}

class _ActiveRouteMapState extends State<ActiveRouteMap> {
  final MapController _mapController = MapController();
  bool _followBus = true;
  bool _shareGps = true;
  bool _showOptimizedRoute = false;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<MockDatabase>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Find the route
    final routeIndex = db.routes.indexWhere((r) => r.id == widget.routeId);
    if (routeIndex == -1) {
      return const Scaffold(body: Center(child: Text('Ruta no encontrada')));
    }
    
    final route = db.routes[routeIndex];
    final routeStudents = db.students.where((s) => route.studentIds.contains(s.id)).toList();
    final busPosition = LatLng(route.currentLatitude, route.currentLongitude);

    // If map is active and followBus is true, move camera to bus
    if (_followBus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(busPosition, _mapController.camera.zoom);
      });
    }

    // Path calculation: standard vs OR-Tools optimized order
    final standardPoints = route.pathPoints;
    final optimizedPoints = List<LatLng>.from(standardPoints);
    if (optimizedPoints.length > 2) {
      // Simulate OR-Tools optimization by sorting intermediate coordinates
      final temp = optimizedPoints[1];
      optimizedPoints[1] = optimizedPoints[2];
      optimizedPoints[2] = temp;
    }

    // Prepare markers
    List<Marker> markers = [];

    // 1. Bus Marker (Only show if sharing GPS is active)
    if (_shareGps) {
      markers.add(
        Marker(
          point: busPosition,
          width: 50,
          height: 50,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: const Icon(
              Icons.directions_bus_filled,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      );
    }

    // 2. School Marker (last point in path)
    if (route.pathPoints.isNotEmpty) {
      markers.add(
        Marker(
          point: route.pathPoints.last,
          width: 45,
          height: 45,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      );
    }

    // 3. Student Stop Markers
    for (var student in routeStudents) {
      Color statusColor;
      IconData statusIcon;

      switch (student.status) {
        case StudentStatus.atHome:
          statusColor = AppColors.accent;
          statusIcon = Icons.home_outlined;
          break;
        case StudentStatus.inRoute:
          statusColor = AppColors.warning;
          statusIcon = Icons.directions_bus_outlined;
          break;
        case StudentStatus.atSchool:
          statusColor = AppColors.success;
          statusIcon = Icons.check_circle_outline;
          break;
        case StudentStatus.absent:
          statusColor = AppColors.danger;
          statusIcon = Icons.cancel_outlined;
          break;
      }

      markers.add(
        Marker(
          point: LatLng(student.stopLatitude, student.stopLongitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showStudentDialog(context, student, db),
            child: Container(
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4),
                ],
              ),
              child: Icon(
                statusIcon,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(route.name),
        actions: [
          IconButton(
            icon: Icon(
              _followBus ? Icons.gps_fixed : Icons.gps_not_fixed,
              color: _followBus ? AppColors.accent : Colors.white70,
            ),
            tooltip: 'Centrar en Autobús',
            onPressed: () => setState(() => _followBus = !_followBus),
          ),
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
            tooltip: 'Botón SOS de Alerta',
            onPressed: () => _showSOSDialog(context, db, route.id),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Flutter Map Integration
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: busPosition,
              initialZoom: 15.0,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture) {
                  setState(() => _followBus = false);
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
                    points: _showOptimizedRoute ? optimizedPoints : standardPoints,
                    strokeWidth: 5.5,
                    color: _showOptimizedRoute ? AppColors.accent : AppColors.primary.withOpacity(0.7),
                  ),
                ],
              ),
              MarkerLayer(
                markers: markers,
              ),
            ],
          ),

          // Floating GPS Control and OR-Tools Path Optimization Panel
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 6,
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.share_location_rounded,
                                color: _shareGps ? AppColors.success : Colors.grey,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Compartir Ubicación GPS',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _shareGps
                                          ? 'Transmitiendo coordenadas en vivo...'
                                          : 'Transmisión GPS pausada.',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: _shareGps ? AppColors.success : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _shareGps,
                          activeColor: AppColors.success,
                          onChanged: (val) {
                            setState(() {
                              _shareGps = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.explore_outlined,
                                color: _showOptimizedRoute ? AppColors.accent : Colors.grey,
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Consultar Mejor Ruta (OR-Tools)',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      _showOptimizedRoute
                                          ? 'Visualizando recorrido más corto'
                                          : 'Visualizando trazado estándar',
                                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showOptimizedRoute = !_showOptimizedRoute;
                            });
                          },
                          icon: Icon(
                            _showOptimizedRoute ? Icons.visibility : Icons.visibility_off,
                            size: 16,
                            color: _showOptimizedRoute ? AppColors.accent : Colors.grey,
                          ),
                          label: Text(
                            _showOptimizedRoute ? 'Optimizado' : 'Estándar',
                            style: TextStyle(
                              fontSize: 11,
                              color: _showOptimizedRoute ? AppColors.accent : AppColors.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Sliding Checklist or Bottom Controller Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomChecklistSheet(
              students: routeStudents,
              routeIsActive: route.isActive,
              db: db,
              onStopRoute: () {
                db.stopRoute(route.id);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDialog(BuildContext context, Student student, MockDatabase db) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(student.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Representante: ${student.tutorName}'),
              Text('Parada: ${student.stopName}'),
              const SizedBox(height: 16),
              const Text('Modificar Estado:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: StudentStatus.values.map((status) {
                  String label = '';
                  Color color = Colors.grey;
                  switch (status) {
                    case StudentStatus.atHome:
                      label = 'En Casa';
                      color = AppColors.accent;
                      break;
                    case StudentStatus.inRoute:
                      label = 'Abordó';
                      color = AppColors.warning;
                      break;
                    case StudentStatus.atSchool:
                      label = 'En Colegio';
                      color = AppColors.success;
                      break;
                    case StudentStatus.absent:
                      label = 'Ausente';
                      color = AppColors.danger;
                      break;
                  }
                  return ActionChip(
                    label: Text(label),
                    backgroundColor: student.status == status ? color.withOpacity(0.2) : null,
                    side: BorderSide(color: student.status == status ? color : Colors.grey[300]!),
                    onPressed: () {
                      db.updateStudentStatus(student.id, status);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _showSOSDialog(BuildContext context, MockDatabase db, String routeId) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: AppColors.danger),
              SizedBox(width: 8),
              Text('🚨 ALERTA SOS 🚨'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Seleccione o describa la emergencia para notificar inmediatamente a la administración y a los padres:'),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Falla Mecánica / Autobús Varado'),
                onTap: () {
                  db.triggerSOS(routeId, 'Falla Mecánica en el autobús.');
                  Navigator.pop(context);
                  _showSOSConfirmation(context);
                },
              ),
              ListTile(
                title: const Text('Tránsito Pesado / Retraso Mayor'),
                onTap: () {
                  db.triggerSOS(routeId, 'Retraso por congestión vehicular pesada.');
                  Navigator.pop(context);
                  _showSOSConfirmation(context);
                },
              ),
              ListTile(
                title: const Text('Problema de Salud'),
                onTap: () {
                  db.triggerSOS(routeId, 'Incidente de salud a bordo.');
                  Navigator.pop(context);
                  _showSOSConfirmation(context);
                },
              ),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Otro motivo (especificar)',
                  hintText: 'Ej. Accidente leve en la vía',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  db.triggerSOS(routeId, textController.text);
                  Navigator.pop(context);
                  _showSOSConfirmation(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Enviar SOS'),
            ),
          ],
        );
      },
    );
  }

  void _showSOSConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alerta SOS enviada con éxito.'),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _BottomChecklistSheet extends StatefulWidget {
  final List<Student> students;
  final bool routeIsActive;
  final MockDatabase db;
  final VoidCallback onStopRoute;

  const _BottomChecklistSheet({
    required this.students,
    required this.routeIsActive,
    required this.db,
    required this.onStopRoute,
  });

  @override
  State<_BottomChecklistSheet> createState() => _BottomChecklistSheetState();
}

class _BottomChecklistSheetState extends State<_BottomChecklistSheet> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < -10 && !_isExpanded) {
          setState(() => _isExpanded = true);
        } else if (details.primaryDelta! > 10 && _isExpanded) {
          setState(() => _isExpanded = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isExpanded ? 360 : 120,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Sheet Title & Controller Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registro de Abordaje',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.primary,
                        ),
                      ),
                      Text(
                        'Alumnos: ${widget.students.where((s) => s.status == StudentStatus.atSchool || s.status == StudentStatus.inRoute).length}/${widget.students.length}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  if (widget.routeIsActive)
                    ElevatedButton(
                      onPressed: widget.onStopRoute,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        minimumSize: const Size(120, 36),
                      ),
                      child: const Text('Finalizar Ruta', style: TextStyle(fontSize: 13, color: Colors.white)),
                    ),
                ],
              ),
            ),
            const Divider(),

            // Students Checklist
            if (_isExpanded)
              Expanded(
                child: ListView.builder(
                  itemCount: widget.students.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final student = widget.students[index];
                    IconData icon;
                    Color color;
                    String statusText;

                    switch (student.status) {
                      case StudentStatus.atHome:
                        icon = Icons.home_outlined;
                        color = AppColors.accent;
                        statusText = 'En Espera';
                        break;
                      case StudentStatus.inRoute:
                        icon = Icons.directions_bus;
                        color = AppColors.warning;
                        statusText = 'En Bus';
                        break;
                      case StudentStatus.atSchool:
                        icon = Icons.school;
                        color = AppColors.success;
                        statusText = 'Entregado';
                        break;
                      case StudentStatus.absent:
                        icon = Icons.cancel;
                        color = AppColors.danger;
                        statusText = 'Ausente';
                        break;
                    }

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withOpacity(0.1),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      title: Text(student.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      subtitle: Text('${student.stopName} • $statusText', style: const TextStyle(fontSize: 11)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: AppColors.success),
                            tooltip: 'Abordó / Entregado',
                            onPressed: () {
                              if (student.status == StudentStatus.atHome) {
                                widget.db.updateStudentStatus(student.id, StudentStatus.inRoute);
                              } else if (student.status == StudentStatus.inRoute) {
                                widget.db.updateStudentStatus(student.id, StudentStatus.atSchool);
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.danger),
                            tooltip: 'Ausente',
                            onPressed: () {
                              widget.db.updateStudentStatus(student.id, StudentStatus.absent);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Deslice hacia arriba para ver el listado de alumnos',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
