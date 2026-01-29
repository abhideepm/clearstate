import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../shared/widgets/noise_background.dart';
import '../../shared/widgets/sunrise_logo.dart';
import '../relapse/slip_vs_relapse_sheet.dart';
import '../urge_surfing/urge_surfing_screen.dart';
import 'habit_provider.dart';
import 'widgets/timer_display.dart';
import 'widgets/status_indicator.dart';
import 'widgets/habit_dropdown.dart';
import 'widgets/streak_stats_card.dart'; // Contains StatBox
import 'widgets/reset_button.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late Animation<double> _fadeInAnimation;
  late AnimationController _statsRevealController;
  late Animation<double> _statsRevealAnimation;

  @override
  void initState() {
    super.initState();
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeInController, curve: Curves.easeOutCubic),
    );

    _statsRevealController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _statsRevealAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _statsRevealController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLaunchSequence();
    });
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _statsRevealController.dispose();
    super.dispose();
  }

  Future<void> _startLaunchSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    await _fadeInController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _statsRevealController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.value;

    return Scaffold(
      backgroundColor: themeState.background,
      body: DawnBackground(
        opacity: 0.02,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Header with logo and habit selector
                AnimatedBuilder(
                  animation: _fadeInAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeInAnimation.value,
                      child: Transform.translate(
                        offset: Offset(0, -10 * (1 - _fadeInAnimation.value)),
                        child: child,
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SunriseLogoSmall(
                        size: 28,
                        accentColor: accentColor,
                      ),
                      const HabitDropdown(),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Timer Display
                AnimatedBuilder(
                  animation: _fadeInAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 0.9 + (0.1 * _fadeInAnimation.value),
                      child: Opacity(
                        opacity: _fadeInAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: const TimerDisplay(),
                ),
                const SizedBox(height: 24),
                // Status Indicator
                const StatusIndicator(),
                const SizedBox(height: 32),
                // Streak Stats Cards
                AnimatedBuilder(
                  animation: _statsRevealAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - _statsRevealAnimation.value)),
                      child: Opacity(
                        opacity: _statsRevealAnimation.value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Consumer(
                    builder: (context, ref, child) {
                      final stats = ref.watch(habitStatsProvider);
                      final themeState = ref.watch(themeProvider);
                      return Row(
                        children: [
                          Expanded(
                            child: StatBox(
                              label: 'LONGEST STREAK',
                              value: '${stats.longestStreak}',
                              unit: 'days',
                              themeState: themeState,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: StatBox(
                              label: 'RELAPSES',
                              value: '${stats.relapseCount}',
                              unit: '',
                              themeState: themeState,
                              isNegative: true,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 72), // Increased spacing for reset button
                // Action Buttons
                ResetButton(
                  onReset: () => _showSlipVsRelapseSheet(context),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    HapticService.medium();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const UrgeSurfingScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "I'M STRUGGLING",
                    style: ClearStateTypography.caption.copyWith(
                      color: themeState.textMuted,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSlipVsRelapseSheet(BuildContext context) {
    final themeState = ref.read(themeProvider);
    HapticService.heavy();
    showModalBottomSheet(
      context: context,
      backgroundColor: themeState.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SlipVsRelapseSheet(),
    );
  }
}
