import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Typography using DM Serif Display for headers and Plus Jakarta Sans for body
class ClearStateTypography {
  ClearStateTypography._();

  // Display font - elegant serif
  static String get displayFontFamily => GoogleFonts.dmSerifDisplay().fontFamily!;
  
  // Body font - modern warmth
  static String get bodyFontFamily => GoogleFonts.plusJakartaSans().fontFamily!;

  // Timer display - large, elegant
  static TextStyle get timerDisplay => GoogleFonts.dmSerifDisplay(
    fontSize: 72,
    fontWeight: FontWeight.w400,
    letterSpacing: -1,
    height: 1.0,
    color: ClearStateColors.textPrimaryDark,
  );

  // Timer label
  static TextStyle get timerLabel => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: ClearStateColors.textSecondaryDark,
  );

  // Headings - DM Serif Display
  static TextStyle get h1 => GoogleFonts.dmSerifDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: -0.5,
    color: ClearStateColors.textPrimaryDark,
  );

  static TextStyle get h2 => GoogleFonts.dmSerifDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: -0.3,
    color: ClearStateColors.textPrimaryDark,
  );

  static TextStyle get h3 => GoogleFonts.dmSerifDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: ClearStateColors.textPrimaryDark,
  );

  // Body text - Plus Jakarta Sans
  static TextStyle get body => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: ClearStateColors.textPrimaryDark,
  );

  static TextStyle get bodySecondary => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: ClearStateColors.textSecondaryDark,
  );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: ClearStateColors.textPrimaryDark,
  );

  static TextStyle get bodySemiBold => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: ClearStateColors.textPrimaryDark,
  );

  // Caption & small text
  static TextStyle get caption => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: ClearStateColors.textSecondaryDark,
  );

  static TextStyle get captionBold => GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: ClearStateColors.textSecondaryDark,
  );

  // Button text
  static TextStyle get button => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.0,
  );

  static TextStyle get buttonSmall => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Quote/emphasis text
  static TextStyle get quote => GoogleFonts.dmSerifDisplay(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    height: 1.4,
    color: ClearStateColors.lavender,
  );

  // Stat/number display
  static TextStyle get statLarge => GoogleFonts.dmSerifDisplay(
    fontSize: 48,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: ClearStateColors.textPrimaryDark,
  );

  static TextStyle get statMedium => GoogleFonts.dmSerifDisplay(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: ClearStateColors.textPrimaryDark,
  );

  // Navigation label
  static TextStyle get navLabel => GoogleFonts.plusJakartaSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    color: ClearStateColors.textSecondaryDark,
  );

  // Stat display styles
  static TextStyle get statNumber => GoogleFonts.dmSerifDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.1,
    color: ClearStateColors.textPrimaryDark,
  );

  static TextStyle get statLabel => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: ClearStateColors.textSecondaryDark,
  );
}
