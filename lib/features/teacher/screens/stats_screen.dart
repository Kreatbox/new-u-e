import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_exam/features/teacher/controllers/teacher_controller.dart';
import 'package:universal_exam/shared/widgets/container.dart';
import 'package:universal_exam/shared/widgets/list_item.dart';

class StatsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final TeacherController controller;

  const StatsScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.controller,
  });

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;
  int _totalQuestions = 0;
  int _activeQuestions = 0;
  int _disabledQuestions = 0;
  int _studentsDidExam = 0;
  final List<Map<String, dynamic>> _questionStats = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final String? teacherUid = FirebaseAuth.instance.currentUser?.uid;
    if (teacherUid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where('createdBy', isEqualTo: teacherUid)
        .get();

    setState(() {
      _totalQuestions = snapshot.size;
      _activeQuestions =
          snapshot.docs.where((doc) => doc.data()['disabled'] != true).length;
      _disabledQuestions =
          snapshot.docs.where((doc) => doc.data()['disabled'] == true).length;
    });
    if (_disabledQuestions == 0) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final attemptsSnapshot = await FirebaseFirestore.instance
        .collection('examAttempts')
        .where('studentId', isNotEqualTo: '')
        .get();

    setState(() {
      _studentsDidExam = attemptsSnapshot.docs.length;
    });
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final questionId = doc.id;

      if (data['disabled'] != true) continue;
      int correctAnswered = 0;

      final totalAnswered = await FirebaseFirestore.instance
          .collection('examAttempts')
          .where('answers', arrayContains: questionId)
          .get()
          .then((snap) => snap.size);

      final correctSnapshot = await FirebaseFirestore.instance
          .collection('examAttempts')
          .where('correctAnswers', isEqualTo: questionId)
          .get();

      correctAnswered = correctSnapshot.docs.length;

      final double correctRate =
          totalAnswered > 0 ? (correctAnswered / totalAnswered) * 100 : 0.0;

      String difficultyLabel = 'صعبة';
      if (correctRate >= 50 && correctRate <= 70) {
        difficultyLabel = 'عادية';
      } else if (correctRate > 70) {
        difficultyLabel = 'سهلة';
      }

      _questionStats.add({
        'questionText': data['text'],
        'totalAnswered': totalAnswered,
        'correctAnswered': correctAnswered,
        'correctRate': correctRate,
        'difficulty': difficultyLabel,
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildStatCard(String label, String value) {
    return CustomListItem(
      title: label,
      description: value,
      begin: widget.begin,
      end: widget.end,
      gradientColors: widget.gradientColors,
      trailingIcon: const Icon(Icons.question_answer),
    );
  }

  Widget _buildQuestionStatTile(Map<String, dynamic> stat) {
    final questionText = stat['questionText'] ?? 'سؤال غير معروف';
    final totalAnswered = stat['totalAnswered'];
    final correctAnswered = stat['correctAnswered'];
    final correctRate = stat['correctRate'];
    final difficulty = stat['difficulty'];

    Widget trailing;

    if (difficulty == 'سهلة') {
      trailing = Chip(
          label: Text("$correctRate%", style: TextStyle(color: Colors.white)));
    } else if (difficulty == 'عادية') {
      trailing = Chip(
          label:
              Text("$correctRate%", style: TextStyle(color: Colors.black87)));
    } else {
      trailing = Chip(
          label: Text("$correctRate%", style: TextStyle(color: Colors.white)));
    }

    return CustomListItem(
      title: questionText,
      begin: widget.begin,
      end: widget.end,
      gradientColors: widget.gradientColors,
      additionalTitles: [
        "الإجابات الصحيحة",
        "نسبة الإجابة الصحيحة",
        "صعوبة السؤال"
      ],
      additionalDescriptions: [
        "$correctAnswered من $totalAnswered",
        "$correctRate%",
        difficulty,
      ],
      trailingIcon: trailing,
      onPressed: () {},
      isboxed: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return CustomContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildStatCard('عدد الأسئلة المنشأة', '$_totalQuestions'),
            _buildStatCard('الأسئلة النشطة', '$_activeQuestions'),
            _buildStatCard('الأسئلة المستخدمة', '$_disabledQuestions'),
            if (_studentsDidExam > 0)
              _buildStatCard('عدد الطلاب الذين امتحنوا', '$_studentsDidExam'),
            const SizedBox(height: 24),
            if (_disabledQuestions > 0) ...[
              const Text(
                'تحليل الأسئلة المستخدمة:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._questionStats.map(_buildQuestionStatTile),
            ] else ...[
              const Text('لا توجد أسئلة مستخدمة بعد.'),
            ]
          ],
        ),
      ),
    );
  }
}
