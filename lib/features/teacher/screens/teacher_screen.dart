import 'package:flutter/material.dart';
import 'package:universal_exam/features/teacher/screens/manage_question_screen.dart';
import 'package:universal_exam/features/teacher/screens/stats_screen.dart';
import '../../../shared/theme/color_animation.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import '../controllers/teacher_controller.dart';
import 'create_question_screen.dart';

enum TeacherTask {
  createQuestion,
  manageQuestions,
  viewStatistics,
}

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  List<Color> gradientColors = [AppColors.primary, AppColors.secondary];
  Alignment begin = Alignment.topLeft;
  Alignment end = Alignment.bottomRight;

  late ColorAnimationService colorAnimationService;
  late final TeacherController teacherController;
  TeacherTask? selectedTask;

  @override
  void initState() {
    super.initState();
    teacherController = TeacherController();
    selectedTask = TeacherTask.createQuestion;

    colorAnimationService = ColorAnimationService();
    colorAnimationService.startColorAnimation((colors, newBegin, newEnd) {
      setState(() {
        gradientColors = colors;
        begin = newBegin;
        end = newEnd;
      });
    });
  }

  @override
  void dispose() {
    colorAnimationService.stopColorAnimation();
    teacherController.dispose();
    super.dispose();
  }

  final Map<
      TeacherTask,
      Widget Function(
        List<Color>,
        Alignment,
        Alignment,
        TeacherController,
      )> teacherScreens = {
    TeacherTask.createQuestion: (colors, begin, end, controller) =>
        CreateQuestionScreen(
          gradientColors: colors,
          begin: begin,
          end: end,
          controller: controller,
        ),
    TeacherTask.manageQuestions: (colors, begin, end, controller) =>
        ManageQuestionsScreen(
          gradientColors: colors,
          begin: begin,
          end: end,
          controller: controller,
        ),
    TeacherTask.viewStatistics: (colors, begin, end, controller) => StatsScreen(
        gradientColors: colors, begin: begin, end: end, controller: controller),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('صفحة المدرس'),
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
                children: TeacherTask.values.map((task) {
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
                child:
                    selectedTask != null && teacherScreens[selectedTask] != null
                        ? teacherScreens[selectedTask]!(
                            gradientColors, begin, end, teacherController)
                        : const Center(
                            child: Text(
                              "اختر مهمة لعرضها",
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

  String _getTaskTitle(TeacherTask task) {
    switch (task) {
      case TeacherTask.createQuestion:
        return "إنشاء سؤال جديد";
      case TeacherTask.manageQuestions:
        return "إدارة الأسئلة";
      case TeacherTask.viewStatistics:
        return "عرض الإحصائيات";
    }
  }
}
