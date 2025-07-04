import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:universal_exam/features/teacher/controllers/teacher_controller.dart';
import 'package:universal_exam/features/teacher/screens/edit_question_screen.dart';
import 'package:universal_exam/shared/theme/colors.dart';
import 'package:universal_exam/shared/widgets/button.dart';
import 'package:universal_exam/shared/widgets/container.dart';
import 'dart:convert';

class ManageQuestionsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final TeacherController controller;

  const ManageQuestionsScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.controller,
  });

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where('createdBy', isEqualTo: user.uid)
        .where('disabled', isEqualTo: false)
        .get();

    setState(() {
      _questions = snapshot.docs
          .map((doc) =>
              Map<String, dynamic>.from(doc.data()..addAll({'id': doc.id})))
          .toList();
      _isLoading = false;
    });
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> question) {
    final controller = TeacherController()
      ..questionController.text = question['text'] ?? ''
      ..questionType = question['type'] ?? 'MCQ'
      ..selectedSubject = question['specialty']
      ..selectedCorrectAnswer = question['correctAnswer']
      ..questionImage = question['imageBase64'] != null
          ? base64Decode(question['imageBase64'])
          : null;

    final options = (question['options'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    if (controller.optionControllers.isNotEmpty) {
      controller.optionControllers.clear();
    }

    controller.optionControllers.addAll(
      options.map((opt) => TextEditingController(text: opt)).toList(),
    );

    while (controller.optionControllers.length < 2) {
      controller.optionControllers.add(TextEditingController());
    }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: CreateQuestionForm(
              controller: controller,
              onSubmit: () async {
                await controller.updateQuestion(question['id']);
                Navigator.pop(context);
                _loadQuestions();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuestionItem(Map<String, dynamic> question) {
    final String text = question['text'] ?? '';
    final String type = question['type'] ?? 'MCQ';
    final String correctAnswer = question['correctAnswer'] ?? '';
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: CustomContainer(
        begin: widget.begin,
        end: widget.end,
        gradientColors: widget.gradientColors,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('النوع: ${type == 'MCQ' ? 'اختيار من متعدد' : 'صح أو خطأ'}'),
              Text('الإجابة الصحيحة: $correctAnswer'),
              const SizedBox(height: 12),
              if (question['imageBase64'] != null)
                AnimatedContainer(
                  height: 200,
                  duration: Duration(seconds: 5),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    image: DecorationImage(
                      image: MemoryImage(base64Decode(question['imageBase64'])),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    text: "تعديل",
                    gradientColors: [AppColors.secondary, AppColors.primary],
                    onPressed: () => _showEditDialog(context, question),
                  ),
                  const SizedBox(width: 8),
                  CustomButton(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                    text: "حذف",
                    gradientColors: [Colors.redAccent, Colors.red],
                    onPressed: () => _deleteQuestion(question['id']),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteQuestion(String questionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(questionId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم حذف السؤال")),
      );
      _loadQuestions();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("خطأ في الحذف: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'إدارة الأسئلة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_questions.isEmpty)
            const Center(child: Text("لا توجد أسئلة بعد"))
          else
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length,
                itemBuilder: (context, index) =>
                    _buildQuestionItem(_questions[index]),
              ),
            ),
        ],
      ),
    );
  }
}
