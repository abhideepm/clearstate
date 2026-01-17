import 'package:flutter/material.dart';
import 'colors.dart';

class ClearStateTypography {
  static const String fontFamily = 'JetBrains Mono';

  static TextStyle timerDisplay = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 72,
    fontWeight: FontWeight.w700,
    color: ClearStateColors.bone,
    letterSpacing: -2,
  );

  static TextStyle h1 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: ClearStateColors.bone,
    letterSpacing: 1,
  );

  static TextStyle body = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.bone,
    height: 1.5,
  );

  static TextStyle timerLabel = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: ClearStateColors.smoke,
    letterSpacing: 2,
  );

  static TextStyle statNumber = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: ClearStateColors.bone,
  );

  static TextStyle statLabel = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.smoke,
    letterSpacing: 1.5,
  );

  static TextStyle h2 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: ClearStateColors.bone,
  );

  static TextStyle h3 = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ClearStateColors.bone,
  );

  static TextStyle bodySecondary = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.smoke,
    height: 1.5,
  );

  static TextStyle caption = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.smoke,
    letterSpacing: 1,
  );

  static TextStyle button = const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ClearStateColors.bone,
    letterSpacing: 0.5,
  );
}
