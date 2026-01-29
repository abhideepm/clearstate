import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'colors.dart';

/// Theme mode for the app
enum AppThemeMode {
  system, // Follow system setting
  light,
  dark,
}

/// Accent color options
enum AccentColor {
  teal(TrueStateColors.accent, 'Teal'),
  electricBlue(Color(0xFF3B82F6), 'Electric Blue'),
  emerald(Color(0xFF22C55E), 'Emerald'),
  rose(Color(0xFFF43F5E), 'Rose'),
  lavender(Color(0xFFA78BFA), 'Lavender'),
  cyan(Color(0xFF06B6D4), 'Cyan'),
  gold(Color(0xFFF59E0B), 'Gold');

  final Color value;
  final String displayName;
  const AccentColor(this.value, this.displayName);
}

/// Theme state containing all theme-related settings
class ThemeState {
  final AccentColor accent;
  final AppThemeMode themeMode;
  final bool isDarkMode;
  final Color? customAccentColor;
  final BackgroundTheme? customBackground;

  const ThemeState({
    required this.accent,
    required this.themeMode,
    required this.isDarkMode,
    this.customAccentColor,
    this.customBackground,
  });

  ThemeState copyWith({
    AccentColor? accent,
    AppThemeMode? themeMode,
    bool? isDarkMode,
    Color? customAccentColor,
    BackgroundTheme? customBackground,
    bool clearCustomAccent = false,
  }) {
    return ThemeState(
      accent: accent ?? this.accent,
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      customAccentColor: clearCustomAccent ? null : (customAccentColor ?? this.customAccentColor),
      customBackground: customBackground ?? this.customBackground,
    );
  }

  // Convenience getters for current theme colors
  Color get background =>
      customBackground?.value ??
      (isDarkMode ? TrueStateColors.darkBackground : TrueStateColors.lightBackground);
  Color get surface =>
      isDarkMode ? TrueStateColors.darkSurface : TrueStateColors.lightSurface;
  Color get card =>
      isDarkMode ? TrueStateColors.darkCard : TrueStateColors.lightCard;
  Color get elevated =>
      isDarkMode ? TrueStateColors.darkElevated : TrueStateColors.lightElevated;
  Color get textPrimary =>
      isDarkMode ? TrueStateColors.textPrimaryDark : TrueStateColors.textPrimaryLight;
  Color get textSecondary =>
      isDarkMode ? TrueStateColors.textSecondaryDark : TrueStateColors.textSecondaryLight;
  Color get textMuted =>
      isDarkMode ? TrueStateColors.textMutedDark : TrueStateColors.textMutedLight;
  Color get border =>
      isDarkMode ? TrueStateColors.borderDark : TrueStateColors.borderLight;
  
  /// Returns the effective accent color (custom if set, otherwise from enum)
  Color get accentValue => customAccentColor ?? accent.value;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _boxName = 'theme_settings';
  static const String _accentKey = 'accent_color';
  static const String _themeModeKey = 'theme_mode';
  static const String _backgroundKey = 'background_theme';

  ThemeNotifier()
      : super(
          ThemeState(
            accent: AccentColor.teal,
            themeMode: AppThemeMode.dark,
            isDarkMode: true,
          ),
        ) {
    _loadTheme();
  }

  void _loadTheme() {
    try {
      final box = Hive.box(_boxName);
      final accentIndex = box.get(_accentKey, defaultValue: 0) as int;
      final themeModeIndex = box.get(_themeModeKey, defaultValue: 2) as int; // Default to dark
      final backgroundIndex = box.get(_backgroundKey, defaultValue: 0) as int;

      final themeMode = AppThemeMode.values[themeModeIndex.clamp(0, 2)];
      final isDarkMode = _resolveIsDarkMode(themeMode);

      state = ThemeState(
        accent: AccentColor.values[accentIndex.clamp(0, AccentColor.values.length - 1)],
        themeMode: themeMode,
        isDarkMode: isDarkMode,
        customBackground: BackgroundTheme.values[backgroundIndex.clamp(0, BackgroundTheme.values.length - 1)],
      );
    } catch (e) {
      // Use defaults on error
    }
  }

  bool _resolveIsDarkMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
    }
  }

  void setAccentColor(AccentColor accent) {
    state = state.copyWith(accent: accent);
    _saveTheme();
  }

  void setBackgroundColor(BackgroundTheme background) {
    state = state.copyWith(customBackground: background);
    _saveTheme();
  }

  /// Sets accent color from a hex color string (for habit theme colors)
  void setAccentColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return;
    
    try {
      final hex = hexColor.replaceFirst('#', '');
      final color = Color(int.parse('FF$hex', radix: 16));
      
      // Find matching AccentColor or use the custom color directly
      final matchingAccent = AccentColor.values.firstWhere(
        (a) => a.value.value == color.value,
        orElse: () => AccentColor.teal,
      );
      
      if (matchingAccent.value.value == color.value) {
        state = state.copyWith(accent: matchingAccent, clearCustomAccent: true);
      } else {
        state = state.copyWith(customAccentColor: color);
      }
    } catch (_) {
      // Ignore invalid hex colors
    }
  }

  void setThemeMode(AppThemeMode mode) {
    final isDarkMode = _resolveIsDarkMode(mode);
    state = state.copyWith(themeMode: mode, isDarkMode: isDarkMode);
    _saveTheme();
  }

  void toggleDarkMode() {
    final newMode = state.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    setThemeMode(newMode);
  }

  void _saveTheme() {
    try {
      final box = Hive.box(_boxName);
      box.put(_accentKey, state.accent.index);
      box.put(_themeModeKey, state.themeMode.index);
      box.put(_backgroundKey, state.customBackground?.index ?? 0);
    } catch (e) {
      // Silent fail for persistence errors
    }
  }
}

// Legacy enum for backward compatibility during transition
enum ThemeVibe { cyber, cozy }

// Legacy enum for backward compatibility
enum BackgroundTheme {
  void_(TrueStateColors.darkBackground),
  oledBlack(Color(0xFF000000)),
  charcoalDark(TrueStateColors.darkSurface),
  deepNavy(Color(0xFF0A1628)),
  texturedDark(TrueStateColors.darkCard);

  final Color value;
  const BackgroundTheme(this.value);
}
