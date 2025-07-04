import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_exam/core/models/exam_attempt_model.dart';
import 'package:universal_exam/core/models/exam_model.dart';
import 'package:universal_exam/core/models/question_model.dart';
import 'package:universal_exam/features/exam/exam_service.dart';
import 'package:universal_exam/shared/theme/colors.dart';
import 'package:universal_exam/shared/theme/color_animation.dart';
import 'package:universal_exam/shared/widgets/app_bar.dart';
import 'package:universal_exam/shared/widgets/button.dart';
import 'package:universal_exam/shared/widgets/container.dart';
import 'package:universal_exam/shared/widgets/exam_question.dart';
import 'package:universal_exam/features/exam/data/colors.dart';
import 'dart:async';

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
  Map<String, String> confirmedAnswers = {};
  int totalTime = 360;
  Duration switchDuration = Duration(seconds: 5);
  int selectedQuestionIndex = 0;
  bool isVerified = false;
  late Exam currentExam;
  bool isWaitingRoom = false;
  bool isExamFinished = false;
  DateTime? examStartTime;
  DateTime? examEndTime;
  Duration timeLeft = Duration.zero;
  Timer? countdownTimer;
  bool isSubmitted = false;
  ExamAttempt? submittedAttempt;

  @override
  void initState() {
    super.initState();
    checkEligibilityAndLoad();
  }

  Future<void> checkEligibilityAndLoad() async {
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
      final exam = await ExamService().activateExamIfNeeded(studentSpecialty);
      if (exam == null) throw Exception("لا يوجد امتحان نشط الآن");
      final eligible = await ExamService().canStudentEnterExam(
        studentId: widget.studentUid,
        exam: exam,
      );
      if (!eligible) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              title: const Text("غير مسموح بالدخول"),
              content: const Text(
                  "لا يمكنك دخول الامتحان بسبب محاولة سابقة أو رسوب في آخر 6 أشهر."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  child: const Text("العودة للرئيسية"),
                )
              ],
            ),
          );
        }
        return;
      }
      await verifyAndLoadExamWithExam(exam);
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

  Future<void> verifyAndLoadExamWithExam(Exam exam) async {
    try {
      currentExam = exam;
      examStartTime = exam.date;
      examEndTime = exam.date.add(Duration(minutes: exam.duration));
      final now = DateTime.now();
      if (now.isBefore(examStartTime!)) {
        isWaitingRoom = true;
        timeLeft = examStartTime!.difference(now);
        startCountdown();
        setState(() {});
        return;
      } else if (now.isAfter(examEndTime!)) {
        isExamFinished = true;
        setState(() {});
        return;
      }
      totalTime = exam.duration * 60;
      switchDuration = Duration(seconds: (totalTime ~/ colorPalettes.length));
      final secureQuestions =
          await ExamService().getSecureExamQuestions(currentExam.id);
      if (secureQuestions.isEmpty) {
        throw Exception("لا توجد أسئلة في هذا الامتحان");
      }
      questions = List<Question>.from(secureQuestions)..shuffle(Random());
      confirmedAnswers = await ExamService().loadSavedAnswers(currentExam.id);
      isVerified = true;
      colorService = ColorAnimationService();
      colorService!.startColorAnimation((colors, begin, end) {
        updateColorsBasedOnTime();
      }, switchDuration: switchDuration, customColorPalettes: colorPalettes);
      startCountdown();
      setState(() {});
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

  void startCountdown() {
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (examStartTime != null && now.isBefore(examStartTime!)) {
        setState(() {
          timeLeft = examStartTime!.difference(now);
        });
      } else if (examEndTime != null && now.isAfter(examEndTime!)) {
        timer.cancel();
        isWaitingRoom = false;
        isExamFinished = true;
        submitExam();
        setState(() {});
      } else {
        setState(() {
          timeLeft = examEndTime!.difference(now);
        });
      }
    });
  }

  void updateColorsBasedOnTime() {
    if (examEndTime == null || examStartTime == null) return;

    final totalExamDuration = examEndTime!.difference(examStartTime!);
    final remainingTime = examEndTime!.difference(DateTime.now());
    final elapsedRatio =
        1 - (remainingTime.inSeconds / totalExamDuration.inSeconds);

    final colorIndex = (elapsedRatio * (colorPalettes.length - 1))
        .clamp(0, colorPalettes.length - 1)
        .round();
    setState(() {
      gradientColors = colorPalettes[colorIndex];
    });
  }

  void selectQuestion(int index) {
    setState(() {
      selectedQuestionIndex = index;
    });
  }

  void saveAnswer(String questionId, String answer) {
    confirmedAnswers[questionId] = answer;
    ExamService().autoSaveAnswers(
      examId: currentExam.id,
      answers: confirmedAnswers,
    );
    setState(() {});
  }

  void submitExam() async {
    if (isSubmitted) return;
    isSubmitted = true;
    submittedAttempt = await ExamService().submitAndGradeAttempt(
      exam: currentExam,
      studentId: widget.studentUid,
      answers: confirmedAnswers,
    );
    setState(() {});
  }

  @override
  void dispose() {
    colorService?.stopColorAnimation();
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isExamFinished && isSubmitted && submittedAttempt != null) {
      return Scaffold(
        appBar: CustomAppBar(title: 'الامتحان', gradientColors: gradientColors),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('تم تسليم الامتحان!'),
              const SizedBox(height: 16),
              Text(
                  'علامتك: ${submittedAttempt!.score.toStringAsFixed(2)} من 20'),
            ],
          ),
        ),
      );
    }
    if (isExamFinished) {
      submitExam();
      return Scaffold(
        appBar: CustomAppBar(title: 'الامتحان', gradientColors: gradientColors),
        body: Center(child: Text('انتهى وقت الامتحان.')),
      );
    }
    if (isWaitingRoom) {
      return Scaffold(
        appBar: CustomAppBar(title: 'الامتحان', gradientColors: gradientColors),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('يرجى الانتظار حتى بدء الامتحان...'),
              const SizedBox(height: 16),
              Text(
                  'الوقت المتبقي: ${timeLeft.inMinutes}:${(timeLeft.inSeconds % 60).toString().padLeft(2, '0')}'),
            ],
          ),
        ),
      );
    }
    if (!isVerified || questions.isEmpty)
      return const Center(child: CircularProgressIndicator());

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
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 1,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final answered =
                          confirmedAnswers.containsKey(questions[index].id);
                      final selected = index == selectedQuestionIndex;
                      return Column(
                        children: [
                          CustomButton(
                            gradientColors: answered
                                ? [Colors.green, Colors.greenAccent]
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
                        isAnswered: confirmedAnswers.containsKey(question.id),
                        currentAnswers: confirmedAnswers,
                        questionId: question.id,
                        onOptionSelected: saveAnswer,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isSubmitted)
              CustomButton(
                text: 'تسليم الامتحان',
                onPressed: submitExam,
                gradientColors: [Colors.green, Colors.blue],
              ),
          ],
        ),
      ),
    );
  }
}
