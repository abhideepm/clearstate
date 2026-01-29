import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/motion.dart';

/// Sunrise logo with DAWN aesthetic - warm gradient fill and optional glow
class SunriseLogo extends StatelessWidget {
  final double size;
  final Color? accentColor;
  final bool showLabel;
  final bool showGlow;

  const SunriseLogo({
    super.key,
    this.size = 80,
    this.accentColor,
    this.showLabel = true,
    this.showGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: showGlow
              ? BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: ClearStateColors.dawnCoral.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                )
              : null,
          child: SizedBox(
            width: size,
            height: size * 0.7,
            child: CustomPaint(
              painter: _SunriseGradientPainter(accentColor: accentColor),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 12),
          Text(
            'CLEARSTATE',
            style: ClearStateTypography.timerLabel.copyWith(
              fontSize: 11,
              letterSpacing: 3,
              color: ClearStateColors.textSecondaryDark,
            ),
          ),
        ],
      ],
    );
  }
}

class _SunriseGradientPainter extends CustomPainter {
  final Color? accentColor;

  _SunriseGradientPainter({this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final bottomY = size.height;

    final path = Path()
      ..moveTo(0, bottomY)
      ..lineTo(centerX, bottomY * 0.2)
      ..lineTo(size.width, bottomY)
      ..close();

    // Gradient fill for DAWN aesthetic
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: accentColor != null
            ? [accentColor!, accentColor!.withValues(alpha: 0.7)]
            : [ClearStateColors.dawnCoral, ClearStateColors.sunriseGold],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);

    // Subtle horizon line
    final horizonPaint = Paint()
      ..color = ClearStateColors.deepForest.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(0, bottomY - 1),
      Offset(size.width, bottomY - 1),
      horizonPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Smaller logo variant for headers
class SunriseLogoSmall extends StatelessWidget {
  final double size;
  final Color? accentColor;

  const SunriseLogoSmall({super.key, this.size = 32, this.accentColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.6,
      child: CustomPaint(
        painter: _SunriseSmallGradientPainter(accentColor: accentColor),
      ),
    );
  }
}

class _SunriseSmallGradientPainter extends CustomPainter {
  final Color? accentColor;

  _SunriseSmallGradientPainter({this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(centerX, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: accentColor != null
            ? [accentColor!, accentColor!.withValues(alpha: 0.7)]
            : [ClearStateColors.dawnCoral, ClearStateColors.sunriseGold],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Animated sunrise logo with breathing glow effect
class AnimatedSunriseLogo extends StatefulWidget {
  final double size;
  final bool showLabel;

  const AnimatedSunriseLogo({
    super.key,
    this.size = 80,
    this.showLabel = true,
  });

  @override
  State<AnimatedSunriseLogo> createState() => _AnimatedSunriseLogoState();
}

class _AnimatedSunriseLogoState extends State<AnimatedSunriseLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: ClearStateMotion.breathCycle,
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: ClearStateMotion.organic,
      ),
    );

    if (!ClearStateMotion.reduceMotion) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: ClearStateColors.dawnCoral.withValues(alpha: _glowAnimation.value),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SunriseLogo(
            size: widget.size,
            showLabel: widget.showLabel,
            showGlow: false,
          ),
        );
      },
    );
  }
}
