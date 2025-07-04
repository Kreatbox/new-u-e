import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_exam/core/models/exam_model.dart';
import 'package:universal_exam/core/models/question_model.dart';
import 'package:universal_exam/features/exam/exam_service.dart';
import 'package:universal_exam/shared/theme/colors.dart';
import 'package:universal_exam/shared/theme/color_animation.dart';
import 'package:universal_exam/shared/widgets/app_bar.dart';
import 'package:universal_exam/shared/widgets/button.dart';
import 'package:universal_exam/shared/widgets/container.dart';
import 'package:universal_exam/shared/widgets/exam_question.dart';

class ExamScreen extends StatefulWidget {
  final String studentUid;
  const ExamScreen({super.key, required this.studentUid});
  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  ColorAnimationService? colorService;
  List<Color> gradientColors = [AppColors.primary, AppColors.secondary];
  List<Question> questions = [];
  Map<String, String> currentAnswers = {};
  int totalTime = 360;
  Duration switchDuration = Duration(seconds: 5);
  int selectedQuestionIndex = 0;
  bool isVerified = false;
  late Exam currentExam;

  @override
  void initState() {
    super.initState();
    verifyAndLoadExam();
  }

  Future<void> verifyAndLoadExam() async {
    try {
      final studentDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.studentUid)
          .get();

      if (!studentDoc.exists) throw Exception("المستخدم غير موجود");

      final userData = studentDoc.data()!;

      if (userData["role"] != "طالب") throw Exception("أنت لست طالبًا");
      if (!userData["verified"]) throw Exception("لم يتم التحقق من حسابك");

      final studentSpecialty = userData["specialty"];
      if (studentSpecialty == null || studentSpecialty.isEmpty) {
        throw Exception("لا يوجد تخصص مسجل لك");
      }

      final exam =
          await ExamService().getActiveExamBySpecialtyAndTime(studentSpecialty);

      if (exam == null) throw Exception("لا يوجد امتحان نشط الآن");

      setState(() {
        currentExam = exam;
        totalTime = exam.duration * 60;
        switchDuration = Duration(seconds: (totalTime ~/ 40));
      });

      final secureQuestions =
          await ExamService().getSecureExamQuestions(currentExam.id);

      if (secureQuestions.isEmpty) {
        throw Exception("لا توجد أسئلة في هذا الامتحان");
      }
      questions = List<Question>.from(secureQuestions)..shuffle(Random());
      currentAnswers = await ExamService().loadSavedAnswers(currentExam.id);
      setState(() {
        isVerified = true;
      });

      colorService = ColorAnimationService();
      colorService!.startColorAnimation((colors, begin, end) {
        setState(() {
          gradientColors = colors;
        });
      }, switchDuration: switchDuration);
    } catch (e) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("خطأ"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text("حسنًا"),
            )
          ],
        ),
      );
    }
  }

  void selectQuestion(int index) {
    setState(() {
      selectedQuestionIndex = index;
    });
  }

  void saveAnswer(String questionId, String answer) {
    currentAnswers[questionId] = answer;
    ExamService().autoSaveAnswers(
      examId: currentExam.id,
      answers: currentAnswers,
    );
  }

  @override
  void dispose() {
    colorService?.stopColorAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const Center(child: CircularProgressIndicator());
    final question = questions[selectedQuestionIndex];
    return Scaffold(
      appBar: CustomAppBar(
        title: 'الامتحان',
        gradientColors: gradientColors,
      ),
      body: CustomContainer(
        duration: const Duration(seconds: 5),
        gradientColors: gradientColors,
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final answered =
                      currentAnswers.containsKey(questions[index].id);
                  final selected = index == selectedQuestionIndex;
                  return Column(
                    children: [
                      CustomButton(
                        gradientColors: answered
                            ? [
                                gradientColors[1],
                                gradientColors[0],
                                gradientColors[0],
                                gradientColors[1]
                              ]
                            : selected
                                ? [
                                    Colors.white,
                                    gradientColors[1],
                                    gradientColors[1],
                                    Colors.white
                                  ]
                                : gradientColors,
                        onPressed: () => selectQuestion(index),
                        text: "السؤال ${index + 1}",
                      ),
                      const SizedBox(height: 2),
                    ],
                  );
                },
              ),
            ),
            Flexible(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: CustomContainer(
                  duration: const Duration(seconds: 5),
                  gradientColors: gradientColors,
                  child: ExamQuestion(
                    gradientColors: gradientColors,
                    questionText: question.text,
                    imageBase64: question.imageBase64,
                    type: question.type,
                    options: question.options,
                    isAnswered: currentAnswers.containsKey(question.id),
                    currentAnswers: currentAnswers,
                    questionId: question.id,
                    onOptionSelected: saveAnswer,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
