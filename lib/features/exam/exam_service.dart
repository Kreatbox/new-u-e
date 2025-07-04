import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_exam/core/encryption.dart';
import 'package:universal_exam/core/models/exam_attempt_model.dart';
import 'package:universal_exam/core/models/exam_model.dart';
import 'package:universal_exam/core/models/question_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
          .where('date', isGreaterThanOrEqualTo: now)
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        return Exam.fromJson(doc.id, data);
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
      final questionIds = qids;

      if (questionIds.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('questions')
          .where(FieldPath.documentId, whereIn: questionIds)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Question.fromJson(doc.id, {
          'text': data['text'] ?? '',
          'specialty': data['specialty'] ?? '',
          'createdBy': data['createdBy'] ?? '',
          'createdAt': data['createdAt'] is Timestamp
              ? data['createdAt'].toDate()
              : data['createdAt'] is DateTime
                  ? data['createdAt']
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

  Future<Exam?> getAvailableExamForStudent(String specialty) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('exams')
          .where('specialty', isEqualTo: specialty)
          .get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final exam = Exam.fromJson(doc.id, data);
        final start = (data['date'] is Timestamp)
            ? (data['date'] as Timestamp).toDate()
            : DateTime.tryParse(data['date'].toString()) ?? DateTime.now();
        final duration = data['duration'] is int
            ? data['duration']
            : int.tryParse(data['duration'].toString()) ?? 0;
        final windowStart = start.subtract(const Duration(minutes: 5));
        final windowEnd = start.add(Duration(minutes: duration));
        if (now.isAfter(windowStart) && now.isBefore(windowEnd)) {
          return exam;
        }
      }
      return null;
    } catch (e) {
      print('Error finding available exam: $e');
      return null;
    }
  }

  Future<Exam?> activateExamIfNeeded(String specialty) async {
    try {
      // Set the server timestamp
      await _firestore
          .collection('serverTime')
          .doc('now')
          .set({'ts': FieldValue.serverTimestamp()});
      // Wait for the server to update the timestamp
      Timestamp? serverTimestamp;

      for (int i = 0; i < 10; i++) {
        // Try up to 10 times
        final serverTimeDoc =
            await _firestore.collection('serverTime').doc('now').get();
        if (serverTimeDoc.exists && serverTimeDoc.data()?['ts'] != null) {
          serverTimestamp = serverTimeDoc['ts'] as Timestamp;
          break;
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
      if (serverTimestamp == null) {
        throw Exception('Failed to get server time from Firestore');
      }
      final now = serverTimestamp.toDate();

      final snapshot = await _firestore
          .collection('exams')
          .where('specialty', isEqualTo: specialty)
          .get();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final exam = Exam.fromJson(doc.id, data);
        final start = exam.date;
        final duration = exam.duration;
        final windowStart = start.subtract(const Duration(minutes: 5));
        final windowEnd = start.add(Duration(minutes: duration));
        debugPrint(
            'now: $now, windowStart: $windowStart, windowEnd: $windowEnd');
        if (now.isAfter(windowStart) && now.isBefore(windowEnd)) {
          if (!exam.isActive) {
            // Decrypt questionIds
            final String encryptionKey = '${dotenv.env['EXAM_KEY']}';
            final encryptedQids = List<String>.from(
                (data['questionIds'] as List?)
                        ?.map((e) => e.toString())
                        .toList() ??
                    []);
            final decryptedQids = encryptedQids
                .map((encryptedId) {
                  try {
                    return xorDecrypt(encryptedId, encryptionKey);
                  } catch (e) {
                    return null;
                  }
                })
                .whereType<String>()
                .toList();
            await _firestore.collection('exams').doc(doc.id).update({
              'questionIds': decryptedQids,
              'isActive': true,
            });
            return Exam(
              id: exam.id,
              title: exam.title,
              specialty: exam.specialty,
              date: exam.date,
              duration: exam.duration,
              createdAt: exam.createdAt,
              questionIds: decryptedQids,
              isActive: true,
              questionsPerStudent: exam.questionsPerStudent,
            );
          } else {
            return exam;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error activating exam: $e');
      return null;
    }
  }

  Future<ExamAttempt?> submitAndGradeAttempt({
    required Exam exam,
    required String studentId,
    required Map<String, String> answers,
  }) async {
    try {
      // Prevent duplicate attempts
      final existing = await _firestore
          .collection('examAttempts')
          .where('examId', isEqualTo: exam.id)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return ExamAttempt.fromJson(
            existing.docs.first.id, existing.docs.first.data());
      }
      final now = DateTime.now();
      // Fetch correct answers for the exam questions
      final questionsSnap = await _firestore
          .collection('questions')
          .where(FieldPath.documentId, whereIn: exam.questionIds)
          .get();
      final correctAnswers = <String, String>{};
      for (var doc in questionsSnap.docs) {
        final data = doc.data();
        correctAnswers[doc.id] = data['correctAnswer'] ?? '';
      }
      // Calculate score
      int correct = 0;
      answers.forEach((qid, ans) {
        if (correctAnswers[qid] == ans) correct++;
      });
      final score = exam.questionIds.isEmpty
          ? 0.0
          : (correct / exam.questionIds.length) * 20.0;
      // Create attempt
      final attemptRef = _firestore.collection('examAttempts').doc();
      final attempt = ExamAttempt(
        id: attemptRef.id,
        examId: exam.id,
        studentId: studentId,
        startedAt: now,
        submittedAt: now,
        status: 'submitted',
        answers: answers,
        correctAnswers: correctAnswers,
        score: score,
      );
      await attemptRef.set(attempt.toJson());
      return attempt;
    } catch (e) {
      print('Error submitting/grading attempt: $e');
      return null;
    }
  }

  Future<void> calculateExamStatsIfNeeded(Exam exam) async {
    try {
      final examDoc = await _firestore.collection('exams').doc(exam.id).get();
      final data = examDoc.data() ?? {};
      if (!(data['isActive'] == true) || data['calculated'] == true) return;

      // 1. Get all attempts for this exam
      final attemptsSnap = await _firestore
          .collection('examAttempts')
          .where('examId', isEqualTo: exam.id)
          .get();
      final attempts = attemptsSnap.docs
          .map((d) => ExamAttempt.fromJson(d.id, d.data()))
          .toList();
      if (attempts.isEmpty) return;

      // 2. Top Students (by specialty)
      final top = attempts..sort((a, b) => b.score.compareTo(a.score));
      final top5 = top.take(5).toList();
      final topStudentsRef = _firestore.collection('topStudents');
      for (var att in top5) {
        await topStudentsRef.doc(att.studentId).set({
          'studentId': att.studentId,
          'averageScore': att.score,
          'updatedAt': DateTime.now(),
        });
      }

      // 3. Question stats
      final questionStats = <String, Map<String, dynamic>>{};
      for (var qid in exam.questionIds) {
        int total = 0, correct = 0;
        for (var att in attempts) {
          if (att.answers.containsKey(qid)) {
            total++;
            if (att.correctAnswers[qid] == att.answers[qid]) correct++;
          }
        }
        final rate = total == 0 ? 0.0 : (correct / total) * 100;
        questionStats[qid] = {
          'totalAnswered': total,
          'correctAnswered': correct,
          'correctRate': rate,
        };
        // Update question doc
        await _firestore.collection('questions').doc(qid).update({
          'stats': questionStats[qid],
        });
      }

      // 4. Top Teachers
      final teacherStats = <String, List<double>>{};
      final teacherQuestions = <String, int>{};
      for (var qid in exam.questionIds) {
        final qDoc = await _firestore.collection('questions').doc(qid).get();
        final qData = qDoc.data() ?? {};
        final createdBy = qData['createdBy'] ?? '';
        final rate = questionStats[qid]?['correctRate'] ?? 0.0;
        teacherStats.putIfAbsent(createdBy, () => []).add(rate);
        teacherQuestions[createdBy] = (teacherQuestions[createdBy] ?? 0) + 1;
      }
      final topTeachersRef = _firestore.collection('topTeachers');
      for (var entry in teacherStats.entries) {
        final avgRate = entry.value.isEmpty
            ? 0.0
            : entry.value.reduce((a, b) => a + b) / entry.value.length;
        final totalQ = teacherQuestions[entry.key] ?? 0;
        // Best: 40-60% correct, enough questions
        if (avgRate >= 40 && avgRate <= 60 && totalQ >= 5) {
          await topTeachersRef.doc(entry.key).set({
            'teacherId': entry.key,
            'avgStudentScore': avgRate,
            'totalQuestions': totalQ,
            'updatedAt': DateTime.now(),
          });
        }
        // Trash: 0-5% or 95-100%
        if ((avgRate >= 0 && avgRate <= 5) ||
            (avgRate >= 95 && avgRate <= 100)) {
          await _firestore.collection('users').doc(entry.key).update({
            'verified': false,
          });
        }
      }

      // 5. Mark exam as calculated
      await _firestore
          .collection('exams')
          .doc(exam.id)
          .update({'calculated': true});
    } catch (e) {
      print('Error calculating exam stats: $e');
    }
  }

  Future<bool> canStudentEnterExam({
    required String studentId,
    required Exam exam,
  }) async {
    try {
      // Check for existing attempt for this exam
      final existing = await _firestore
          .collection('examAttempts')
          .where('examId', isEqualTo: exam.id)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      if (existing.docs.isNotEmpty) {
        return false;
      }
      // Check for failed attempts in the same specialty in the past 6 months
      final sixMonthsAgo = DateTime.now().subtract(const Duration(days: 180));
      final pastAttempts = await _firestore
          .collection('examAttempts')
          .where('studentId', isEqualTo: studentId)
          .where('score', isLessThan: 10)
          .get();
      for (var doc in pastAttempts.docs) {
        final data = doc.data();
        final attemptExamId = data['examId'] ?? '';
        final examDoc =
            await _firestore.collection('exams').doc(attemptExamId).get();
        final examData = examDoc.data() ?? {};
        final specialty = examData['specialty'] ?? '';
        final submittedAt = data['submittedAt'] is Timestamp
            ? (data['submittedAt'] as Timestamp).toDate()
            : null;
        if (specialty == exam.specialty &&
            submittedAt != null &&
            submittedAt.isAfter(sixMonthsAgo)) {
          return false;
        }
      }
      return true;
    } catch (e) {
      print('Error checking student exam eligibility: $e');
      return false;
    }
  }
}
