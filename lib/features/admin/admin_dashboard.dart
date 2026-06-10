import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/navigation/routes.dart';
import '../../data/models/payment.dart';
import '../../data/services/mock_database.dart';
import 'student_management.dart';
import 'route_management.dart';
import 'payment_verification.dart';
import 'payment_history_screen.dart';
import 'partner_management.dart';
import 'students_by_route_screen.dart';
import 'reports_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<MockDatabase>(context);
    final admin = db.currentUser;

    // Calculate metrics
    final totalStudents = db.students.length;
    final totalRoutes = db.routes.length;
    final activeRoutes = db.routes.where((r) => r.isActive).length;
    final pendingPayments = db.payments
        .where((p) => p.status == PaymentStatus.pending)
        .length;

    final List<Widget> tabs = [
      _buildInicioTab(
        admin?.name ?? "Administrador",
        totalStudents,
        totalRoutes,
        activeRoutes,
        pendingPayments,
      ),
      _buildEscolarTab(),
      _buildPersonalTab(),
      _buildFinanzasTab(pendingPayments),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrador - Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
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
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Inicio'),
              _buildNavItem(1, Icons.school_outlined, Icons.school, 'Escolar'),
              _buildNavItem(2, Icons.badge_outlined, Icons.badge, 'Personal'),
              _buildNavItem(3, Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, 'Finanzas'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInicioTab(
    String adminName,
    int totalStudents,
    int totalRoutes,
    int activeRoutes,
    int pendingPayments,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Admin Profile Welcome
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenido, $adminName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Coordinación de Transporte Escolar',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Resumen del Sistema',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Statistics Grid (4 items)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.4,
            children: [
              _StatCard(
                title: 'Estudiantes',
                value: '$totalStudents',
                icon: Icons.people,
                color: AppColors.primary,
              ),
              _StatCard(
                title: 'Rutas Totales',
                value: '$totalRoutes',
                icon: Icons.alt_route,
                color: AppColors.info,
              ),
              _StatCard(
                title: 'Buses en Ruta',
                value: '$activeRoutes',
                icon: Icons.directions_bus,
                color: activeRoutes > 0
                    ? AppColors.success
                    : AppColors.textMuted,
                isGlowing: activeRoutes > 0,
              ),
              _StatCard(
                title: 'Pagos Pendientes',
                value: '$pendingPayments',
                icon: Icons.receipt_long,
                color: pendingPayments > 0
                    ? AppColors.warning
                    : AppColors.textMuted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEscolarTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Gestión Escolar y Rutas'),
          _ActionCard(
            title: 'Gestión de Estudiantes',
            subtitle: 'Registrar, editar y asignar rutas a estudiantes',
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
            title: 'Configuración de Rutas',
            subtitle: 'Crear rutas, definir paradas y asignar conductores',
            icon: Icons.map_outlined,
            color: AppColors.info,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RouteManagement()),
              );
            },
          ),
          const SizedBox(height: 12),
          _ActionCard(
            title: 'Consulta de Estudiantes por Ruta',
            subtitle: 'Listado agrupado de estudiantes según su ruta asignada',
            icon: Icons.format_list_bulleted_rounded,
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentsByRouteScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Personal y Socios'),
          _ActionCard(
            title: 'Gestión de Socios y Conductores',
            subtitle: 'Administrar perfiles, licencias y vehículos',
            icon: Icons.badge_outlined,
            color: AppColors.accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PartnerManagement()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinanzasTab(int pendingPayments) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Finanzas y Reportes'),
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
            subtitle:
                'Consultar y filtrar el historial de pagos de cada alumno',
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.accent : AppColors.textDark,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isGlowing;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isGlowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isGlowing ? 4 : 2,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: isGlowing
              ? Border.all(color: AppColors.success, width: 1.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                if (isGlowing) const _PingIndicator(),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PingIndicator extends StatefulWidget {
  const _PingIndicator();

  @override
  State<_PingIndicator> createState() => _PingIndicatorState();
}

class _PingIndicatorState extends State<_PingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.accent.withOpacity(0.5) 
                      : AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
