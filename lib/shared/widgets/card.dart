// Displays TopStudents or TopTeachers with full user info loaded from Firestore.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:universal_exam/core/models/top_student_model.dart';
import 'package:universal_exam/core/models/top_teacher_model.dart';
import 'package:universal_exam/core/models/user_info_model.dart';
import 'package:universal_exam/shared/theme/colors.dart';
import 'package:universal_exam/shared/widgets/container.dart';

class LeaderboardCard extends StatefulWidget {
  final List<dynamic> leaders; // List<TopStudent> or List<TopTeacher>

  const LeaderboardCard({
    super.key,
    required this.leaders,
  });

  @override
  State<LeaderboardCard> createState() => _LeaderboardCardState();
}

class _LeaderboardCardState extends State<LeaderboardCard> {
  late PageController _pageController;
  late Timer _timer;
  int _currentIndex = 0;

  bool _toggle = true;
  Alignment _begin = Alignment.centerLeft;
  Alignment _end = Alignment.centerRight;

  static const _transitionDuration = Duration(milliseconds: 1000);
  static const _timerDuration = Duration(seconds: 5);
  static const _pageChangeDuration = Duration(milliseconds: 1000);
  List<UserInfo> _userInfos = [];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: 0);
    _loadUserInfos();
    _startAutoScroll();
  }

  Future<void> _loadUserInfos() async {
    final List<UserInfo> infos = [];

    for (var leader in widget.leaders) {
      if (leader is TopStudent) {
        final info = await leader.loadUserInfo();
        infos.add(info);
      } else if (leader is TopTeacher) {
        final info = await leader.loadUserInfo();
        infos.add(info);
      }
    }

    setState(() {
      _userInfos = infos;
    });
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(_timerDuration, (_) {
      setState(() {
        _toggle = !_toggle;
        _begin = _toggle ? Alignment.centerLeft : Alignment.centerRight;
        _end = _toggle ? Alignment.centerRight : Alignment.centerLeft;
      });

      _currentIndex = (_currentIndex + 1) % _userInfos.length;
      _pageController.animateToPage(
        _currentIndex,
        duration: _transitionDuration,
        curve: Curves.easeOut,
      );
    });
  }

  String _getScoreOrCount(dynamic leader) {
    if (leader is TopStudent) {
      return "${leader.averageScore.toStringAsFixed(2)}";
    } else if (leader is TopTeacher) {
      return "${leader.totalQuestions}";
    }
    return "0";
  }

  Widget _buildImage(String base64) {
    if (base64.isEmpty) {
      return const CircleAvatar(
        radius: 48,
        backgroundImage: AssetImage('assets/default_avatar.png'),
      );
    }

    try {
      final decoded = base64Decode(base64);
      return CircleAvatar(
        radius: 48,
        backgroundImage: MemoryImage(decoded),
      );
    } catch (e) {
      return const CircleAvatar(
        radius: 48,
        backgroundImage: AssetImage('assets/default_avatar.png'),
      );
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double size =
        screenWidth < 800 ? (screenWidth / 2) - 8 : screenWidth / 5;

    if (_userInfos.isEmpty) {
      return const SizedBox.shrink(); // Or show loading spinner
    }

    final title = _userInfos.isNotEmpty ? _userInfos[0].specialty : "الاختصاص";

    final isStudent =
        widget.leaders.isNotEmpty && widget.leaders[0] is TopStudent;

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
              itemCount: _userInfos.length,
              itemBuilder: (context, index) {
                final userInfo = _userInfos[index];
                final leader = widget.leaders[index];

                final name = userInfo.fullName;
                final specialty = userInfo.specialty;
                final imageBase64 = userInfo.profileImage;
                final scoreOrCount = _getScoreOrCount(leader);

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
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
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
