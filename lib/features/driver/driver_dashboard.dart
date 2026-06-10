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


class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<MockDatabase>(context);
    final driver = db.currentUser;
    final driverRoutes = db.routes.where((r) => r.driverId == driver?.id).toList();
    final pendingPayments = db.payments.where((p) => p.status == PaymentStatus.pending).length;

    final List<Widget> tabs = [
      _buildInicioTab(context, db, driver, driverRoutes),
      _buildEscolarTab(context),
      _buildFinanzasTab(context, pendingPayments),
    ];

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
      extendBody: true,
      body: Stack(
        children: [
          // Yellow background pattern - bottom left
          Positioned(
            bottom: -150,
            left: -100,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
            ),
          ),
          // Yellow background pattern - bottom right
          Positioned(
            bottom: -50,
            right: -100,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutQuart,
              switchOutCurve: Curves.easeInQuart,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.95,
                      end: 1.0,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: Container(
                key: ValueKey<int>(_currentIndex),
                child: tabs[_currentIndex],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.black54 : Colors.black12,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              if (Theme.of(context).brightness == Brightness.dark)
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
            ],
            border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: Colors.white24, width: 1) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.map_outlined, Icons.map, 'Rutas'),
              _buildNavItem(1, Icons.school_outlined, Icons.school, 'Escolar'),
              _buildNavItem(2, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Finanzas'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInicioTab(BuildContext context, MockDatabase db, dynamic driver, List<dynamic> driverRoutes) {
    return SingleChildScrollView(
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
                    child: const Icon(Icons.person, size: 36, color: AppColors.accent),
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
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: route.isActive ? AppColors.primary : (isDark ? Colors.white12 : Colors.black12),
                    width: route.isActive ? 2 : 1,
                  ),
                  boxShadow: route.isActive ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ] : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              route.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                color: isDark ? Colors.white : AppColors.textDark,
                              ),
                            ),
                          ),
                          if (route.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'EN RUTA',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.accent,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.symmetric(
                            horizontal: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _InfoColumn(
                              icon: Icons.people_outline,
                              value: '${route.studentIds.length}',
                              label: 'ALUMNOS',
                            ),
                            _InfoColumn(
                              icon: Icons.place_outlined,
                              value: '${route.pathPoints.length - 2}',
                              label: 'PARADAS',
                            ),
                            const _InfoColumn(
                              icon: Icons.school_outlined,
                              value: 'Col. Americano',
                              label: 'DESTINO',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (!route.isActive) {
                            db.startRoute(route.id);
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ActiveRouteMap(routeId: route.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: route.isActive ? AppColors.surfaceDarker : AppColors.primary,
                          foregroundColor: route.isActive ? Colors.white : AppColors.accent,
                          side: route.isActive ? BorderSide(color: isDark ? Colors.white24 : Colors.black26) : BorderSide.none,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              route.isActive ? Icons.map_outlined : Icons.play_arrow_rounded,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              route.isActive ? 'VER MAPA DE RUTA' : 'INICIAR RECORRIDO',
                              style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEscolarTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestión de Estudiantes',
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
        ],
      ),
    );
  }

  Widget _buildFinanzasTab(BuildContext context, int pendingPayments) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Finanzas y Reportes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 16 : 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(isDark ? 0.2 : 0.15) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected 
                  ? (isDark ? AppColors.primary : AppColors.accent)
                  : (isDark ? Colors.white70 : Colors.grey),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isDark ? AppColors.primary : AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ]
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(isDark ? 0.3 : 0.5), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              )
            else
              const Icon(Icons.arrow_forward, size: 20, color: AppColors.textMuted),
          ],
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
