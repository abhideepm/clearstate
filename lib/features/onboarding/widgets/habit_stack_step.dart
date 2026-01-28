import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../../../data/models/habit_template.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/animated_chip.dart';
import '../../../shared/widgets/brutalist_button.dart';

class HabitStackStep extends ConsumerWidget {
  final VoidCallback onNext;

  const HabitStackStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHabits = ref.watch(onboardingProvider).selectedHabits;
    final hasSelection = selectedHabits.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          Text(
            'WHAT ARE YOU\nQUITTING?',
            style: ClearStateTypography.h1.copyWith(fontSize: 32, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Select all that apply',
            style: ClearStateTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: HabitTemplate.all.map((habit) {
              final isSelected = selectedHabits.any((h) => h.id == habit.id);
              return AnimatedChip(
                isSelected: isSelected,
                onTap: () {
                  HapticService.selection();
                  ref.read(onboardingProvider.notifier).toggleHabit(habit);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      habit.icon,
                      size: 18,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(habit.name.toUpperCase()),
                        Text(
                          habit.description,
                          style: ClearStateTypography.caption.copyWith(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.black.withValues(alpha: 0.7)
                                : Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          BrutalistButton(
            label: 'CONTINUE',
            onPressed: onNext,
            type: BrutalistButtonType.primary,
            enabled: hasSelection,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
