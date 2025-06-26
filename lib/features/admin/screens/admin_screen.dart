import 'package:flutter/material.dart';
import '../../../shared/theme/color_animation.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import 'logs_screen.dart';
import 'manage_users_screen.dart';
import 'system_settings_screen.dart';
import 'verify_teachers_screen.dart';
import 'verify_students_screen.dart';
import 'manage_exams_screen.dart';
import 'view_statistics_screen.dart';
import '../controllers/admin_controller.dart';

enum AdminTask {
  verifyTeachers,
  verifyStudents,
  manageExams,
  viewStatistics,
  manageUsers,
  systemSettings,
  logs,
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<Color> gradientColors = [
    AppColors.primary,
    AppColors.secondary,
  ];
  Alignment begin = Alignment.topLeft;
  Alignment end = Alignment.bottomRight;

  late ColorAnimationService colorAnimationService;
  late final AdminController adminController;

  @override
  void initState() {
    super.initState();
    selectedTask = AdminTask.verifyTeachers;
    adminController = AdminController();

    colorAnimationService = ColorAnimationService();
    colorAnimationService.startColorAnimation(
      (colors, newBegin, newEnd) {
        setState(() {
          gradientColors = colors;
          begin = newBegin;
          end = newEnd;
        });
      },
    );
  }

  @override
  void dispose() {
    colorAnimationService.stopColorAnimation();
    super.dispose();
  }

  final Map<
      AdminTask,
      Widget Function(
        List<Color>,
        Alignment,
        Alignment,
        AdminController,
      )> adminScreens = {
    AdminTask.verifyTeachers: (colors, begin, end, controller) =>
        VerifyTeachersScreen(
          gradientColors: colors,
          begin: begin,
          end: end,
          controller: controller,
        ),
    AdminTask.verifyStudents: (colors, begin, end, controller) =>
        VerifyStudentsScreen(
          gradientColors: colors,
          begin: begin,
          end: end,
          controller: controller,
        ),
    AdminTask.manageExams: (colors, begin, end, controller) =>
        ManageExamsScreen(
          gradientColors: colors,
          begin: begin,
          end: end,
          controller: controller,
        ),
    AdminTask.viewStatistics: (colors, begin, end, controller) =>
        ViewStatisticsScreen(
          gradientColors: colors,
          begin: begin,
          end: end,
        ),
    AdminTask.manageUsers: (colors, begin, end, controller) =>
        UserManagementScreen(
          gradientColors: colors,
          begin: begin,
          end: end,
          controller: controller,
        ),
    AdminTask.systemSettings: (colors, begin, end, controller) =>
        SystemSettingsScreen(
          gradientColors: colors,
          begin: begin,
          end: end,
          controller: controller,
        ),
    AdminTask.logs: (colors, begin, end, controller) => LogsScreen(
          gradientColors: colors,
          begin: begin,
          end: end,
          controller: controller,
        ),
  };

  AdminTask? selectedTask;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صفحة الأدمن'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: CustomContainer(
        gradientColors: gradientColors,
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: ListView(
                children: AdminTask.values.map((task) {
                  return Column(
                    children: [
                      CustomButton(
                        gradientColors: gradientColors,
                        onPressed: () {
                          setState(() {
                            selectedTask = task;
                          });
                        },
                        text: _getTaskTitle(task),
                      ),
                      const SizedBox(height: 2),
                    ],
                  );
                }).toList(),
              ),
            ),
            Flexible(
              flex: 4,
              child: CustomContainer(
                gradientColors: gradientColors,
                height: double.infinity,
                child: selectedTask != null
                    ? adminScreens[selectedTask]!(
                        gradientColors, begin, end, adminController)
                    : const Center(
                        child: Text(
                          "اختر خدمة لعرضها",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTaskTitle(AdminTask task) {
    switch (task) {
      case AdminTask.verifyTeachers:
        return "التحقق من المعلمين";
      case AdminTask.verifyStudents:
        return "التحقق من الطلاب";
      case AdminTask.manageExams:
        return "إدارة الامتحانات";
      case AdminTask.viewStatistics:
        return "عرض الإحصائيات";
      case AdminTask.manageUsers:
        return "إدارة المستخدمين";
      case AdminTask.systemSettings:
        return "إعدادات النظام";
      case AdminTask.logs:
        return "السجلات";
    }
  }
}
