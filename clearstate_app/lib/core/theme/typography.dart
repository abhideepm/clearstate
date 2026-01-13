import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class ClearStateTypography {
  // Timer display - Bebas Neue, massive
  static TextStyle timerDisplay = GoogleFonts.bebasNeue(
    fontSize: 96,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.bone,
    letterSpacing: 2,
    height: 1.0,
  );

  // Timer labels (DAYS, HOURS, etc)
  static TextStyle timerLabel = GoogleFonts.ibmPlexMono(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: ClearStateColors.smoke,
    letterSpacing: 2,
  );

  // Stats/numbers - IBM Plex Mono
  static TextStyle statNumber = GoogleFonts.ibmPlexMono(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: ClearStateColors.bone,
  );

  static TextStyle statLabel = GoogleFonts.ibmPlexMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.smoke,
    letterSpacing: 1.5,
  );

  // Headings - Chivo
  static TextStyle h1 = GoogleFonts.chivo(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: ClearStateColors.bone,
  );

  static TextStyle h2 = GoogleFonts.chivo(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: ClearStateColors.bone,
  );

  static TextStyle h3 = GoogleFonts.chivo(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: ClearStateColors.bone,
  );

  // Body - Chivo
  static TextStyle body = GoogleFonts.chivo(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.bone,
    height: 1.5,
  );

  static TextStyle bodySecondary = GoogleFonts.chivo(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.smoke,
    height: 1.5,
  );

  // Caption
  static TextStyle caption = GoogleFonts.ibmPlexMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: ClearStateColors.smoke,
    letterSpacing: 1,
  );

  // Button text
  static TextStyle button = GoogleFonts.chivo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ClearStateColors.bone,
    letterSpacing: 0.5,
  );
}
