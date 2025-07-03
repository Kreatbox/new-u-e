// app_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppService {
  final CollectionReference examsCol =
      FirebaseFirestore.instance.collection('exams');

  final CollectionReference topStudentsCol =
      FirebaseFirestore.instance.collection('topStudents');

  final CollectionReference topTeachersCol =
      FirebaseFirestore.instance.collection('topTeachers');

  final CollectionReference usersCol =
      FirebaseFirestore.instance.collection('users');

  Future<bool> shouldFetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetch = prefs.getInt('last_data_fetch_time');

    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastFetch == null) return true;

    final hoursSinceLastFetch = (now - lastFetch) / (1000 * 60 * 60);

    return hoursSinceLastFetch >= 24;
  }

  Future<void> markDataFetched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'last_data_fetch_time', DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<Map<String, dynamic>>> fetchTopStudentsWithUserInfo() async {
    final snapshot = await topStudentsCol.get();
    final List<Map<String, dynamic>> result = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final studentId = data['studentId'] as String? ?? '';
      if (studentId.isEmpty) continue;

      final userSnapshot = await usersCol.doc(studentId).get();
      final userData = userSnapshot.exists
          ? (userSnapshot.data() as Map<String, dynamic>)
          : const {};

      final merged = {
        'studentId': data['studentId'],
        'averageScore': data['averageScore'] ?? 0.0,
        'updatedAt': data['updatedAt'],
        'firstName': userData['firstName'] ?? '',
        'lastName': userData['lastName'] ?? '',
        'specialty': userData['specialty'] ?? '',
        'profileImage': userData['photoBase64'] ?? '',
        'role': userData['role'] ?? '',
      };

      result.add(merged);
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> fetchTopTeachersWithUserInfo() async {
    final snapshot = await topTeachersCol.get();
    final List<Map<String, dynamic>> result = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final teacherId = data['teacherId'] as String? ?? '';
      if (teacherId.isEmpty) continue;

      final userSnapshot = await usersCol.doc(teacherId).get();
      final userData = userSnapshot.exists
          ? (userSnapshot.data() as Map<String, dynamic>)
          : const {};

      final merged = {
        'teacherId': data['teacherId'],
        'avgStudentScore': data['avgStudentScore'] ?? 0.0,
        'totalQuestions': data['totalQuestions'] ?? 0,
        'updatedAt': data['updatedAt'],
        'firstName': userData['firstName'] ?? '',
        'lastName': userData['lastName'] ?? '',
        'specialty': userData['specialty'] ?? '',
        'profileImage': userData['photoBase64'] ?? '',
        'role': userData['role'] ?? '',
      };

      result.add(merged);
    }

    return result;
  }

  Future<Map<DateTime, List<String>>> fetchExamEvents() async {
    final snapshot = await examsCol.get();
    final Map<DateTime, List<String>> events = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp =
          data['date'] is Timestamp ? data['date'] as Timestamp : null;
      if (timestamp == null) continue;
      final date =
          DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final title = data['title'] as String? ?? 'امتحان';
      if (!events.containsKey(normalizedDate)) {
        events[normalizedDate] = [];
      }
      events[normalizedDate]?.add(title);
    }

    return events;
  }
}
