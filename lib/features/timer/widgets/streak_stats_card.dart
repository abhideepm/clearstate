import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:truestate/core/theme/theme_provider.dart';
import 'package:truestate/features/timer/habit_provider.dart';

/// Card displaying streak statistics for the currently selected habit
class StreakStatsCard extends ConsumerWidget {
  const StreakStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(habitStatsProvider);
    final themeState = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeState.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeState.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'CURRENT STREAK',
                  value: '${stats.currentStreak}',
                  unit: 'days',
                  themeState: themeState,
                  isHighlighted: true,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: themeState.border,
              ),
              Expanded(
                child: _StatItem(
                  label: 'LONGEST STREAK',
                  value: '${stats.longestStreak}',
                  unit: 'days',
                  themeState: themeState,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: themeState.border,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'TOTAL SOBER',
                  value: '${stats.totalSoberDays}',
                  unit: 'days',
                  themeState: themeState,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: themeState.border,
              ),
              Expanded(
                child: _StatItem(
                  label: 'RELAPSES',
                  value: '${stats.relapseCount}',
                  unit: '',
                  themeState: themeState,
                  isNegative: stats.relapseCount > 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final ThemeState themeState;
  final bool isHighlighted;
  final bool isNegative;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.themeState,
    this.isHighlighted = false,
    this.isNegative = false,
  });

  @override
  Widget build(BuildContext context) {
    Color valueColor = themeState.textPrimary;
    if (isHighlighted) {
      valueColor = themeState.accent.value;
    } else if (isNegative) {
      valueColor = const Color(0xFFEF4444);
    }

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: themeState.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
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
                style: TextStyle(
                  color: themeState.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
