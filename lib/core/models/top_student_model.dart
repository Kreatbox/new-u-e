import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_exam/core/models/user_info_model.dart';

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
    return TopStudent(
      studentId: json['studentId'],
      averageScore: json['averageScore'].toDouble(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'averageScore': averageScore,
      'updatedAt': updatedAt,
    };
  }

  Future<UserInfo> loadUserInfo() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
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
        fullName: "${data['firstName']} ${data['lastName']}",
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
