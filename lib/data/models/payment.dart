enum PaymentStatus { pending, approved, rejected }

class Payment {
  final String id;
  final String studentId;
  final String studentName;
  final double amount;
  final DateTime date;
  final PaymentStatus status;
  final String receiptImagePath;
  final String? referenceNumber;

  Payment({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.amount,
    required this.date,
    required this.status,
    required this.receiptImagePath,
    this.referenceNumber,
  });

  Payment copyWith({
    String? id,
    String? studentId,
    String? studentName,
    double? amount,
    DateTime? date,
    PaymentStatus? status,
    String? receiptImagePath,
    String? referenceNumber,
  }) {
    return Payment(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      referenceNumber: referenceNumber ?? this.referenceNumber,
    );
  }

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      receiptImagePath: json['receiptImagePath'] as String,
      referenceNumber: json['referenceNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status.toString().split('.').last,
      'receiptImagePath': receiptImagePath,
      'referenceNumber': referenceNumber,
    };
  }
}
