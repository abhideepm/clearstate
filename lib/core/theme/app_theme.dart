import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';
import 'theme_provider.dart';

/// ClearState Theme - Modern Fintech aesthetic
class ClearStateTheme {
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
      scaffoldBackgroundColor: ClearStateColors.darkBackground,
      colorScheme: ColorScheme.dark(
        surface: ClearStateColors.darkSurface,
        primary: accentColor,
        secondary: accentColor,
        error: ClearStateColors.error,
        onSurface: ClearStateColors.textPrimaryDark,
        onPrimary: ClearStateColors.darkBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: ClearStateTypography.h3,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ClearStateColors.darkSurface,
        selectedItemColor: accentColor,
        unselectedItemColor: ClearStateColors.textMutedDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: ClearStateColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ClearStateColors.borderDark,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: ClearStateColors.darkBackground,
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
        fillColor: ClearStateColors.darkCard,
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
        labelStyle: ClearStateTypography.caption,
        hintStyle: ClearStateTypography.bodySecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ClearStateColors.darkCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ClearStateColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadiusXLarge)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ClearStateColors.darkSurface,
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
      scaffoldBackgroundColor: ClearStateColors.lightBackground,
      colorScheme: ColorScheme.light(
        surface: ClearStateColors.lightSurface,
        primary: accentColor,
        secondary: accentColor,
        error: ClearStateColors.error,
        onSurface: ClearStateColors.textPrimaryLight,
        onPrimary: ClearStateColors.textPrimaryLight,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: ClearStateTypography.h3.copyWith(
          color: ClearStateColors.textPrimaryLight,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: ClearStateColors.textPrimaryLight),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: ClearStateColors.lightSurface,
        selectedItemColor: accentColor,
        unselectedItemColor: ClearStateColors.textMutedLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: CardThemeData(
        color: ClearStateColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusLarge),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ClearStateColors.borderLight,
        thickness: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: ClearStateColors.textPrimaryLight,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ClearStateColors.textPrimaryLight,
          side: BorderSide(color: ClearStateColors.borderLight),
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
        fillColor: ClearStateColors.lightElevated,
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
        labelStyle: ClearStateTypography.caption.copyWith(
          color: ClearStateColors.textSecondaryLight,
        ),
        hintStyle: ClearStateTypography.bodySecondary.copyWith(
          color: ClearStateColors.textMutedLight,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: ClearStateColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadiusXLarge)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ClearStateColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusXLarge),
        ),
      ),
    );
  }

  // Legacy getter for backward compatibility
  static ThemeData get darkTheme => _buildDarkTheme(ClearStateColors.accent);

  // Legacy method for backward compatibility
  static ThemeData getTheme(AccentColor accent, BackgroundTheme background) {
    return _buildDarkTheme(accent.value);
  }
}
