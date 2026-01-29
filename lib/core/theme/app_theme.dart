import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import 'theme_provider.dart';

/// TrueState Theme - Modern Fintech aesthetic
class TrueStateTheme {
  // Design constants - Increased radii for modern look
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusMedium = 16.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusXLarge = 28.0;

  /// Generate theme based on current theme state
  static ThemeData getThemeFromState(ThemeState themeState) {
    final isDark = themeState.isDarkMode;
    final accentColor = themeState.accent.value;

    return isDark
        ? _buildDarkTheme(accentColor)
        : _buildLightTheme(accentColor);
  }

  /// Build dark theme
  static ThemeData _buildDarkTheme(Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: TrueStateColors.darkBackground,
      colorScheme: ColorScheme.dark(
        surface: TrueStateColors.darkSurface,
        primary: accentColor,
        secondary: accentColor,
        error: TrueStateColors.error,
        onSurface: TrueStateColors.textPrimaryDark,
        onPrimary: TrueStateColors.darkBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TrueStateTypography.h3,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: TrueStateColors.darkSurface,
        selectedItemColor: accentColor,
        unselectedItemColor: TrueStateColors.textMutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: TrueStateColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: TrueStateColors.borderDark,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: TrueStateColors.darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accentColor,
          side: BorderSide(color: accentColor),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accentColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TrueStateColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        labelStyle: TrueStateTypography.caption,
        hintStyle: TrueStateTypography.bodySecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: TrueStateColors.darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: TrueStateColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadiusXLarge),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: TrueStateColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusXLarge),
        ),
      ),
    );
  }

  /// Build light theme
  static ThemeData _buildLightTheme(Color accentColor) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: TrueStateColors.lightBackground,
      colorScheme: ColorScheme.light(
        surface: TrueStateColors.lightSurface,
        primary: accentColor,
        secondary: accentColor,
        error: TrueStateColors.error,
        onSurface: TrueStateColors.textPrimaryLight,
        onPrimary: TrueStateColors.textPrimaryLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TrueStateTypography.h3.copyWith(
          color: TrueStateColors.textPrimaryLight,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: TrueStateColors.textPrimaryLight),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: TrueStateColors.lightSurface,
        selectedItemColor: accentColor,
        unselectedItemColor: TrueStateColors.textMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: TrueStateColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: TrueStateColors.borderLight,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: TrueStateColors.textPrimaryLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TrueStateColors.textPrimaryLight,
          side: BorderSide(color: TrueStateColors.borderLight),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accentColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TrueStateColors.lightElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        labelStyle: TrueStateTypography.caption.copyWith(
          color: TrueStateColors.textSecondaryLight,
        ),
        hintStyle: TrueStateTypography.bodySecondary.copyWith(
          color: TrueStateColors.textMutedLight,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: TrueStateColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(borderRadiusXLarge),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: TrueStateColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusXLarge),
        ),
      ),
    );
  }

  // Legacy getter for backward compatibility
  static ThemeData get darkTheme => _buildDarkTheme(TrueStateColors.accent);

  // Legacy method for backward compatibility
  static ThemeData getTheme(AccentColor accent, BackgroundTheme background) {
    return _buildDarkTheme(accent.value);
  }
}
