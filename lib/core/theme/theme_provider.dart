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
  teal(ClearStateColors.accent, 'Teal'),
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

  const ThemeState({
    required this.accent,
    required this.themeMode,
    required this.isDarkMode,
  });

  ThemeState copyWith({
    AccentColor? accent,
    AppThemeMode? themeMode,
    bool? isDarkMode,
  }) {
    return ThemeState(
      accent: accent ?? this.accent,
      themeMode: themeMode ?? this.themeMode,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  // Convenience getters for current theme colors
  Color get background =>
      isDarkMode ? ClearStateColors.darkBackground : ClearStateColors.lightBackground;
  Color get surface =>
      isDarkMode ? ClearStateColors.darkSurface : ClearStateColors.lightSurface;
  Color get card =>
      isDarkMode ? ClearStateColors.darkCard : ClearStateColors.lightCard;
  Color get elevated =>
      isDarkMode ? ClearStateColors.darkElevated : ClearStateColors.lightElevated;
  Color get textPrimary =>
      isDarkMode ? ClearStateColors.textPrimaryDark : ClearStateColors.textPrimaryLight;
  Color get textSecondary =>
      isDarkMode ? ClearStateColors.textSecondaryDark : ClearStateColors.textSecondaryLight;
  Color get textMuted =>
      isDarkMode ? ClearStateColors.textMutedDark : ClearStateColors.textMutedLight;
  Color get border =>
      isDarkMode ? ClearStateColors.borderDark : ClearStateColors.borderLight;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _boxName = 'theme_settings';
  static const String _accentKey = 'accent_color';
  static const String _themeModeKey = 'theme_mode';

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

      final themeMode = AppThemeMode.values[themeModeIndex.clamp(0, 2)];
      final isDarkMode = _resolveIsDarkMode(themeMode);

      state = ThemeState(
        accent: AccentColor.values[accentIndex.clamp(0, AccentColor.values.length - 1)],
        themeMode: themeMode,
        isDarkMode: isDarkMode,
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
    } catch (e) {
      // Silent fail for persistence errors
    }
  }
}

// Legacy enum for backward compatibility during transition
enum ThemeVibe { cyber, cozy }

// Legacy enum for backward compatibility
enum BackgroundTheme {
  void_(ClearStateColors.darkBackground),
  oledBlack(Color(0xFF000000)),
  charcoalDark(ClearStateColors.darkSurface),
  deepNavy(Color(0xFF0A1628)),
  texturedDark(ClearStateColors.darkCard);

  final Color value;
  const BackgroundTheme(this.value);
}
