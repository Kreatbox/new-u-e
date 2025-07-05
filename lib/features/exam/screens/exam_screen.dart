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
  int currentColorIndex = 0;

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
      if (!mounted) return;
      if (!studentDoc.exists) throw Exception("المستخدم غير موجود");
      final userData = studentDoc.data()!;
      if (userData["role"] != "طالب") throw Exception("أنت لست طالبًا");
      if (!userData["verified"]) throw Exception("لم يتم التحقق من حسابك");
      final studentSpecialty = userData["specialty"];
      if (studentSpecialty == null || studentSpecialty.isEmpty) {
        throw Exception("لا يوجد تخصص مسجل لك");
      }
      final exam = await ExamService().activateExamIfNeeded(studentSpecialty);
      if (!mounted) return;
      if (exam == null) throw Exception("لا يوجد امتحان نشط الآن");
      final eligible = await ExamService().canStudentEnterExam(
        studentId: widget.studentUid,
        exam: exam,
      );
      if (!mounted) return;
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
      if (!mounted) return;
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
        if (mounted) setState(() {});
        return;
      } else if (now.isAfter(examEndTime!)) {
        isExamFinished = true;
        if (mounted) setState(() {});
        return;
      }
      totalTime = exam.duration * 60;
      final secureQuestions =
          await ExamService().getSecureExamQuestions(currentExam.id);
      if (!mounted) return;
      if (secureQuestions.isEmpty) {
        throw Exception("لا توجد أسئلة في هذا الامتحان");
      }
      questions = List<Question>.from(secureQuestions)..shuffle(Random());
      confirmedAnswers = await ExamService().loadSavedAnswers(currentExam.id);
      isVerified = true;
      _updateColorsBasedOnTime();
      startCountdown();
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
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
      if (!mounted) {
        timer.cancel();
        return;
      }
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
        if (mounted) setState(() {});
      } else {
        setState(() {
          timeLeft = examEndTime!.difference(now);
        });
        _updateColorsBasedOnTime();
      }
    });
  }

  void _updateColorsBasedOnTime() {
    if (!mounted || examEndTime == null || examStartTime == null) return;
    
    final totalExamDuration = examEndTime!.difference(examStartTime!);
    final remainingTime = examEndTime!.difference(DateTime.now());
    final elapsedRatio = 1 - (remainingTime.inSeconds / totalExamDuration.inSeconds);
    
    final newColorIndex = (elapsedRatio * (colorPalettes.length - 1))
        .clamp(0, colorPalettes.length - 1)
        .round();
    
    if (newColorIndex != currentColorIndex) {
      setState(() {
        currentColorIndex = newColorIndex;
        gradientColors = colorPalettes[currentColorIndex];
      });
    }
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
    if (mounted) setState(() {});
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'السؤال ${selectedQuestionIndex + 1} من ${questions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (selectedQuestionIndex + 1) / questions.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(gradientColors[1]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final answered = confirmedAnswers.containsKey(questions[index].id);
                  final selected = index == selectedQuestionIndex;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => selectQuestion(index),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: answered
                              ? Colors.green
                              : selected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? gradientColors[1] : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: gradientColors[1].withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: answered || selected ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: CustomContainer(
                  duration: const Duration(seconds: 5),
                  gradientColors: gradientColors,
                  child: ExamQuestion(
                    currentColorIndex: currentColorIndex,
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
            const SizedBox(height: 16),
            Row(
              children: [
                if (selectedQuestionIndex > 0)
                  Expanded(
                    child: CustomButton(
                      text: 'السابق',
                      onPressed: () => selectQuestion(selectedQuestionIndex - 1),
                      gradientColors: [Colors.grey, Colors.grey.shade600],
                    ),
                  ),
                if (selectedQuestionIndex > 0) const SizedBox(width: 8),
                if (selectedQuestionIndex < questions.length - 1)
                  Expanded(
                    child: CustomButton(
                      text: 'التالي',
                      onPressed: () => selectQuestion(selectedQuestionIndex + 1),
                      gradientColors: gradientColors,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
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
