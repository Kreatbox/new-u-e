import 'package:cloud_firestore/cloud_firestore.dart';

class TopTeacher {
  final String teacherId;
  final double avgStudentScore;
  final int totalQuestions;
  final DateTime? updatedAt;

  const TopTeacher({
    required this.teacherId,
    required this.avgStudentScore,
    required this.totalQuestions,
    this.updatedAt,
  });

  factory TopTeacher.fromJson(Map<String, dynamic> json) {
    DateTime? updatedAt;
    final updatedAtJson = json['updatedAt'];

    if (updatedAtJson != null) {
      if (updatedAtJson is String) {
        updatedAt = DateTime.tryParse(updatedAtJson);
      } else if (updatedAtJson is Timestamp) {
        updatedAt = updatedAtJson.toDate();
      }
    }
    return TopTeacher(
      teacherId: json['teacherId'],
      avgStudentScore: json['avgStudentScore'].toDouble(),
      totalQuestions: json['totalQuestions'],
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'avgStudentScore': avgStudentScore,
      'totalQuestions': totalQuestions,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
