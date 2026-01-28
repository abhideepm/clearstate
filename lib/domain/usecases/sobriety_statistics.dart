import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/i_sobriety_repository.dart';
import '../../data/repositories/sobriety_repository.dart';

/// Domain use case for calculating sobriety statistics.
/// Separates business logic from the repository layer.
class SobrietyStatistics {
  final ISobrietyRepository _repository;

  SobrietyStatistics(this._repository);

  /// Calculate success rate for a habit.
  /// Returns a value between 0.0 and 1.0.
  double getSuccessRate(String habitId) {
    final habit = _repository.getHabit(habitId);
    if (habit == null) return 0.0;

    final duration = DateTime.now().difference(habit.startDate);
    final totalDays = duration.inDays + 1;

    // Count slips by iterating through all relapses
    // Note: This requires access to internal data, so we delegate to repository
    // For now, use the repository's method until we have a proper query API
    return _calculateSuccessRate(habit, totalDays);
  }

  double _calculateSuccessRate(Habit habit, int totalDays) {
    // This is a simplified calculation
    // In a full implementation, we'd have a query method on the repository
    final slips = _repository.getTotalSlips(habit.id);
    return ((totalDays - slips) / totalDays).clamp(0.0, 1.0);
  }

  /// Get total sober days for a habit.
  int getTotalSoberDays(String habitId) {
    final habit = _repository.getHabit(habitId);
    if (habit == null) return 0;

    final duration = DateTime.now().difference(habit.startDate);
    final totalDays = duration.inDays;

    // Get count of non-sober days from slips
    final slips = _repository.getTotalSlips(habitId);

    return (totalDays - slips).clamp(0, 100000);
  }

  /// Get current streak in days.
  int getCurrentStreakDays(String habitId) {
    final session = _repository.getActiveSession(habitId);
    if (session == null) return 0;

    return DateTime.now().difference(session.startDate).inDays;
  }
}

/// Provider for SobrietyStatistics use case.
final sobrietyStatisticsProvider = Provider<SobrietyStatistics>((ref) {
  final repository = ref.watch(sobrietyRepositoryProvider);
  return SobrietyStatistics(repository);
});
