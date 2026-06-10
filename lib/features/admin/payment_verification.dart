import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/payment.dart';
import '../../data/services/mock_database.dart';

class PaymentVerification extends StatelessWidget {
  const PaymentVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<MockDatabase>(context);
    final pendingPayments = db.payments.where((p) => p.status == PaymentStatus.pending).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validación de Pagos (OCR)'),
      ),
      body: pendingPayments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 48, color: AppColors.success),
                  SizedBox(height: 12),
                  Text(
                    'Todos los comprobantes han sido validados.',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: pendingPayments.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final pay = pendingPayments[index];
                
                Color statusColor = AppColors.warning;
                String statusStr = 'Validación Pendiente';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pay.studentName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                statusStr,
                                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Monto: \$${pay.amount}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('Referencia: ${pay.referenceNumber ?? "N/A"}', style: const TextStyle(fontSize: 12)),
                        Text('Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(pay.date)}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (pay.status == PaymentStatus.pending)
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OcrVerificationScreen(payment: pay, db: db),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.document_scanner, size: 16, color: Colors.white),
                                label: const Text('Escanear OCR', style: TextStyle(color: Colors.white, fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  minimumSize: const Size(120, 36),
                                ),
                              )
                            else
                              Text(
                                'Procesado',
                                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// --- Screen for Scanning and OCR Simulation ---
class OcrVerificationScreen extends StatefulWidget {
  final Payment payment;
  final MockDatabase db;

  const OcrVerificationScreen({
    super.key,
    required this.payment,
    required this.db,
  });

  @override
  State<OcrVerificationScreen> createState() => _OcrVerificationScreenState();
}

class _OcrVerificationScreenState extends State<OcrVerificationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  bool _isScanning = true;
  bool _scanComplete = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Simulate scanning delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scanComplete = true;
          _scanController.stop();
        });
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador OCR'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Receipt Image Frame with Scan Line Animation
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: Stack(
                    children: [
                      // Simulated Receipt Document details
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.receipt, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text(
                                'BANCO DE LA NACIÓN',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                              ),
                              Text(
                                'TRANSFERENCIA EXITOSA\nRef: ${widget.payment.referenceNumber}\nMonto: \$${widget.payment.amount}\nFecha: ${DateFormat('dd/MM/yyyy').format(widget.payment.date)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 10, color: Colors.black54, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Scan overlay animation
                      if (_isScanning)
                        AnimatedBuilder(
                          animation: _scanController,
                          builder: (context, child) {
                            return Positioned(
                              top: _scanController.value * 260,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.success.withOpacity(0.8),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      
                      // Scanning indicator overlay text
                      if (_isScanning)
                        Container(
                          color: Colors.black38,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: AppColors.accent),
                                SizedBox(height: 12),
                                Text(
                                  'Analizando comprobante...',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // OCR Reading Results
            if (_scanComplete) ...[
              Card(
                color: isDark ? Colors.white54.withOpacity(0.05) : Colors.green.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.success, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          SizedBox(width: 8),
                          Text(
                            'Lectura OCR Completada',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _OcrMatchRow(
                        label: 'Monto Identificado',
                        ocrValue: '\$${widget.payment.amount}',
                        inputValue: '\$${widget.payment.amount}',
                        isMatch: true,
                      ),
                      const SizedBox(height: 10),
                      _OcrMatchRow(
                        label: 'Número de Referencia',
                        ocrValue: '${widget.payment.referenceNumber}',
                        inputValue: '${widget.payment.referenceNumber}',
                        isMatch: true,
                      ),
                      const SizedBox(height: 10),
                      const _OcrMatchRow(
                        label: 'Emisor del Pago',
                        ocrValue: 'Mariana Reyes',
                        inputValue: 'Mariana Reyes',
                        isMatch: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.db.updatePaymentStatus(widget.payment.id, PaymentStatus.rejected);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pago Rechazado'), backgroundColor: AppColors.danger),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                      child: const Text('Rechazar Pago', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.db.updatePaymentStatus(widget.payment.id, PaymentStatus.approved);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pago Aprobado con Éxito'), backgroundColor: AppColors.success),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      child: const Text('Aprobar Pago', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OcrMatchRow extends StatelessWidget {
  final String label;
  final String ocrValue;
  final String inputValue;
  final bool isMatch;

  const _OcrMatchRow({
    required this.label,
    required this.ocrValue,
    required this.inputValue,
    required this.isMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'OCR: $ocrValue  •  Ingresado: $inputValue',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Icon(
              isMatch ? Icons.check : Icons.close,
              color: isMatch ? AppColors.success : AppColors.danger,
              size: 18,
            ),
          ],
        ),
      ],
    );
  }
}
