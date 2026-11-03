import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primaryNavy,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryNavy,
        secondary: AppColors.accentTeal,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: AppTypography.getTextTheme(),
      useMaterial3: true,
    );
  }
}
