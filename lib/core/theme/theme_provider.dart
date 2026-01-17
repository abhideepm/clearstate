import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccentColor {
  signalOrange(Color(0xFFFF6B35)),
  electricBlue(Color(0xFF3B82F6)),
  emerald(Color(0xFF10B981)),
  lavender(Color(0xFFA78BFA)),
  rose(Color(0xFFF43F5E)),
  pureWhite(Color(0xFFFFFFFF)),
  cyan(Color(0xFF06B6D4)),
  gold(Color(0xFFF59E0B));

  final Color value;
  const AccentColor(this.value);

  Color get complementary {
    final hsl = HSLColor.fromColor(value);
    return hsl.withHue((hsl.hue + 180) % 360).toColor();
  }
}

enum BackgroundTheme {
  void_(Color(0xFF050505)),
  oledBlack(Color(0xFF000000)),
  charcoalDark(Color(0xFF0F0F0F)),
  deepNavy(Color(0xFF0A1628)),
  texturedDark(Color(0xFF121212));

  final Color value;
  const BackgroundTheme(this.value);
}

class ThemeState {
  final AccentColor accent;
  final BackgroundTheme background;

  ThemeState({required this.accent, required this.background});

  ThemeState copyWith({AccentColor? accent, BackgroundTheme? background}) {
    return ThemeState(
      accent: accent ?? this.accent,
      background: background ?? this.background,
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeState> {
  static const String _boxName = 'theme_settings';
  static const String _accentKey = 'accent_color';
  static const String _backgroundKey = 'background_theme';

  ThemeNotifier()
    : super(
        ThemeState(
          accent: AccentColor.signalOrange,
          background: BackgroundTheme.void_,
        ),
      ) {
    _loadTheme();
  }

  void _loadTheme() {
    try {
      final box = Hive.box(_boxName);
      final accentIndex = box.get(_accentKey, defaultValue: 0) as int;
      final backgroundIndex = box.get(_backgroundKey, defaultValue: 0) as int;
      state = ThemeState(
        accent: AccentColor.values[accentIndex],
        background: BackgroundTheme.values[backgroundIndex],
      );
    } catch (e) {
      state = ThemeState(
        accent: AccentColor.signalOrange,
        background: BackgroundTheme.void_,
      );
    }
  }

  void setAccentColor(AccentColor accent) {
    state = state.copyWith(accent: accent);
    _saveTheme();
  }

  void setBackgroundTheme(BackgroundTheme background) {
    state = state.copyWith(background: background);
    _saveTheme();
  }

  void _saveTheme() {
    try {
      final box = Hive.box(_boxName);
      box.put(_accentKey, state.accent.index);
      box.put(_backgroundKey, state.background.index);
    } catch (e) {
      // Silent fail for persistence errors
    }
  }
}
