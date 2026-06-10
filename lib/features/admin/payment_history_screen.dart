import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/payment.dart';
import '../../data/services/mock_database.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<MockDatabase>(context);
    
    // Filter students by query
    final studentsFiltered = db.students
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultar e Historial de Pagos'),
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar estudiante por nombre...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),

          // Collapsible History List Grouped by Student
          Expanded(
            child: studentsFiltered.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron estudiantes.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: studentsFiltered.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final student = studentsFiltered[index];
                      
                      // Get all payments related to this student
                      final studentPayments = db.payments
                          .where((p) => p.studentId == student.id)
                          .toList();

                      // Calculations for student summary card
                      final totalApproved = studentPayments
                          .where((p) => p.status == PaymentStatus.approved)
                          .fold<double>(0, (sum, p) => sum + p.amount);

                      final totalPending = studentPayments
                          .where((p) => p.status == PaymentStatus.pending)
                          .fold<double>(0, (sum, p) => sum + p.amount);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.person, color: AppColors.primary),
                          ),
                          title: Text(
                            student.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Pagado: \$${totalApproved.toStringAsFixed(2)} • Pendiente: \$${totalPending.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                          children: [
                            const Divider(height: 1),
                            if (studentPayments.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'No registra pagos en el historial.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: studentPayments.length,
                                itemBuilder: (context, pIndex) {
                                  final payment = studentPayments[pIndex];
                                  Color statusColor = Colors.grey;
                                  IconData statusIcon = Icons.help;
                                  String statusText = '';

                                  switch (payment.status) {
                                    case PaymentStatus.pending:
                                      statusColor = AppColors.warning;
                                      statusIcon = Icons.hourglass_empty;
                                      statusText = 'Pendiente';
                                      break;
                                    case PaymentStatus.approved:
                                      statusColor = AppColors.success;
                                      statusIcon = Icons.check_circle_outline;
                                      statusText = 'Aprobado';
                                      break;
                                    case PaymentStatus.rejected:
                                      statusColor = AppColors.danger;
                                      statusIcon = Icons.cancel_outlined;
                                      statusText = 'Rechazado';
                                      break;
                                  }

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                    leading: CircleAvatar(
                                      backgroundColor: statusColor.withOpacity(0.1),
                                      radius: 16,
                                      child: Icon(statusIcon, color: statusColor, size: 16),
                                    ),
                                    title: Text(
                                      'Pago Mensualidad: \$${payment.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(payment.date)}\nRef: ${payment.referenceNumber ?? "N/A"}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    isThreeLine: true,
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
          ),
        ],
      ),
    );
  }
}
