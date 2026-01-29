import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/colors.dart';
import '../../../core/constants/milestones.dart';
import '../../../core/providers/navigation_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../timer_provider.dart';
import '../habit_provider.dart';

class StatusIndicator extends ConsumerWidget {
  const StatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final durationAsync = ref.watch(elapsedDurationProvider);
    final selectedHabit = ref.watch(selectedHabitProvider);

    // Get habit-specific milestones (habit is always selected after onboarding)
    final milestones = RecoveryMilestones.getMilestonesForHabit(
      selectedHabit?.id ?? 'alcohol',
    );

    return durationAsync.when(
      data: (duration) {
        final currentMilestone = RecoveryMilestones.getCurrentMilestoneFromList(
          duration.inDays,
          milestones,
        );

        return GestureDetector(
          onTap: () {
            HapticService.light();
            ref.read(currentTabIndexProvider.notifier).state = 1;
            ref.read(scrollToCurrentMilestoneProvider.notifier).state++;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ClearStateColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ClearStateColors.borderDark, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: ClearStateColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    currentMilestone.status,
                    style: ClearStateTypography.caption.copyWith(
                      color: ClearStateColors.textPrimaryDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
