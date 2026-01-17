import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../shared/widgets/noise_background.dart';
import '../timer/timer_provider.dart';
import '../timer/roi_provider.dart';
import 'widgets/stat_card.dart';
import 'widgets/heatmap_calendar.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerComponents = ref.watch(timerComponentsProvider);
    final avgDailySpend = ref.watch(avgDailySpendProvider);
    final avgDailyCalories = ref.watch(avgDailyCaloriesProvider);
    final avgDrinksPerWeek = ref.watch(avgDrinksPerWeekProvider);
    final themeState = ref.watch(themeProvider);

    final days =
        timerComponents.days +
        (timerComponents.years * 365) +
        (timerComponents.months * 30);
    final moneySaved = days * avgDailySpend;
    final caloriesAvoided = (days * avgDailyCalories).round();

    return Scaffold(
      backgroundColor: themeState.background.value,
      body: NoiseBackground(
        opacity: 0.025,
        child: SafeArea(
          child: SingleChildScrollView(
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
                Row(
                  children: [
                    Expanded(
                      child: AnimatedStatCard(
                        label: 'MONEY SAVED',
                        value: '\$${moneySaved.toStringAsFixed(0)}',
                        icon: Icons.savings_outlined,
                        delay: Duration(milliseconds: 0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedStatCard(
                        label: 'CALORIES AVOIDED',
                        value: caloriesAvoided.toString(),
                        icon: Icons.local_fire_department_outlined,
                        delay: Duration(milliseconds: 100),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AnimatedStatCard(
                        label: 'SOBER DAYS',
                        value: days.toString(),
                        icon: Icons.calendar_today_outlined,
                        delay: Duration(milliseconds: 200),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnimatedStatCard(
                        label: 'DRINKS SKIPPED',
                        value: '${(days * avgDrinksPerWeek / 7).round()}',
                        icon: Icons.no_drinks_outlined,
                        delay: Duration(milliseconds: 300),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'CONSISTENCY',
                  style: ClearStateTypography.caption.copyWith(
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedHeatmapCalendar(delay: Duration(milliseconds: 400)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(color: ClearStateColors.ash, label: 'No data'),
                    const SizedBox(width: 24),
                    _LegendItem(color: ClearStateColors.sober, label: 'Sober'),
                    const SizedBox(width: 24),
                    _LegendItem(
                      color: ClearStateColors.relapse,
                      label: 'Relapse',
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
}

class AnimatedStatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final Duration delay;

  const AnimatedStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.delay,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: StatCard(
        label: widget.label,
        value: widget.value,
        icon: widget.icon,
      ),
    );
  }
}

class AnimatedHeatmapCalendar extends StatefulWidget {
  final Duration delay;

  const AnimatedHeatmapCalendar({super.key, required this.delay});

  @override
  State<AnimatedHeatmapCalendar> createState() =>
      _AnimatedHeatmapCalendarState();
}

class _AnimatedHeatmapCalendarState extends State<AnimatedHeatmapCalendar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(scale: _scaleAnimation.value, child: child),
        );
      },
      child: const HeatmapCalendar(),
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
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label, style: ClearStateTypography.caption.copyWith(fontSize: 11)),
      ],
    );
  }
}
