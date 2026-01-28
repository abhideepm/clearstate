import 'package:flutter/material.dart';
import 'colors.dart';

/// ClearState Typography - Modern clean sans-serif
class ClearStateTypography {
  // Using system fonts for clean modern look
  // iOS: SF Pro, Android: Roboto
  static const String fontFamily = '.SF Pro Display';
  static const String fontFamilyFallback = 'Roboto';

  static TextStyle timerDisplay = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 72,
    fontWeight: FontWeight.w700,
    color: ClearStateColors.textPrimaryDark,
    letterSpacing: -2,
  );

  static TextStyle h1 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: ClearStateColors.textPrimaryDark,
    letterSpacing: -0.5,
  );

  static TextStyle h2 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: ClearStateColors.textPrimaryDark,
    letterSpacing: -0.3,
  );

  static TextStyle h3 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ClearStateColors.textPrimaryDark,
    letterSpacing: -0.2,
  );

  static TextStyle body = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.textPrimaryDark,
    height: 1.5,
  );

  static TextStyle bodySecondary = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.textSecondaryDark,
    height: 1.5,
  );

  static TextStyle timerLabel = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ClearStateColors.textSecondaryDark,
    letterSpacing: 0.5,
  );

  static TextStyle statNumber = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: ClearStateColors.textPrimaryDark,
    letterSpacing: -0.5,
  );

  static TextStyle statLabel = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: ClearStateColors.textSecondaryDark,
    letterSpacing: 0.3,
  );

  static TextStyle caption = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.textSecondaryDark,
    letterSpacing: 0.2,
  );

  static TextStyle button = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ClearStateColors.textPrimaryDark,
    letterSpacing: 0.2,
  );

  static TextStyle navLabel = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: ClearStateColors.textSecondaryDark,
    letterSpacing: 0.2,
  );
}
