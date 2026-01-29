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
                      style: ClearStateTypography.h1.copyWith(
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
                  style: ClearStateTypography.bodySecondary.copyWith(
                    color: themeState.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Progress Overview Cards
                _buildProgressCard(
                  themeState: themeState,
                  title: 'Current Streak',
                  value: '${stats.currentStreak}',
                  unit: 'days',
                  icon: Icons.local_fire_department_rounded,
                  iconColor: themeState.accent.value,
                  isHighlighted: true,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMiniCard(
                        themeState: themeState,
                        title: 'Longest',
                        value: '${stats.longestStreak}',
                        unit: 'days',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMiniCard(
                        themeState: themeState,
                        title: 'Total Sober',
                        value: '${stats.totalSoberDays}',
                        unit: 'days',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMiniCard(
                        themeState: themeState,
                        title: 'Relapses',
                        value: '${stats.relapseCount}',
                        unit: '',
                        isNegative: stats.relapseCount > 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Success Rate
                _buildSuccessRateCard(themeState, stats),
                const SizedBox(height: 32),

                // Consistency Heatmap
                Text(
                  'Consistency',
                  style: ClearStateTypography.h3.copyWith(
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
                        ? ClearStateColors.cardShadowDark 
                        : ClearStateColors.cardShadowLight,
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
                      color: ClearStateColors.success,
                      label: 'Sober',
                      themeState: themeState,
                    ),
                    const SizedBox(width: 24),
                    _LegendItem(
                      color: ClearStateColors.error,
                      label: 'Relapse',
                      themeState: themeState,
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required ThemeState themeState,
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeState.card,
        borderRadius: BorderRadius.circular(20),
        border: isHighlighted 
            ? Border.all(color: iconColor.withValues(alpha: 0.3), width: 1)
            : null,
        boxShadow: themeState.isDarkMode 
            ? ClearStateColors.cardShadowDark 
            : ClearStateColors.cardShadowLight,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ClearStateTypography.caption.copyWith(
                  color: themeState.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: isHighlighted ? iconColor : themeState.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    unit,
                    style: ClearStateTypography.body.copyWith(
                      color: themeState.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCard({
    required ThemeState themeState,
    required String title,
    required String value,
    required String unit,
    bool isNegative = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeState.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: themeState.isDarkMode 
            ? ClearStateColors.cardShadowDark 
            : ClearStateColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: ClearStateTypography.caption.copyWith(
              color: themeState.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: isNegative ? ClearStateColors.error : themeState.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    color: themeState.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessRateCard(ThemeState themeState, HabitStats stats) {
    final totalDays = stats.totalSoberDays + stats.relapseCount;
    final successRate = totalDays > 0 
        ? (stats.totalSoberDays / totalDays * 100).round() 
        : 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeState.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: themeState.isDarkMode 
            ? ClearStateColors.cardShadowDark 
            : ClearStateColors.cardShadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Success Rate',
                style: ClearStateTypography.body.copyWith(
                  color: themeState.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$successRate%',
                style: TextStyle(
                  color: ClearStateColors.success,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: successRate / 100,
              backgroundColor: themeState.border,
              valueColor: AlwaysStoppedAnimation<Color>(ClearStateColors.success),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.totalSoberDays} sober days',
                style: TextStyle(
                  color: themeState.textMuted,
                  fontSize: 12,
                ),
              ),
              Text(
                '${stats.relapseCount} relapses',
                style: TextStyle(
                  color: themeState.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
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
