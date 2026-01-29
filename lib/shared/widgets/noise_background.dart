import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/theme_provider.dart';
import 'aurora_background.dart';

/// DAWN background with optional animated aurora overlay
class DawnBackground extends ConsumerWidget {
  final Widget child;
  final bool showAurora;
  final double auroraIntensity;
  final double opacity; // Legacy parameter, now controls aurora intensity

  const DawnBackground({
    super.key,
    required this.child,
    this.showAurora = true,
    this.auroraIntensity = 1.0,
    this.opacity = 0.02,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? ClearStateColors.darkBackgroundGradient
            : ClearStateColors.lightBackgroundGradient,
      ),
      child: showAurora
          ? Stack(
              children: [
                Positioned.fill(
                  child: AuroraBackground(intensity: auroraIntensity),
                ),
                child,
              ],
            )
          : child,
    );
  }
}

/// Simple gradient container for custom gradient usage
class GradientBackground extends StatelessWidget {
  final Widget child;
  final LinearGradient gradient;

  const GradientBackground({
    super.key,
    required this.child,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: child,
    );
  }
}
