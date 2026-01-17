import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/widget_config.dart';
import '../../data/repositories/sobriety_repository.dart';
import '../constants/bio_states.dart';
import '../constants/milestones.dart';
import '../constants/stoic_quotes.dart';
import '../theme/theme_provider.dart';

/// Service that prepares data for home screen widgets.
///
/// Provides methods to calculate battery progress, retrieve stoic quotes,
/// access bio-state metrics, and get milestone information based on the
/// user's current sobriety data.
class WidgetDataService {
  final SobrietyRepository _repository;

  /// Creates a [WidgetDataService] with the given [SobrietyRepository].
  const WidgetDataService(this._repository);

  /// Returns the current accent color for widgets.
  Color getAccentColor(ThemeState themeState) {
    return themeState.accent.value;
  }

  /// Calculates battery progress based on the display mode.
  ///
  /// Returns a value between 0.0 and 1.0 representing progress:
  /// - [BatteryDisplayMode.milestone]: Progress toward the next recovery milestone
  /// - [BatteryDisplayMode.goal]: Streak days as percentage of user-defined goal
  /// - [BatteryDisplayMode.daily]: Percentage of current day completed sober
  ///
  /// For [BatteryDisplayMode.goal], provide [goalDays] (defaults to 30 if null).
  double getBatteryProgress(BatteryDisplayMode mode, {int? goalDays}) {
    final days = getCurrentStreak();

    switch (mode) {
      case BatteryDisplayMode.milestone:
        return RecoveryMilestones.getProgressToNextMilestone(days);

      case BatteryDisplayMode.goal:
        final goal = goalDays ?? 30;
        if (goal <= 0) return 1.0;
        final progress = days / goal;
        return progress.clamp(0.0, 1.0);

      case BatteryDisplayMode.daily:
        return _calculateDailyProgress();
    }
  }

  /// Calculates the percentage of the current day completed sober.
  ///
  /// Returns 0.0 at midnight of sobriety start, approaching 1.0 at end of day.
  double _calculateDailyProgress() {
    final session = _repository.getActiveSession();
    if (session == null) return 0.0;

    final now = DateTime.now();
    final startDate = session.startDate;

    // If sobriety started today, calculate hours since start
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final startMidnight = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );

    if (startMidnight == todayMidnight) {
      // Started today - calculate from actual start time
      final hoursSinceStart = now.difference(startDate).inMinutes / 60.0;
      final hoursRemainingInDay = 24.0 - startDate.hour - startDate.minute / 60;
      if (hoursRemainingInDay <= 0) return 1.0;
      return (hoursSinceStart / hoursRemainingInDay).clamp(0.0, 1.0);
    }

    // Started before today - calculate from midnight
    final hoursSinceMidnight = now.hour + now.minute / 60.0;
    return (hoursSinceMidnight / 24.0).clamp(0.0, 1.0);
  }

  /// Returns the daily stoic quote appropriate for the user's recovery phase.
  ///
  /// The quote is determined by the current date and the user's sober days,
  /// ensuring the same quote is shown throughout a given day while being
  /// tailored to the recovery phase (early, growing, or strong).
  StoicQuote getStoicQuote() {
    final soberDays = getCurrentStreak();
    return StoicQuotes.getDailyQuote(
      date: DateTime.now(),
      soberDays: soberDays,
    );
  }

  /// Returns the interpolated recovery value for a bio-state metric.
  ///
  /// The [metricId] should be one of: 'gaba', 'dopamine', 'serotonin',
  /// 'sleep', 'liver', 'brain', or 'recovery' (combined index).
  ///
  /// Returns a value between 0.0 and 1.0 representing recovery progress.
  /// Returns 0.0 if the metric is not found.
  double getBioStateValue(String metricId) {
    final days = getCurrentStreak();
    final metric = BioStates.getMetric(metricId);
    return metric?.getValueForDay(days) ?? 0.0;
  }

  /// Returns the full bio-state metric object for the given ID.
  ///
  /// Useful for accessing display labels and descriptions.
  /// Returns null if the metric is not found.
  BioStateMetric? getBioStateMetric(String metricId) {
    return BioStates.getMetric(metricId);
  }

  /// Returns the current streak in days from the active sobriety session.
  ///
  /// Returns 0 if there is no active session.
  int getCurrentStreak() {
    final session = _repository.getActiveSession();
    return session?.totalDays ?? 0;
  }

  /// Returns the next recovery milestone the user is working toward.
  ///
  /// Returns null if the user has passed all defined milestones (1 year+).
  RecoveryMilestone? getNextMilestone() {
    final days = getCurrentStreak();
    return RecoveryMilestones.getNextMilestone(days);
  }

  /// Returns the current recovery milestone the user has achieved.
  RecoveryMilestone getCurrentMilestone() {
    final days = getCurrentStreak();
    return RecoveryMilestones.getCurrentMilestone(days);
  }

  /// Returns the number of days until the next milestone.
  ///
  /// Returns null if there is no next milestone.
  int? getDaysUntilNextMilestone() {
    final days = getCurrentStreak();
    final next = getNextMilestone();
    if (next == null) return null;
    return next.dayThreshold - days;
  }
}

/// Provider for [WidgetDataService].
///
/// Depends on [sobrietyRepositoryProvider] for accessing sobriety data.
final widgetDataServiceProvider = Provider<WidgetDataService>((ref) {
  final repo = ref.watch(sobrietyRepositoryProvider);
  return WidgetDataService(repo);
});
