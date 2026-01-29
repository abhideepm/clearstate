import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/services/haptic_service.dart';
import '../../../data/models/habit_template.dart';
import '../onboarding_provider.dart';
import '../../../shared/widgets/haptic_calendar.dart';
import '../../../shared/widgets/brutalist_button.dart';

class StartDateStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const StartDateStep({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<StartDateStep> createState() => _StartDateStepState();
}

class _StartDateStepState extends ConsumerState<StartDateStep> {
  void _setTodayForAll() {
    HapticService.selection();
    final state = ref.read(onboardingProvider);
    final today = DateTime.now();
    for (final habit in state.selectedHabits) {
      ref.read(onboardingProvider.notifier).setHabitStartDate(habit.id, today);
    }
  }

  Future<void> _selectDateForHabit(HabitTemplate habit, DateTime currentDate) async {
    HapticService.light();
    DateTime selectedDate = currentDate;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: ClearStateColors.darkSurface,
            border: Border.all(color: ClearStateColors.borderDark, width: 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(habit.icon, size: 20, color: ClearStateColors.textPrimaryDark),
                    const SizedBox(width: 12),
                    Text(
                      habit.name.toUpperCase(),
                      style: ClearStateTypography.button.copyWith(
                        color: ClearStateColors.textPrimaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              HapticCalendar(
                selectedDate: selectedDate,
                showModal: false,
                onDateSelected: (date) {
                  selectedDate = date;
                },
                shouldDisableDate: (date) => date.isAfter(DateTime.now()),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(onboardingProvider.notifier)
                          .setHabitStartDate(habit.id, selectedDate);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ClearStateColors.dawnCoral,
                      foregroundColor: ClearStateColors.darkBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('CONFIRM DATE'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final selectedHabits = state.selectedHabits;
    final habitStartDates = state.habitStartDates;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'MARK YOUR\nTURNING POINT',
            style: ClearStateTypography.h1.copyWith(fontSize: 32, height: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'When did you take control?',
            style: ClearStateTypography.bodySecondary,
            textAlign: TextAlign.center,
          ),
          if (selectedHabits.length > 1) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _setTodayForAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: ClearStateColors.borderDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.today,
                      size: 16,
                      color: ClearStateColors.textSecondaryDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'USE TODAY FOR ALL',
                      style: ClearStateTypography.caption.copyWith(
                        color: ClearStateColors.textSecondaryDark,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: selectedHabits.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final habit = selectedHabits[index];
                final startDate = habitStartDates[habit.id] ?? DateTime.now();

                return GestureDetector(
                  onTap: () => _selectDateForHabit(habit, startDate),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ClearStateColors.darkSurface,
                      border: Border.all(color: ClearStateColors.borderDark),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          habit.icon,
                          size: 24,
                          color: ClearStateColors.textPrimaryDark,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.name.toUpperCase(),
                                style: ClearStateTypography.button.copyWith(
                                  color: ClearStateColors.textPrimaryDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(startDate),
                                style: ClearStateTypography.caption.copyWith(
                                  color: ClearStateColors.textSecondaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'TAP TO CHANGE',
                          style: ClearStateTypography.caption.copyWith(
                            fontSize: 10,
                            color: ClearStateColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ModernButton(
            label: 'CONTINUE',
            onPressed: widget.onNext,
            type: ModernButtonType.primary,
          ),
          const SizedBox(height: 12),
          ModernButton(
            label: 'BACK',
            onPressed: widget.onBack,
            type: ModernButtonType.secondary,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
