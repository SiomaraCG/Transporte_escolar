import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/partner.dart';
import '../../data/services/mock_database.dart';

class PartnerManagement extends StatefulWidget {
  const PartnerManagement({super.key});

  @override
  State<PartnerManagement> createState() => _PartnerManagementState();
}

class _PartnerManagementState extends State<PartnerManagement> {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<MockDatabase>(context);
    final partners = db.partners;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Socios y Conductores'),
      ),
      body: partners.isEmpty
          ? const Center(
              child: Text(
                'No se encontraron socios registrados.',
                style: TextStyle(color: AppColors.textMuted),
              ),
            )
          : ListView.builder(
              itemCount: partners.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final partner = partners[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.surfaceDark 
                        : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person, color: AppColors.textDark, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                partner.name.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark 
                                      ? Colors.white12 
                                      : Colors.black12,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Placa: ${partner.vehiclePlate}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Licencia: ${partner.licenseNumber} • Tel: ${partner.phone}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                              onPressed: () => _showPartnerFormDialog(context, db, partner),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                              onPressed: () => _showDeleteConfirmation(context, db, partner.id, partner.name),
                            ),
                          ],
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
        onPressed: () => _showPartnerFormDialog(context, db, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MockDatabase db, String partnerId, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Está seguro de que desea eliminar al socio/conductor "$name"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                db.deletePartner(partnerId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Socio eliminado con éxito')),
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

  void _showPartnerFormDialog(BuildContext context, MockDatabase db, Partner? partner) {
    final isEdit = partner != null;
    final nameController = TextEditingController(text: partner?.name ?? '');
    final phoneController = TextEditingController(text: partner?.phone ?? '');
    final plateController = TextEditingController(text: partner?.vehiclePlate ?? '');
    final licenseController = TextEditingController(text: partner?.licenseNumber ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEdit ? 'Editar Socio' : 'Nuevo Socio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre Completo'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: plateController,
                  decoration: const InputDecoration(
                    labelText: 'Placa del Vehículo',
                    hintText: 'Ej: PAB-1234',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: licenseController,
                  decoration: const InputDecoration(labelText: 'Número de Licencia'),
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
                  db.updatePartner(partner.copyWith(
                    name: nameController.text,
                    phone: phoneController.text,
                    vehiclePlate: plateController.text,
                    licenseNumber: licenseController.text,
                  ));
                } else {
                  db.addPartner(Partner(
                    id: 'partner_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    phone: phoneController.text,
                    vehiclePlate: plateController.text,
                    licenseNumber: licenseController.text,
                  ));
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isEdit ? 'Socio modificado con éxito' : 'Socio registrado con éxito')),
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
