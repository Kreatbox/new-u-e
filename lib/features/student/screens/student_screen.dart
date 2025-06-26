import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/theme/color_animation.dart';
import 'personal_info_screen.dart';
import 'settings_screen.dart';
import 'exams_screen.dart';
import 'results_screen.dart';
import 'notifications_screen.dart';
import 'help_support_screen.dart';

enum StudentTask {
  personalInfo,
  settings,
  exams,
  results,
  notifications,
  support,
}

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  late ColorAnimationService colorService;
  StudentTask selectedTask = StudentTask.personalInfo;

  @override
  void initState() {
    super.initState();
    colorService = ColorAnimationService();
    colorService.startColorAnimation(_updateColors);
  }

  void _updateColors(
      List<Color> newGradientColors, Alignment newBegin, Alignment newEnd) {
    setState(() {
      gradientColors = newGradientColors;
      begin = newBegin;
      end = newEnd;
    });
  }

  @override
  void dispose() {
    colorService.stopColorAnimation();
    super.dispose();
  }

  List<Color> gradientColors = [
    AppColors.lightSecondary,
    AppColors.primary,
  ];

  Alignment begin = Alignment.topLeft;
  Alignment end = Alignment.bottomRight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صفحة الطالب'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: begin,
              end: end,
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
                children: StudentTask.values.map((task) {
                  return Column(
                    children: [
                      CustomButton(
                        gradientColors: gradientColors,
                        onPressed: () {
                          setState(() {
                            selectedTask = task;
                          });
                        },
                        text: _taskTitle(task),
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
                child:
                    studentScreens[selectedTask]!(gradientColors, begin, end),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _taskTitle(StudentTask task) {
    switch (task) {
      case StudentTask.personalInfo:
        return "البيانات الشخصية";
      case StudentTask.settings:
        return "الإعدادات الشخصية";
      case StudentTask.exams:
        return "الامتحانات";
      case StudentTask.results:
        return "النتائج";
      case StudentTask.notifications:
        return "الإشعارات والتنبيهات";
      case StudentTask.support:
        return "المساعدة والدعم";
    }
  }

  final Map<StudentTask, Widget Function(List<Color>, Alignment, Alignment)>
      studentScreens = {
    StudentTask.personalInfo: (gradientColors, begin, end) =>
        PersonalInfoScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
        ),
    StudentTask.settings: (gradientColors, begin, end) => SettingsScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
        ),
    StudentTask.exams: (gradientColors, begin, end) => ExamsScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
        ),
    StudentTask.results: (gradientColors, begin, end) => ResultsScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
        ),
    StudentTask.notifications: (gradientColors, begin, end) =>
        NotificationsScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
        ),
    StudentTask.support: (gradientColors, begin, end) => HelpSupportScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
        ),
  };
}
