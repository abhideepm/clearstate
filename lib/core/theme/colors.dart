import 'package:flutter/material.dart';

/// ClearState color system - Modern Fintech aesthetic
class ClearStateColors {
  // Primary Accent - Sun Yellow (fintech-inspired)
  static const Color sunYellow = Color(0xFFFFE500);
  static const Color sunYellowMuted = Color(0xFFD4BF00);

  // Dark Mode Backgrounds - Softer dark grays (not pure black)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkElevated = Color(0xFF262626);

  // Light Mode Backgrounds - Mint/Sage gradient inspired
  static const Color lightBackground = Color(0xFFE8F5E9);
  static const Color lightBackgroundSecondary = Color(0xFFF1F8E9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF5F5F5);

  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFFAFAFA);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textMutedDark = Color(0xFF808080);

  // Text Colors - Light Mode
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textMutedLight = Color(0xFF999999);

  // Borders & Dividers - Softer
  static const Color borderDark = Color(0xFF333333);
  static const Color borderLight = Color(0xFFE0E0E0);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Habit-specific accent colors
  static const Color habitAlcohol = Color(0xFFFFE500);
  static const Color habitNicotine = Color(0xFF64748B);
  static const Color habitCannabis = Color(0xFF22C55E);
  static const Color habitPorn = Color(0xFFEC4899);
  static const Color habitCaffeine = Color(0xFF92400E);

  // Gradients - Modern fintech
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sunYellow, Color(0xFFFFC107)],
  );

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightBackground, lightBackgroundSecondary],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBackground, darkSurface],
  );

  // Shadow definitions for modern cards
  static List<BoxShadow> get cardShadowLight => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> get cardShadowDark => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];

  // Legacy aliases for compatibility during transition
  static const Color sober = success;
  static const Color relapse = error;
  static const Color signal = sunYellow;
  static const Color bone = textPrimaryDark;
  static const Color smoke = textSecondaryDark;
  static const Color ash = borderDark;
  static const Color charcoal = darkSurface;
  static const Color void_ = darkBackground;
  static const Color oledBlack = Color(0xFF000000);
  static const Color acidGreen = Color(0xFFB0FF00);
  static const Color signalOrange = Color(0xFFFF4500);
}
