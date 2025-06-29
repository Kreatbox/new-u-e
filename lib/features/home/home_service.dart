// home_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getBestStudents() async {
    List<Map<String, dynamic>> students = [];
    final specialtiesSnapshot = await _firestore.collection('topStudents').get();

    for (var specialtyDoc in specialtiesSnapshot.docs) {
      final data = specialtyDoc.data();
      students.add({
        'title': data['title'] ?? 'طالب متفوق',
        'name': data['fullName'] ?? '',
        'score': data['averageScore']?.toDouble() ?? 0.0,
        'imageBase64': data['photoBase64'] ?? '',
      });
    }
    return students;
  }

  Future<List<Map<String, dynamic>>> getBestTeachers() async {
    List<Map<String, dynamic>> teachers = [];
    final specialtiesSnapshot = await _firestore.collection('topTeachers').get();

    for (var specialtyDoc in specialtiesSnapshot.docs) {
      final data = specialtyDoc.data();
      teachers.add({
        'title': data['title'] ?? 'أستاذ مميز',
        'name': data['fullName'] ?? '',
        // Using specialty as subject for now, assuming it's relevant.
        // If a specific subject field is added to the topTeachers collection,
        // that should be used instead.
        'subject': data['specialty'] ?? '',
        'imageBase64': data['photoBase64'] ?? '',
      });
    }
    return teachers;
  }

  // NOTE: The getEvents method remains unchanged as it was not part of the
  // instruction to modify.
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
