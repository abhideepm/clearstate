import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../../../data/models/habit_template.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/brutalist_button.dart';

class HabitStackStep extends ConsumerWidget {
  final VoidCallback onNext;

  const HabitStackStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedHabits = ref.watch(onboardingProvider).selectedHabits;
    final hasSelection = selectedHabits.isNotEmpty;
    final themeState = ref.watch(themeProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'What would you\nlike to leave behind?',
            style: TrueStateTypography.h1.copyWith(
              fontSize: 32,
              height: 1.2,
              color: themeState.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Select all that apply',
            style: TrueStateTypography.bodySecondary.copyWith(
              color: themeState.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: themeState.accent.value.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '✨ Join 10,000+ people on their journey',
              style: TrueStateTypography.caption.copyWith(
                color: themeState.accent.value,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: HabitTemplate.all.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final habit = HabitTemplate.all[index];
                final isSelected = selectedHabits.any((h) => h.id == habit.id);
                return _HabitChip(
                  habit: habit,
                  isSelected: isSelected,
                  themeState: themeState,
                  onTap: () {
                    HapticService.selection();
                    ref.read(onboardingProvider.notifier).toggleHabit(habit);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          ModernButton(
            label: 'Continue',
            onPressed: onNext,
            type: ModernButtonType.primary,
            enabled: hasSelection,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _HabitChip extends StatelessWidget {
  final HabitTemplate habit;
  final bool isSelected;
  final ThemeState themeState;
  final VoidCallback onTap;

  const _HabitChip({
    required this.habit,
    required this.isSelected,
    required this.themeState,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = themeState.accent.value;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : themeState.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : themeState.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ]
              : themeState.isDarkMode
              ? TrueStateColors.cardShadowDark
              : TrueStateColors.cardShadowLight,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : themeState.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                habit.icon,
                size: 24,
                color: isSelected ? Colors.white : themeState.textPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    habit.name,
                    style: TrueStateTypography.body.copyWith(
                      color: isSelected ? Colors.white : themeState.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.description,
                    style: TrueStateTypography.caption.copyWith(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : themeState.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Static checkbox - no animation needed for simple toggle
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? null
                    : Border.all(color: themeState.border, width: 2),
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 16, color: accentColor)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
