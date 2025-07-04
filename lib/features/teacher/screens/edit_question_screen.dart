import 'package:flutter/material.dart';
import '../controllers/teacher_controller.dart';

class CreateQuestionForm extends StatelessWidget {
  final TeacherController controller;
  final VoidCallback onSubmit;

  const CreateQuestionForm({
    Key? key,
    required this.controller,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'تعديل السؤال',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.questionController,
            decoration: const InputDecoration(labelText: 'نص السؤال'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          InputDecorator(
            decoration: const InputDecoration(
              labelText: 'نوع السؤال',
              border: OutlineInputBorder(),
            ),
            child: Text(
              controller.questionType == 'MCQ'
                  ? 'اختيار من متعدد'
                  : 'صح أو خطأ',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              await controller.pickQuestionImage();
            },
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                image: controller.questionImage != null
                    ? DecorationImage(
                        image: MemoryImage(controller.questionImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: controller.questionImage == null
                  ? const Center(
                      child: Icon(Icons.camera_alt_outlined,
                          size: 50, color: Colors.grey),
                    )
                  : Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.redAccent,
                          child: IconButton(
                            icon: const Icon(Icons.delete_forever,
                                color: Colors.white, size: 14),
                            onPressed: controller.clearImage,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 24),
          if (controller.questionType == 'MCQ')
            ...controller.optionControllers.asMap().entries.map((entry) {
              final c = entry.value;
              return Row(
                children: [
                  Expanded(child: TextField(controller: c)),
                ],
              );
            }).toList()
          else
            DropdownButtonFormField<String>(
              value: controller.selectedCorrectAnswer,
              items: ['صح', 'خطأ']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                controller.selectedCorrectAnswer = val;
              },
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onSubmit,
            child: const Text('حفظ التعديلات'),
          )
        ],
      ),
    );
  }
}
