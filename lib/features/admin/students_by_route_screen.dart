import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/mock_database.dart';
import '../../data/models/student.dart';

class StudentsByRouteScreen extends StatelessWidget {
  const StudentsByRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<MockDatabase>(context);
    final routes = db.routes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estudiantes por Ruta'),
      ),
      body: routes.isEmpty
          ? const Center(
              child: Text(
                'No hay rutas registradas.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                final route = routes[index];
                final studentsInRoute = db.students.where((s) => route.studentIds.contains(s.id)).toList();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.info.withOpacity(0.1),
                      child: const Icon(Icons.alt_route, color: AppColors.info),
                    ),
                    title: Text(
                      route.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Conductor: ${route.driverName} • Alumnos: ${studentsInRoute.length}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    children: [
                      if (studentsInRoute.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No hay estudiantes asignados a esta ruta.',
                            style: TextStyle(color: AppColors.textMuted, fontStyle: FontStyle.italic),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: studentsInRoute.length,
                          itemBuilder: (context, sIndex) {
                            final student = studentsInRoute[sIndex];
                            
                            Color statusColor = AppColors.textMuted;
                            String statusText = 'Desconocido';
                            
                            switch (student.status) {
                              case StudentStatus.atHome:
                                statusColor = AppColors.accent;
                                statusText = 'En Casa / Espera';
                                break;
                              case StudentStatus.inRoute:
                                statusColor = AppColors.warning;
                                statusText = 'En Ruta';
                                break;
                              case StudentStatus.atSchool:
                                statusColor = AppColors.success;
                                statusText = 'En Colegio';
                                break;
                              case StudentStatus.absent:
                                statusColor = AppColors.danger;
                                statusText = 'Ausente';
                                break;
                            }

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                              leading: const Icon(Icons.person_outline, color: AppColors.textMuted),
                              title: Text(student.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                'Tutor: ${student.tutorName}\nParada: ${student.stopName}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
