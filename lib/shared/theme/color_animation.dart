import 'dart:async';
import 'package:flutter/material.dart';
import 'colors.dart';

class ColorAnimationService {
  List<Color> gradientColors = [
    AppColors.lightSecondary,
    AppColors.primary,
  ];
  Alignment begin = Alignment.topLeft;
  Alignment end = Alignment.bottomRight;
  late Timer colorTimer;
  List<List<Color>> colorPalettes = [
    [AppColors.primary, AppColors.lightSecondary],
    [AppColors.lightSecondary, AppColors.primary],
    [AppColors.lightPrimary, AppColors.secondary],
    [AppColors.secondary, AppColors.lightPrimary],
  ];
  int currentPaletteIndex = 0;

  void startColorAnimation(
      Function(List<Color>, Alignment, Alignment) onColorChange,
      {Duration switchDuration = const Duration(seconds: 5),
      List<List<Color>>? customColorPalettes}) {
    if (customColorPalettes != null) {
      colorPalettes = customColorPalettes;
    }

    colorTimer = Timer.periodic(switchDuration, (timer) {
      currentPaletteIndex = (currentPaletteIndex + 1) % colorPalettes.length;
      gradientColors = colorPalettes[currentPaletteIndex];
      begin = begin == Alignment.topLeft
          ? Alignment.bottomRight
          : Alignment.topLeft;
      end = end == Alignment.bottomRight
          ? Alignment.topLeft
          : Alignment.bottomRight;

      onColorChange(gradientColors, begin, end);
    });
  }

  void stopColorAnimation() {
    colorTimer.cancel();
  }
}
