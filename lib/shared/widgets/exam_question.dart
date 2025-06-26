import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'button.dart';
import 'container.dart';

class ExamQuestion extends StatefulWidget {
  final String questionText;
  final String? imageUrl;
  final List<String> options;
  final void Function(String selectedOption) onOptionSelected;
  final List<Color> gradientColors;
  final Duration duration;
  final Duration buttonDuration;
  final Alignment begin;
  final Alignment end;
  final bool isAnswered;
  final void Function() onAnswered;
  final void Function() onReset;

  const ExamQuestion({
    super.key,
    required this.questionText,
    this.imageUrl,
    required this.options,
    required this.onOptionSelected,
    this.gradientColors = const [
      AppColors.primary,
      AppColors.lightSecondary,
    ],
    this.duration = const Duration(seconds: 5),
    this.buttonDuration = const Duration(milliseconds: 400),
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    required this.isAnswered,
    required this.onAnswered,
    required this.onReset,
  });

  @override
  ExamQuestionState createState() => ExamQuestionState();
}

class ExamQuestionState extends State<ExamQuestion> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = widget.questionText[0].contains(RegExp(r'[a-zA-Z]'));
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (widget.imageUrl != null) ...[
            const SizedBox(height: 8),
            Center(
              child: CustomContainer(
                duration: widget.duration,
                padding: EdgeInsets.zero,
                borderRadius: 4,
                child: Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          ...widget.options.map((option) {
            bool isSelected = option == selectedOption;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: CustomButton(
                duration: widget.buttonDuration,
                text: option,
                onPressed: () {
                  setState(() {
                    selectedOption = option;
                  });
                  widget.onOptionSelected(option);
                },
                gradientColors: widget.isAnswered && isSelected
                    ? [
                        widget.gradientColors[1],
                        widget.gradientColors[0],
                        widget.gradientColors[0],
                        widget.gradientColors[1]
                      ]
                    : isSelected
                        ? [
                            Colors.white,
                            widget.gradientColors[1],
                            widget.gradientColors[1],
                            Colors.white
                          ]
                        : widget.gradientColors,
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  duration: widget.buttonDuration,
                  text: 'تأكيد الإجابة',
                  onPressed: () {
                    widget.onAnswered();
                  },
                  gradientColors: selectedOption != null && !widget.isAnswered
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
                      widget.onReset();
                      selectedOption = null;
                    });
                  },
                  gradientColors: widget.gradientColors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
