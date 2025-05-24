import 'package:flutter/material.dart';
import 'app_colors.dart';

final ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBackground,
  primaryColor: AppColors.lightPrimary,
  fontFamily: 'TafelSansProLight',
  colorScheme: const ColorScheme.light(
    background: AppColors.lightBackground,
    primary: AppColors.lightPrimary,
    secondary: AppColors.lightSecondary,
    tertiary: AppColors.lightTertiary,
    error: AppColors.lightError,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onError: Colors.white,
    surface: AppColors.lightInputFill,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: AppColors.lightText,
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.lightText,
    ),
    bodyLarge: TextStyle(fontSize: 18, color: AppColors.lightText),
    bodyMedium: TextStyle(fontSize: 16, color: AppColors.lightText),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.lightText,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.lightInputFill,
    labelStyle: const TextStyle(color: AppColors.lightText),
    prefixIconColor: AppColors.lightPrimary,
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.lightBorder.withOpacity(0.4)),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.lightBorder, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.lightError),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.lightError, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 14),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
);
