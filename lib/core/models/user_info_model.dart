import 'package:universal_exam/core/models/top_student_model.dart';
import 'package:universal_exam/core/models/top_teacher_model.dart';

class UserInfo {
  final String fullName;
  final String specialty;
  final String profileImage;

  const UserInfo({
    required this.fullName,
    required this.specialty,
    required this.profileImage,
  });
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      fullName: json['fullName'] ?? '',
      specialty: json['specialty'] ?? '',
      profileImage: json['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'specialty': specialty,
      'profileImage': profileImage,
    };
  }
}

class LeaderWithInfo {
  final dynamic leader;
  final UserInfo userInfo;

  const LeaderWithInfo({
    required this.leader,
    required this.userInfo,
  });

  factory LeaderWithInfo.fromJson(Map<String, dynamic> json) {
    final leaderJson = json['leader'] as Map<String, dynamic>;
    final String? studentId = leaderJson['studentId'];
    final String? teacherId = leaderJson['teacherId'];

    final LeaderWithInfo result;

    if (studentId != null) {
      result = LeaderWithInfo(
        leader: TopStudent.fromJson(leaderJson),
        userInfo: UserInfo.fromJson(json['userInfo']),
      );
    } else if (teacherId != null) {
      result = LeaderWithInfo(
        leader: TopTeacher.fromJson(leaderJson),
        userInfo: UserInfo.fromJson(json['userInfo']),
      );
    } else {
      throw Exception("Unknown leader type");
    }

    return result;
  }

  Map<String, dynamic> toJson() {
    return {
      'leader': leader.toJson(),
      'userInfo': userInfo.toJson(),
    };
  }
}
