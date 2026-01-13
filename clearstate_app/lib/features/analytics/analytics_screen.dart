import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../shared/widgets/noise_background.dart';
import '../timer/timer_provider.dart';
import 'widgets/stat_card.dart';
import 'widgets/heatmap_calendar.dart';

// Provider for user profile data (simplified for now)
final avgDailySpendProvider = Provider<double>((ref) => 11.43); // $80/week / 7
final avgDailyCaloriesProvider = Provider<double>((ref) => 214.0); // 1500/week / 7

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationAsync = ref.watch(elapsedDurationProvider);
    final avgDailySpend = ref.watch(avgDailySpendProvider);
    final avgDailyCalories = ref.watch(avgDailyCaloriesProvider);
    
    return Scaffold(
      backgroundColor: ClearStateColors.void_,
      body: NoiseBackground(
        opacity: 0.025,
        child: SafeArea(
          child: durationAsync.when(
            data: (duration) {
              final days = duration.inDays;
              final moneySaved = days * avgDailySpend;
              final caloriesAvoided = (days * avgDailyCalories).round();
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANALYTICS',
                      style: ClearStateTypography.timerLabel.copyWith(
                        fontSize: 14,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'YOUR PROGRESS',
                      style: ClearStateTypography.h1.copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: 32),
                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'MONEY SAVED',
                            value: '\$${moneySaved.toStringAsFixed(0)}',
                            icon: Icons.savings_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            label: 'CALORIES AVOIDED',
                            value: caloriesAvoided.toString(),
                            icon: Icons.local_fire_department_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            label: 'SOBER DAYS',
                            value: days.toString(),
                            icon: Icons.calendar_today_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            label: 'DRINKS SKIPPED',
                            value: '${(days * 1.43).round()}', // avg 10/week
                            icon: Icons.no_drinks_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Heatmap section
                    Text(
                      'CONSISTENCY',
                      style: ClearStateTypography.caption.copyWith(
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const HeatmapCalendar(),
                    const SizedBox(height: 16),
                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(color: ClearStateColors.ash, label: 'No data'),
                        const SizedBox(width: 24),
                        _LegendItem(color: ClearStateColors.sober, label: 'Sober'),
                        const SizedBox(width: 24),
                        _LegendItem(color: ClearStateColors.relapse, label: 'Relapse'),
                      ],
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: ClearStateColors.signal),
            ),
            error: (_, __) => const Center(
              child: Text('Error loading analytics'),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  
  const _LegendItem({required this.color, required this.label});
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: ClearStateTypography.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
