import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../shared/theme/colors.dart';
import '../../shared/widgets/button.dart';
import '../../shared/widgets/container.dart';
import '../../shared/theme/color_animation.dart';
import 'screens/personal_info_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/exams_screen.dart';
import 'screens/results_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/help_support_screen.dart';

enum UserTask {
  personalInfo,
  settings,
  exams,
  results,
  notifications,
  support,
}

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late ColorAnimationService colorService;
  UserTask selectedTask = UserTask.personalInfo;

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
    final user = Provider.of<UserProvider>(context).user;
    final isStudent = user?.role == 'طالب';

    final availableTasks = UserTask.values.where((task) {
      if (task == UserTask.exams) return true;
      if (task == UserTask.results && isStudent) return true;
      if (task == UserTask.personalInfo ||
          task == UserTask.settings ||
          task == UserTask.notifications ||
          task == UserTask.support) return true;
      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isStudent ? 'صفحة الطالب' : 'صفحة الأستاذ'),
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
                children: availableTasks.map((task) {
                  return Column(
                    children: [
                      CustomButton(
                        gradientColors: gradientColors,
                        onPressed: () {
                          setState(() {
                            selectedTask = task;
                          });
                        },
                        text: _taskTitle(task, isStudent),
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
                child: userScreens[selectedTask]!(
                    gradientColors, begin, end, isStudent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _taskTitle(UserTask task, bool isStudent) {
    switch (task) {
      case UserTask.personalInfo:
        return "البيانات الشخصية";
      case UserTask.settings:
        return "الإعدادات الشخصية";
      case UserTask.exams:
        return isStudent ? "الامتحانات" : "إدارة الامتحانات";
      case UserTask.results:
        return "النتائج";
      case UserTask.notifications:
        return "الإشعارات والتنبيهات";
      case UserTask.support:
        return "المساعدة والدعم";
    }
  }

  final Map<UserTask, Widget Function(List<Color>, Alignment, Alignment, bool)>
      userScreens = {
    UserTask.personalInfo: (gradientColors, begin, end, isStudent) =>
        PersonalInfoScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
        ),
    UserTask.settings: (gradientColors, begin, end, isStudent) =>
        SettingsScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
        ),
    UserTask.exams: (gradientColors, begin, end, isStudent) => ExamsScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
          isStudent: isStudent,
        ),
    UserTask.results: (gradientColors, begin, end, isStudent) => ResultsScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
          isStudent: isStudent,
        ),
    UserTask.notifications: (gradientColors, begin, end, isStudent) =>
        NotificationsScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
        ),
    UserTask.support: (gradientColors, begin, end, isStudent) =>
        HelpSupportScreen(
          gradientColors: gradientColors,
          begin: begin,
          end: end,
        ),
  };
}
