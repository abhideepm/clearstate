import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';

class RestoreConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const RestoreConfirmationDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ClearStateColors.void_,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RESTORE DATA?',
              style: ClearStateTypography.timerLabel.copyWith(
                color: ClearStateColors.signal,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This will permanently overwrite all your current data with the contents of the backup file. This cannot be undone.',
              style: ClearStateTypography.body.copyWith(
                color: ClearStateColors.smoke,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'CANCEL',
                    style: ClearStateTypography.caption.copyWith(
                      color: ClearStateColors.ash,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    HapticService.heavy();
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ClearStateColors.signal,
                    foregroundColor: ClearStateColors.void_,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  child: const Text('RESTORE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
