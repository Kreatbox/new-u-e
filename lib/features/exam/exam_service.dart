import 'package:cloud_firestore/cloud_firestore.dart';

class ExamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get questions for a specific exam
  Future<List<Map<String, dynamic>>> getExamQuestions(String examId) async {
    try {
      final snapshot = await _firestore
          .collection('questions')
          .where('examId', isEqualTo: examId)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error fetching questions: $e');
      return [];
    }
  }

  // Get exam details
  Future<Map<String, dynamic>?> getExamById(String examId) async {
    try {
      final doc = await _firestore.collection('exams').doc(examId).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data()!,
          'startTime': (doc.data()!['startTime'] as Timestamp).toDate(),
        };
      }
      return null;
    } catch (e) {
      print('Error fetching exam: $e');
      return null;
    }
  }

  // Submit exam answers
  Future<void> submitExamAnswers({
    required String examId,
    required String studentId,
    required Map<String, String> answers, // questionId -> selectedAnswer
    required DateTime submissionTime,
    required int timeSpent, // in seconds
  }) async {
    try {
      await _firestore.collection('exam_submissions').add({
        'examId': examId,
        'studentId': studentId,
        'answers': answers,
        'submissionTime': submissionTime,
        'timeSpent': timeSpent,
        'status': 'submitted',
      });
    } catch (e) {
      print('Error submitting exam: $e');
      throw e;
    }
  }

  // Auto-save answers (call this every few seconds)
  Future<void> autoSaveAnswers({
    required String examId,
    required String studentId,
    required Map<String, String> answers,
  }) async {
    try {
      await _firestore
          .collection('exam_drafts')
          .doc('${examId}_$studentId')
          .set({
        'examId': examId,
        'studentId': studentId,
        'answers': answers,
        'lastSaved': DateTime.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error auto-saving: $e');
    }
  }

  // Load saved answers
  Future<Map<String, String>> loadSavedAnswers(
      String examId, String studentId) async {
    try {
      final doc = await _firestore
          .collection('exam_drafts')
          .doc('${examId}_$studentId')
          .get();
      if (doc.exists) {
        final data = doc.data()!;
        return Map<String, String>.from(data['answers'] ?? {});
      }
      return {};
    } catch (e) {
      print('Error loading saved answers: $e');
      return {};
    }
  }
}
