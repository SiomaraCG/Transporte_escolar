import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/route.dart';
import '../../data/services/mock_database.dart';

class RouteManagement extends StatelessWidget {
  const RouteManagement({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<MockDatabase>(context);
    final routes = db.routes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Rutas'),
      ),
      body: ListView.builder(
        itemCount: routes.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final route = routes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.info.withOpacity(0.1),
                child: const Icon(Icons.alt_route, color: AppColors.info),
              ),
              title: Text(
                route.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                'Conductor: ${route.driverName}\nAlumnos asignados: ${route.studentIds.length}\nParadas en mapa: ${route.pathPoints.length}',
                style: const TextStyle(fontSize: 11),
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                    onPressed: () => _showRouteFormDialog(context, db, route),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                    onPressed: () {
                      _showDeleteConfirmation(context, db, route.id, route.name);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textDark,
        onPressed: () => _showRouteFormDialog(context, db, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MockDatabase db, String routeId, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Está seguro de que desea eliminar la ruta "$name"? Los estudiantes asignados quedarán sin ruta.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                db.deleteRoute(routeId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ruta eliminada con éxito')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showRouteFormDialog(BuildContext context, MockDatabase db, SchoolRoute? route) {
    final isEdit = route != null;
    final nameController = TextEditingController(text: route?.name ?? '');
    final driverController = TextEditingController(text: route?.driverName ?? 'Jorge Ortega');
    
    // Choose simple preset driver IDs
    String driverId = route?.driverId ?? 'driver_2';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Editar Ruta' : 'Nueva Ruta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre de la Ruta'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: driverController,
                  decoration: const InputDecoration(labelText: 'Nombre del Conductor'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Los puntos del trazado del mapa y alumnos se generarán con coordenadas escolares de forma automática.',
                  style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) return;

                if (isEdit) {
                  db.updateRoute(route.copyWith(
                    name: nameController.text,
                    driverName: driverController.text,
                  ));
                } else {
                  db.addRoute(SchoolRoute(
                    id: 'route_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    driverId: driverId,
                    driverName: driverController.text,
                    studentIds: [],
                    pathPoints: [
                      LatLng(-0.1750, -78.4750),
                      LatLng(-0.1870, -78.4810),
                      LatLng(-0.1920, -78.4880),
                    ],
                    isActive: false,
                    currentLatitude: -0.1750,
                    currentLongitude: -78.4750,
                  ));
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Ruta modificada con éxito' : 'Ruta creada con éxito')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
