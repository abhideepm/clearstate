import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/widgets/noise_background.dart';
import '../timer/habit_provider.dart';
import '../timer/widgets/habit_dropdown.dart';
import 'widgets/heatmap_calendar.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final stats = ref.watch(habitStatsProvider);
    final selectedHabit = ref.watch(selectedHabitProvider);

    return Scaffold(
      backgroundColor: themeState.background,
      body: DawnBackground(
        opacity: 0.02,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with habit selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Analytics',
                      style: TrueStateTypography.h1.copyWith(
                        color: themeState.textPrimary,
                        fontSize: 28,
                      ),
                    ),
                    const HabitDropdown(),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your progress at a glance',
                  style: TrueStateTypography.bodySecondary.copyWith(
                    color: themeState.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Consistency Heatmap
                Text(
                  'Consistency',
                  style: TrueStateTypography.h3.copyWith(
                    color: themeState.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeState.card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: themeState.isDarkMode 
                        ? TrueStateColors.cardShadowDark 
                        : TrueStateColors.cardShadowLight,
                  ),
                  child: const HeatmapCalendar(),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(
                      color: themeState.border,
                      label: 'No data',
                      themeState: themeState,
                    ),
                    const SizedBox(width: 24),
                    _LegendItem(
                      color: TrueStateColors.success,
                      label: 'Sober',
                      themeState: themeState,
                    ),
                    const SizedBox(width: 24),
                    _LegendItem(
                      color: TrueStateColors.error,
                      label: 'Relapse',
                      themeState: themeState,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Success Rate
                _buildSuccessRateCard(themeState, stats),
                const SizedBox(height: 32),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSuccessRateCard(ThemeState themeState, HabitStats stats) {
    final totalDays = stats.totalSoberDays + stats.relapseCount;
    final successRate = totalDays > 0 
        ? (stats.totalSoberDays / totalDays * 100).round() 
        : 100;
    final accentColor = themeState.accent.value;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeState.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: themeState.isDarkMode 
            ? TrueStateColors.cardShadowDark 
            : TrueStateColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Success Rate',
                style: TrueStateTypography.h3.copyWith(
                  color: themeState.textPrimary,
                  fontSize: 20,
                ),
              ),
              Text(
                '$successRate%',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: themeState.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 10,
                    width: constraints.maxWidth * (successRate / 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSuccessDetail(
                '${stats.totalSoberDays} sober days',
                themeState,
              ),
              _buildSuccessDetail(
                '${stats.relapseCount} relapses',
                themeState,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessDetail(String text, ThemeState themeState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: themeState.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: TrueStateTypography.caption.copyWith(
          color: themeState.textMuted,
          fontSize: 9,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final ThemeState themeState;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.themeState,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: themeState.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
