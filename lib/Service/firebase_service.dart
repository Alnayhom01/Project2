import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get reports =>
      firestore.collection('reports');

  CollectionReference<Map<String, dynamic>> get employees =>
      firestore.collection('employees');
}
