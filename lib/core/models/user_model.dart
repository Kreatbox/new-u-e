import 'exam_model.dart';

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String motherName;
  final String dateOfBirth;
  final String email;
  final String role;
  final String profileImage;
  final String? specialty;
  final List<Exam> exams;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fatherName,
    required this.motherName,
    required this.dateOfBirth,
    required this.email,
    required this.role,
    required this.profileImage,
    this.specialty,
    this.exams = const [],
  });

  Map<String, String> get userDetails {
    return {
      "الاسم الأول": firstName,
      "الاسم الأخير": lastName,
      "اسم الأب": fatherName,
      "اسم الأم": motherName,
      "تاريخ الميلاد": dateOfBirth,
      "البريد الإلكتروني": email,
      "الدور": role,
      "الاختصاص": specialty ?? "",
      "profileImage": profileImage,
    };
  }
}
