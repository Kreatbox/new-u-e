import 'package:cloud_firestore/cloud_firestore.dart';

class TopStudent {
  final String studentId;
  final double averageScore;
  final DateTime? updatedAt;

  const TopStudent({
    required this.studentId,
    required this.averageScore,
    this.updatedAt,
  });

  factory TopStudent.fromJson(Map<String, dynamic> json) {
    DateTime? updatedAt;
    final updatedAtJson = json['updatedAt'];

    if (updatedAtJson != null) {
      if (updatedAtJson is String) {
        updatedAt = DateTime.tryParse(updatedAtJson);
      } else if (updatedAtJson is Timestamp) {
        updatedAt = updatedAtJson.toDate();
      }
    }
    return TopStudent(
      studentId: json['studentId'],
      averageScore: json['averageScore'].toDouble(),
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'averageScore': averageScore,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
