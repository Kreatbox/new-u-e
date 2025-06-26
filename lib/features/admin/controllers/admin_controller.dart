// core/features/admin/controllers/admin_controller.dart

import '../admin_service.dart';

class AdminController {
  final AdminService _service = AdminService();

  Future<List<Map<String, dynamic>>> fetchLogs() => _service.getLogs();

  Future<List<Map<String, dynamic>>> fetchUnverifiedStudents() =>
      _service.getUnverifiedStudents();

  Future<List<Map<String, dynamic>>> fetchUnverifiedTeachers() =>
      _service.getUnverifiedTeachers();

  Future<void> verifyUser(String collection, String id) =>
      _service.verifyUser(collection, id);

  Future<void> deleteUser(String collection, String id) =>
      _service.deleteUser(collection, id);

  Future<List<Map<String, dynamic>>> fetchStudentGrades() =>
      _service.getStudentGrades();

  Future<List<Map<String, dynamic>>> fetchAllUsers() => _service.getAllUsers();

  Future<List<Map<String, dynamic>>> fetchExams() => _service.getExams();

  Future<void> createExam({
    required String subject,
    required String examType,
    required DateTime startTime,
    required int numberOfQuestions,
    required int examDuration,
  }) =>
      _service.createExam(
        subject: subject,
        examType: examType,
        startTime: startTime,
        numberOfQuestions: numberOfQuestions,
        examDuration: examDuration,
      );

  Future<void> approveExam(String examId) => _service.approveExam(examId);

  Future<void> editExamDate(String examId, DateTime newDateTime) =>
      _service.editExamDate(examId, newDateTime);
}
