// Renders an exam question with proper state management and animations

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:universal_exam/features/exam/data/colors.dart';

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
  final int currentColorIndex;

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
    required this.currentColorIndex,
  });

  @override
  ExamQuestionState createState() => ExamQuestionState();
}

class ExamQuestionState extends State<ExamQuestion>
    with TickerProviderStateMixin {
  String? selectedOption;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<Color> get currentColors => colorPalettes[widget.currentColorIndex];

  @override
  void initState() {
    super.initState();
    selectedOption = widget.currentAnswers[widget.questionId];

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectOption(String option) {
    if (widget.isAnswered) return;

    setState(() {
      selectedOption = option;
    });
  }

  void _confirmAnswer() {
    if (selectedOption == null) return;
    widget.onOptionSelected(widget.questionId, selectedOption!);
  }

  void _clearSelection() {
    if (widget.isAnswered) return;

    setState(() {
      selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnglish = widget.questionText.isNotEmpty &&
        widget.questionText[0].contains(RegExp(r'[a-zA-Z]'));
    final TextDirection textDirection =
        isEnglish ? TextDirection.ltr : TextDirection.rtl;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Directionality(
          textDirection: textDirection,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildQuestionHeader(),
                if (widget.imageBase64 != null &&
                    widget.imageBase64!.isNotEmpty)
                  _buildQuestionImage(),
                const SizedBox(height: 20),
                _buildOptions(),
                const SizedBox(height: 20),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: currentColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: currentColors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        widget.questionText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildQuestionImage() {
    return AnimatedContainer(
      width: double.infinity,
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      duration: Duration(seconds: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    try {
      final decodedBytes = base64Decode(widget.imageBase64!);
      return Image.memory(
        Uint8List.fromList(decodedBytes),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey.shade100,
            child: const Icon(
              Icons.image_not_supported,
              size: 48,
              color: Colors.grey,
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color: Colors.grey.shade100,
        child: const Icon(
          Icons.image_not_supported,
          size: 48,
          color: Colors.grey,
        ),
      );
    }
  }

  Widget _buildOptions() {
    if (widget.type == "MCQ") {
      return Column(
        children: widget.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return _buildOptionButton(option, index);
        }).toList(),
      );
    } else if (widget.type == "true_false") {
      return Row(
        children: ['صح', 'خطأ'].asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 1 ? 8.0 : 0.0,
                right: index == 0 ? 8.0 : 0.0,
              ),
              child: _buildOptionButton(option, index),
            ),
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildOptionButton(String option, int index) {
    final bool isSelected = option == selectedOption;
    final bool isAnswered = widget.isAnswered;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isAnswered && isSelected
            ? const LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : isSelected
                ? LinearGradient(
                    colors: [
                      Colors.white,
                      currentColors[1],
                      currentColors[1],
                      Colors.white
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: currentColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? currentColors[1] : Colors.transparent,
          width: isSelected ? 3 : 0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: currentColors[1].withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAnswered ? null : () => _selectOption(option),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.black : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (widget.isAnswered) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.greenAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'تم تأكيد الإجابة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            text: 'تأكيد الإجابة',
            onPressed: selectedOption != null ? _confirmAnswer : null,
            gradientColors: selectedOption != null
                ? [
                    Colors.white,
                    currentColors[0],
                    currentColors[0],
                    Colors.white
                  ]
                : currentColors,
            textColor: selectedOption != null ? Colors.black : Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            text: 'إلغاء التحديد',
            onPressed: _clearSelection,
            gradientColors: currentColors,
            textColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback? onPressed,
    required List<Color> gradientColors,
    required Color textColor,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
