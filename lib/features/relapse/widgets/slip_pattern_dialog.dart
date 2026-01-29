import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';

/// Non-judgmental dialog shown when user has 3+ slips in a week.
/// Offers option to recategorize as a relapse or continue with slips.
class SlipPatternDialog extends StatelessWidget {
  final VoidCallback onKeepAsSlips;
  final Future<void> Function() onConvertToRelapse;

  const SlipPatternDialog({
    super.key,
    required this.onKeepAsSlips,
    required this.onConvertToRelapse,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ClearStateColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ClearStateColors.borderDark),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: ClearStateColors.dawnCoral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.insights,
                color: ClearStateColors.dawnCoral,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'A GENTLE OBSERVATION',
              style: ClearStateTypography.h3.copyWith(
                color: ClearStateColors.dawnCoral,
              ),
            ),
            const SizedBox(height: 12),

            Text(
              "You've had a few slips recently. This isn't judgment—just a moment to reflect.",
              style: ClearStateTypography.body.copyWith(
                color: ClearStateColors.textPrimaryDark,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Some people find it helpful to reset and start fresh. Others prefer to continue tracking slips separately. There is no wrong choice.',
              style: ClearStateTypography.bodySecondary.copyWith(height: 1.5),
            ),
            const SizedBox(height: 28),

            // Keep as slips option
            OutlinedButton(
              onPressed: () {
                HapticService.light();
                onKeepAsSlips();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: ClearStateColors.borderDark),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'KEEP AS SLIPS',
                style: ClearStateTypography.button.copyWith(
                  color: ClearStateColors.textPrimaryDark,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Convert to relapse option
            ElevatedButton(
              onPressed: () async {
                HapticService.medium();
                await onConvertToRelapse();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ClearStateColors.dawnCoral,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('RESET AND START FRESH'),
            ),
          ],
        ),
      ),
    );
  }
}
