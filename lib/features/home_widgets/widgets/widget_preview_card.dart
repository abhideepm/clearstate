import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/widget_config.dart';

/// A reusable card showing a preview of a home screen widget.
///
/// Displays a mini visual preview along with title, description,
/// and configuration status. Tappable to open configuration.
class WidgetPreviewCard extends StatelessWidget {
  /// The type of widget being previewed.
  final WidgetType widgetType;

  /// Display title for the widget.
  final String title;

  /// Brief description of what the widget shows.
  final String description;

  /// Whether this widget has been configured.
  final bool isConfigured;

  /// Callback when the card is tapped.
  final VoidCallback onTap;

  const WidgetPreviewCard({
    super.key,
    required this.widgetType,
    required this.title,
    required this.description,
    required this.isConfigured,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TrueStateColors.darkSurface,
        border: Border.all(color: TrueStateColors.borderDark, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Widget preview thumbnail
                _WidgetPreviewThumbnail(widgetType: widgetType),
                const SizedBox(width: 16),
                // Widget info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TrueStateTypography.h3.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (isConfigured)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: TrueStateColors.success.withAlpha(
                                  (0.15 * 255).round(),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'CONFIGURED',
                                style: TrueStateTypography.caption.copyWith(
                                  fontSize: 9,
                                  color: TrueStateColors.success,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: TrueStateTypography.caption.copyWith(
                          color: TrueStateColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Chevron
                const Icon(
                  Icons.chevron_right,
                  color: TrueStateColors.borderDark,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mini preview thumbnail showing what the widget looks like.
class _WidgetPreviewThumbnail extends StatelessWidget {
  final WidgetType widgetType;

  const _WidgetPreviewThumbnail({required this.widgetType});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: TrueStateColors.darkBackground,
        border: Border.all(color: TrueStateColors.borderDark, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: _buildPreview(),
    );
  }

  Widget _buildPreview() {
    switch (widgetType) {
      case WidgetType.battery:
        return _BatteryPreview();
      case WidgetType.stoic:
        return _StoicPreview();
      case WidgetType.bioState:
        return _BioStatePreview();
    }
  }
}

/// Battery widget preview - circular progress ring.
class _BatteryPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background ring
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: TrueStateColors.borderDark, width: 3),
              ),
            ),
            // Progress arc
            CustomPaint(
              size: const Size(44, 44),
              painter: _ProgressArcPainter(progress: 0.72),
            ),
            // Center percentage
            Text(
              '72',
              style: TrueStateTypography.statNumber.copyWith(
                fontSize: 14,
                color: TrueStateColors.textPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the battery progress arc.
class _ProgressArcPainter extends CustomPainter {
  final double progress;

  _ProgressArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1.5;

    final paint = Paint()
      ..color = TrueStateColors.dawnCoral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const startAngle = -90 * (3.14159 / 180);
    final sweepAngle = 360 * progress * (3.14159 / 180);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Stoic widget preview - quote icon.
class _StoicPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"',
            style: TrueStateTypography.h1.copyWith(
              fontSize: 24,
              color: TrueStateColors.dawnCoral,
              height: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Container(height: 4, width: 32, color: TrueStateColors.borderDark),
          const SizedBox(height: 4),
          Container(height: 4, width: 24, color: TrueStateColors.borderDark),
        ],
      ),
    );
  }
}

/// Bio-state widget preview - mini graph.
class _BioStatePreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: CustomPaint(
        size: const Size(48, 48),
        painter: _MiniGraphPainter(),
      ),
    );
  }
}

/// Custom painter for the bio-state mini graph preview.
class _MiniGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TrueStateColors.dawnCoral
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Draw a simple recovery curve
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.2,
      size.width,
      size.height * 0.15,
    );

    canvas.drawPath(path, paint);

    // Draw baseline
    final baselinePaint = Paint()
      ..color = TrueStateColors.borderDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      baselinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
