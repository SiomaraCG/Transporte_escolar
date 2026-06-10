import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/student.dart';
import '../../data/services/mock_database.dart';

class StudentManagement extends StatefulWidget {
  const StudentManagement({super.key});

  @override
  State<StudentManagement> createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement> {
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
    
    // Filter students based on search query
    final students = db.students
        .where((s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Estudiantes'),
      ),
      body: Column(
        children: [
          // Search / Query Bar
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Consultar estudiante por nombre...',
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

          // Students List
          Expanded(
            child: students.isEmpty
                ? const Center(
                    child: Text(
                      'No se encontraron estudiantes.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : ListView.builder(
                    itemCount: students.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final student = students[index];
                      
                      // Find route name
                      final route = db.routes.firstWhere(
                        (r) => r.id == student.routeId,
                        orElse: () => db.routes.first,
                      );
                      final routeName = student.routeId != null ? route.name : 'Sin ruta asignada';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: const Icon(Icons.school, color: AppColors.primary),
                          ),
                          title: Text(
                            student.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Edad: ${student.age} • Tutor: ${student.tutorName}\n$routeName\nParada: ${student.stopName}',
                            style: const TextStyle(fontSize: 11),
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                                onPressed: () => _showStudentFormDialog(context, db, student),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                                onPressed: () {
                                  _showDeleteConfirmation(context, db, student.id, student.name);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.textDark,
        onPressed: () => _showStudentFormDialog(context, db, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, MockDatabase db, String studentId, String name) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Está seguro de que desea eliminar al estudiante "$name"? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                db.deleteStudent(studentId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Estudiante eliminado con éxito')),
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

  void _showStudentFormDialog(BuildContext context, MockDatabase db, Student? student) {
    final isEdit = student != null;
    final nameController = TextEditingController(text: student?.name ?? '');
    final ageController = TextEditingController(text: student?.age.toString() ?? '');
    final tutorController = TextEditingController(text: student?.tutorName ?? 'Mariana Reyes');
    final stopNameController = TextEditingController(text: student?.stopName ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdit ? 'Editar Estudiante' : 'Nuevo Estudiante'),
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
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Edad'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: tutorController,
                      decoration: const InputDecoration(labelText: 'Representante (Tutor)'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: stopNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de Parada',
                        hintText: 'Ej: Av. Shyris y Amazonas',
                      ),
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
                    if (nameController.text.isEmpty || ageController.text.isEmpty) return;

                    final age = int.tryParse(ageController.text) ?? 8;
                    // Default fallback stop coordinates (or keep existing)
                    final lat = student?.stopLatitude ?? -0.1800;
                    final lng = student?.stopLongitude ?? -78.4800;

                    if (isEdit) {
                      db.updateStudent(student.copyWith(
                        name: nameController.text,
                        age: age,
                        tutorName: tutorController.text,
                        routeId: student.routeId,
                        stopName: stopNameController.text,
                        stopLatitude: lat,
                        stopLongitude: lng,
                      ));
                    } else {
                      db.addStudent(Student(
                        id: 'student_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text,
                        age: age,
                        tutorId: 'parent_1', // default mock tutor for simplicity
                        tutorName: tutorController.text,
                        routeId: null, // No manual route assigned at creation
                        stopName: stopNameController.text,
                        stopLatitude: lat,
                        stopLongitude: lng,
                        status: StudentStatus.atHome,
                      ));
                    }

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEdit ? 'Estudiante modificado con éxito' : 'Estudiante registrado con éxito')),
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
