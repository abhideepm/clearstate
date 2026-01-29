import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Brutalist typographic app icon widget.
/// Can be used for in-app branding or exported as icon.
class AppIconWidget extends StatelessWidget {
  final double size;
  final bool showBorder;

  const AppIconWidget({super.key, this.size = 120, this.showBorder = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: TrueStateColors.darkBackground,
        border: showBorder
            ? Border.all(color: TrueStateColors.borderDark, width: 1)
            : null,
      ),
      child: Stack(
        children: [
          // Background gradient accent
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size * 0.15,
            child: Container(color: TrueStateColors.dawnCoral),
          ),
          // Typography
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CS',
                  style: TrueStateTypography.timerDisplay.copyWith(
                    fontSize: size * 0.45,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                ),
                SizedBox(height: size * 0.02),
                Text(
                  'CLEAR',
                  style: TrueStateTypography.timerLabel.copyWith(
                    fontSize: size * 0.08,
                    letterSpacing: size * 0.02,
                    color: TrueStateColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal icon version for small sizes (like app launcher)
class AppIconMinimal extends StatelessWidget {
  final double size;

  const AppIconMinimal({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: TrueStateColors.darkBackground),
      child: Stack(
        children: [
          // Signal accent bar at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size * 0.12,
            child: Container(color: TrueStateColors.dawnCoral),
          ),
          // Just "CS" letters
          Center(
            child: Text(
              'CS',
              style: TrueStateTypography.timerDisplay.copyWith(
                fontSize: size * 0.5,
                height: 1.0,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
