import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String id;
  final String name;
  final String phone;
  final String role;
  final bool active;
  final DateTime? createdAt;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.active,
    required this.createdAt,
  });

  factory EmployeeModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final rawCreated = data['createdAt'];

    return EmployeeModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? doc.id,
      role: data['role']?.toString() ?? 'simpleEmployee',
      active: data['active'] != false,
      createdAt: rawCreated is Timestamp ? rawCreated.toDate() : null,
    );
  }

  String get roleLabel {
    switch (role) {
      case 'admin':
        return 'مدير';
      case 'employee':
        return 'موظف (لا يمكنه إضافة موظف)';
      default:
        return 'موظف (لا يمكنه إضافة موظف، إنشاء تنبيه، تغيير حالة بلاغ)';
    }
  }
}
