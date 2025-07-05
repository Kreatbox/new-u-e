import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/providers/app_provider.dart';
import '../../../core/models/exam_model.dart';
import '../../../core/models/exam_attempt_model.dart';
import 'package:universal_exam/shared/widgets/container.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/list_item.dart';

class ExamsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final bool isStudent;

  const ExamsScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.isStudent,
  });

  @override
  _ExamsScreenState createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  List<Exam> exams = [];
  List<ExamAttempt> attempts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExamData();
  }

  Future<void> _loadExamData() async {
    try {
      final user = Provider.of<AppProvider>(context, listen: false).user;
      if (user == null) return;

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      if (widget.isStudent) {
        await _loadStudentExamData(user.specialty, currentUser.uid);
      } else {
        await _loadTeacherExamData(currentUser.uid);
      }
    } catch (e) {
      print('Error loading exam data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _loadStudentExamData(String specialty, String studentId) async {
    // Load exams for student's specialty
    final examsSnapshot = await FirebaseFirestore.instance
        .collection('exams')
        .where('specialty', isEqualTo: specialty)
        .get();

    final List<Exam> loadedExams = [];
    for (var doc in examsSnapshot.docs) {
      loadedExams.add(Exam.fromJson(doc.id, doc.data()));
    }

    // Load student's attempts
    final attemptsSnapshot = await FirebaseFirestore.instance
        .collection('examAttempts')
        .where('studentId', isEqualTo: studentId)
        .get();

    final List<ExamAttempt> loadedAttempts = [];
    for (var doc in attemptsSnapshot.docs) {
      loadedAttempts.add(ExamAttempt.fromJson(doc.id, doc.data()));
    }

    if (mounted) {
      setState(() {
        exams = loadedExams;
        attempts = loadedAttempts;
      });
    }
  }

  Future<void> _loadTeacherExamData(String teacherId) async {
    // Load questions created by teacher
    final questionsSnapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where('createdBy', isEqualTo: teacherId)
        .get();

    final questionIds = questionsSnapshot.docs.map((doc) => doc.id).toList();

    // Load exams that contain teacher's questions
    final examsSnapshot =
        await FirebaseFirestore.instance.collection('exams').get();

    final List<Exam> teacherExams = [];
    for (var doc in examsSnapshot.docs) {
      final exam = Exam.fromJson(doc.id, doc.data());
      if (exam.questionIds.any((qid) => questionIds.contains(qid))) {
        teacherExams.add(exam);
      }
    }

    if (mounted) {
      setState(() {
        exams = teacherExams;
      });
    }
  }

  ExamAttempt? _getAttemptForExam(String examId) {
    return attempts.where((attempt) => attempt.examId == examId).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (widget.isStudent) {
      return _buildStudentExams();
    } else {
      return _buildTeacherExams();
    }
  }

  Widget _buildStudentExams() {
    final now = DateTime.now();
    final upcomingExams = <Exam>[];
    final pastExams = <Exam>[];

    for (var exam in exams) {
      if (now.isBefore(exam.date)) {
        upcomingExams.add(exam);
      } else {
        pastExams.add(exam);
      }
    }

    return CustomContainer(
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
      ),
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      child: ListView(
        children: [
          Text(
            "الامتحانات",
            style: TextStyle(
              fontSize: 32,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (upcomingExams.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _sectionTitle("الامتحانات القادمة"),
                  const SizedBox(height: 10),
                  ...upcomingExams.map((exam) {
                    return CustomListItem(
                      title: exam.title,
                      additionalTitles: ['التاريخ', 'الوقت', 'المدة'],
                      additionalDescriptions: [
                        exam.date.toString().substring(0, 16),
                        exam.date.toString().substring(11, 16),
                        '${exam.duration} دقيقة'
                      ],
                      gradientColors: widget.gradientColors,
                      begin: widget.begin,
                      end: widget.end,
                      trailingIcon: Icon(
                        Icons.event_available,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
          if (pastExams.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _sectionTitle("الامتحانات السابقة"),
                  const SizedBox(height: 10),
                  ...pastExams.map((exam) {
                    final attempt = _getAttemptForExam(exam.id);
                    final score = attempt?.score ?? 0.0;
                    final status = attempt != null ? 'مكتمل' : 'لم يشارك';

                    return CustomListItem(
                      title: exam.title,
                      additionalTitles: ['التاريخ', 'الدرجة', 'الحالة'],
                      additionalDescriptions: [
                        exam.date.toString().substring(0, 16),
                        attempt != null
                            ? '${score.toStringAsFixed(1)}/20'
                            : '-',
                        status
                      ],
                      gradientColors: widget.gradientColors,
                      begin: widget.begin,
                      end: widget.end,
                      trailingIcon: Icon(
                        attempt != null ? Icons.check_circle : Icons.cancel,
                        color: attempt != null ? Colors.green : Colors.red,
                        size: 18,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
          if (exams.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  "لا توجد امتحانات متاحة",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTeacherExams() {
    final now = DateTime.now();
    final activeExams = <Exam>[];
    final pendingExams = <Exam>[];

    for (var exam in exams) {
      final examEndTime = exam.date.add(Duration(minutes: exam.duration));
      if (exam.isActive && now.isBefore(examEndTime)) {
        activeExams.add(exam);
      } else if (!exam.isActive) {
        pendingExams.add(exam);
      }
    }

    // Calculate teacher stats
    int totalQuestions = 0;
    double avgSuccessRate = 0.0;
    int activeExamCount = activeExams.length;

    for (var exam in exams) {
      totalQuestions += exam.questionIds.length;
    }

    final examStats = <Map<String, dynamic>>[
      {
        'title': 'إجمالي الأسئلة',
        'value': totalQuestions.toString(),
        'icon': Icons.question_answer,
      },
      {
        'title': 'متوسط النجاح',
        'value': '${avgSuccessRate.toStringAsFixed(1)}%',
        'icon': Icons.trending_up,
      },
      {
        'title': 'الامتحانات النشطة',
        'value': activeExamCount.toString(),
        'icon': Icons.assignment,
      },
    ];

    return CustomContainer(
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
      ),
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      child: ListView(
        children: [
          Text(
            "إدارة الامتحانات",
            style: TextStyle(
              fontSize: 32,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Stats Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                _sectionTitle("إحصائيات الامتحانات"),
                const SizedBox(height: 10),
                ...examStats.map((stat) {
                  return CustomListItem(
                    title: stat['title']!,
                    additionalTitles: ['القيمة'],
                    additionalDescriptions: [stat['value']!],
                    gradientColors: widget.gradientColors,
                    begin: widget.begin,
                    end: widget.end,
                    trailingIcon: Icon(
                      stat['icon'] as IconData,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Active Exams Section
          if (activeExams.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _sectionTitle("الامتحانات النشطة"),
                  const SizedBox(height: 10),
                  ...activeExams.map((exam) {
                    return CustomListItem(
                      title: exam.title,
                      additionalTitles: ['التاريخ', 'الحالة', 'الأسئلة'],
                      additionalDescriptions: [
                        exam.date.toString().substring(0, 16),
                        'نشط',
                        '${exam.questionIds.length}'
                      ],
                      gradientColors: widget.gradientColors,
                      begin: widget.begin,
                      end: widget.end,
                      trailingIcon: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],

          // Pending Exams Section
          if (pendingExams.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _sectionTitle("الامتحانات في الانتظار"),
                  const SizedBox(height: 10),
                  ...pendingExams.map((exam) {
                    return CustomListItem(
                      title: exam.title,
                      additionalTitles: ['التاريخ', 'الحالة', 'الأسئلة'],
                      additionalDescriptions: [
                        exam.date.toString().substring(0, 16),
                        'في الانتظار',
                        '${exam.questionIds.length}'
                      ],
                      gradientColors: widget.gradientColors,
                      begin: widget.begin,
                      end: widget.end,
                      trailingIcon: Icon(
                        Icons.schedule,
                        color: Colors.orange,
                        size: 18,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],

          if (exams.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  "لا توجد امتحانات",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        color: AppColors.primary,
      ),
      textAlign: TextAlign.center,
    );
  }
}
