import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:universal_exam/features/teacher/controllers/teacher_controller.dart';
import 'package:universal_exam/shared/widgets/container.dart';

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
    try {
      print('=== Starting _loadStats ===');

      final user = FirebaseAuth.instance.currentUser;
      print('User: ${user?.uid}');
      if (user == null) return;

      final String? teacherUid = FirebaseAuth.instance.currentUser?.uid;
      print('Teacher UID: $teacherUid');
      if (teacherUid == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('questions')
          .where('createdBy', isEqualTo: teacherUid)
          .get();

      print('Questions found: ${snapshot.size}');

      setState(() {
        _totalQuestions = snapshot.size;
        _activeQuestions =
            snapshot.docs.where((doc) => doc.data()['disabled'] != true).length;
        _disabledQuestions =
            snapshot.docs.where((doc) => doc.data()['disabled'] == true).length;
      });

      print('Active questions: $_activeQuestions');
      print('Disabled questions: $_disabledQuestions');

      if (_disabledQuestions == 0) {
        print('No disabled questions, returning early');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final attemptsSnapshot = await FirebaseFirestore.instance
          .collection('examAttempts')
          .where('studentId', isNotEqualTo: '')
          .get();

      print('Total attempts: ${attemptsSnapshot.docs.length}');

      setState(() {
        _studentsDidExam = attemptsSnapshot.docs.length;
      });

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final questionId = doc.id;

        print('Processing question: $questionId');
        print('Question data: $data');

        if (data['disabled'] != true) {
          print('Question not disabled, skipping');
          continue;
        }

        final stats = data['stats'] as Map<String, dynamic>?;
        final totalAnswered = stats?['totalAnswered'] ?? 0;
        final correctAnswered = stats?['correctAnswered'] ?? 0;
        final correctRate = stats?['correctRate'] ?? 0.0;

        print(
            'Stats from document: totalAnswered=$totalAnswered, correctAnswered=$correctAnswered, correctRate=$correctRate');

        String difficultyLabel = 'صعبة';
        if (correctRate >= 50 && correctRate <= 70) {
          difficultyLabel = 'عادية';
        } else if (correctRate > 70) {
          difficultyLabel = 'سهلة';
        }

        final questionText = data['text'] ?? 'سؤال بدون نص';
        print('Question text: $questionText');

        _questionStats.add({
          'questionText': questionText,
          'totalAnswered': totalAnswered,
          'correctAnswered': correctAnswered,
          'correctRate': correctRate,
          'difficulty': difficultyLabel,
        });

        print('Added question stat: ${_questionStats.last}');
      }

      print('Final question stats count: ${_questionStats.length}');
      setState(() {
        _isLoading = false;
      });
      print('=== _loadStats completed ===');
    } catch (e, stackTrace) {
      print('Error loading stats: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildStatCard(String label, String value) {
    return CustomContainer(
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.analytics,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionStatTile(Map<String, dynamic> stat) {
    print('Building question stat tile with data: $stat');

    final questionText = stat['questionText'] ?? 'سؤال غير معروف';
    final totalAnswered = stat['totalAnswered'] ?? 0;
    final correctAnswered = stat['correctAnswered'] ?? 0;
    final correctRate = stat['correctRate'] ?? 0.0;
    final difficulty = stat['difficulty'] ?? 'غير محدد';

    print(
        'Parsed values: questionText=$questionText, totalAnswered=$totalAnswered, correctAnswered=$correctAnswered, correctRate=$correctRate, difficulty=$difficulty');

    final correctRateText = '${correctRate.toStringAsFixed(1)}%';

    Color chipColor;
    Color textColor;
    IconData difficultyIcon;

    if (difficulty == 'سهلة') {
      chipColor = Colors.green;
      textColor = Colors.white;
      difficultyIcon = Icons.trending_up;
    } else if (difficulty == 'عادية') {
      chipColor = Colors.orange;
      textColor = Colors.white;
      difficultyIcon = Icons.trending_flat;
    } else {
      chipColor = Colors.red;
      textColor = Colors.white;
      difficultyIcon = Icons.trending_down;
    }

    return CustomContainer(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  questionText,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: chipColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(difficultyIcon, color: textColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      correctRateText,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomContainer(
            padding: const EdgeInsets.all(16),
            end: widget.begin,
            begin: widget.end,
            child: Column(
              children: [
                _buildStatRow(
                    'الإجابات الصحيحة',
                    '$correctAnswered من $totalAnswered',
                    Icons.check_circle,
                    Colors.green),
                const SizedBox(height: 8),
                _buildStatRow('نسبة الإجابة الصحيحة', correctRateText,
                    Icons.percent, Colors.blue),
                const SizedBox(height: 8),
                _buildStatRow(
                    'صعوبة السؤال', difficulty, Icons.speed, chipColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomContainer(
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics_outlined,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إحصائيات الأسئلة',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'تحليل أداء الأسئلة المستخدمة في الامتحانات',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomContainer(
              begin: widget.end,
              end: widget.begin,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    _buildStatCard('عدد الأسئلة المنشأة', '$_totalQuestions'),
                    _buildStatCard('الأسئلة النشطة', '$_activeQuestions'),
                    _buildStatCard('الأسئلة المستخدمة', '$_disabledQuestions'),
                    if (_studentsDidExam > 0)
                      _buildStatCard(
                          'عدد الطلاب الذين امتحنوا', '$_studentsDidExam'),
                    const SizedBox(height: 16),
                    if (_disabledQuestions > 0 &&
                        _questionStats.isNotEmpty) ...[
                      CustomContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.assessment, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            const Text(
                              'تحليل الأسئلة المستخدمة:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._questionStats
                          .map((stat) => _buildQuestionStatTile(stat))
                          .toList(),
                    ] else if (_disabledQuestions > 0 &&
                        _questionStats.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.hourglass_empty,
                                  size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'جاري تحميل إحصائيات الأسئلة...',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: const Center(
                          child: Column(
                            children: [
                              Icon(Icons.quiz, size: 48, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد أسئلة مستخدمة بعد.',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
