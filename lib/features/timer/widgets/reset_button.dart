import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';

class ResetButton extends StatelessWidget {
  final VoidCallback onReset;

  const ResetButton({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticService.heavy();
        onReset();
      },
      child: Container(
        width: 200,
        height: 56,
        decoration: BoxDecoration(
          color: ClearStateColors.darkSurface,
          border: Border.all(color: ClearStateColors.borderDark, width: 1),
        ),
        child: Center(
          child: Text(
            'I SLIPPED UP',
            style: ClearStateTypography.button.copyWith(
              color: ClearStateColors.textSecondaryDark,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
