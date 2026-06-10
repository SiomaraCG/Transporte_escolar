import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/navigation/routes.dart';
import '../../data/models/payment.dart';
import '../../data/services/mock_database.dart';
import '../admin/student_management.dart';
import '../admin/payment_verification.dart';
import '../admin/payment_history_screen.dart';
import '../admin/reports_screen.dart';
import 'active_route_map.dart';


class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<MockDatabase>(context);
    final driver = db.currentUser;
    final driverRoutes = db.routes.where((r) => r.driverId == driver?.id).toList();
    final pendingPayments = db.payments.where((p) => p.status == PaymentStatus.pending).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conductor - Panel de Control'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              db.logout();
              Navigator.pushReplacementNamed(context, AppRoutes.login);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Profile Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.accent.withOpacity(0.2),
                      child: Icon(Icons.person, size: 36, color: AppColors.accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver?.name ?? 'Nombre Conductor',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Conductor Autorizado',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rutas Asignadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (driverRoutes.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text('No tienes rutas asignadas actualmente.'),
                ),
              )
            else
              ...driverRoutes.map((route) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: route.isActive ? AppColors.accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                route.name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            if (route.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'ACTIVA',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _InfoColumn(
                              icon: Icons.people_outline,
                              value: '${route.studentIds.length}',
                              label: 'Alumnos',
                            ),
                            _InfoColumn(
                              icon: Icons.place_outlined,
                              value: '${route.pathPoints.length - 2}', // stops are between start & school
                              label: 'Paradas',
                            ),
                            _InfoColumn(
                              icon: Icons.school_outlined,
                              value: 'Col. Americano',
                              label: 'Destino',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // If route is not already active, start it
                            if (!route.isActive) {
                              db.startRoute(route.id);
                            }
                            
                            // Navigate to active map
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ActiveRouteMap(routeId: route.id),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: route.isActive ? AppColors.success : AppColors.primary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                route.isActive ? Icons.map_outlined : Icons.play_arrow_rounded,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                route.isActive ? 'Ver Mapa de Ruta' : 'Iniciar Recorrido de Ruta',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            const SizedBox(height: 28),
            const Text(
              'Gestión y Operaciones (Conductor)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'Gestión de Estudiantes',
              subtitle: 'Registrar, editar, eliminar y consultar estudiantes',
              icon: Icons.person_add_alt_1,
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentManagement()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'Validación de Comprobantes (OCR)',
              subtitle: 'Aprobar o rechazar pagos con escaneo automático',
              icon: Icons.document_scanner,
              color: AppColors.warning,
              badgeCount: pendingPayments,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentVerification()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'Consultar Pagos e Historial',
              subtitle: 'Consultar y filtrar el historial de pagos de cada alumno',
              icon: Icons.receipt_long_rounded,
              color: AppColors.info,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentHistoryScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ActionCard(
              title: 'Generación de Reportes',
              subtitle: 'Ver resúmenes financieros y de asistencia de rutas',
              icon: Icons.analytics_outlined,
              color: AppColors.success,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int badgeCount;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (badgeCount > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              else
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}


class _InfoColumn extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _InfoColumn({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
