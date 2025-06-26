import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.primary,
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'HSI'),
      displayMedium: TextStyle(fontFamily: 'HSI'),
      displaySmall: TextStyle(fontFamily: 'HSI'),
      headlineMedium: TextStyle(fontFamily: 'HSI'),
      headlineSmall: TextStyle(fontFamily: 'HSI', fontSize: 22),
      titleLarge: TextStyle(fontFamily: 'HSI'),
      titleMedium: TextStyle(fontFamily: 'HSI'),
      titleSmall: TextStyle(fontFamily: 'HSI'),
      bodyLarge: TextStyle(fontFamily: 'HSI'),
      bodyMedium: TextStyle(fontFamily: 'HSI'),
      labelLarge: TextStyle(fontFamily: 'HSI'),
      bodySmall: TextStyle(fontFamily: 'HSI'),
      labelSmall: TextStyle(fontFamily: 'HSI'),
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.lightSecondary,
      error: AppColors.darkPrimary,
    ),
  );
}
