import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_exam/core/models/exam_model.dart';
import 'package:universal_exam/core/models/question_model.dart';

class ExamService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Exam>> getExamsByStudent(String specialty) async {
    try {
      final snapshot = await _firestore
          .collection('exams')
          .where('specialty', isEqualTo: specialty)
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => Exam.fromJson(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching exams: $e');
      return [];
    }
  }

  Future<Exam?> getExamById(String examId) async {
    try {
      final doc = await _firestore.collection('exams').doc(examId).get();
      if (!doc.exists) return null;
      return Exam.fromJson(doc.id, doc.data() ?? {});
    } catch (e) {
      print('Error fetching exam: $e');
      return null;
    }
  }

  Future<Exam?> getActiveExamBySpecialtyAndTime(String specialty) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('exams')
          .where('specialty', isEqualTo: specialty)
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final date = (data['date'] as Timestamp).toDate();
        final duration = data['duration'] as int? ?? 0;

        if (now.isAfter(date.subtract(const Duration(minutes: 2))) &&
            now.isBefore(date.add(Duration(minutes: duration + 2)))) {
          return Exam.fromJson(doc.id, data);
        }
      }

      return null;
    } catch (e) {
      print('Error finding active exam: $e');
      return null;
    }
  }

  Future<List<Question>> getSecureExamQuestions(String examId) async {
    try {
      final examDoc = await _firestore.collection('exams').doc(examId).get();
      if (!examDoc.exists) return [];

      final examData = examDoc.data() ?? {};
      final qids = List<String>.from((examData['questionIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          []);

      final querySnapshot = await _firestore
          .collection('questions')
          .where(FieldPath.documentId, whereIn: qids)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();

        return Question.fromJson(doc.id, {
          'text': data['text'] ?? '',
          'specialty': data['specialty'] ?? '',
          'createdBy': data['createdBy'] ?? '',
          'createdAt': data['createdAt'] is Timestamp
              ? data['createdAt'].toDate()
              : DateTime.now(),
          'type': data['type'] ?? '',
          'options':
              (data['options'] as List?)?.map((e) => e.toString()).toList() ??
                  [],
          'imageBase64': data['imageBase64'] as String?,
        });
      }).toList();
    } catch (e) {
      print('Error fetching secure questions: $e');
      return [];
    }
  }

  Future<void> autoSaveAnswers({
    required String examId,
    required Map<String, String> answers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'exam_${examId}';
    final json = jsonEncode(answers);
    await prefs.setString(key, json);
  }

  Future<Map<String, String>> loadSavedAnswers(String examId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'exam_${examId}';
    final json = prefs.getString(key);
    if (json != null) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((key, value) => MapEntry(key, value.toString()));
    }
    return {};
  }
}
