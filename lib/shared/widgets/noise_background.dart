import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/theme_provider.dart';

/// Modern gradient background that replaces the brutalist noise texture
class NoiseBackground extends ConsumerWidget {
  final Widget child;
  final double opacity;

  const NoiseBackground({
    super.key,
    required this.child,
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
      child: child,
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
