import 'package:cloud_firestore/cloud_firestore.dart';

class ExamAttempt {
  final String id;
  final String examId;
  final String studentId;
  final DateTime startedAt;
  final DateTime? submittedAt;
  final String status; // in_progress, submitted, graded
  final Map<String, String> answers;
  final Map<String, String> correctAnswers;
  final double score;

  const ExamAttempt({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.startedAt,
    this.submittedAt,
    required this.status,
    required this.answers,
    required this.correctAnswers,
    required this.score,
  });

  factory ExamAttempt.fromJson(String id, Map<String, dynamic> json) {
    return ExamAttempt(
      id: id,
      examId: json['examId'],
      studentId: json['studentId'],
      startedAt: (json['startedAt'] as Timestamp).toDate(),
      submittedAt: json['submittedAt'] is Timestamp
          ? (json['submittedAt'] as Timestamp).toDate()
          : null,
      status: json['status'],
      answers: Map<String, String>.from(json['answers']),
      correctAnswers: Map<String, String>.from(json['correctAnswers']),
      score: json['score'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'examId': examId,
      'studentId': studentId,
      'startedAt': startedAt,
      'submittedAt': submittedAt,
      'status': status,
      'answers': answers,
      'correctAnswers': correctAnswers,
      'score': score,
    };
  }
}
