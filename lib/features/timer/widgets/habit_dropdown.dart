import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clearstate/core/theme/colors.dart';
import 'package:clearstate/core/theme/theme_provider.dart';
import 'package:clearstate/data/models/habit.dart';
import 'package:clearstate/data/models/habit_template.dart';
import 'package:clearstate/data/repositories/sobriety_repository.dart';
import 'package:clearstate/core/services/sobriety_orchestrator.dart';
import 'package:clearstate/features/timer/habit_provider.dart';

/// Modern dropdown widget for selecting active habit
class HabitDropdown extends ConsumerWidget {
  const HabitDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(activeHabitsProvider);
    final selectedHabit = ref.watch(selectedHabitProvider);
    final themeState = ref.watch(themeProvider);

    // Always show dropdown, even with 0 or 1 habit (allows adding new habits)
    final displayHabit = selectedHabit ?? (habits.isNotEmpty ? habits.first : null);

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
            if (displayHabit != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _parseColor(displayHabit.themeColor),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                displayHabit.name,
                style: TextStyle(
                  color: themeState.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ] else ...[
              Icon(
                Icons.add_rounded,
                color: themeState.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Add Habit',
                style: TextStyle(
                  color: themeState.textSecondary,
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

  void _showHabitPicker(
    BuildContext context,
    WidgetRef ref,
    List<Habit> habits,
    Habit? selectedHabit,
  ) {
    // Pre-capture all data BEFORE showing the modal to avoid lag
    final themeState = ref.read(themeProvider);
    final habitSwitcher = ref.read(habitSwitcherProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: themeState.surface,
      useRootNavigator: true,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _HabitPickerContent(
        habits: habits,
        selectedHabit: selectedHabit,
        themeState: themeState,
        habitSwitcher: habitSwitcher,
        onAddHabit: () {
          Navigator.pop(sheetContext);
          _showAddHabitDialog(context, themeState);
        },
      ),
    );
  }

  Widget _buildAddHabitOption(
    BuildContext parentContext,
    BuildContext sheetContext,
    ThemeState themeState,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(sheetContext);
        _showAddHabitDialog(parentContext, themeState);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: themeState.accent.value.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeState.accent.value,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 8,
                color: themeState.accent.value,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Add New Habit',
              style: TextStyle(
                color: themeState.accent.value,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, ThemeState themeState) {
    showDialog(
      context: context,
      builder: (dialogContext) => _AddHabitDialog(themeState: themeState),
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
      return ClearStateColors.sunriseGold;
    }
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return ClearStateColors.sunriseGold;
    }
  }
}

/// Dialog for adding a new habit
class _AddHabitDialog extends ConsumerStatefulWidget {
  final ThemeState themeState;

  const _AddHabitDialog({required this.themeState});

  @override
  ConsumerState<_AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<_AddHabitDialog> {
  HabitTemplate? _selectedTemplate;
  DateTime _startDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final themeState = widget.themeState;
    final existingHabits = ref.watch(activeHabitsProvider);
    final existingIds = existingHabits.map((h) => h.id).toSet();
    
    // Filter out already added habits
    final availableTemplates = HabitTemplate.all
        .where((t) => !existingIds.contains(t.id))
        .toList();

    return AlertDialog(
      backgroundColor: themeState.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'Add New Habit',
        style: TextStyle(
          color: themeState.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: availableTemplates.isEmpty
          ? Text(
              'All available habits have been added.',
              style: TextStyle(color: themeState.textSecondary),
            )
          : SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a habit to track:',
                    style: TextStyle(
                      color: themeState.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...availableTemplates.map((template) => _buildTemplateOption(template, themeState)),
                  const SizedBox(height: 16),
                  if (_selectedTemplate != null) ...[
                    Text(
                      'Start date:',
                      style: TextStyle(
                        color: themeState.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: themeState.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: themeState.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDate(_startDate),
                              style: TextStyle(
                                color: themeState.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_outlined,
                              color: themeState.textSecondary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: TextStyle(color: themeState.textSecondary),
          ),
        ),
        if (availableTemplates.isNotEmpty && _selectedTemplate != null)
          TextButton(
            onPressed: () => _addHabit(context),
            child: Text(
              'Add',
              style: TextStyle(color: themeState.accent.value),
            ),
          ),
      ],
    );
  }

  Widget _buildTemplateOption(HabitTemplate template, ThemeState themeState) {
    final isSelected = _selectedTemplate?.id == template.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedTemplate = template),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? template.defaultThemeColor.withValues(alpha: 0.15)
              : themeState.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? template.defaultThemeColor : themeState.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              template.icon,
              color: template.defaultThemeColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.name,
                    style: TextStyle(
                      color: themeState.textPrimary,
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  Text(
                    template.description,
                    style: TextStyle(
                      color: themeState.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: template.defaultThemeColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _addHabit(BuildContext context) async {
    if (_selectedTemplate == null) return;

    final repository = ref.read(sobrietyRepositoryProvider);
    final orchestrator = ref.read(sobrietyOrchestratorProvider);

    // Create habit from template
    final habit = _selectedTemplate!.toHabit(
      startDate: _startDate,
      motivation: '',
    );

    // Save habit and start session
    await repository.saveHabit(habit);
    await orchestrator.startNewSession(
      habit.id,
      _startDate,
      scheduleNotifications: false,
    );

    // Select the newly added habit
    ref.read(habitSwitcherProvider).selectHabit(habit.id);

    if (context.mounted) {
      Navigator.pop(context);
    }
  }
}

/// Pre-built content for habit picker modal to avoid lag on first click.
/// All data is passed in as constructor arguments, no provider access during build.
class _HabitPickerContent extends StatelessWidget {
  final List<Habit> habits;
  final Habit? selectedHabit;
  final ThemeState themeState;
  final HabitSwitcher habitSwitcher;
  final VoidCallback onAddHabit;

  const _HabitPickerContent({
    required this.habits,
    required this.selectedHabit,
    required this.themeState,
    required this.habitSwitcher,
    required this.onAddHabit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
          ...habits.map((habit) => _buildHabitOption(context, habit)),
          _buildAddHabitOption(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHabitOption(BuildContext context, Habit habit) {
    final isSelected = habit.id == selectedHabit?.id;
    final habitColor = _parseColor(habit.themeColor);

    return InkWell(
      onTap: () {
        habitSwitcher.selectHabit(habit.id);
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

  Widget _buildAddHabitOption() {
    return InkWell(
      onTap: onAddHabit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: themeState.accent.value.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: themeState.accent.value,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add,
                size: 8,
                color: themeState.accent.value,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Add New Habit',
              style: TextStyle(
                color: themeState.accent.value,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) {
      return ClearStateColors.sunriseGold;
    }
    try {
      final hex = hexColor.replaceFirst('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return ClearStateColors.sunriseGold;
    }
  }
}
