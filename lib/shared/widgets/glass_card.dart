import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// Glass morphism card with frosted blur effect
/// Uses ClipRRect + BackdropFilter for the frosted glass look
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final bool showBorder;
  final bool showGlow;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 10,
    this.showBorder = true,
    this.showGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? TrueStateColors.glassOverlayDark
                : TrueStateColors.glassOverlayLight,
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(
                    color: isDark
                        ? TrueStateColors.glassBorderDark
                        : TrueStateColors.glassBorderLight,
                    width: 1,
                  )
                : null,
            boxShadow: showGlow ? TrueStateColors.glowShadow : null,
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      card = Padding(padding: margin!, child: card);
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

/// Simpler glass container without backdrop filter (better performance)
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool showBorder;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? TrueStateColors.darkCard.withValues(alpha: 0.8)
            : TrueStateColors.lightCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: isDark
                    ? TrueStateColors.borderDark
                    : TrueStateColors.borderLight,
                width: 1,
              )
            : null,
        boxShadow: isDark
            ? TrueStateColors.cardShadowDark
            : TrueStateColors.cardShadowLight,
      ),
      child: child,
    );
  }
}
