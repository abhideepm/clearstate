import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/constants/milestones.dart';
import '../../shared/widgets/noise_background.dart';
import '../../shared/widgets/scroll_reveal.dart';
import '../../shared/widgets/haptic_scroll_view.dart';
import '../timer/timer_provider.dart';
import '../timer/widgets/habit_dropdown.dart';
import 'widgets/milestone_card.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationAsync = ref.watch(elapsedDurationProvider);
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: themeState.background,
      body: DawnBackground(
        opacity: 0.025,
        child: SafeArea(
          child: durationAsync.when(
            data: (duration) {
              final currentDays = duration.inDays;

              return HapticCustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Timeline',
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
                            'Your recovery milestones',
                            style: ClearStateTypography.bodySecondary.copyWith(
                              color: themeState.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your body is healing',
                            style: ClearStateTypography.bodySecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final milestone = RecoveryMilestones.milestones[index];
                        final isUnlocked =
                            currentDays >= milestone.dayThreshold;
                        final isCurrent =
                            milestone ==
                            RecoveryMilestones.getCurrentMilestone(currentDays);
                        final isLast =
                            index == RecoveryMilestones.milestones.length - 1;

                        return ScrollRevealItem(
                          delay: Duration(milliseconds: index * 50),
                          child: MilestoneCard(
                            milestone: milestone,
                            isUnlocked: isUnlocked,
                            isCurrent: isCurrent,
                            isLast: isLast,
                          ),
                        );
                      }, childCount: RecoveryMilestones.milestones.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: themeState.accent.value),
            ),
            error: (error, stack) =>
                const Center(child: Text('Error loading timeline')),
          ),
        ),
      ),
    );
  }
}
