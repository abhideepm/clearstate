import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/sobriety_orchestrator.dart';
import '../../core/utils/pro_feature_gate.dart';
import '../../domain/usecases/sobriety_statistics.dart';
import '../timer/timer_provider.dart';
import 'widgets/bento_card.dart';
import 'widgets/daily_log_input_sheet.dart';
import 'widgets/symptom_prediction_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getRecoveryPhase(int days) {
    if (days < 15) return 'The Wall';
    if (days < 30) return 'Withdrawal';
    if (days < 90) return 'Pink Cloud';
    if (days < 180) return 'Adjustment';
    return 'Resolution';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerComponentsProvider);
    final orchestrator = ref.watch(sobrietyOrchestratorProvider);
    final statistics = ref.watch(sobrietyStatisticsProvider);
    final themeState = ref.watch(themeProvider);
    final repo = orchestrator.repository;
    final profile = repo.getUserProfile();
    final habitId = profile?.selectedHabitIds.isNotEmpty == true
        ? profile!.selectedHabitIds.first
        : null;

    final totalDays = habitId != null
        ? statistics.getTotalSoberDays(habitId)
        : 0;
    final totalSlips = habitId != null ? repo.getTotalSlips(habitId) : 0;
    final totalLogs = totalDays + totalSlips;
    final successRate = totalLogs > 0 ? (totalDays / totalLogs) * 100 : 100.0;

    final currentDays = timer.days + (timer.months * 30) + (timer.years * 365);
    final phase = _getRecoveryPhase(currentDays);
    final accentColor = themeState.accent.value;

    return Scaffold(
      backgroundColor: themeState.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: themeState.isDarkMode
              ? TrueStateColors.darkBackgroundGradient
              : TrueStateColors.lightBackgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              floating: true,
              title: Text(
                'Dashboard',
                style: TrueStateTypography.h2.copyWith(
                  color: themeState.textPrimary,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Hero Card - Streak
                    BentoCard(
                      backgroundColor: accentColor,
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Streak',
                            style: TrueStateTypography.caption.copyWith(
                              color: TrueStateColors.textPrimaryLight
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${timer.days}',
                                style: TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w700,
                                  color: TrueStateColors.textPrimaryLight,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'days',
                                style: TrueStateTypography.h3.copyWith(
                                  color: TrueStateColors.textPrimaryLight
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${timer.hours}h ${timer.minutes}m ${timer.seconds}s',
                            style: TrueStateTypography.body.copyWith(
                              color: TrueStateColors.textPrimaryLight
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        // Success Rate Card
                        Expanded(
                          child: BentoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Success Rate',
                                  style: TrueStateTypography.caption.copyWith(
                                    color: themeState.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '${successRate.toStringAsFixed(1)}%',
                                  style: TrueStateTypography.h2.copyWith(
                                    color: TrueStateColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Phase Card
                        Expanded(
                          child: BentoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phase',
                                  style: TrueStateTypography.caption.copyWith(
                                    color: themeState.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  phase,
                                  style: TrueStateTypography.body.copyWith(
                                    color: themeState.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const ProFeatureGate(
                      featureName: 'AI Symptom Predictions',
                      child: SymptomPredictionCard(),
                    ),
                    const SizedBox(height: 16),
                    // Quick Log Card
                    BentoCard(
                      backgroundColor: themeState.isDarkMode
                          ? TrueStateColors.darkCard
                          : TrueStateColors.lightCard,
                      onTap: habitId == null
                          ? null
                          : () {
                              HapticService.medium();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    const DailyLogInputSheet(),
                              );
                            },
                      onLongPress: habitId == null
                          ? null
                          : () async {
                              HapticService.heavy();
                              await orchestrator.repository.logDay(
                                date: DateTime.now(),
                                habitId: habitId,
                                isSober: true,
                                moodScore: 5,
                                symptoms: [],
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Quick log: Sober day saved!',
                                    ),
                                    backgroundColor: themeState.surface,
                                  ),
                                );
                              }
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline, color: accentColor),
                          const SizedBox(width: 12),
                          Text(
                            'Log Sober Day',
                            style: TrueStateTypography.button.copyWith(
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
