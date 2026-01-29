import 'package:flutter/material.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/typography.dart';

/// A reusable mini-stat box for displaying stats in the timer screen
class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final ThemeState themeState;
  final bool isNegative;

  const StatBox({
    super.key,
    required this.label,
    required this.value,
    required this.themeState,
    this.unit = '',
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    Color valueColor = themeState.textPrimary;
    if (isNegative && value != '0') {
      valueColor = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: themeState.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeState.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: ClearStateTypography.caption.copyWith(
              color: themeState.textMuted,
              fontSize: 10,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: ClearStateTypography.bodySecondary.copyWith(
                    color: themeState.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
