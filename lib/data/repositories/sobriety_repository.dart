import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/sobriety_session.dart';
import '../models/relapse_event.dart';
import '../models/daily_log.dart';
import '../models/widget_config.dart';
import '../../core/constants/drink_presets.dart';
import '../../core/constants/hive_boxes.dart';
import '../../core/services/encryption_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/widget_update_service.dart';
import '../../core/services/widget_data_service.dart';

class SobrietyRepository {
  static const int currentSchemaVersion = 1;

  late Box<UserProfile> _userProfileBox;
  late Box<SobrietySession> _sessionsBox;
  late Box<RelapseEvent> _relapseBox;
  late Box<DailyLog> _dailyLogBox;
  late Box _settingsBox;
  HiveAesCipher? _cipher;

  SobrietySession? _activeSessionCache;

  bool _isInitialized = false;

  /// Throws if the repository has not been initialized.
  /// Call init() before using any other methods.
  void _assertInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'SobrietyRepository not initialized. Call init() before use.',
      );
    }
  }

  Future<void> init() async {
    if (_isInitialized) return;

    // Get encryption cipher for sensitive data boxes
    _cipher = await EncryptionService.getEncryptionCipher();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SobrietySessionAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(RelapseEventAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(DailyLogAdapter());
    }

    // Open encrypted boxes for sensitive data
    _userProfileBox = await Hive.openBox<UserProfile>(
      HiveBoxes.userProfile,
      encryptionCipher: _cipher,
    );
    _sessionsBox = await Hive.openBox<SobrietySession>(
      HiveBoxes.sessions,
      encryptionCipher: _cipher,
    );
    _relapseBox = await Hive.openBox<RelapseEvent>(
      HiveBoxes.relapses,
      encryptionCipher: _cipher,
    );
    _dailyLogBox = await Hive.openBox<DailyLog>(
      HiveBoxes.dailyLogs,
      encryptionCipher: _cipher,
    );

    // Settings box is not encrypted (contains only schema version, etc.)
    _settingsBox = await Hive.openBox(HiveBoxes.settings);

    await _checkAndPerformMigration();

    _isInitialized = true;
  }

  Future<void> _checkAndPerformMigration() async {
    final int storedVersion =
        _settingsBox.get(SettingsKeys.schemaVersion, defaultValue: 0) as int;

    if (storedVersion < currentSchemaVersion) {
      await _performMigration(storedVersion, currentSchemaVersion);
      await _settingsBox.put(SettingsKeys.schemaVersion, currentSchemaVersion);
    }
  }

  Future<void> _performMigration(int from, int to) async {
    // Currently at version 1, no migrations yet.
    // Future migrations will be handled here.
  }

  /// Updates all home screen widgets with current sobriety data.
  /// Call this after any sobriety state change (session start, relapse, slip).
  /// If no active session, clears widget data to protect privacy after data wipe.
  Future<void> triggerWidgetUpdate() async {
    try {
      final widgetService = WidgetUpdateService();

      // Get widget configurations from Hive
      Box<WidgetConfig>? configBox;
      try {
        configBox = Hive.box<WidgetConfig>(HiveBoxes.widgetConfigs);
      } catch (e) {
        // Box not open, skip widget update
        debugPrint('Widget config box not open, skipping widget update');
        return;
      }

      final session = getActiveSession();

      // If no active session, clear widget data (privacy protection after data wipe)
      if (session == null) {
        await widgetService.clearAllWidgets();
        return;
      }

      final dataService = WidgetDataService(this);

      final batteryConfig = configBox.get('battery');
      final stoicConfig = configBox.get('stoic');
      final bioStateConfig = configBox.get('bioState');

      // Build widget data
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

      await widgetService.updateAllWidgets(
        data: widgetData,
        batteryConfig: batteryConfig,
        stoicConfig: stoicConfig,
        bioStateConfig: bioStateConfig,
      );
    } catch (e) {
      debugPrint('Error triggering widget update: $e');
      // Don't crash the app if widget update fails
    }
  }

  // User Profile
  UserProfile? getUserProfile() {
    _assertInitialized();
    return _userProfileBox.get(UserProfileKeys.profile);
  }

  Future<void> saveUserProfile({
    required DateTime lastDrinkDate,
    required int avgDrinksPerWeek,
    required double avgCostPerDrink,
    required String defaultDrinkType,
  }) async {
    _assertInitialized();
    final preset = DrinkPresets.getByName(defaultDrinkType);
    final profile = UserProfile(
      lastDrinkDate: lastDrinkDate,
      avgDrinksPerWeek: avgDrinksPerWeek,
      avgCostPerDrink: avgCostPerDrink,
      avgCaloriesPerDrink: preset.defaultCalories,
      defaultDrinkType: defaultDrinkType,
      onboardingComplete: true,
    );
    await _userProfileBox.put(UserProfileKeys.profile, profile);

    // Also create initial sobriety session
    await startNewSession(lastDrinkDate);
  }

  // Sessions
  SobrietySession? getActiveSession() {
    _assertInitialized();

    if (_activeSessionCache != null && _activeSessionCache!.isActive) {
      return _activeSessionCache;
    }

    final sessions = _sessionsBox.values.where((s) => s.isActive).toList();
    if (sessions.isEmpty) {
      _activeSessionCache = null;
      return null;
    }

    if (sessions.length > 1) {
      debugPrint(
        'Warning: Found ${sessions.length} active sessions, using most recent',
      );
      sessions.sort((a, b) => b.startDate.compareTo(a.startDate));
    }

    _activeSessionCache = sessions.first;
    return _activeSessionCache;
  }

  Future<void> startNewSession(
    DateTime startDate, {
    bool scheduleNotifications = true,
  }) async {
    _assertInitialized();

    final existingActive = getActiveSession();
    if (existingActive != null) {
      await endCurrentSession();
    }

    _activeSessionCache = null;

    final session = SobrietySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: startDate,
    );
    await _sessionsBox.put(session.id, session);
    _activeSessionCache = session;

    if (scheduleNotifications) {
      await NotificationService.instance.scheduleMilestoneNotifications(
        startDate,
      );
    }

    await triggerWidgetUpdate();
  }

  Future<void> endCurrentSession() async {
    _assertInitialized();
    final session = getActiveSession();
    if (session != null) {
      session.endDate = DateTime.now();
      await session.save();
    }
    _activeSessionCache = null;
  }

  // Relapses
  Future<void> logRelapse({
    required int drinksConsumed,
    required double costIncurred,
    required int caloriesConsumed,
    required String drinkType,
  }) async {
    _assertInitialized();
    final currentSession = getActiveSession();
    final streakDays = currentSession?.totalDays ?? 0;

    // Cancel pending milestone notifications before ending session
    await NotificationService.instance.cancelAllMilestoneNotifications();

    // End current session
    await endCurrentSession();

    // Log relapse event
    final relapse = RelapseEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      drinksConsumed: drinksConsumed,
      costIncurred: costIncurred,
      caloriesConsumed: caloriesConsumed,
      streakDaysLost: streakDays,
      drinkType: drinkType,
      isSlip: false,
    );
    await _relapseBox.put(relapse.id, relapse);

    // Log daily as not sober
    await logDay(DateTime.now(), false, drinksConsumed);

    // Start new session (this will schedule new notifications)
    await startNewSession(DateTime.now());
  }

  /// Log a slip (momentary incident) WITHOUT resetting the sobriety timer.
  /// Only marks the day on heatmap and records the event for analytics.
  Future<void> logSlip({
    required int drinksConsumed,
    required double costIncurred,
    required int caloriesConsumed,
    required String drinkType,
  }) async {
    _assertInitialized();
    final currentSession = getActiveSession();
    final streakDays = currentSession?.totalDays ?? 0;

    // Log slip event (does NOT end session or reset timer)
    final slip = RelapseEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      drinksConsumed: drinksConsumed,
      costIncurred: costIncurred,
      caloriesConsumed: caloriesConsumed,
      streakDaysLost: streakDays,
      drinkType: drinkType,
      isSlip: true,
    );
    await _relapseBox.put(slip.id, slip);

    // Log daily as not sober (marks day red on heatmap)
    await logDay(DateTime.now(), false, drinksConsumed);

    // Update home screen widgets to reflect slip
    await triggerWidgetUpdate();
  }

  /// Get slips (not full relapses) from the past 7 days for gentle prompt logic.
  int getSlipsThisWeek() {
    _assertInitialized();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _relapseBox.values
        .where((event) => event.isSlip && event.timestamp.isAfter(weekAgo))
        .length;
  }

  /// Convert recent slips to a relapse (user acknowledges pattern).
  /// This ends the current session and starts fresh.
  Future<void> convertSlipsToRelapse() async {
    _assertInitialized();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recentSlips = _relapseBox.values
        .where((event) => event.isSlip && event.timestamp.isAfter(weekAgo))
        .toList();

    // Calculate totals from slips
    int totalDrinks = 0;
    double totalCost = 0;
    int totalCalories = 0;
    for (final slip in recentSlips) {
      totalDrinks += slip.drinksConsumed;
      totalCost += slip.costIncurred;
      totalCalories += slip.caloriesConsumed;
    }

    // Delete the slip records (they're being merged into relapse)
    for (final slip in recentSlips) {
      await _relapseBox.delete(slip.id);
    }

    // Log as a full relapse
    final profile = getUserProfile();
    await logRelapse(
      drinksConsumed: totalDrinks,
      costIncurred: totalCost,
      caloriesConsumed: totalCalories,
      drinkType: profile?.defaultDrinkType ?? 'Other',
    );
  }

  // Daily logs for heatmap
  Future<void> logDay(DateTime date, bool isSober, [int? drinks]) async {
    _assertInitialized();
    final log = DailyLog(
      date: DateTime(date.year, date.month, date.day),
      isSober: isSober,
      drinksConsumed: drinks,
    );
    await _dailyLogBox.put(log.dateKey, log);
  }

  DailyLog? getDayLog(DateTime date) {
    _assertInitialized();
    final key = DailyLog(
      date: DateTime(date.year, date.month, date.day),
      isSober: true,
    ).dateKey;
    return _dailyLogBox.get(key);
  }

  List<DailyLog> getLogsForRange(DateTime start, DateTime end) {
    _assertInitialized();
    return _dailyLogBox.values
        .where(
          (log) =>
              log.date.isAfter(start.subtract(const Duration(days: 1))) &&
              log.date.isBefore(end.add(const Duration(days: 1))),
        )
        .toList();
  }

  // Stats
  int getTotalSoberDays() {
    _assertInitialized();
    return _dailyLogBox.values.where((log) => log.isSober).length;
  }

  int getTotalRelapses() {
    _assertInitialized();
    return _relapseBox.length;
  }

  double getTotalMoneySaved() {
    _assertInitialized();
    final profile = getUserProfile();
    if (profile == null) return 0;
    return getTotalSoberDays() * profile.avgDailySpend;
  }

  int getTotalCaloriesAvoided() {
    _assertInitialized();
    final profile = getUserProfile();
    if (profile == null) return 0;
    return (getTotalSoberDays() * profile.avgDailyCalories).round();
  }

  /// Nuclear wipe - deletes ALL user data from all boxes.
  /// This is irreversible and should only be called after user confirmation.
  /// Note: Security settings (biometric) persist across wipes by design.
  Future<void> nukeAllData() async {
    _assertInitialized();

    // Cancel all pending notifications
    await NotificationService.instance.cancelAllMilestoneNotifications();

    // Clear cache before clearing boxes
    _activeSessionCache = null;

    await _userProfileBox.clear();
    await _sessionsBox.clear();
    await _relapseBox.clear();
    await _dailyLogBox.clear();

    // Reset schema version so migrations run again if needed
    await _settingsBox.put(SettingsKeys.schemaVersion, currentSchemaVersion);
  }

  /// Full factory reset - deletes ALL data including security settings.
  Future<void> factoryReset() async {
    _assertInitialized();

    await nukeAllData();
    await _settingsBox.clear();
    await _settingsBox.put(SettingsKeys.schemaVersion, currentSchemaVersion);
    await EncryptionService.deleteEncryptionKey();
  }

  // Backup & Restore
  Map<String, dynamic> exportData() {
    _assertInitialized();
    return {
      'version': currentSchemaVersion,
      'timestamp': DateTime.now().toIso8601String(),
      'profile': _userProfileBox.get(UserProfileKeys.profile)?.toJson(),
      'sessions': _sessionsBox.values.map((s) => s.toJson()).toList(),
      'relapses': _relapseBox.values.map((r) => r.toJson()).toList(),
      'daily_logs': _dailyLogBox.values.map((l) => l.toJson()).toList(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    _assertInitialized();

    final version = data['version'] as int? ?? 0;
    if (version > currentSchemaVersion) {
      throw Exception(
        'Backup from newer app version (v$version). '
        'Please update ClearState to restore this backup.',
      );
    }

    if (!data.containsKey('profile') && !data.containsKey('sessions')) {
      throw Exception('Invalid backup file: missing required data');
    }

    _validateAllDataStructures(data);

    final previousData = exportData();

    try {
      await _importDataInternal(data);
    } catch (e) {
      try {
        await _importDataInternal(previousData);
      } catch (_) {}
      rethrow;
    }
  }

  void _validateAllDataStructures(Map<String, dynamic> data) {
    if (data['profile'] != null) {
      final profile = data['profile'] as Map<String, dynamic>;
      if (!profile.containsKey('lastDrinkDate')) {
        throw Exception('Invalid profile: missing lastDrinkDate');
      }
    }

    if (data['sessions'] != null) {
      final sessions = data['sessions'] as List;
      for (final s in sessions) {
        if (s is! Map<String, dynamic>) {
          throw Exception('Invalid session: not a map');
        }
        if (!s.containsKey('id') || !s.containsKey('startDate')) {
          throw Exception('Invalid session: missing required fields');
        }
      }
    }

    if (data['relapses'] != null) {
      final relapses = data['relapses'] as List;
      for (final r in relapses) {
        if (r is! Map<String, dynamic>) {
          throw Exception('Invalid relapse: not a map');
        }
        if (!r.containsKey('id') || !r.containsKey('timestamp')) {
          throw Exception('Invalid relapse: missing required fields');
        }
      }
    }

    if (data['daily_logs'] != null) {
      final logs = data['daily_logs'] as List;
      for (final l in logs) {
        if (l is! Map<String, dynamic>) {
          throw Exception('Invalid daily log: not a map');
        }
        if (!l.containsKey('date')) {
          throw Exception('Invalid daily log: missing date');
        }
      }
    }
  }

  Future<void> _importDataInternal(Map<String, dynamic> data) async {
    await nukeAllData();
    _activeSessionCache = null;

    if (data['profile'] != null) {
      final profile = UserProfile.fromJson(
        data['profile'] as Map<String, dynamic>,
      );
      await _userProfileBox.put(UserProfileKeys.profile, profile);
    }

    if (data['sessions'] != null) {
      final List sessions = data['sessions'] as List;
      for (final s in sessions) {
        final session = SobrietySession.fromJson(s as Map<String, dynamic>);
        await _sessionsBox.put(session.id, session);
      }
    }

    if (data['relapses'] != null) {
      final List relapses = data['relapses'] as List;
      for (final r in relapses) {
        final relapse = RelapseEvent.fromJson(r as Map<String, dynamic>);
        await _relapseBox.put(relapse.id, relapse);
      }
    }

    if (data['daily_logs'] != null) {
      final List logs = data['daily_logs'] as List;
      for (final l in logs) {
        final log = DailyLog.fromJson(l as Map<String, dynamic>);
        await _dailyLogBox.put(log.dateKey, log);
      }
    }

    await _settingsBox.put(SettingsKeys.schemaVersion, currentSchemaVersion);

    final activeSession = getActiveSession();
    if (activeSession != null) {
      await NotificationService.instance.scheduleMilestoneNotifications(
        activeSession.startDate,
      );
    }

    await triggerWidgetUpdate();
  }
}

/// Provider for SobrietyRepository.
/// In production, use via main's override with initialized instance.
/// Tests must call init() before use.
final sobrietyRepositoryProvider = Provider<SobrietyRepository>((ref) {
  return SobrietyRepository();
});
