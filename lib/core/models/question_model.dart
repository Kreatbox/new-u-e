import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String id;
  final String text;
  final String specialty;
  final String createdBy;
  final DateTime createdAt;
  final String type; // MCQ / true_false
  final List<String> options;
  final String correctAnswer;
  final bool disabled;
  final String? imageBase64;

  const Question({
    required this.id,
    required this.text,
    required this.specialty,
    required this.createdBy,
    required this.createdAt,
    required this.type,
    required this.options,
    required this.correctAnswer,
    required this.disabled,
    this.imageBase64,
  });

  factory Question.fromJson(String id, Map<String, dynamic> json) {
    return Question(
      id: id,
      text: json['text'] ?? '',
      specialty: json['specialty'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      type: json['type'] ?? 'MCQ',
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      disabled: json['disabled'] ?? false,
      imageBase64: json['imageBase64'] ?? null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'specialty': specialty,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
      'disabled': disabled,
      'imageBase64': imageBase64 ?? FieldValue.delete(),
    };
  }
}
