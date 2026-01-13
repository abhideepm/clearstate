import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../roi_provider.dart';

/// Compact horizontal row of 3 ROI metric cards
class RoiCards extends ConsumerWidget {
  const RoiCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metrics = ref.watch(roiMetricsProvider);

    return Row(
      children: [
        Expanded(
          child: _RoiCard(
            label: 'SAVED',
            value: _formatMoney(metrics.moneySaved),
            accentColor: ClearStateColors.signal,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RoiCard(
            label: 'HOURS FREE',
            value: _formatHours(metrics.hoursFree),
            accentColor: ClearStateColors.smoke,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _RoiCard(
            label: 'STREAK',
            value: '${metrics.streakDays}d',
            accentColor: ClearStateColors.sober,
          ),
        ),
      ],
    );
  }

  String _formatMoney(double amount) {
    if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}k';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  String _formatHours(double hours) {
    if (hours >= 100) {
      return '${hours.toStringAsFixed(0)}h';
    }
    return '${hours.toStringAsFixed(1)}h';
  }
}

/// Individual ROI metric card
class _RoiCard extends StatelessWidget {
  final String label;
  final String value;
  final Color accentColor;

  const _RoiCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ClearStateColors.charcoal,
        border: Border.all(color: ClearStateColors.ash, width: 1),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent line
          Container(width: 16, height: 2, color: accentColor),
          const SizedBox(height: 8),
          // Value (large, prominent)
          Text(
            value,
            style: ClearStateTypography.statNumber.copyWith(
              fontSize: 20,
              color: ClearStateColors.bone,
            ),
          ),
          const SizedBox(height: 4),
          // Label (small caps)
          Text(
            label,
            style: ClearStateTypography.caption.copyWith(
              fontSize: 9,
              letterSpacing: 1.5,
              color: ClearStateColors.smoke,
            ),
          ),
        ],
      ),
    );
  }
}
