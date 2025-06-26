import 'dart:async';
import 'package:flutter/material.dart';
import 'package:universal_exam/shared/widgets/container.dart';
import '../theme/colors.dart';

class CustomCard extends StatefulWidget {
  final List<Map<String, dynamic>> persons;

  const CustomCard({
    super.key,
    this.persons = const [
      {
        "title": "العنوان",
        "name": "اسم افتراضي",
        "score": 0.0,
        "imageUrl": "assets/default_avatar.png",
      },
    ],
  });

  @override
  State<CustomCard> createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  late PageController _pageController;
  late Timer _timer;
  int _currentIndex = 0;

  final Color _startColor = AppColors.lightSecondary;
  final Color _endColor = AppColors.highlight;
  bool _toggle = true;
  Alignment _begin = Alignment.centerLeft;
  Alignment _end = Alignment.centerRight;

  static const _transitionDuration = Duration(milliseconds: 1000);
  static const _timerDuration = Duration(seconds: 5);
  static const _pageChangeDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    _timer = Timer.periodic(_timerDuration, (timer) {
      _updatePage();
    });
  }

  void _updatePage() {
    setState(() {
      _toggle = !_toggle;
      _begin = _toggle ? Alignment.centerLeft : Alignment.centerRight;
      _end = _toggle ? Alignment.centerRight : Alignment.centerLeft;
    });

    if (_currentIndex < widget.persons.length - 1) {
      _currentIndex++;
    } else {
      _currentIndex = 0;
    }

    _pageController.animateToPage(
      _currentIndex,
      duration: _transitionDuration,
      curve: Curves.easeOut,
    );
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
                widget.persons.isNotEmpty
                    ? widget.persons[0]["title"]
                    : "العنوان",
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
                colors: [_startColor, _endColor],
                begin: _begin,
                end: _end,
              ),
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.persons.length,
              itemBuilder: (context, index) {
                final person = widget.persons[index];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: size / 3,
                        backgroundImage: AssetImage(person["imageUrl"]),
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(height: 16),
                      Text(
                        person["name"],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'المعدل: ${(person["score"] as double).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium,
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
