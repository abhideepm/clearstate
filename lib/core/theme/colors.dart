import 'package:flutter/material.dart';

enum ThemeVibe { cyber, cozy }

class ClearStateColors {
  // Cyber (Brutalist) Palette
  static const Color oledBlack = Color(0xFF000000);
  static const Color charcoal = Color(0xFF0F0F0F);
  static const Color graphite = Color(0xFF1C1C1C);
  static const Color acidGreen = Color(0xFFB0FF00);
  static const Color hyperViolet = Color(0xFF8A2BE2);
  static const Color signalOrange = Color(0xFFFF4500);

  // Cozy (Nature) Palette
  static const Color cream = Color(0xFFFAF9F6);
  static const Color warmTaupe = Color(0xFF2D241E);
  static const Color sageGreen = Color(0xFF8A9A5B);
  static const Color terracotta = Color(0xFFE2725B);
  static const Color softClay = Color(0xFFD2B48C);
  static const Color morningMist = Color(0xFFE5E4E2);

  // Common Text & UI
  static const Color bone = Color(0xFFE8E8E8);
  static const Color smoke = Color(0xFF5C5C5C);
  static const Color ash = Color(0xFF2A2A2A);

  // Semantic
  static const Color sober = acidGreen;
  static const Color relapse = signalOrange;

  // Back-compat aliases
  static const Color signal = signalOrange;
  static const Color void_ = oledBlack;

  static Color getVibeAccent(ThemeVibe vibe) {
    return vibe == ThemeVibe.cyber ? acidGreen : sageGreen;
  }

  static Color getVibeBackground(ThemeVibe vibe) {
    return vibe == ThemeVibe.cyber ? oledBlack : warmTaupe;
  }
}
