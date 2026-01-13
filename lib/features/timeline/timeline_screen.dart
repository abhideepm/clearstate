import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/constants/milestones.dart';
import '../../shared/widgets/noise_background.dart';
import '../timer/timer_provider.dart';
import 'widgets/milestone_card.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationAsync = ref.watch(elapsedDurationProvider);

    return Scaffold(
      backgroundColor: ClearStateColors.void_,
      body: NoiseBackground(
        opacity: 0.025,
        child: SafeArea(
          child: durationAsync.when(
            data: (duration) {
              final currentDays = duration.inDays;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RECOVERY',
                            style: ClearStateTypography.timerLabel.copyWith(
                              fontSize: 14,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'TIMELINE',
                            style: ClearStateTypography.h1.copyWith(
                              fontSize: 36,
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

                        return MilestoneCard(
                          milestone: milestone,
                          isUnlocked: isUnlocked,
                          isCurrent: isCurrent,
                          isLast: isLast,
                        );
                      }, childCount: RecoveryMilestones.milestones.length),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: ClearStateColors.signal),
            ),
            error: (_, _) =>
                const Center(child: Text('Error loading timeline')),
          ),
        ),
      ),
    );
  }
}
