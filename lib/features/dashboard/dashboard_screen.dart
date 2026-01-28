import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/services/haptic_service.dart';
import '../../core/services/sobriety_orchestrator.dart';
import '../../domain/usecases/sobriety_statistics.dart';
import '../timer/timer_provider.dart';
import 'widgets/bento_card.dart';
import 'widgets/daily_log_input_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _getRecoveryPhase(int days) {
    if (days < 15) return 'THE WALL';
    if (days < 30) return 'WITHDRAWAL';
    if (days < 90) return 'PINK CLOUD';
    if (days < 180) return 'ADJUSTMENT';
    return 'RESOLUTION';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerComponentsProvider);
    final orchestrator = ref.watch(sobrietyOrchestratorProvider);
    final statistics = ref.watch(sobrietyStatisticsProvider);
    final repo = orchestrator.repository;
    final profile = repo.getUserProfile();
    final habitId = profile?.selectedHabitIds.isNotEmpty == true
        ? profile!.selectedHabitIds.first
        : null;

    final totalDays = habitId != null ? statistics.getTotalSoberDays(habitId) : 0;
    final totalSlips = habitId != null ? repo.getTotalSlips(habitId) : 0;
    final totalLogs = totalDays + totalSlips;
    final successRate = totalLogs > 0 ? (totalDays / totalLogs) * 100 : 100.0;

    final currentDays = timer.days + (timer.months * 30) + (timer.years * 365);
    final phase = _getRecoveryPhase(currentDays);

    return Scaffold(
      backgroundColor: ClearStateColors.oledBlack,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            backgroundColor: Colors.transparent,
            floating: true,
            title: Text(
              'DASHBOARD',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildListDelegate([
                // Hero Card (2x2 technically requires a custom delegate or manual layout)
                // We'll use a Span of 2 for the Hero.
              ]),
            ),
          ),
          // Custom layout for Bento Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Hero Card (2x2 equivalent)
                  BentoCard(
                    backgroundColor: ClearStateColors.acidGreen,
                    borderColor: ClearStateColors.oledBlack,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STREAK',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: ClearStateColors.oledBlack,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${timer.days}',
                              style: const TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: ClearStateColors.oledBlack,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'DAYS',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: ClearStateColors.oledBlack,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${timer.hours}H ${timer.minutes}M ${timer.seconds}S',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: ClearStateColors.oledBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Success Rate Card (1x1)
                      Expanded(
                        child: BentoCard(
                          backgroundColor: ClearStateColors.charcoal,
                          borderColor: ClearStateColors.hyperViolet,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SUCCESS',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 12,
                                  color: ClearStateColors.smoke,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${successRate.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: ClearStateColors.hyperViolet,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Phase Card (1x1)
                      Expanded(
                        child: BentoCard(
                          backgroundColor: ClearStateColors.charcoal,
                          borderColor: ClearStateColors.signalOrange,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PHASE',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 12,
                                  color: ClearStateColors.smoke,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                phase,
                                style: const TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: ClearStateColors.signalOrange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick Log Card (Full width / 2x1)
                  BentoCard(
                    backgroundColor: ClearStateColors.oledBlack,
                    borderColor: ClearStateColors.acidGreen,
                    onTap: habitId == null
                        ? null
                        : () {
                            HapticService.medium();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: ClearStateColors.oledBlack,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (context) => const DailyLogInputSheet(),
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
                                const SnackBar(
                                  content: Text('Quick log: Sober day saved!'),
                                  backgroundColor: ClearStateColors.charcoal,
                                ),
                              );
                            }
                          },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: ClearStateColors.acidGreen,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'LOG SOBER DAY',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: ClearStateColors.acidGreen,
                            letterSpacing: 1.5,
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
    );
  }
}
