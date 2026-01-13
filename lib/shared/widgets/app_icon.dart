import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Brutalist typographic app icon widget.
/// Can be used for in-app branding or exported as icon.
class AppIconWidget extends StatelessWidget {
  final double size;
  final bool showBorder;

  const AppIconWidget({
    super.key,
    this.size = 120,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ClearStateColors.void_,
        border: showBorder
            ? Border.all(color: ClearStateColors.ash, width: 1)
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
            child: Container(
              color: ClearStateColors.signal,
            ),
          ),
          // Typography
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'CS',
                  style: ClearStateTypography.timerDisplay.copyWith(
                    fontSize: size * 0.45,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                ),
                SizedBox(height: size * 0.02),
                Text(
                  'CLEAR',
                  style: ClearStateTypography.timerLabel.copyWith(
                    fontSize: size * 0.08,
                    letterSpacing: size * 0.02,
                    color: ClearStateColors.smoke,
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

  const AppIconMinimal({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: ClearStateColors.void_,
      ),
      child: Stack(
        children: [
          // Signal accent bar at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: size * 0.12,
            child: Container(
              color: ClearStateColors.signal,
            ),
          ),
          // Just "CS" letters
          Center(
            child: Text(
              'CS',
              style: ClearStateTypography.timerDisplay.copyWith(
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
