import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/services/haptic_service.dart';
import '../../shared/widgets/noise_background.dart';
import 'urge_surfing_provider.dart';
import 'widgets/breathing_circle.dart';

/// Full-screen immersive breathing exercise for urge surfing.
/// Uses the 4-7-8 breathing pattern to help users ride out cravings.
class UrgeSurfingScreen extends ConsumerStatefulWidget {
  const UrgeSurfingScreen({super.key});

  @override
  ConsumerState<UrgeSurfingScreen> createState() => _UrgeSurfingScreenState();
}

class _UrgeSurfingScreenState extends ConsumerState<UrgeSurfingScreen> {
  BreathingPhase? _lastPhase;

  @override
  void initState() {
    super.initState();
    // Start the exercise when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(urgeSurfingProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(urgeSurfingProvider);

    // Trigger haptic on phase change
    if (_lastPhase != null && _lastPhase != state.phase && state.isActive) {
      HapticService.light();
    }
    _lastPhase = state.phase;

    // Auto-exit when timer completes
    if (!state.isActive && state.remainingSeconds == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          HapticService.success();
          Navigator.of(context).pop();
        }
      });
    }

    return Scaffold(
      backgroundColor: ClearStateColors.darkBackground,
      body: DawnBackground(
        opacity: 0.02,
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Header
                Text(
                  'BREATHE',
                  textAlign: TextAlign.center,
                  style: ClearStateTypography.timerDisplay.copyWith(
                    fontSize: 48,
                    letterSpacing: 8,
                    color: ClearStateColors.textPrimaryDark,
                  ),
                ),
                const Spacer(flex: 2),
                // Breathing circle
                BreathingCircle(phase: state.phase, isActive: state.isActive),
                const SizedBox(height: 48),
                // Phase text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    state.phaseText,
                    key: ValueKey(state.phase),
                    textAlign: TextAlign.center,
                    style: ClearStateTypography.h1.copyWith(
                      fontSize: 24,
                      letterSpacing: 6,
                      color: ClearStateColors.textSecondaryDark,
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                // Countdown timer
                Text(
                  state.formattedTime,
                  textAlign: TextAlign.center,
                  style: ClearStateTypography.statNumber.copyWith(
                    fontSize: 20,
                    color: ClearStateColors.textSecondaryDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'REMAINING',
                  textAlign: TextAlign.center,
                  style: ClearStateTypography.timerLabel.copyWith(
                    fontSize: 10,
                    color: ClearStateColors.borderDark,
                  ),
                ),
                const SizedBox(height: 40),
                // Exit button
                TextButton(
                  onPressed: () {
                    HapticService.medium();
                    ref.read(urgeSurfingProvider.notifier).stop();
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: Text(
                    "I'M OKAY NOW",
                    style: ClearStateTypography.button.copyWith(
                      color: ClearStateColors.textPrimaryDark,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
