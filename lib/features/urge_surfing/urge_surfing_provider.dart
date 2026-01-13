import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Breathing phases for the 4-7-8 pattern
enum BreathingPhase {
  inhale, // 4 seconds
  hold, // 7 seconds
  exhale, // 8 seconds
}

/// State for the urge surfing exercise
class UrgeSurfingState {
  final BreathingPhase phase;
  final int remainingSeconds;
  final int cycleCount;
  final int phaseSecondsRemaining;
  final bool isActive;

  const UrgeSurfingState({
    this.phase = BreathingPhase.inhale,
    this.remainingSeconds = 180, // 3 minutes
    this.cycleCount = 0,
    this.phaseSecondsRemaining = 4,
    this.isActive = false,
  });

  UrgeSurfingState copyWith({
    BreathingPhase? phase,
    int? remainingSeconds,
    int? cycleCount,
    int? phaseSecondsRemaining,
    bool? isActive,
  }) {
    return UrgeSurfingState(
      phase: phase ?? this.phase,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      cycleCount: cycleCount ?? this.cycleCount,
      phaseSecondsRemaining:
          phaseSecondsRemaining ?? this.phaseSecondsRemaining,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Get the duration for each phase in seconds
  static int phaseDuration(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return 4;
      case BreathingPhase.hold:
        return 7;
      case BreathingPhase.exhale:
        return 8;
    }
  }

  /// Get display text for the current phase
  String get phaseText {
    switch (phase) {
      case BreathingPhase.inhale:
        return 'INHALE';
      case BreathingPhase.hold:
        return 'HOLD';
      case BreathingPhase.exhale:
        return 'EXHALE';
    }
  }

  /// Format remaining time as MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Notifier for managing urge surfing state
class UrgeSurfingNotifier extends StateNotifier<UrgeSurfingState> {
  Timer? _timer;
  final void Function()? onPhaseChange;

  UrgeSurfingNotifier({this.onPhaseChange}) : super(const UrgeSurfingState());

  /// Start the breathing exercise
  void start() {
    if (state.isActive) return;

    state = state.copyWith(
      isActive: true,
      phase: BreathingPhase.inhale,
      phaseSecondsRemaining: UrgeSurfingState.phaseDuration(
        BreathingPhase.inhale,
      ),
      remainingSeconds: 180,
      cycleCount: 0,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// Stop the breathing exercise
  void stop() {
    _timer?.cancel();
    _timer = null;
    state = const UrgeSurfingState();
  }

  /// Handle each second tick
  void _tick() {
    if (!state.isActive) return;

    // Decrement overall timer
    final newRemainingSeconds = state.remainingSeconds - 1;

    // Check if exercise is complete
    if (newRemainingSeconds <= 0) {
      stop();
      return;
    }

    // Decrement phase timer
    final newPhaseSeconds = state.phaseSecondsRemaining - 1;

    if (newPhaseSeconds <= 0) {
      // Advance to next phase
      _advancePhase(newRemainingSeconds);
    } else {
      state = state.copyWith(
        remainingSeconds: newRemainingSeconds,
        phaseSecondsRemaining: newPhaseSeconds,
      );
    }
  }

  /// Advance to the next breathing phase
  void _advancePhase(int remainingSeconds) {
    BreathingPhase nextPhase;
    int newCycleCount = state.cycleCount;

    switch (state.phase) {
      case BreathingPhase.inhale:
        nextPhase = BreathingPhase.hold;
        break;
      case BreathingPhase.hold:
        nextPhase = BreathingPhase.exhale;
        break;
      case BreathingPhase.exhale:
        nextPhase = BreathingPhase.inhale;
        newCycleCount = state.cycleCount + 1;
        break;
    }

    state = state.copyWith(
      phase: nextPhase,
      phaseSecondsRemaining: UrgeSurfingState.phaseDuration(nextPhase),
      remainingSeconds: remainingSeconds,
      cycleCount: newCycleCount,
    );

    // Trigger haptic callback
    onPhaseChange?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider for urge surfing state
final urgeSurfingProvider =
    StateNotifierProvider.autoDispose<UrgeSurfingNotifier, UrgeSurfingState>(
      (ref) => UrgeSurfingNotifier(),
    );
