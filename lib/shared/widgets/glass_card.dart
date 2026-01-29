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
                ? ClearStateColors.glassOverlayDark
                : ClearStateColors.glassOverlayLight,
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(
                    color: isDark
                        ? ClearStateColors.glassBorderDark
                        : ClearStateColors.glassBorderLight,
                    width: 1,
                  )
                : null,
            boxShadow: showGlow ? ClearStateColors.glowShadow : null,
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
            ? ClearStateColors.darkCard.withValues(alpha: 0.8)
            : ClearStateColors.lightCard.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder
            ? Border.all(
                color: isDark
                    ? ClearStateColors.borderDark
                    : ClearStateColors.borderLight,
                width: 1,
              )
            : null,
        boxShadow: isDark
            ? ClearStateColors.cardShadowDark
            : ClearStateColors.cardShadowLight,
      ),
      child: child,
    );
  }
}
