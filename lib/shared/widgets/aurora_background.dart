import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Solid background wrapper - simplified from aurora effect
class AuroraBackground extends StatelessWidget {
  final double intensity;
  final List<Color>? colors;
  final Widget? child;

  const AuroraBackground({
    super.key,
    this.intensity = 1.0,
    this.colors,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TrueStateColors.deepCharcoal,
      child: child ?? const SizedBox.expand(),
    );
  }
}

/// Static overlay - simplified to transparent
class StaticAuroraOverlay extends StatelessWidget {
  final double opacity;

  const StaticAuroraOverlay({super.key, this.opacity = 0.3});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
