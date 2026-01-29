import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/sobriety_repository.dart';
import '../../data/repositories/i_sobriety_repository.dart';
import '../../data/models/widget_config.dart';
import 'notification_service_interface.dart';
import 'widget_update_service.dart';
import 'widget_data_service.dart';

/// Orchestrates side-effects (notifications, widget updates) that were
/// previously mixed into the repository. This separation ensures:
/// - Repository stays focused on persistence
/// - Side-effects are testable via provider overrides
/// - Clear boundaries between data and UI concerns
class SobrietyOrchestrator {
  final ISobrietyRepository _repository;
  final INotificationService _notificationService;
  final WidgetUpdateService _widgetService;
  final WidgetDataService _dataService;

  SobrietyOrchestrator({
    required ISobrietyRepository repository,
    required INotificationService notificationService,
    required WidgetUpdateService widgetService,
    required WidgetDataService dataService,
  }) : _repository = repository,
       _notificationService = notificationService,
       _widgetService = widgetService,
       _dataService = dataService;

  ISobrietyRepository get repository => _repository;

  /// Triggers home screen widget update with current sobriety data.
  Future<void> triggerWidgetUpdate() async {
    try {
      final profile = _repository.getUserProfile();
      final habitId = profile?.selectedHabitIds.isNotEmpty == true
          ? profile!.selectedHabitIds.first
          : null;
      final session = habitId != null
          ? _repository.getActiveSession(habitId)
          : null;

      if (session == null) {
        await _widgetService.clearAllWidgets();
        return;
      }

      final batteryConfig = _repository.getWidgetConfig('battery');
      final stoicConfig = _repository.getWidgetConfig('stoic');
      final bioStateConfig = _repository.getWidgetConfig('bioState');

      final quote = _dataService.getStoicQuote();
      final bioMetric = _dataService.getBioStateMetric(
        bioStateConfig?.bioStateMetricId ?? 'gaba',
      );

      final widgetData = WidgetData(
        batteryProgress: _dataService.getBatteryProgress(
          batteryConfig?.displayMode ?? BatteryDisplayMode.milestone,
          goalDays: batteryConfig?.goalDays,
        ),
        streakDays: _dataService.getCurrentStreak(),
        stoicQuote: quote.text,
        stoicAuthor: quote.author,
        bioStateLabel: bioMetric?.stealthLabel ?? 'Recovery',
        bioStateValue: _dataService.getBioStateValue(
          bioStateConfig?.bioStateMetricId ?? 'gaba',
        ),
      );

      await _widgetService.updateAllWidgets(
        data: widgetData,
        batteryConfig: batteryConfig,
        stoicConfig: stoicConfig,
        bioStateConfig: bioStateConfig,
      );
    } catch (e) {
      debugPrint('Error triggering widget update: $e');
    }
  }

  /// Starts a new sobriety session with optional notification scheduling.
  Future<void> startNewSession(
    String habitId,
    DateTime startDate, {
    bool scheduleNotifications = true,
  }) async {
    await _repository.startNewSession(habitId, startDate: startDate);

    if (scheduleNotifications) {
      await _notificationService.cancelAllMilestoneNotifications();
      await _notificationService.scheduleMilestoneNotifications(startDate);
    }

    await triggerWidgetUpdate();
  }

  /// Logs a relapse: ends session, logs event, starts new session.
  Future<void> logRelapse(String habitId) async {
    await _notificationService.cancelAllMilestoneNotifications();

    await _repository.logRelapse(habitId);

    final activeSession = _repository.getActiveSession(habitId);
    if (activeSession != null) {
      await _notificationService.scheduleMilestoneNotifications(
        activeSession.startDate,
      );
    }

    await triggerWidgetUpdate();
  }

  /// Logs a slip without resetting the timer.
  Future<void> logSlip(String habitId) async {
    await _repository.logSlip(habitId);

    await triggerWidgetUpdate();
  }

  /// Converts recent slips to a relapse.
  Future<void> convertSlipsToRelapse(String habitId) async {
    await _notificationService.cancelAllMilestoneNotifications();

    await _repository.convertSlipsToRelapse(habitId);

    final activeSession = _repository.getActiveSession(habitId);
    if (activeSession != null) {
      await _notificationService.scheduleMilestoneNotifications(
        activeSession.startDate,
      );
    }

    await triggerWidgetUpdate();
  }

  /// Nuclear wipe - deletes all user data.
  Future<void> nukeAllData() async {
    await _notificationService.cancelAllMilestoneNotifications();
    await _repository.nukeAllData();
    await _widgetService.clearAllWidgets();
  }

  /// Full factory reset including security settings.
  Future<void> factoryReset() async {
    await _notificationService.cancelAllMilestoneNotifications();
    await _repository.factoryReset();
    await _widgetService.clearAllWidgets();
  }

  /// Clears widget data for privacy when app is locked.
  Future<void> clearWidgetsForPrivacy() async {
    await _widgetService.clearAllWidgets();
  }

  /// Imports data and schedules notifications for any active session.
  Future<void> importData(Map<String, dynamic> data) async {
    await _notificationService.cancelAllMilestoneNotifications();

    await _repository.importData(data);

    final profile = _repository.getUserProfile();
    if (profile != null && profile.selectedHabitIds.isNotEmpty) {
      final activeSession = _repository.getActiveSession(
        profile.selectedHabitIds.first,
      );
      if (activeSession != null) {
        await _notificationService.scheduleMilestoneNotifications(
          activeSession.startDate,
        );
      }
    }

    await triggerWidgetUpdate();
  }

  /// Saves user profile and starts initial session.
  Future<void> saveUserProfile({
    required List<String> selectedHabitIds,
    required DateTime lastDrinkDate,
    bool onboardingComplete = true,
  }) async {
    await _repository.saveUserProfile(
      selectedHabitIds: selectedHabitIds,
      onboardingComplete: onboardingComplete,
    );

    final profile = _repository.getUserProfile();
    if (profile != null) {
      profile.lastDrinkDate = lastDrinkDate;
      // Start trial for new users
      profile.trialStartDate ??= DateTime.now();
      await _repository.updateUserProfile(profile);
    }

    await _notificationService.scheduleMilestoneNotifications(lastDrinkDate);
    await triggerWidgetUpdate();
  }
}

/// Provider for SobrietyOrchestrator.
final sobrietyOrchestratorProvider = Provider<SobrietyOrchestrator>((ref) {
  final repository = ref.watch(sobrietyRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final widgetService = ref.watch(widgetUpdateServiceProvider);
  final dataService = ref.watch(widgetDataServiceProvider);

  return SobrietyOrchestrator(
    repository: repository,
    notificationService: notificationService,
    widgetService: widgetService,
    dataService: dataService,
  );
});
