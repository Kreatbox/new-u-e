import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'container.dart';

class CustomBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final Widget? child;
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  const CustomBottomSheet({
    super.key,
    required this.title,
    required this.description,
    this.child,
    this.gradientColors = const [AppColors.primary, AppColors.lightSecondary],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      gradientColors: gradientColors,
      begin: begin,
      end: end,
      borderRadius: 2.0,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            child ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
