import 'package:cloud_firestore/cloud_firestore.dart';

class Exam {
  final String id;
  final String title;
  final String specialty;
  final DateTime date;
  final int duration;
  final DateTime createdAt;
  final List<String> questionIds;
  final bool isActive;
  final int questionsPerStudent;

  const Exam({
    required this.id,
    required this.title,
    required this.specialty,
    required this.date,
    required this.duration,
    required this.createdAt,
    required this.questionIds,
    required this.isActive,
    required this.questionsPerStudent,
  });

  factory Exam.fromJson(String id, Map<String, dynamic> json) {
    List<String> questionIds = [];
    if (json['questionIds'] != null && json['questionIds'] is List) {
      questionIds =
          (json['questionIds'] as List).map((item) => item.toString()).toList();
    }

    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Exam(
      id: id,
      title: json['title'] ?? '',
      specialty: json['specialty'] ?? '',
      date: parseDate(json['date']),
      duration: json['duration'] ?? 0,
      createdAt: parseDate(json['createdAt']),
      questionIds: questionIds,
      isActive: json['isActive'] ?? false,
      questionsPerStudent: json['questionsPerStudent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'specialty': specialty,
      'date': Timestamp.fromDate(date),
      'duration': duration,
      'createdAt': Timestamp.fromDate(createdAt),
      'questionIds': questionIds,
      'isActive': isActive,
      'questionsPerStudent': questionsPerStudent,
    };
  }
}
