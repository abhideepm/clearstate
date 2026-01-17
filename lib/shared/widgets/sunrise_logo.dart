import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class SunriseLogo extends StatelessWidget {
  final double size;
  final Color? accentColor;
  final bool showLabel;

  const SunriseLogo({
    super.key,
    this.size = 80,
    this.accentColor,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? ClearStateColors.signal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size * 0.7,
          child: CustomPaint(painter: _SunrisePainter(accent: accent)),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(
            'CLEARSTATE',
            style: ClearStateTypography.timerLabel.copyWith(
              fontSize: 10,
              letterSpacing: 3,
              color: ClearStateColors.smoke,
            ),
          ),
        ],
      ],
    );
  }
}

class _SunrisePainter extends CustomPainter {
  final Color accent;

  _SunrisePainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final bottomY = size.height;

    final path = Path()
      ..moveTo(0, bottomY)
      ..lineTo(centerX, bottomY * 0.2)
      ..lineTo(size.width, bottomY)
      ..close();

    canvas.drawPath(path, paint);

    final horizonPaint = Paint()
      ..color = ClearStateColors.void_
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, bottomY - 2),
      Offset(size.width, bottomY - 2),
      horizonPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SunriseLogoSmall extends StatelessWidget {
  final double size;
  final Color? accentColor;

  const SunriseLogoSmall({super.key, this.size = 32, this.accentColor});

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? ClearStateColors.signal;

    return SizedBox(
      width: size,
      height: size * 0.6,
      child: CustomPaint(painter: _SunriseSmallPainter(accent: accent)),
    );
  }
}

class _SunriseSmallPainter extends CustomPainter {
  final Color accent;

  _SunriseSmallPainter({required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(centerX, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
