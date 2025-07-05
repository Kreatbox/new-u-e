import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_exam/core/encryption.dart';
import 'package:universal_exam/core/models/exam_attempt_model.dart';
import 'package:universal_exam/core/models/exam_model.dart';
import 'package:universal_exam/core/models/user_model.dart';

class AdminController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Exam>> fetchExams() async {
    try {
      final snapshot = await _firestore.collection('exams').get();
      return snapshot.docs
          .map((doc) => Exam.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching exams: $e');
      return [];
    }
  }

  Future<void> createExam(
      {required String specialty,
      required DateTime startTime,
      required int examDuration,
      required int numberOfQuestions,
      required String adminUid}) async {
    final querySnapshot = await _firestore
        .collection('questions')
        .where('specialty', isEqualTo: specialty)
        .where('disabled', isEqualTo: false)
        .get();

    final List<DocumentSnapshot> allQuestions = querySnapshot.docs;

    if (allQuestions.length < numberOfQuestions) {
      throw Exception(
          "لا توجد أسئلة كافية (${allQuestions.length}/$numberOfQuestions)");
    }

    final List<String> questionIds = allQuestions
        .sublist(0, numberOfQuestions)
        .map((doc) => doc.id)
        .toList();

    final encryptedQuestionIds =
        questionIds.map((id) => xorEncrypt(id, adminUid)).toList();
    for (String id in questionIds) {
      await _firestore.collection('questions').doc(id).update({
        'disabled': true,
      });
    }
    final examData = {
      'title': 'إمتحان $specialty',
      'specialty': specialty,
      'date': Timestamp.fromDate(startTime),
      'duration': examDuration,
      'createdAt': Timestamp.now(),
      'questionIds': encryptedQuestionIds,
      'isActive': false,
      'questionsPerStudent': numberOfQuestions,
    };

    await _firestore.collection('exams').add(examData);
  }

  Future<void> approveExam(String examId) async {
    await _firestore.collection('exams').doc(examId).update({'isActive': true});
  }

  Future<void> editExamDate(String examId, DateTime newDate) async {
    await _firestore.collection('exams').doc(examId).update({
      'date': Timestamp.fromDate(newDate),
    });
  }

  Future<void> deleteExam(String examId) async {
    try {
      final examDoc = await _firestore.collection('exams').doc(examId).get();
      if (!examDoc.exists) {
        throw Exception('الامتحان غير موجود');
      }
      
      final exam = Exam.fromJson(examId, examDoc.data()!);
      if (!exam.canBeDeleted) {
        throw Exception('لا يمكن حذف الامتحان بعد بدايته');
      }
      
      await _firestore.collection('exams').doc(examId).delete();
    } catch (e) {
      print('Error deleting exam: $e');
      rethrow;
    }
  }

  Future<List<User>> fetchAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<List<User>> fetchUnverifiedStudents() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'طالب')
          .where('verified', isEqualTo: false)
          .get();

      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching unverified students: $e');
      return [];
    }
  }

  Future<void> verifyUser(String userId) async {
    await _firestore.collection('users').doc(userId).update({'verified': true});
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  Future<List<User>> fetchUnverifiedTeachers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'أستاذ')
          .where('verified', isEqualTo: false)
          .get();

      return snapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
    } catch (e) {
      print('Error fetching unverified teachers: $e');
      return [];
    }
  }

  Future<int> getUnverifiedRequestsCount() async {
    try {
      final studentSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'طالب')
          .where('verified', isEqualTo: false)
          .get();

      final teacherSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'أستاذ')
          .where('verified', isEqualTo: false)
          .get();

      return studentSnapshot.docs.length + teacherSnapshot.docs.length;
    } catch (e) {
      print("Error fetching unverified count: $e");
      return 0;
    }
  }

  Future<List<ExamAttempt>> fetchExamAttemptStats() async {
    try {
      final snapshot = await _firestore.collection('examAttempts').get();
      return snapshot.docs
          .map((doc) => ExamAttempt.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print("Error fetching exam attempts: $e");
      return [];
    }
  }
}
