import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/sobriety_repository.dart';

/// ID of the currently selected habit for display
final selectedHabitIdProvider = StateProvider<String?>((ref) => null);

/// All active habits for the user
final activeHabitsProvider = Provider<List<Habit>>((ref) {
  final repository = ref.watch(sobrietyRepositoryProvider);
  return repository.getAllHabits().where((h) => h.isActive).toList();
});

/// Currently selected habit (full object)
final selectedHabitProvider = Provider<Habit?>((ref) {
  final selectedId = ref.watch(selectedHabitIdProvider);
  final habits = ref.watch(activeHabitsProvider);

  if (selectedId == null && habits.isNotEmpty) {
    // Auto-select first habit if none selected
    Future.microtask(() {
      ref.read(selectedHabitIdProvider.notifier).state = habits.first.id;
    });
    return habits.first;
  }

  return habits.where((h) => h.id == selectedId).firstOrNull;
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

  final currentStreak = habit.totalDays;
  final totalSoberDays = habit.totalDays;

  return HabitStats(
    currentStreak: currentStreak,
    longestStreak: currentStreak, // TODO: Track longest streak in Habit model
    totalSoberDays: totalSoberDays,
    relapseCount: 0, // TODO: Add getRelapseCount method
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
    _ref.read(selectedHabitIdProvider.notifier).state = habitId;
  }

  void selectNext() {
    final habits = _ref.read(activeHabitsProvider);
    final currentId = _ref.read(selectedHabitIdProvider);

    if (habits.isEmpty) return;

    final currentIndex = habits.indexWhere((h) => h.id == currentId);
    final nextIndex = (currentIndex + 1) % habits.length;
    _ref.read(selectedHabitIdProvider.notifier).state = habits[nextIndex].id;
  }

  void selectPrevious() {
    final habits = _ref.read(activeHabitsProvider);
    final currentId = _ref.read(selectedHabitIdProvider);

    if (habits.isEmpty) return;

    final currentIndex = habits.indexWhere((h) => h.id == currentId);
    final prevIndex = (currentIndex - 1 + habits.length) % habits.length;
    _ref.read(selectedHabitIdProvider.notifier).state = habits[prevIndex].id;
  }
}
