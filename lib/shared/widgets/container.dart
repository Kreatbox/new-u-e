import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CustomContainer extends StatelessWidget {
  final double? height;
  final double width;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final Widget? child;
  final Duration duration;
  final Curve curve;
  const CustomContainer({
    super.key,
    this.height,
    this.width = double.infinity,
    this.borderRadius = 2.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.gradientColors = const [AppColors.primary, AppColors.lightSecondary],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.child,
    this.duration = const Duration(seconds: 2),
    this.curve = Curves.ease,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: begin,
          end: end,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
