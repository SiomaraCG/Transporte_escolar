class Partner {
  final String id;
  final String name;
  final String phone;
  final String vehiclePlate;
  final String licenseNumber;

  Partner({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehiclePlate,
    required this.licenseNumber,
  });

  Partner copyWith({
    String? id,
    String? name,
    String? phone,
    String? vehiclePlate,
    String? licenseNumber,
  }) {
    return Partner(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      licenseNumber: licenseNumber ?? this.licenseNumber,
    );
  }
}
