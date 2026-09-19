import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String userPhone;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final String status;
  final DateTime? finalizedAt;

  const ReportModel({
    required this.id,
    required this.userPhone,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    required this.finalizedAt,
  });

  factory ReportModel.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    DateTime? dateValue(dynamic value) =>
        value is Timestamp ? value.toDate() : null;

    final rawImages = data['imageUrls'] ?? data['images'] ?? const [];
    final images = rawImages is List
        ? rawImages.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    return ReportModel(
      id: doc.id,
      userPhone: data['userPhone']?.toString() ?? '',
      type: data['reportType']?.toString() ?? data['type']?.toString() ?? 'بلاغ',
      description:
          data['description']?.toString() ?? data['notes']?.toString() ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      imageUrls: images,
      createdAt: dateValue(data['createdAt']),
      expiresAt: dateValue(data['expiresAt']),
      status: data['status']?.toString() ?? 'جديد',
      finalizedAt: dateValue(data['finalizedAt']),
    );
  }
}
