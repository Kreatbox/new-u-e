import 'package:flutter/material.dart';
import '../theme/colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final List<Color> gradientColors;
  final Color? textColor;
  final Widget? child;
  final Duration duration;

  const CustomButton({
    super.key,
    this.text = '',
    required this.onPressed,
    this.borderRadius = 2.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.gradientColors = const [AppColors.primary, AppColors.secondary],
    this.textColor = Colors.white,
    this.child,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  State<CustomButton> createState() => CustomButtonState();
}

class CustomButtonState extends State<CustomButton> {
  Alignment begin = Alignment.topLeft;
  Alignment endAlignment = Alignment.bottomRight;

  void _updateAlignment({required bool isHovering}) {
    setState(() {
      begin = isHovering ? Alignment.topRight : Alignment.topLeft;
      endAlignment = isHovering ? Alignment.bottomLeft : Alignment.bottomRight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _updateAlignment(isHovering: true),
      onExit: (_) => _updateAlignment(isHovering: false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: widget.duration,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: begin,
              end: endAlignment,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Center(
            child: widget.child ??
                Text(
                  widget.text,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 16.0,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
