import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/sobriety_repository.dart';
import 'timer_provider.dart';

/// Provider for user profile data from the repository
final userProfileProvider = Provider((ref) {
  final repository = ref.watch(sobrietyRepositoryProvider);
  return repository.getUserProfile();
});

/// Provider for average daily spend from user profile
final avgDailySpendProvider = Provider<double>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.avgDailySpend ?? 0.0;
});

/// Provider for average daily calories from user profile
final avgDailyCaloriesProvider = Provider<double>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.avgDailyCalories ?? 0.0;
});

/// Provider for average drinks per week from user profile
final avgDrinksPerWeekProvider = Provider<int>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile?.avgDrinksPerWeek ?? 10;
});

/// Reactive provider for money saved based on elapsed duration
/// Updates every second as the timer ticks
final moneySavedProvider = Provider<double>((ref) {
  final durationAsync = ref.watch(elapsedDurationProvider);
  final avgDailySpend = ref.watch(avgDailySpendProvider);

  return durationAsync.when(
    data: (duration) {
      // Calculate based on total elapsed days (including fractional days)
      final totalDays = duration.inSeconds / 86400.0;
      return totalDays * avgDailySpend;
    },
    loading: () => 0.0,
    error: (e, s) => 0.0,
  );
});

/// Default hours per drinking session (used when user hasn't specified)
const double kDefaultHoursPerSession = 2.0;

/// Provider for hours reclaimed (freed from drinking activities)
/// Estimates 2 hours per drinking session as default
final hoursFreeProvider = Provider<double>((ref) {
  final durationAsync = ref.watch(elapsedDurationProvider);
  final avgDrinksPerWeek = ref.watch(avgDrinksPerWeekProvider);

  return durationAsync.when(
    data: (duration) {
      // Estimate drinking sessions per week (assume 1 session = 2-3 drinks avg)
      final drinksPerSession = 2.5;
      final sessionsPerWeek = avgDrinksPerWeek / drinksPerSession;
      final sessionsPerDay = sessionsPerWeek / 7.0;

      // Calculate total hours saved
      final totalDays = duration.inSeconds / 86400.0;
      final totalSessions = totalDays * sessionsPerDay;
      return totalSessions * kDefaultHoursPerSession;
    },
    loading: () => 0.0,
    error: (e, s) => 0.0,
  );
});

/// Provider for current streak in days (whole days only)
final currentStreakDaysProvider = Provider<int>((ref) {
  final durationAsync = ref.watch(elapsedDurationProvider);

  return durationAsync.when(
    data: (duration) => duration.inDays,
    loading: () => 0,
    error: (e, s) => 0,
  );
});

/// ROI data class for consolidated metrics
class RoiMetrics {
  final double moneySaved;
  final double hoursFree;
  final int streakDays;

  const RoiMetrics({
    required this.moneySaved,
    required this.hoursFree,
    required this.streakDays,
  });
}

/// Combined provider for all ROI metrics
final roiMetricsProvider = Provider<RoiMetrics>((ref) {
  return RoiMetrics(
    moneySaved: ref.watch(moneySavedProvider),
    hoursFree: ref.watch(hoursFreeProvider),
    streakDays: ref.watch(currentStreakDaysProvider),
  );
});
