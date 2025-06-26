import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'container.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  const CustomAppBar({
    super.key,
    required this.title,
    this.gradientColors = const [AppColors.primary, AppColors.lightSecondary],
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: CustomContainer(
        gradientColors: gradientColors,
        begin: begin,
        end: end,
      ),
      title: Text(title),
      actions: actions,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
