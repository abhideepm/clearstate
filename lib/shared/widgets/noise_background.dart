import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A widget that adds a subtle noise texture overlay to create depth.
/// This gives the brutalist design a tactile, printed-paper quality.
class NoiseBackground extends ConsumerWidget {
  final Widget child;
  final double opacity;
  final Color? backgroundColor;

  const NoiseBackground({
    super.key,
    required this.child,
    this.opacity = 0.03,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final bgOpacity = themeState.background == BackgroundTheme.texturedDark
        ? 0.05
        : 0.03;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: backgroundColor ?? themeState.background.value,
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: NoisePainter(opacity: opacity > 0 ? opacity : bgOpacity),
          ),
        ),
        child,
      ],
    );
  }
}

/// Custom painter that generates a static noise pattern.
/// Uses a seeded random for consistent appearance across rebuilds.
class NoisePainter extends CustomPainter {
  final double opacity;
  final int seed;

  NoisePainter({this.opacity = 0.03, this.seed = 42});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint();

    // Density of noise points (lower = more sparse, higher = denser)
    const density = 0.15;
    final totalPoints = (size.width * size.height * density).toInt();

    for (int i = 0; i < totalPoints; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Vary the brightness of each noise point
      final brightness = random.nextDouble();
      final alpha = (opacity * brightness * 255).toInt();

      paint.color = Color.fromARGB(alpha, 255, 255, 255);

      // Draw tiny rectangles for a more pixelated look
      canvas.drawRect(Rect.fromLTWH(x, y, 1, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant NoisePainter oldDelegate) {
    return oldDelegate.opacity != opacity || oldDelegate.seed != seed;
  }
}

/// A more performant noise overlay using a pre-generated pattern.
/// This is better for animations and scrolling content.
class CachedNoiseBackground extends StatefulWidget {
  final Widget child;
  final double opacity;
  final Color? backgroundColor;

  const CachedNoiseBackground({
    super.key,
    required this.child,
    this.opacity = 0.03,
    this.backgroundColor,
  });

  @override
  State<CachedNoiseBackground> createState() => _CachedNoiseBackgroundState();
}

class _CachedNoiseBackgroundState extends State<CachedNoiseBackground> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base background
        Positioned.fill(
          child: Container(
            color: widget.backgroundColor ?? ClearStateColors.void_,
          ),
        ),
        // Noise overlay using shader mask for performance
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: NoisePainter(opacity: widget.opacity),
              willChange: false,
              isComplex: true,
            ),
          ),
        ),
        // Content
        widget.child,
      ],
    );
  }
}
