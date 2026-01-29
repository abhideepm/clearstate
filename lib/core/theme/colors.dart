import 'package:flutter/material.dart';

/// Teal theme - modern, calm, focused
class TrueStateColors {
  TrueStateColors._();

  // Primary accent colors - vibrant teal
  static const Color accent = Color(0xFF20D5C2);
  static const Color accentLight = Color(0xFF5EEAD4);
  
  // Background colors - deep charcoal tones
  static const Color charcoal = Color(0xFF1A1D23);
  static const Color deepCharcoal = Color(0xFF13151A);
  static const Color midCharcoal = Color(0xFF252830);
  
  // Semantic colors
  static const Color success = Color(0xFF20D5C2);
  static const Color error = Color(0xFFF87171);
  static const Color warning = Color(0xFFFBBF24);

  // Text colors - clean whites to muted grays
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color textMutedDark = Color(0xFF475569);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF94A3B8);

  // Surface & card colors
  static const Color darkBackground = Color(0xFF13151A);
  static const Color darkSurface = Color(0xFF1A1D23);
  static const Color darkCard = Color(0xFF252830);
  static const Color darkElevated = Color(0xFF2E323C);
  
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFFFFFFF);

  // Border colors
  static const Color borderDark = Color(0xFF374151);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Glass morphism overlays
  static const Color glassOverlayDark = Color(0x1AFFFFFF);
  static const Color glassOverlayLight = Color(0x80FFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x4DFFFFFF);

  // Aurora gradient colors - teal theme
  static const List<Color> auroraColors = [
    Color(0x2614B8A6), // teal glow
    Color(0x1A2DD4BF), // cyan
    Color(0x14F4D58D), // gold hint
    Color(0x0D94A3B8), // neutral
  ];

  // Background gradients (solid color - no gradient)
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF13151A),
      Color(0xFF13151A),
    ],
  );

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8FAFC),
      Color(0xFFF1F5F9),
    ],
  );

  // Accent gradient
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  // Glow shadow for glass cards
  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: accent.withValues(alpha: 0.25),
      blurRadius: 24,
      spreadRadius: 2,
    ),
  ];

  // Card shadows
  static const List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Color(0x40000000),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  static const List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Color(0x12000000),
      offset: Offset(0, 4),
      blurRadius: 16,
    ),
  ];

  // Pro feature accent
  static const Color acidGreen = Color(0xFFB0FF00);
  
  // Legacy/alias mappings for compatibility
  static const Color mint = accent;
  static const Color seafoam = accentLight;
  static const Color gold = accent;
  static const Color warmGold = accentLight;
  static const Color lavender = accent;
  static const Color roseGold = accent;
  static const Color sunriseGold = accent;
  static const Color dawnCoral = accentLight;
  static const Color warmIvory = textPrimaryDark;
  static const Color morningMist = textSecondaryDark;
  static const Color deepForest = charcoal;
  static const Color moss = success;
  static const Color twilightPurple = midCharcoal;
  static const Color midPurple = midCharcoal;
}
