import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/app_user.dart';
import '../models/student.dart';
import '../models/route.dart';
import '../models/payment.dart';

class MockDatabase extends ChangeNotifier {
  // Current logged in user
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  // Mock Users
  final List<AppUser> _users = [
    AppUser(id: 'admin_1', name: 'Lic. Sofía Andrade', email: 'admin@transporte.com', role: UserRole.admin),
    AppUser(id: 'driver_1', name: 'Carlos Mendoza (Conductor 1)', email: 'conductor@transporte.com', role: UserRole.driver),
    AppUser(id: 'parent_1', name: 'Mariana Reyes', email: 'padre@transporte.com', role: UserRole.parent),
  ];

  // Mock Students
  final List<Student> _students = [
    Student(
      id: 'student_1',
      name: 'Alejandro Mendoza Reyes',
      age: 8,
      tutorId: 'parent_1',
      tutorName: 'Mariana Reyes',
      routeId: 'route_1',
      stopName: 'Calle Eloy Alfaro y Amazonas',
      stopLatitude: -0.1800,
      stopLongitude: -78.4800,
      status: StudentStatus.atHome,
    ),
    Student(
      id: 'student_2',
      name: 'Camila Mendoza Reyes',
      age: 11,
      tutorId: 'parent_1',
      tutorName: 'Mariana Reyes',
      routeId: 'route_1',
      stopName: 'Calle Eloy Alfaro y Amazonas', // same stop for siblings
      stopLatitude: -0.1800,
      stopLongitude: -78.4800,
      status: StudentStatus.atHome,
    ),
    Student(
      id: 'student_3',
      name: 'Mateo Ortiz',
      age: 9,
      tutorId: 'parent_2',
      tutorName: 'José Ortiz',
      routeId: 'route_1',
      stopName: 'Av. Shyris y Naciones Unidas',
      stopLatitude: -0.1850,
      stopLongitude: -78.4820,
      status: StudentStatus.atHome,
    ),
    Student(
      id: 'student_4',
      name: 'Valentina Castro',
      age: 7,
      tutorId: 'parent_3',
      tutorName: 'Laura Castro',
      routeId: 'route_2',
      stopName: 'Av. Colón y 10 de Agosto',
      stopLatitude: -0.2000,
      stopLongitude: -78.4900,
      status: StudentStatus.atHome,
    ),
  ];

  // Mock Routes
  final List<SchoolRoute> _routes = [
    SchoolRoute(
      id: 'route_1',
      name: 'Ruta Norte - Colegio Americano',
      driverId: 'driver_1',
      driverName: 'Carlos Mendoza',
      studentIds: ['student_1', 'student_2', 'student_3'],
      pathPoints: [
        LatLng(-0.1750, -78.4750), // Start (Depot)
        LatLng(-0.1800, -78.4800), // Stop 1 (Alejandro & Camila)
        LatLng(-0.1850, -78.4820), // Stop 2 (Mateo)
        LatLng(-0.1920, -78.4880), // School
      ],
      isActive: false,
      currentLatitude: -0.1750,
      currentLongitude: -78.4750,
    ),
    SchoolRoute(
      id: 'route_2',
      name: 'Ruta Sur - Colegio Americano',
      driverId: 'driver_2',
      driverName: 'Jorge Ortega',
      studentIds: ['student_4'],
      pathPoints: [
        LatLng(-0.2100, -78.4950), // Start
        LatLng(-0.2000, -78.4900), // Stop 1 (Valentina)
        LatLng(-0.1920, -78.4880), // School
      ],
      isActive: false,
      currentLatitude: -0.2100,
      currentLongitude: -78.4950,
    ),
  ];

  // Mock Payments
  final List<Payment> _payments = [
    Payment(
      id: 'pay_1',
      studentId: 'student_1',
      studentName: 'Alejandro Mendoza Reyes',
      amount: 65.00,
      date: DateTime.now().subtract(const Duration(days: 30)),
      status: PaymentStatus.approved,
      receiptImagePath: 'assets/receipts/mock_approved.png',
      referenceNumber: 'REF-882716',
    ),
    Payment(
      id: 'pay_2',
      studentId: 'student_1',
      studentName: 'Alejandro Mendoza Reyes',
      amount: 65.00,
      date: DateTime.now(),
      status: PaymentStatus.pending,
      receiptImagePath: 'assets/receipts/mock_pending.png',
      referenceNumber: 'REF-992812',
    ),
  ];

  // Mock Notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': 'not_1',
      'title': 'Ruta Finalizada',
      'body': 'La Ruta Norte ha finalizado exitosamente en el colegio.',
      'time': DateTime.now().subtract(const Duration(hours: 24)),
      'type': 'route'
    },
    {
      'id': 'not_2',
      'title': 'Mensualidad Disponible',
      'body': 'Ya está disponible el cobro del servicio para el mes actual.',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'payment'
    }
  ];

  Timer? _gpsSimulationTimer;
  int _currentPathIndex = 0;

  List<AppUser> get users => _users;
  List<Student> get students => _students;
  List<SchoolRoute> get routes => _routes;
  List<Payment> get payments => _payments;
  List<Map<String, dynamic>> get notifications => _notifications;

  // --- Auth Methods ---
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate API delay
    try {
      final user = _users.firstWhere((u) => u.email.trim().toLowerCase() == email.trim().toLowerCase());
      _currentUser = user;
      notifyListeners();
      return true;
    } catch (_) {
      return false; // User not found
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // --- Admin Methods ---
  void addStudent(Student student) {
    _students.add(student);
    // Add to route if assigned
    if (student.routeId != null) {
      final rIndex = _routes.indexWhere((r) => r.id == student.routeId);
      if (rIndex != -1) {
        final currentStudentIds = List<String>.from(_routes[rIndex].studentIds);
        if (!currentStudentIds.contains(student.id)) {
          currentStudentIds.add(student.id);
          _routes[rIndex] = _routes[rIndex].copyWith(studentIds: currentStudentIds);
        }
      }
    }
    notifyListeners();
  }

  void updateStudent(Student student) {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      // Manage route association changes
      final oldRouteId = _students[index].routeId;
      if (oldRouteId != student.routeId) {
        if (oldRouteId != null) {
          final rOldIndex = _routes.indexWhere((r) => r.id == oldRouteId);
          if (rOldIndex != -1) {
            final ids = List<String>.from(_routes[rOldIndex].studentIds)..remove(student.id);
            _routes[rOldIndex] = _routes[rOldIndex].copyWith(studentIds: ids);
          }
        }
        if (student.routeId != null) {
          final rNewIndex = _routes.indexWhere((r) => r.id == student.routeId);
          if (rNewIndex != -1) {
            final ids = List<String>.from(_routes[rNewIndex].studentIds);
            if (!ids.contains(student.id)) ids.add(student.id);
            _routes[rNewIndex] = _routes[rNewIndex].copyWith(studentIds: ids);
          }
        }
      }
      _students[index] = student;
      notifyListeners();
    }
  }

  void deleteStudent(String studentId) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final routeId = _students[index].routeId;
      if (routeId != null) {
        final rIndex = _routes.indexWhere((r) => r.id == routeId);
        if (rIndex != -1) {
          final ids = List<String>.from(_routes[rIndex].studentIds)..remove(studentId);
          _routes[rIndex] = _routes[rIndex].copyWith(studentIds: ids);
        }
      }
      _students.removeAt(index);
      notifyListeners();
    }
  }

  void addRoute(SchoolRoute route) {
    _routes.add(route);
    notifyListeners();
  }

  void updateRoute(SchoolRoute route) {
    final index = _routes.indexWhere((r) => r.id == route.id);
    if (index != -1) {
      _routes[index] = route;
      notifyListeners();
    }
  }

  void deleteRoute(String routeId) {
    _routes.removeWhere((r) => r.id == routeId);
    // Clear student assignments to this route
    for (int i = 0; i < _students.length; i++) {
      if (_students[i].routeId == routeId) {
        _students[i] = _students[i].copyWith(routeId: null);
      }
    }
    notifyListeners();
  }

  // --- Payment Methods ---
  void uploadPayment({
    required String studentId,
    required String studentName,
    required double amount,
    required String imagePath,
    required String reference,
  }) {
    final newPayment = Payment(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      studentId: studentId,
      studentName: studentName,
      amount: amount,
      date: DateTime.now(),
      status: PaymentStatus.pending,
      receiptImagePath: imagePath,
      referenceNumber: reference,
    );
    _payments.add(newPayment);
    
    // Add parent notification
    addNotification(
      title: 'Comprobante Recibido',
      body: 'El comprobante de $studentName por \$$amount ha sido subido y está en espera de validación.',
      type: 'payment'
    );
    notifyListeners();
  }

  void updatePaymentStatus(String paymentId, PaymentStatus status) {
    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index != -1) {
      final oldPayment = _payments[index];
      _payments[index] = oldPayment.copyWith(status: status);
      
      // Notify parent
      final statusStr = status == PaymentStatus.approved ? 'APROBADO' : 'RECHAZADO';
      addNotification(
        title: 'Pago $statusStr',
        body: 'El pago de \$${oldPayment.amount} para ${oldPayment.studentName} ha sido $statusStr por el administrador.',
        type: 'payment'
      );
      notifyListeners();
    }
  }

  // --- Notification Helper ---
  void addNotification({required String title, required String body, required String type}) {
    _notifications.insert(0, {
      'id': 'not_${DateTime.now().millisecondsSinceEpoch}',
      'title': title,
      'body': body,
      'time': DateTime.now(),
      'type': type
    });
    notifyListeners();
  }

  // --- GPS Simulation (Driver / Parent interaction) ---
  void startRoute(String routeId) {
    final rIndex = _routes.indexWhere((r) => r.id == routeId);
    if (rIndex == -1) return;

    _routes[rIndex] = _routes[rIndex].copyWith(
      isActive: true,
      currentLatitude: _routes[rIndex].pathPoints.first.latitude,
      currentLongitude: _routes[rIndex].pathPoints.first.longitude,
    );
    
    _currentPathIndex = 0;
    
    // Set all students of this route to "inRoute" initially
    final studentIds = _routes[rIndex].studentIds;
    for (int i = 0; i < _students.length; i++) {
      if (studentIds.contains(_students[i].id)) {
        _students[i] = _students[i].copyWith(status: StudentStatus.inRoute);
      }
    }

    addNotification(
      title: 'Ruta Iniciada',
      body: 'La ruta "${_routes[rIndex].name}" ha iniciado su recorrido.',
      type: 'route'
    );
    
    notifyListeners();

    // Start periodic GPS movement timer
    _gpsSimulationTimer?.cancel();
    _gpsSimulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      final route = _routes[rIndex];
      if (_currentPathIndex < route.pathPoints.length - 1) {
        _currentPathIndex++;
        final nextLatLng = route.pathPoints[_currentPathIndex];
        
        _routes[rIndex] = route.copyWith(
          currentLatitude: nextLatLng.latitude,
          currentLongitude: nextLatLng.longitude,
        );

        // Update matching students status based on proximity
        for (int i = 0; i < _students.length; i++) {
          final s = _students[i];
          if (studentIds.contains(s.id)) {
            // If we are at the stop, update status
            final distance = const Distance().as(
              LengthUnit.Meter,
              LatLng(s.stopLatitude, s.stopLongitude),
              nextLatLng,
            );
            // If close to student stop
            if (distance < 50 && s.status == StudentStatus.inRoute) {
              // Simulating bus approaching
              addNotification(
                title: 'Autobús cerca',
                body: 'El autobús escolar está cerca de la parada de ${s.name}.',
                type: 'route'
              );
            }
          }
        }
        
        notifyListeners();
      } else {
        // Arrived at destination
        stopRoute(routeId);
      }
    });
  }

  void stopRoute(String routeId) {
    _gpsSimulationTimer?.cancel();
    _gpsSimulationTimer = null;

    final rIndex = _routes.indexWhere((r) => r.id == routeId);
    if (rIndex != -1) {
      final route = _routes[rIndex];
      _routes[rIndex] = route.copyWith(
        isActive: false,
        currentLatitude: route.pathPoints.first.latitude,
        currentLongitude: route.pathPoints.first.longitude,
      );

      // Set students to atSchool (morning)
      final studentIds = route.studentIds;
      for (int i = 0; i < _students.length; i++) {
        if (studentIds.contains(_students[i].id)) {
          // If they weren't absent, mark as atSchool
          if (_students[i].status != StudentStatus.absent) {
            _students[i] = _students[i].copyWith(status: StudentStatus.atSchool);
          }
        }
      }

      addNotification(
        title: 'Ruta Finalizada',
        body: 'La ruta "${route.name}" ha finalizado y el autobús llegó al colegio.',
        type: 'route'
      );
    }
    notifyListeners();
  }

  void updateStudentStatus(String studentId, StudentStatus status) {
    final index = _students.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final student = _students[index];
      _students[index] = student.copyWith(status: status);

      String statusText = '';
      switch (status) {
        case StudentStatus.atHome:
          statusText = 'en casa';
          break;
        case StudentStatus.inRoute:
          statusText = 'en el autobús (en ruta)';
          break;
        case StudentStatus.atSchool:
          statusText = 'en el colegio';
          break;
        case StudentStatus.absent:
          statusText = 'marcado como ausente hoy';
          break;
      }

      addNotification(
        title: 'Estado de Estudiante',
        body: 'El estudiante ${student.name} está $statusText.',
        type: 'route'
      );
      notifyListeners();
    }
  }

  void triggerSOS(String routeId, String message) {
    final rIndex = _routes.indexWhere((r) => r.id == routeId);
    if (rIndex == -1) return;
    
    addNotification(
      title: '🚨 ALERTA SOS 🚨',
      body: 'Alerta del conductor de ${_routes[rIndex].name}: $message',
      type: 'alert'
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _gpsSimulationTimer?.cancel();
    super.dispose();
  }
}
