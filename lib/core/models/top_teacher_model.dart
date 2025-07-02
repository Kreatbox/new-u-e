import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_exam/core/models/user_info_model.dart';

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
    return TopTeacher(
      teacherId: json['teacherId'],
      avgStudentScore: json['avgStudentScore'].toDouble(),
      totalQuestions: json['totalQuestions'],
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'avgStudentScore': avgStudentScore,
      'totalQuestions': totalQuestions,
      'updatedAt': updatedAt,
    };
  }

  Future<UserInfo> loadUserInfo() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(teacherId)
          .get();

      if (!snapshot.exists) {
        return UserInfo(
          fullName: "غير معروف",
          specialty: "لا يوجد",
          profileImage: "",
        );
      }

      final data = snapshot.data()!;
      return UserInfo(
        fullName: data['fullName'] ?? "غير معروف",
        specialty: data['specialty'] ?? "لا يوجد",
        profileImage: data['photoBase64'] ?? "",
      );
    } catch (e) {
      return UserInfo(
        fullName: "غير معروف",
        specialty: "خطأ في التحميل",
        profileImage: "",
      );
    }
  }
}
