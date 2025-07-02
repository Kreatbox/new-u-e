import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_exam/core/models/top_student_model.dart';
import 'package:universal_exam/core/models/top_teacher_model.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TopStudent>> getBestStudents() async {
    final snapshot = await _firestore
        .collection('topStudents')
        .orderBy('averageScore', descending: true)
        .limit(5)
        .get();
    final uids = snapshot.docs.map((doc) => doc.id).toList();

    final usersSnapshot =
        await _firestore.collection('users').where('uid', whereIn: uids).get();

    return usersSnapshot.docs.map((doc) {
      final data = doc.data();
      return TopStudent(
        studentId: doc.id,
        averageScore: data['averageScore'] ?? 0.0,
      );
    }).toList();
  }

  Future<List<TopTeacher>> getBestTeachers() async {
    final snapshot = await _firestore
        .collection('topTeachers')
        .orderBy('avgStudentScore', descending: true)
        .limit(5)
        .get();
    final uids = snapshot.docs.map((doc) => doc.id).toList();

    final usersSnapshot =
        await _firestore.collection('users').where('uid', whereIn: uids).get();

    return usersSnapshot.docs.map((doc) {
      final data = doc.data();
      return TopTeacher(
        teacherId: doc.id,
        avgStudentScore: data['avgStudentScore'] ?? 0.0,
        totalQuestions: data['totalQuestions'] ?? 0,
      );
    }).toList();
  }
}
