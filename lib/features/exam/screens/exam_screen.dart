import 'dart:math';
import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/theme/color_animation.dart';
import '../../../shared/widgets/app_bar.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/exam_question.dart';
import '../data/colors.dart'; // Here is the colorPalettes + questions so we don't add +200 lines

class ExamScreen extends StatefulWidget {
  const ExamScreen({super.key});

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  List<Color> gradientColors = [
    AppColors.primary,
    AppColors.secondary,
  ];
  int totalTime = 360;
  Duration switchDuration = Duration(seconds: (5).floor());
  late ColorAnimationService colorService;

  late List<Map<String, dynamic>> shuffledQuestions;
  Map<String, dynamic>? selectedQuestion;
  bool isAnswered = false;
  Map<int, bool> questionAnswered = {};
  @override
  void initState() {
    super.initState();
    shuffledQuestions = List.from(questions)..shuffle(Random());

    colorService = ColorAnimationService();
    colorService.startColorAnimation((colors, begin, end) {
      setState(() {
        gradientColors = colors;
      });
    }, switchDuration: switchDuration, customColorPalettes: colorPalettes);
    selectedQuestion =
        shuffledQuestions.isNotEmpty ? shuffledQuestions[0] : null;
  }

  @override
  void dispose() {
    colorService.stopColorAnimation();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'الامتحان',
        gradientColors: gradientColors,
      ),
      body: CustomContainer(
        duration: Duration(seconds: 5),
        gradientColors: gradientColors,
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: ListView.builder(
                itemCount: shuffledQuestions.length,
                itemBuilder: (context, index) {
                  bool isSelected =
                      selectedQuestion == shuffledQuestions[index];
                  bool answered = questionAnswered[index] ?? false;
                  return Column(
                    children: [
                      CustomButton(
                        gradientColors: answered
                            ? [
                                gradientColors[1],
                                gradientColors[0],
                                gradientColors[0],
                                gradientColors[1]
                              ]
                            : isSelected
                                ? [
                                    Colors.white,
                                    gradientColors[1],
                                    gradientColors[1],
                                    Colors.white
                                  ]
                                : gradientColors,
                        onPressed: () {
                          setState(() {
                            selectedQuestion = shuffledQuestions[index];
                          });
                        },
                        text: "السؤال ${index + 1}",
                      ),
                      const SizedBox(
                        height: 2,
                      )
                    ],
                  );
                },
              ),
            ),
            Flexible(
              flex: 4,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4),
                child: CustomContainer(
                  duration: Duration(seconds: 5),
                  gradientColors: gradientColors,
                  child: selectedQuestion == null
                      ? const Center(child: Text("لا يوجد سؤال محدد"))
                      : ExamQuestion(
                          gradientColors: gradientColors,
                          questionText: selectedQuestion!["text"],
                          imageUrl: selectedQuestion!["imageUrl"],
                          options:
                              List<String>.from(selectedQuestion!["options"]),
                          onOptionSelected: (selectedOption) {
                            debugPrint("Selected option: $selectedOption");
                          },
                          isAnswered: questionAnswered[shuffledQuestions
                                  .indexOf(selectedQuestion!)] ??
                              false,
                          onAnswered: () {
                            setState(() {
                              questionAnswered[shuffledQuestions
                                  .indexOf(selectedQuestion!)] = true;
                            });
                          },
                          onReset: () {
                            setState(() {
                              questionAnswered[shuffledQuestions
                                  .indexOf(selectedQuestion!)] = false;
                            });
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
