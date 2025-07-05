import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:universal_exam/shared/theme/colors.dart';
import 'package:universal_exam/shared/widgets/container.dart';

class LeaderboardCard extends StatefulWidget {
  final List<Map<String, dynamic>> leaders;

  const LeaderboardCard({
    super.key,
    required this.leaders,
  });

  @override
  State<LeaderboardCard> createState() => _LeaderboardCardState();
}

class _LeaderboardCardState extends State<LeaderboardCard> {
  late PageController _pageController;
  Timer? _timer;
  int _currentIndex = 0;

  bool _toggle = true;
  Alignment _begin = Alignment.centerLeft;
  Alignment _end = Alignment.centerRight;

  static const _transitionDuration = Duration(milliseconds: 1000);
  static const _timerDuration = Duration(seconds: 5);
  static const _pageChangeDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();

    if (widget.leaders.isEmpty) return;

    _pageController = PageController(initialPage: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    if (widget.leaders.length <= 1 || widget.leaders.isEmpty) return;

    _timer = Timer.periodic(_timerDuration, (_) {
      setState(() {
        _toggle = !_toggle;
        _begin = _toggle ? Alignment.centerLeft : Alignment.centerRight;
        _end = _toggle ? Alignment.centerRight : Alignment.centerLeft;
      });

      final nextPage = (_currentIndex + 1) % widget.leaders.length;
      _pageController.animateToPage(
        nextPage,
        duration: _transitionDuration,
        curve: Curves.easeOut,
      );

      _currentIndex = nextPage;
    });
  }

  String getScoreOrCount(Map<String, dynamic> item) {
    final role = item['role'] ?? '';
    final score = item['averageScore'] ?? 0.0;
    final questions = item['totalQuestions'] ?? 0;

    if (role == 'طالب') {
      return "${score.toStringAsFixed(2)}";
    } else if (role == 'أستاذ') {
      return "$questions";
    }
    return "0";
  }

  Widget _buildImage(String base64) {
    if (base64.isEmpty) {
      return const CircleAvatar(
        radius: 60,
        backgroundImage: AssetImage('assets/default_avatar.png'),
      );
    }

    try {
      final decoded = base64Decode(base64);
      return CircleAvatar(
        radius: 60,
        backgroundImage: MemoryImage(decoded),
      );
    } catch (e) {
      return const CircleAvatar(
        radius: 60,
        backgroundImage: AssetImage('assets/default_avatar.png'),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double size =
        screenWidth < 800 ? (screenWidth / 2) - 8 : screenWidth / 4 - 8;

    if (widget.leaders.isEmpty) {
      return const SizedBox.shrink();
    }

    // Detect if it's students or teachers based on role
    final isStudent = widget.leaders.every((item) => item['role'] == 'طالب');
    final title = isStudent ? "أفضل الطلاب" : "أفضل الدكاترة";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        children: [
          CustomContainer(
            width: size,
            height: 60,
            gradientColors: [
              AppColors.lightSecondary,
              AppColors.highlight,
              AppColors.lightSecondary
            ],
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: _pageChangeDuration,
            curve: Curves.bounceIn,
            width: size,
            height: size + 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.lightSecondary, AppColors.highlight],
                begin: _begin,
                end: _end,
              ),
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.leaders.length,
              itemBuilder: (context, index) {
                final item = widget.leaders[index];

                final firstName = item['firstName'] ?? '';
                final lastName = item['lastName'] ?? '';
                final name = '$firstName $lastName'.trim();
                final specialty = item['specialty'] ?? 'لا يوجد';
                final imageBase64 = item['profileImage'] ?? '';
                final scoreOrCount = getScoreOrCount(item);

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildImage(imageBase64),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isStudent
                            ? 'المعدل: $scoreOrCount'
                            : 'عدد الأسئلة: $scoreOrCount',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      if (!isStudent)
                        Text(
                          'نسبة الإجابات الصحيحة: ${(item['avgStudentScore'] ?? 0.0).toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 12),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        specialty,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
