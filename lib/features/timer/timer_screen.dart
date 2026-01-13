import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/services/haptic_service.dart';
import '../../shared/widgets/noise_background.dart';
import 'widgets/timer_display.dart';
import 'widgets/status_indicator.dart';
import 'widgets/reset_button.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ClearStateColors.void_,
      body: NoiseBackground(
        opacity: 0.025,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Header
                Text(
                  'CLEARSTATE',
                  style: ClearStateTypography.timerLabel.copyWith(
                    fontSize: 14,
                    letterSpacing: 6,
                  ),
                ),
                const Spacer(flex: 2),
                // Timer
                const TimerDisplay(),
                const SizedBox(height: 32),
                // Status
                const StatusIndicator(),
                const Spacer(flex: 3),
                // Reset button
                ResetButton(
                  onReset: () {
                    // Show relapse flow
                    _showRelapseSheet(context);
                  },
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _showRelapseSheet(BuildContext context) {
    HapticService.heavy();
    showModalBottomSheet(
      context: context,
      backgroundColor: ClearStateColors.charcoal,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (context) => const _RelapseSheet(),
    );
  }
}

class _RelapseSheet extends StatelessWidget {
  const _RelapseSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ClearStateColors.ash,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'STANDARD SLIP-UP?',
            style: ClearStateTypography.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll log your default drink profile',
            style: ClearStateTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              HapticService.relapseConfirm();
              Navigator.pop(context);
              // TODO: Log standard relapse
            },
            child: const Text('YES, LOG IT'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              HapticService.light();
              Navigator.pop(context);
              // TODO: Show custom drink input
            },
            child: Text(
              'NO, LET ME SPECIFY',
              style: ClearStateTypography.button.copyWith(
                color: ClearStateColors.smoke,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
