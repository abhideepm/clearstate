import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clearstate/core/theme/colors.dart';
import 'package:clearstate/core/theme/theme_provider.dart';
import 'package:clearstate/data/models/habit.dart';
import 'package:clearstate/features/timer/habit_provider.dart';

/// Modern dropdown widget for selecting active habit
class HabitDropdown extends ConsumerWidget {
  const HabitDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(activeHabitsProvider);
    final selectedHabit = ref.watch(selectedHabitProvider);
    final themeState = ref.watch(themeProvider);

    if (habits.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show single habit without dropdown if only one
    if (habits.length == 1) {
      return _buildSingleHabitDisplay(habits.first, themeState);
    }

    return GestureDetector(
      onTap: () => _showHabitPicker(context, ref, habits, selectedHabit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: themeState.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeState.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedHabit != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _parseColor(selectedHabit.themeColor),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                selectedHabit.name,
                style: TextStyle(
                  color: themeState.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: themeState.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleHabitDisplay(Habit habit, ThemeState themeState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: themeState.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeState.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _parseColor(habit.themeColor),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            habit.name,
            style: TextStyle(
              color: themeState.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showHabitPicker(
    BuildContext context,
    WidgetRef ref,
    List<Habit> habits,
    Habit? selectedHabit,
  ) {
    final themeState = ref.read(themeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: themeState.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Select Habit',
                style: TextStyle(
                  color: themeState.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Divider(height: 1),
            ...habits.map((habit) => _buildHabitOption(
                  context,
                  ref,
                  habit,
                  isSelected: habit.id == selectedHabit?.id,
                  themeState: themeState,
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitOption(
    BuildContext context,
    WidgetRef ref,
    Habit habit, {
    required bool isSelected,
    required ThemeState themeState,
  }) {
    final habitColor = _parseColor(habit.themeColor);

    return InkWell(
      onTap: () {
        ref.read(habitSwitcherProvider).selectHabit(habit.id);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: isSelected ? habitColor.withValues(alpha: 0.1) : null,
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: habitColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    style: TextStyle(
                      color: themeState.textPrimary,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  Text(
                    '${habit.totalDays} days',
                    style: TextStyle(
                      color: themeState.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_rounded,
                color: habitColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return ClearStateColors.sunYellow;
    }
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return ClearStateColors.sunYellow;
    }
  }
}
