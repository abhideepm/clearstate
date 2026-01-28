import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';

class BentoCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double shadowOffset;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const BentoCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor = ClearStateColors.ash,
    this.borderWidth = 2.0,
    this.shadowOffset = 4.0,
    this.onTap,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? ClearStateColors.charcoal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10), // Slightly less than container
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(right: shadowOffset, bottom: shadowOffset),
      child: card,
    );
  }
}
