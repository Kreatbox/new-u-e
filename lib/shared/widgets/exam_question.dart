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
  final List<Color> gradientColors;
  final Duration duration;
  final Duration buttonDuration;

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
    this.gradientColors = const [
      AppColors.primary,
      AppColors.lightSecondary,
    ],
    this.duration = const Duration(seconds: 5),
    this.buttonDuration = const Duration(milliseconds: 400),
  });

  @override
  ExamQuestionState createState() => ExamQuestionState();
}

class ExamQuestionState extends State<ExamQuestion> {
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.currentAnswers[widget.questionId];
  }

  @override
  void didUpdateWidget(ExamQuestion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentAnswers[widget.questionId] !=
        widget.currentAnswers[widget.questionId]) {
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
            duration: widget.duration,
            padding: const EdgeInsets.symmetric(vertical: 20),
            gradientColors: widget.gradientColors,
            child: Center(
              child: Text(
                widget.questionText,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (widget.imageBase64 != null && widget.imageBase64!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: CustomContainer(
                duration: widget.duration,
                padding: EdgeInsets.zero,
                borderRadius: 4,
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
          ],
          const SizedBox(height: 12),
          if (widget.type == "MCQ")
            ...widget.options.map((option) {
              bool isSelected = option == selectedOption;
              return Padding(
                key: ValueKey(option),
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: CustomButton(
                  duration: widget.buttonDuration,
                  text: option,
                  onPressed: widget.isAnswered
                      ? null
                      : () {
                          setState(() {
                            selectedOption = option;
                          });
                        },
                  gradientColors: widget.isAnswered && isSelected
                      ? [Colors.green, Colors.greenAccent]
                      : isSelected
                          ? [
                              Colors.white,
                              widget.gradientColors[1],
                              widget.gradientColors[1],
                              Colors.white
                            ]
                          : widget.gradientColors,
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
                      duration: widget.buttonDuration,
                      text: option,
                      onPressed: widget.isAnswered
                          ? null
                          : () {
                              setState(() {
                                selectedOption = option;
                              });
                            },
                      gradientColors: widget.isAnswered && isSelected
                          ? [Colors.green, Colors.greenAccent]
                          : isSelected
                              ? [
                                  Colors.white,
                                  widget.gradientColors[1],
                                  widget.gradientColors[1],
                                  Colors.white
                                ]
                              : widget.gradientColors,
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
                    duration: widget.buttonDuration,
                    text: 'تأكيد الإجابة',
                    onPressed: selectedOption != null
                        ? () {
                            widget.onOptionSelected(
                                widget.questionId, selectedOption!);
                          }
                        : null,
                    gradientColors: selectedOption != null
                        ? [
                            Colors.white,
                            widget.gradientColors[0],
                            widget.gradientColors[0],
                            Colors.white
                          ]
                        : widget.gradientColors,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    duration: widget.buttonDuration,
                    text: 'إلغاء التحديد',
                    onPressed: () {
                      setState(() {
                        selectedOption = null;
                      });
                    },
                    gradientColors: widget.gradientColors,
                  ),
                ),
              ],
            ),
          if (widget.isAnswered)
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'تم تأكيد الإجابة',
                    onPressed: null,
                    gradientColors: [Colors.green, Colors.greenAccent],
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
