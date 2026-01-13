import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

class ClearStateTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ClearStateColors.void_,
      colorScheme: const ColorScheme.dark(
        surface: ClearStateColors.void_,
        primary: ClearStateColors.signal,
        secondary: ClearStateColors.signal,
        error: ClearStateColors.relapse,
        onSurface: ClearStateColors.bone,
        onPrimary: ClearStateColors.void_,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ClearStateColors.void_,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: ClearStateTypography.h3,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ClearStateColors.void_,
        selectedItemColor: ClearStateColors.signal,
        unselectedItemColor: ClearStateColors.smoke,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: ClearStateColors.charcoal,
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
          backgroundColor: ClearStateColors.signal,
          foregroundColor: ClearStateColors.void_,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: ClearStateColors.signal),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ClearStateColors.charcoal,
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
          borderSide: const BorderSide(color: ClearStateColors.signal),
        ),
        labelStyle: ClearStateTypography.caption,
        hintStyle: ClearStateTypography.bodySecondary,
      ),
    );
  }
}
