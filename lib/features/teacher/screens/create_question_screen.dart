import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import '../controllers/teacher_controller.dart';

class CreateQuestionScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final TeacherController controller;

  const CreateQuestionScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.controller,
  });

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedSubject;

  void _onImageChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _loadTeacherSpecialty();
  }

  Future<void> _loadTeacherSpecialty() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final specialty = userData.data()?['specialty'] as String?;

    setState(() {
      selectedSubject = specialty;
      widget.controller.selectedSubject = specialty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedSubject == null) {
      return const CustomContainer(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return CustomContainer(
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              'إنشاء سؤال جديد',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                await widget.controller.pickQuestionImage();
                _onImageChanged();
              },
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  image: widget.controller.questionImage != null
                      ? DecorationImage(
                          image: MemoryImage(widget.controller.questionImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.controller.questionImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 50, color: Colors.grey[600]),
                          const SizedBox(height: 8),
                          Text(
                            'إضافة صورة للسؤال (اختياري)',
                            style: TextStyle(color: Colors.grey[700]),
                          )
                        ],
                      )
                    : Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close,
                              color: Colors.white,
                              shadows: [
                                Shadow(blurRadius: 2.0, color: Colors.black)
                              ]),
                          onPressed: () {
                            widget.controller.clearImage();
                            _onImageChanged();
                          },
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'التخصص: $selectedSubject',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: widget.controller.questionType,
              decoration: const InputDecoration(
                labelText: 'نوع السؤال',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'MCQ', child: Text('اختيار من متعدد')),
                DropdownMenuItem(value: 'true_false', child: Text('صح أو خطأ')),
              ],
              onChanged: (val) {
                setState(() {
                  widget.controller.questionType = val!;
                  widget.controller.selectedCorrectAnswer = null;

                  if (val == 'true_false') {
                    widget.controller.optionControllers.clear();
                  } else if (val == 'MCQ' &&
                      widget.controller.optionControllers.isEmpty) {
                    widget.controller.optionControllers.addAll(
                        [TextEditingController(), TextEditingController()]);
                  }
                });
              },
              validator: (val) => val == null ? 'اختر نوع السؤال' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.controller.questionController,
              decoration: const InputDecoration(
                labelText: 'نص السؤال',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty
                  ? 'الرجاء إدخال نص السؤال'
                  : null,
            ),
            const SizedBox(height: 16),
            if (widget.controller.questionType == 'true_false') ...[
              DropdownButtonFormField<String>(
                value: widget.controller.selectedCorrectAnswer,
                decoration: const InputDecoration(
                  labelText: 'الإجابة الصحيحة',
                  border: OutlineInputBorder(),
                ),
                items: ['صح', 'خطأ']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    widget.controller.selectedCorrectAnswer = val;
                  });
                },
                validator: (val) => val == null ? 'اختر الإجابة الصحيحة' : null,
              ),
            ] else if (widget.controller.questionType == 'MCQ') ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.controller.optionControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller:
                              widget.controller.optionControllers[index],
                          decoration: InputDecoration(
                            labelText: 'الخيار ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (val) =>
                              val == null || val.isEmpty ? 'ادخل الخيار' : null,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            widget.controller.removeOption(index);
                            if (widget.controller.selectedCorrectAnswer !=
                                    null &&
                                !widget.controller.optionControllers.any((c) =>
                                    c.text ==
                                    widget.controller.selectedCorrectAnswer)) {
                              widget.controller.selectedCorrectAnswer = null;
                            }
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    widget.controller.addOption();
                  });
                },
                child: const Text('إضافة خيار'),
              ),
              DropdownButtonFormField<String>(
                value: widget.controller.selectedCorrectAnswer,
                decoration: const InputDecoration(
                  labelText: 'اختر الإجابة الصحيحة',
                  border: OutlineInputBorder(),
                ),
                items: widget.controller.optionControllers
                    .map((c) => c.text)
                    .where((text) => text.isNotEmpty)
                    .map((option) =>
                        DropdownMenuItem(value: option, child: Text(option)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    widget.controller.selectedCorrectAnswer = val;
                  });
                },
                validator: (val) => val == null ? 'اختر الإجابة الصحيحة' : null,
              ),
            ],
            const SizedBox(height: 32),
            CustomButton(
              gradientColors: widget.gradientColors,
              text: 'حفظ السؤال',
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final isSaved = await widget.controller.createQuestion();
                  if (isSaved) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حفظ السؤال بنجاح')),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يبدو أن هذا السؤال موجود مسبقًا'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
