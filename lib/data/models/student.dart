enum StudentStatus { atHome, inRoute, atSchool, absent }

class Student {
  final String id;
  final String name;
  final int age;
  final String tutorId;
  final String tutorName;
  final String? routeId;
  final String stopName;
  final double stopLatitude;
  final double stopLongitude;
  final StudentStatus status;

  Student({
    required this.id,
    required this.name,
    required this.age,
    required this.tutorId,
    required this.tutorName,
    this.routeId,
    required this.stopName,
    required this.stopLatitude,
    required this.stopLongitude,
    required this.status,
  });

  Student copyWith({
    String? id,
    String? name,
    int? age,
    String? tutorId,
    String? tutorName,
    String? routeId,
    String? stopName,
    double? stopLatitude,
    double? stopLongitude,
    StudentStatus? status,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      tutorId: tutorId ?? this.tutorId,
      tutorName: tutorName ?? this.tutorName,
      routeId: routeId ?? this.routeId,
      stopName: stopName ?? this.stopName,
      stopLatitude: stopLatitude ?? this.stopLatitude,
      stopLongitude: stopLongitude ?? this.stopLongitude,
      status: status ?? this.status,
    );
  }

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      tutorId: json['tutorId'] as String,
      tutorName: json['tutorName'] as String,
      routeId: json['routeId'] as String?,
      stopName: json['stopName'] as String,
      stopLatitude: (json['stopLatitude'] as num).toDouble(),
      stopLongitude: (json['stopLongitude'] as num).toDouble(),
      status: StudentStatus.values.firstWhere(
        (e) => e.toString() == 'StudentStatus.${json['status']}',
        orElse: () => StudentStatus.atHome,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'tutorId': tutorId,
      'tutorName': tutorName,
      'routeId': routeId,
      'stopName': stopName,
      'stopLatitude': stopLatitude,
      'stopLongitude': stopLongitude,
      'status': status.toString().split('.').last,
    };
  }
}
