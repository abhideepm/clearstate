import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/services/haptic_service.dart';
import '../../shared/widgets/noise_background.dart';
import '../relapse/slip_vs_relapse_sheet.dart';
import '../urge_surfing/urge_surfing_screen.dart';
import 'widgets/timer_display.dart';
import 'widgets/status_indicator.dart';
import 'widgets/roi_cards.dart';
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
                const SizedBox(height: 24),
                // ROI Metrics
                const RoiCards(),
                const Spacer(flex: 3),
                // Reset button
                ResetButton(
                  onReset: () {
                    _showSlipVsRelapseSheet(context);
                  },
                ),
                const SizedBox(height: 24),
                // Urge surfing button
                TextButton(
                  onPressed: () {
                    HapticService.medium();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UrgeSurfingScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "I'M STRUGGLING",
                    style: ClearStateTypography.caption.copyWith(
                      color: ClearStateColors.smoke,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows the new Slip vs. Relapse sheet (anti-shame logic).
  void _showSlipVsRelapseSheet(BuildContext context) {
    HapticService.heavy();
    showModalBottomSheet(
      context: context,
      backgroundColor: ClearStateColors.charcoal,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      builder: (context) => const SlipVsRelapseSheet(),
    );
  }
}
