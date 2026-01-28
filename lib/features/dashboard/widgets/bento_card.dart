import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_provider.dart';

/// Modern fintech-style card with soft shadows and rounded corners
class BentoCard extends ConsumerWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry padding;
  final bool elevated;

  const BentoCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(20.0),
    this.elevated = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.isDarkMode;

    final bgColor = backgroundColor ?? 
        (isDark ? ClearStateColors.darkCard : ClearStateColors.lightCard);
    
    final shadows = elevated 
        ? (isDark ? ClearStateColors.cardShadowDark : ClearStateColors.cardShadowLight)
        : null;

    final card = Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(ClearStateTheme.borderRadiusLarge),
        border: borderColor != null 
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ClearStateTheme.borderRadiusLarge - 1),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(ClearStateTheme.borderRadiusLarge - 1),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );

    return card;
  }
}
