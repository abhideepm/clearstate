import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/repositories/sobriety_repository.dart';
import '../../data/models/widget_config.dart';
import '../../core/constants/hive_boxes.dart';
import 'notification_service_interface.dart';
import 'widget_update_service.dart';
import 'widget_data_service.dart';

/// Orchestrates side-effects (notifications, widget updates) that were
/// previously mixed into the repository. This separation ensures:
/// - Repository stays focused on persistence
/// - Side-effects are testable via provider overrides
/// - Clear boundaries between data and UI concerns
class SobrietyOrchestrator {
  final SobrietyRepository _repository;
  final INotificationService _notificationService;
  final WidgetUpdateService _widgetService;

  SobrietyOrchestrator({
    required SobrietyRepository repository,
    required INotificationService notificationService,
    required WidgetUpdateService widgetService,
  }) : _repository = repository,
       _notificationService = notificationService,
       _widgetService = widgetService;

  SobrietyRepository get repository => _repository;

  /// Triggers home screen widget update with current sobriety data.
  /// If no active session, clears widget data to protect privacy.
  Future<void> triggerWidgetUpdate() async {
    try {
      Box<WidgetConfig>? configBox;
      try {
        configBox = Hive.box<WidgetConfig>(HiveBoxes.widgetConfigs);
      } catch (e) {
        debugPrint('Widget config box not open, skipping widget update');
        return;
      }

      final session = _repository.getActiveSession();

      // If no active session, clear widget data (privacy protection)
      if (session == null) {
        await _widgetService.clearAllWidgets();
        return;
      }

      final dataService = WidgetDataService(_repository);

      final batteryConfig = configBox.get('battery');
      final stoicConfig = configBox.get('stoic');
      final bioStateConfig = configBox.get('bioState');

      final quote = dataService.getStoicQuote();
      final bioMetric = dataService.getBioStateMetric(
        bioStateConfig?.bioStateMetricId ?? 'gaba',
      );

      final widgetData = WidgetData(
        batteryProgress: dataService.getBatteryProgress(
          batteryConfig?.displayMode ?? BatteryDisplayMode.milestone,
          goalDays: batteryConfig?.goalDays,
        ),
        streakDays: dataService.getCurrentStreak(),
        stoicQuote: quote.text,
        stoicAuthor: quote.author,
        bioStateLabel: bioMetric?.stealthLabel ?? 'Recovery',
        bioStateValue: dataService.getBioStateValue(
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
    DateTime startDate, {
    bool scheduleNotifications = true,
  }) async {
    await _repository.startNewSession(startDate);

    if (scheduleNotifications) {
      // Cancel existing notifications before scheduling new ones
      await _notificationService.cancelAllMilestoneNotifications();
      await _notificationService.scheduleMilestoneNotifications(startDate);
    }

    await triggerWidgetUpdate();
  }

  /// Logs a relapse: cancels notifications, ends session, logs event,
  /// starts new session with fresh notifications.
  Future<void> logRelapse({
    required int drinksConsumed,
    required double costIncurred,
    required int caloriesConsumed,
    required String drinkType,
  }) async {
    // Cancel pending notifications before ending session
    await _notificationService.cancelAllMilestoneNotifications();

    await _repository.logRelapse(
      drinksConsumed: drinksConsumed,
      costIncurred: costIncurred,
      caloriesConsumed: caloriesConsumed,
      drinkType: drinkType,
    );

    // Schedule new notifications for the fresh session
    final activeSession = _repository.getActiveSession();
    if (activeSession != null) {
      await _notificationService.scheduleMilestoneNotifications(
        activeSession.startDate,
      );
    }

    await triggerWidgetUpdate();
  }

  /// Logs a slip without resetting the timer, updates widgets.
  Future<void> logSlip({
    required int drinksConsumed,
    required double costIncurred,
    required int caloriesConsumed,
    required String drinkType,
  }) async {
    await _repository.logSlip(
      drinksConsumed: drinksConsumed,
      costIncurred: costIncurred,
      caloriesConsumed: caloriesConsumed,
      drinkType: drinkType,
    );

    await triggerWidgetUpdate();
  }

  /// Converts recent slips to a relapse (user acknowledges pattern).
  Future<void> convertSlipsToRelapse() async {
    await _notificationService.cancelAllMilestoneNotifications();

    await _repository.convertSlipsToRelapse();

    final activeSession = _repository.getActiveSession();
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
    // Cancel existing notifications before importing new data
    await _notificationService.cancelAllMilestoneNotifications();

    await _repository.importData(data);

    final activeSession = _repository.getActiveSession();
    if (activeSession != null) {
      await _notificationService.scheduleMilestoneNotifications(
        activeSession.startDate,
      );
    }

    await triggerWidgetUpdate();
  }

  /// Saves user profile and starts initial session.
  Future<void> saveUserProfile({
    required DateTime lastDrinkDate,
    required int avgDrinksPerWeek,
    required double avgCostPerDrink,
    required String defaultDrinkType,
    String currency = 'USD',
  }) async {
    await _repository.saveUserProfile(
      lastDrinkDate: lastDrinkDate,
      avgDrinksPerWeek: avgDrinksPerWeek,
      avgCostPerDrink: avgCostPerDrink,
      defaultDrinkType: defaultDrinkType,
      currency: currency,
    );

    await _notificationService.scheduleMilestoneNotifications(lastDrinkDate);
    await triggerWidgetUpdate();
  }
}

/// Provider for SobrietyOrchestrator.
/// Depends on repository, notification service, and widget service.
final sobrietyOrchestratorProvider = Provider<SobrietyOrchestrator>((ref) {
  final repository = ref.watch(sobrietyRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final widgetService = ref.watch(widgetUpdateServiceProvider);

  return SobrietyOrchestrator(
    repository: repository,
    notificationService: notificationService,
    widgetService: widgetService,
  );
});
