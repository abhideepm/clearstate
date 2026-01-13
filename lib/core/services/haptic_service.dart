import 'package:flutter/services.dart';

/// Centralized haptic feedback service for consistent tactile experience.
/// Uses iOS-style haptic patterns for that premium feel.
class HapticService {
  /// Light tap - used for selections, toggles, and minor interactions
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium tap - used for confirmations and moderate actions
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy thud - used for significant actions like timer reset
  /// This simulates the "weight" of a major decision
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click - used for scrolling through options
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate pattern - used for errors or warnings
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Success pattern - light then medium
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// Error pattern - heavy vibration
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.heavyImpact();
  }

  /// Timer tick - very subtle feedback for optional timer ticks
  static Future<void> tick() async {
    await HapticFeedback.selectionClick();
  }

  /// Milestone reached - celebratory pattern
  static Future<void> milestone() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    await HapticFeedback.mediumImpact();
  }

  /// Relapse confirmation - heavy, deliberate pattern
  /// Simulates the gravity of resetting the timer
  static Future<void> relapseConfirm() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }

  /// Button press start - feedback when starting a long press
  static Future<void> buttonDown() async {
    await HapticFeedback.lightImpact();
  }

  /// Button press complete - feedback when long press completes
  static Future<void> buttonComplete() async {
    await HapticFeedback.heavyImpact();
  }
}
