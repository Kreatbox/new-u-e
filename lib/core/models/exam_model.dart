import 'package:cloud_firestore/cloud_firestore.dart';

class Exam {
  final String id;
  final String title;
  final String specialty;
  final DateTime date;
  final int duration;
  final String createdBy;
  final DateTime createdAt;
  final List<String> questionIds;
  final Map<String, double> questionWeights;
  final bool isActive;
  final int questionsPerStudent;

  const Exam({
    required this.id,
    required this.title,
    required this.specialty,
    required this.date,
    required this.duration,
    required this.createdBy,
    required this.createdAt,
    required this.questionIds,
    required this.questionWeights,
    required this.isActive,
    required this.questionsPerStudent,
  });

  factory Exam.fromJson(String id, Map<String, dynamic> json) {
    Map<String, double> weights = {};
    if (json['questionWeights'] != null) {
      weights = Map<String, double>.from(json['questionWeights']);
    }

    var qids = json['questionIds'] as List;
    List<String> questionIds = qids.map((item) => item.toString()).toList();

    return Exam(
      id: id,
      title: json['title'],
      specialty: json['specialty'],
      date: (json['date'] as Timestamp).toDate(),
      duration: json['duration'],
      createdBy: json['createdBy'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      questionIds: questionIds,
      questionWeights: weights,
      isActive: json['isActive'] ?? false,
      questionsPerStudent: json['questionsPerStudent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'specialty': specialty,
      'date': date,
      'duration': duration,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'questionIds': questionIds,
      'questionWeights': questionWeights,
      'isActive': isActive,
      'questionsPerStudent': questionsPerStudent,
    };
  }
}
