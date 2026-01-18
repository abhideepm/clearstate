import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract interface for haptic feedback to enable testing.
abstract class IHapticService {
  Future<void> lightFeedback();
  Future<void> mediumFeedback();
  Future<void> heavyFeedback();
  Future<void> selectionFeedback();
  Future<void> vibrateFeedback();
  Future<void> successFeedback();
  Future<void> errorFeedback();
  Future<void> tickFeedback();
  Future<void> milestoneFeedback();
  Future<void> relapseConfirmFeedback();
  Future<void> buttonDownFeedback();
  Future<void> buttonCompleteFeedback();
}

/// Centralized haptic feedback service for consistent tactile experience.
/// Uses iOS-style haptic patterns for that premium feel.
///
/// For testability, use the provider (hapticServiceProvider) which can be
/// overridden with MockHapticService in tests.
///
/// For convenience in widgets, static methods are provided that delegate
/// to the singleton instance.
class HapticService implements IHapticService {
  static final HapticService _instance = HapticService._internal();

  /// Singleton instance for provider-based access.
  static HapticService get instance => _instance;

  HapticService._internal();

  // Static convenience methods (for backward compatibility)

  /// Light tap - used for selections, toggles, and minor interactions
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium tap - used for confirmations and moderate actions
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy thud - used for significant actions like timer reset
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

  // Instance methods (implement IHapticService for testing)

  @override
  Future<void> lightFeedback() => light();
  @override
  Future<void> mediumFeedback() => medium();
  @override
  Future<void> heavyFeedback() => heavy();
  @override
  Future<void> selectionFeedback() => selection();
  @override
  Future<void> vibrateFeedback() => vibrate();
  @override
  Future<void> successFeedback() => success();
  @override
  Future<void> errorFeedback() => error();
  @override
  Future<void> tickFeedback() => tick();
  @override
  Future<void> milestoneFeedback() => milestone();
  @override
  Future<void> relapseConfirmFeedback() => relapseConfirm();
  @override
  Future<void> buttonDownFeedback() => buttonDown();
  @override
  Future<void> buttonCompleteFeedback() => buttonComplete();
}

/// Provider for HapticService.
/// Override in tests with a mock implementation.
final hapticServiceProvider = Provider<IHapticService>((ref) {
  return HapticService.instance;
});

/// Mock implementation for testing.
class MockHapticService implements IHapticService {
  final List<String> calls = [];

  @override
  Future<void> lightFeedback() async => calls.add('light');
  @override
  Future<void> mediumFeedback() async => calls.add('medium');
  @override
  Future<void> heavyFeedback() async => calls.add('heavy');
  @override
  Future<void> selectionFeedback() async => calls.add('selection');
  @override
  Future<void> vibrateFeedback() async => calls.add('vibrate');
  @override
  Future<void> successFeedback() async => calls.add('success');
  @override
  Future<void> errorFeedback() async => calls.add('error');
  @override
  Future<void> tickFeedback() async => calls.add('tick');
  @override
  Future<void> milestoneFeedback() async => calls.add('milestone');
  @override
  Future<void> relapseConfirmFeedback() async => calls.add('relapseConfirm');
  @override
  Future<void> buttonDownFeedback() async => calls.add('buttonDown');
  @override
  Future<void> buttonCompleteFeedback() async => calls.add('buttonComplete');

  void clear() => calls.clear();
}
