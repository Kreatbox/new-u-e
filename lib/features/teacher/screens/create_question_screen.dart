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
  final List<String> subjects = [
    'الطب البشري',
    'طب الأسنان',
    'الصيدلة',
    'الهندسة المعلوماتية'
  ];

  // دالة لتحديث الواجهة عند تغيير الصورة في الـ controller
  void _onImageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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

            // -- إضافة جديدة: واجهة اختيار الصورة --
            GestureDetector(
              onTap: () async {
                await widget.controller.pickQuestionImage();
                _onImageChanged(); // تحديث الواجهة لعرض الصورة
              },
              child: Container(
                height: 200,
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

            DropdownButtonFormField<String>(
              value: widget.controller.selectedSubject,
              decoration: const InputDecoration(
                labelText: 'اختر المادة',
                border: OutlineInputBorder(),
              ),
              items: subjects.map((String subject) {
                return DropdownMenuItem<String>(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  widget.controller.selectedSubject = newValue;
                });
              },
              validator: (value) => value == null ? 'الرجاء اختيار مادة' : null,
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

            _buildOptionField(
                widget.controller.option1Controller, 'الخيار الأول'),
            const SizedBox(height: 16),
            _buildOptionField(
                widget.controller.option2Controller, 'الخيار الثاني'),
            const SizedBox(height: 16),
            _buildOptionField(
                widget.controller.option3Controller, 'الخيار الثالث'),
            const SizedBox(height: 16),
            _buildOptionField(
                widget.controller.option4Controller, 'الخيار الرابع'),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              value: widget.controller.selectedCorrectAnswer,
              decoration: const InputDecoration(
                labelText: 'اختر الإجابة الصحيحة',
                border: OutlineInputBorder(),
              ),
              items: [
                'الخيار الأول',
                'الخيار الثاني',
                'الخيار الثالث',
                'الخيار الرابع'
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  widget.controller.selectedCorrectAnswer = newValue;
                });
              },
              validator: (value) =>
                  value == null ? 'الرجاء تحديد الإجابة الصحيحة' : null,
            ),
            const SizedBox(height: 32),

            CustomButton(
              gradientColors: widget.gradientColors,
              text: 'حفظ السؤال',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.controller.createQuestion();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('تم حفظ السؤال بنجاح (محاكاة)')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'الرجاء إدخال هذا الخيار' : null,
    );
  }
}
