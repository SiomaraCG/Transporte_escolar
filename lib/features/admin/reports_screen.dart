import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/student.dart';
import '../../data/models/payment.dart';
import '../../data/services/mock_database.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<MockDatabase>(context);
    
    // Attendance statistics
    final totalStudents = db.students.length;
    final inSchool = db.students.where((s) => s.status == StudentStatus.atSchool).length;
    final inRoute = db.students.where((s) => s.status == StudentStatus.inRoute).length;
    final absent = db.students.where((s) => s.status == StudentStatus.absent).length;
    final atHome = db.students.where((s) => s.status == StudentStatus.atHome).length;

    // Financial statistics
    final monthlyPricePerStudent = 65.00;
    final expectedRevenue = totalStudents * monthlyPricePerStudent;
    
    final approvedPaymentsTotal = db.payments
        .where((p) => p.status == PaymentStatus.approved)
        .fold<double>(0, (sum, p) => sum + p.amount);

    final pendingPaymentsTotal = db.payments
        .where((p) => p.status == PaymentStatus.pending)
        .fold<double>(0, (sum, p) => sum + p.amount);

    final collectionRate = expectedRevenue > 0 ? (approvedPaymentsTotal / expectedRevenue) * 100 : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes e Indicadores'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Financial Report Card
            const Text(
              'Reporte Financiero Mensual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Meta de Recaudación:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                        Text(
                          '\$${expectedRevenue.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Recaudado:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                        Text(
                          '\$${approvedPaymentsTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.success),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Pendiente Validación:', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                        Text(
                          '\$${pendingPaymentsTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.warning),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Porcentaje de Cobro:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text(
                          '${collectionRate.toStringAsFixed(1)}%',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.info),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: collectionRate / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Section 2: Attendance Report Card
            const Text(
              'Reporte de Asistencia Diario',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _AttendanceRow(
                      label: 'Entregados en Colegio',
                      count: inSchool,
                      color: AppColors.success,
                      percentage: totalStudents > 0 ? (inSchool / totalStudents) : 0,
                    ),
                    const SizedBox(height: 14),
                    _AttendanceRow(
                      label: 'En Ruta / Autobús',
                      count: inRoute,
                      color: AppColors.warning,
                      percentage: totalStudents > 0 ? (inRoute / totalStudents) : 0,
                    ),
                    const SizedBox(height: 14),
                    _AttendanceRow(
                      label: 'Reportados Ausentes',
                      count: absent,
                      color: AppColors.danger,
                      percentage: totalStudents > 0 ? (absent / totalStudents) : 0,
                    ),
                    const SizedBox(height: 14),
                    _AttendanceRow(
                      label: 'En Casa / Sin Recoger',
                      count: atHome,
                      color: AppColors.accent,
                      percentage: totalStudents > 0 ? (atHome / totalStudents) : 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final double percentage;

  const _AttendanceRow({
    required this.label,
    required this.count,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
            Text('$count alumnos', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
