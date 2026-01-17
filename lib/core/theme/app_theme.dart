import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import 'theme_provider.dart';

class ClearStateTheme {
  static ThemeData getTheme(AccentColor accent, BackgroundTheme background) {
    final accentColor = accent.value;
    final backgroundColor = background.value;

    // Determine card/surface colors based on background
    final surfaceColor = background == BackgroundTheme.void_
        ? ClearStateColors.charcoal
        : backgroundColor.withValues(
            alpha: 0.05,
          ); // Use withValues instead of withOpacity

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: ColorScheme.dark(
        surface: backgroundColor,
        primary: accentColor,
        secondary: accentColor,
        error: ClearStateColors.relapse,
        onSurface: ClearStateColors.bone,
        onPrimary: backgroundColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: ClearStateTypography.h3,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: accentColor,
        unselectedItemColor: ClearStateColors.smoke,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: ClearStateColors.ash, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ClearStateColors.ash,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: backgroundColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accentColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: ClearStateColors.ash),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: ClearStateColors.ash),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide(color: accentColor),
        ),
        labelStyle: ClearStateTypography.caption,
        hintStyle: ClearStateTypography.bodySecondary,
      ),
    );
  }

  // Keep old getter for backward compatibility if needed, but updated to use default
  static ThemeData get darkTheme {
    return getTheme(AccentColor.signalOrange, BackgroundTheme.void_);
  }
}
