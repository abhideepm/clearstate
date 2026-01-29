import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/sobriety_repository.dart';
import 'timer_provider.dart';

/// ID of the currently selected habit for display
final selectedHabitIdProvider = StateProvider<String?>((ref) => null);

/// All active habits - synchronous provider for instant access
/// Uses keepAlive to warm up the cache on app start
final activeHabitsProvider = Provider<List<Habit>>((ref) {
  ref.keepAlive();
  final repository = ref.watch(sobrietyRepositoryProvider);
  return repository.getAllHabits().where((h) => h.isActive).toList();
});



/// Currently selected habit (full object)
/// Returns the selected habit, or the first habit if none is selected.
final selectedHabitProvider = Provider<Habit?>((ref) {
  final selectedId = ref.watch(selectedHabitIdProvider);
  final habits = ref.watch(activeHabitsProvider);

  if (habits.isEmpty) return null;

  // If no habit is selected, just return the first one
  if (selectedId == null) {
    return habits.first;
  }

  return habits.where((h) => h.id == selectedId).firstOrNull ?? habits.first;
});

/// Stats for the currently selected habit
class HabitStats {
  final int currentStreak;
  final int longestStreak;
  final int totalSoberDays;
  final int relapseCount;

  const HabitStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalSoberDays,
    required this.relapseCount,
  });

  static const empty = HabitStats(
    currentStreak: 0,
    longestStreak: 0,
    totalSoberDays: 0,
    relapseCount: 0,
  );
}

/// Provider for current habit stats
final habitStatsProvider = Provider<HabitStats>((ref) {
  final habit = ref.watch(selectedHabitProvider);
  if (habit == null) return HabitStats.empty;

  // Current streak is calculated from the habit's start date
  final currentStreak = habit.totalDays;

  // Use the stored values from the Habit model
  // longestStreak is the max of stored value and current streak
  final longestStreak = currentStreak > habit.longestStreak
      ? currentStreak
      : habit.longestStreak;

  // totalSoberDays includes current streak plus accumulated days
  final totalSoberDays = habit.totalSoberDays + currentStreak;

  return HabitStats(
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    totalSoberDays: totalSoberDays,
    relapseCount: habit.relapseCount,
  );
});

/// Provider to switch between habits
final habitSwitcherProvider = Provider<HabitSwitcher>((ref) {
  return HabitSwitcher(ref);
});

class HabitSwitcher {
  final Ref _ref;

  HabitSwitcher(this._ref);

  void selectHabit(String habitId) {
    final habits = _ref.read(activeHabitsProvider);
    final habit = habits.where((h) => h.id == habitId).firstOrNull;
    
    // Update the selected habit ID
    _ref.read(selectedHabitIdProvider.notifier).state = habitId;
    
    if (habit != null) {
      // Update the global start date to match the selected habit
      _ref.read(sobrietyStartDateProvider.notifier).state = habit.startDate;
      
      // Update theme color based on habit's theme color
      _ref.read(themeProvider.notifier).setAccentColorFromHex(habit.themeColor);
    }
  }

  void selectNext() {
    final habits = _ref.read(activeHabitsProvider);
    final currentId = _ref.read(selectedHabitIdProvider);

    if (habits.isEmpty) return;

    final currentIndex = habits.indexWhere((h) => h.id == currentId);
    final nextIndex = (currentIndex + 1) % habits.length;
    selectHabit(habits[nextIndex].id);
  }

  void selectPrevious() {
    final habits = _ref.read(activeHabitsProvider);
    final currentId = _ref.read(selectedHabitIdProvider);

    if (habits.isEmpty) return;

    final currentIndex = habits.indexWhere((h) => h.id == currentId);
    final prevIndex = (currentIndex - 1 + habits.length) % habits.length;
    selectHabit(habits[prevIndex].id);
  }
}
