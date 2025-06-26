// home_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getBestStudents() async {
    final snapshot = await _firestore.collection('bestStudents').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'title': data['title'] ?? 'طالب متفوق',
        'name': data['name'] ?? '',
        'score': data['score']?.toDouble() ?? 0.0,
        'imageBase64': data['imageBase64'] ?? '',
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getBestTeachers() async {
    final snapshot = await _firestore.collection('bestTeachers').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'title': data['title'] ?? 'أستاذ مميز',
        'name': data['name'] ?? '',
        'subject': data['subject'] ?? '',
        'imageBase64': data['imageBase64'] ?? '',
      };
    }).toList();
  }

  Future<Map<DateTime, List<String>>> getEvents() async {
    final snapshot = await _firestore.collection('events').get();

    Map<DateTime, List<String>> events = {};
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final Timestamp timestamp = data['date'];
      final DateTime date = timestamp.toDate();
      final List<String> eventTitles = List<String>.from(data['titles'] ?? []);
      events[date] = eventTitles;
    }
    return events;
  }
}
