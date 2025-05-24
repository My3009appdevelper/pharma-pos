import 'package:flutter/material.dart';
import 'package:pos_farmacia/core/themes/app_colors.dart';

final ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  primaryColor: AppColors.darkPrimary,
  fontFamily: 'TafelSansProLight',
  colorScheme: const ColorScheme.dark(
    background: AppColors.darkBackground,
    primary: AppColors.darkPrimary,
    secondary: AppColors.darkSecondary,
    tertiary: AppColors.lightTertiary,
    error: AppColors.darkError,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onError: Colors.black,
    surface: AppColors.darkInputFill,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.darkText,
    ),
    bodyLarge: TextStyle(fontSize: 18, color: AppColors.darkText),
    bodyMedium: TextStyle(fontSize: 16, color: AppColors.darkText),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.darkText,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.darkInputFill,
    labelStyle: const TextStyle(color: AppColors.darkText),
    prefixIconColor: AppColors.darkPrimary,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.darkBorder.withOpacity(0.4)),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.darkBorder, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.darkError),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.darkError, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkPrimary,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
);
