// Renders an exam question. No feedback until all questions are answered.

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:universal_exam/shared/theme/colors.dart';
import 'package:universal_exam/shared/widgets/button.dart';
import 'package:universal_exam/shared/widgets/container.dart';

class ExamQuestion extends StatefulWidget {
  final String questionText;
  final String? imageBase64;
  final String questionId;
  final String type;
  final List<String> options;
  final bool isAnswered;
  final Map<String, dynamic> currentAnswers;

  final void Function(String questionId, String selectedOption)
      onOptionSelected;
  final VoidCallback? onReset;

  const ExamQuestion({
    super.key,
    required this.questionText,
    this.imageBase64,
    required this.questionId,
    required this.type,
    required this.options,
    required this.isAnswered,
    required this.currentAnswers,
    required this.onOptionSelected,
    this.onReset,
    required List<Color> gradientColors,
  });

  @override
  State<ExamQuestion> createState() => _ExamQuestionState();
}

class _ExamQuestionState extends State<ExamQuestion> {
  late String? selectedOption;

  @override
  void initState() {
    super.initState();
    if (widget.currentAnswers.containsKey(widget.questionId)) {
      selectedOption = widget.currentAnswers[widget.questionId];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = widget.questionText.isNotEmpty &&
        widget.questionText[0].contains(RegExp(r'[a-zA-Z]'));

    final TextDirection textDirection =
        isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomContainer(
            padding: const EdgeInsets.symmetric(vertical: 20),
            gradientColors: [
              AppColors.primary,
              AppColors.highlight,
              AppColors.lightSecondary
            ],
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.questionText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          if (widget.imageBase64 != null && widget.imageBase64!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _buildImage(),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // MCQ Options
          if (widget.type == "MCQ")
            ...widget.options.map((option) {
              bool isSelected = option == selectedOption;

              return Padding(
                key: ValueKey(option),
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: CustomButton(
                  text: option,
                  onPressed: widget.isAnswered || isSelected
                      ? () {}
                      : () {
                          setState(() {
                            selectedOption = option;
                          });
                          widget.onOptionSelected(widget.questionId, option);
                        },
                  gradientColors: isSelected
                      ? [Colors.white, AppColors.highlight]
                      : [AppColors.highlight, AppColors.lightSecondary],
                  textColor: isSelected ? Colors.black : Colors.white,
                ),
              );
            }).toList(),

          if (widget.type == "true_false")
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['صح', 'خطأ'].map((option) {
                bool isSelected = option == selectedOption;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: CustomButton(
                      text: option,
                      onPressed: widget.isAnswered || isSelected
                          ? () {}
                          : () {
                              setState(() {
                                selectedOption = option;
                              });
                              widget.onOptionSelected(
                                  widget.questionId, option);
                            },
                      gradientColors: isSelected
                          ? [Colors.white, AppColors.highlight]
                          : [AppColors.highlight, AppColors.lightSecondary],
                      textColor: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 20),
          if (!widget.isAnswered)
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'تأكيد الإجابة',
                    onPressed: selectedOption != null
                        ? () {
                            widget.onReset?.call();
                            Navigator.pop(context);
                          }
                        : () {},
                    gradientColors: selectedOption != null
                        ? [Colors.white, AppColors.highlight]
                        : [Colors.grey.shade400, Colors.grey.shade600],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    try {
      final decodedBytes = base64Decode(widget.imageBase64!);
      return Image.memory(
        Uint8List.fromList(decodedBytes),
        fit: BoxFit.contain,
      );
    } catch (e) {
      return Image.asset('assets/images/default_question.png');
    }
  }
}
