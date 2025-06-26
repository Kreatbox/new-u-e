// core/features/admin/admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getLogs() async {
    final snapshot = await _firestore.collection('logs').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getUnverifiedStudents() async {
    final snapshot = await _firestore
        .collection('students')
        .where('verified', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getUnverifiedTeachers() async {
    final snapshot = await _firestore
        .collection('teachers')
        .where('verified', isEqualTo: false)
        .get();
    return snapshot.docs.map((doc) {
      return {
        'id': doc.id,
        ...doc.data(),
      };
    }).toList();
  }

  Future<void> verifyUser(String collection, String userId) async {
    await _firestore.collection(collection).doc(userId).update({
      'verified': true,
    });
  }

  Future<void> deleteUser(String collection, String userId) async {
    await _firestore.collection(collection).doc(userId).delete();
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final students = await _firestore.collection('students').get();
    final teachers = await _firestore.collection('teachers').get();
    return [
      ...students.docs.map((doc) => {'type': 'student', ...doc.data()}),
      ...teachers.docs.map((doc) => {'type': 'teacher', ...doc.data()}),
    ];
  }

  Future<List<Map<String, dynamic>>> getStudentGrades() async {
    final snapshot = await _firestore.collection('students').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'name': data['name'],
        'grades': data['grades'],
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getExams() async {
    final snapshot = await _firestore.collection('exams').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'subject': data['subject'],
        'examType': data['examType'],
        'startTime': (data['startTime'] as Timestamp).toDate(),
        'numberOfQuestions': data['numberOfQuestions'],
        'examDuration': data['examDuration'],
        'status': data['status'],
      };
    }).toList();
  }

  Future<void> createExam({
    required String subject,
    required String examType,
    required DateTime startTime,
    required int numberOfQuestions,
    required int examDuration,
  }) async {
    await _firestore.collection('exams').add({
      'subject': subject,
      'examType': examType,
      'startTime': startTime,
      'numberOfQuestions': numberOfQuestions,
      'examDuration': examDuration,
      'status': 'Pending',
    });
  }

  Future<void> approveExam(String examId) async {
    await _firestore
        .collection('exams')
        .doc(examId)
        .update({'status': 'Approved'});
  }

  Future<void> editExamDate(String examId, DateTime newDateTime) async {
    await _firestore
        .collection('exams')
        .doc(examId)
        .update({'startTime': newDateTime});
  }
}
