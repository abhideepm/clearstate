import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/sobriety_session.dart';
import '../models/relapse_event.dart';
import '../models/daily_log.dart';
import '../../core/constants/drink_presets.dart';
import '../../core/services/notification_service.dart';

class SobrietyRepository {
  static const String userProfileBoxName = 'user_profile';
  static const String sessionsBoxName = 'sessions';
  static const String relapseBoxName = 'relapses';
  static const String dailyLogBoxName = 'daily_logs';
  static const String settingsBoxName = 'settings';

  static const int currentSchemaVersion = 1;

  late Box<UserProfile> _userProfileBox;
  late Box<SobrietySession> _sessionsBox;
  late Box<RelapseEvent> _relapseBox;
  late Box<DailyLog> _dailyLogBox;
  late Box _settingsBox;

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Note: Hive.initFlutter() should be called in main.dart before this

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

    // Open boxes
    _userProfileBox = await Hive.openBox<UserProfile>(userProfileBoxName);
    _sessionsBox = await Hive.openBox<SobrietySession>(sessionsBoxName);
    _relapseBox = await Hive.openBox<RelapseEvent>(relapseBoxName);
    _dailyLogBox = await Hive.openBox<DailyLog>(dailyLogBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);

    await _checkAndPerformMigration();

    _isInitialized = true;
  }

  Future<void> _checkAndPerformMigration() async {
    final int storedVersion =
        _settingsBox.get('schema_version', defaultValue: 0) as int;

    if (storedVersion < currentSchemaVersion) {
      await _performMigration(storedVersion, currentSchemaVersion);
      await _settingsBox.put('schema_version', currentSchemaVersion);
    }
  }

  Future<void> _performMigration(int from, int to) async {
    // Currently at version 1, no migrations yet.
    // Future migrations will be handled here.
  }

  // User Profile
  UserProfile? getUserProfile() {
    return _userProfileBox.get('profile');
  }

  Future<void> saveUserProfile({
    required DateTime lastDrinkDate,
    required int avgDrinksPerWeek,
    required double avgCostPerDrink,
    required String defaultDrinkType,
  }) async {
    final preset = DrinkPresets.getByName(defaultDrinkType);
    final profile = UserProfile(
      lastDrinkDate: lastDrinkDate,
      avgDrinksPerWeek: avgDrinksPerWeek,
      avgCostPerDrink: avgCostPerDrink,
      avgCaloriesPerDrink: preset.defaultCalories,
      defaultDrinkType: defaultDrinkType,
      onboardingComplete: true,
    );
    await _userProfileBox.put('profile', profile);

    // Also create initial sobriety session
    await startNewSession(lastDrinkDate);
  }

  // Sessions
  SobrietySession? getActiveSession() {
    final sessions = _sessionsBox.values.where((s) => s.isActive).toList();
    if (sessions.isEmpty) return null;
    return sessions.first;
  }

  Future<void> startNewSession(
    DateTime startDate, {
    bool scheduleNotifications = true,
  }) async {
    final session = SobrietySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: startDate,
    );
    await _sessionsBox.put(session.id, session);

    // Schedule milestone notifications for this session
    if (scheduleNotifications) {
      await NotificationService.instance.scheduleMilestoneNotifications(
        startDate,
      );
    }
  }

  Future<void> endCurrentSession() async {
    final session = getActiveSession();
    if (session != null) {
      session.endDate = DateTime.now();
      await session.save();
    }
  }

  // Relapses
  Future<void> logRelapse({
    required int drinksConsumed,
    required double costIncurred,
    required int caloriesConsumed,
    required String drinkType,
  }) async {
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
  }

  /// Get slips (not full relapses) from the past 7 days for gentle prompt logic.
  int getSlipsThisWeek() {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return _relapseBox.values
        .where((event) => event.isSlip && event.timestamp.isAfter(weekAgo))
        .length;
  }

  /// Convert recent slips to a relapse (user acknowledges pattern).
  /// This ends the current session and starts fresh.
  Future<void> convertSlipsToRelapse() async {
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
    final log = DailyLog(
      date: DateTime(date.year, date.month, date.day),
      isSober: isSober,
      drinksConsumed: drinks,
    );
    await _dailyLogBox.put(log.dateKey, log);
  }

  DailyLog? getDayLog(DateTime date) {
    final key =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _dailyLogBox.get(key);
  }

  List<DailyLog> getLogsForRange(DateTime start, DateTime end) {
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
    return _dailyLogBox.values.where((log) => log.isSober).length;
  }

  int getTotalRelapses() {
    return _relapseBox.length;
  }

  double getTotalMoneySaved() {
    final profile = getUserProfile();
    if (profile == null) return 0;
    return getTotalSoberDays() * profile.avgDailySpend;
  }

  int getTotalCaloriesAvoided() {
    final profile = getUserProfile();
    if (profile == null) return 0;
    return (getTotalSoberDays() * profile.avgDailyCalories).round();
  }

  /// Nuclear wipe - deletes ALL user data from all boxes.
  /// This is irreversible and should only be called after user confirmation.
  Future<void> nukeAllData() async {
    // Cancel all pending notifications
    await NotificationService.instance.cancelAllMilestoneNotifications();

    await _userProfileBox.clear();
    await _sessionsBox.clear();
    await _relapseBox.clear();
    await _dailyLogBox.clear();
  }

  // Backup & Restore
  Map<String, dynamic> exportData() {
    return {
      'version': currentSchemaVersion,
      'timestamp': DateTime.now().toIso8601String(),
      'profile': _userProfileBox.get('profile')?.toJson(),
      'sessions': _sessionsBox.values.map((s) => s.toJson()).toList(),
      'relapses': _relapseBox.values.map((r) => r.toJson()).toList(),
      'daily_logs': _dailyLogBox.values.map((l) => l.toJson()).toList(),
    };
  }

  Future<void> importData(Map<String, dynamic> data) async {
    // 1. Wipe current data
    await nukeAllData();

    // 2. Import Profile
    if (data['profile'] != null) {
      final profile = UserProfile.fromJson(
        data['profile'] as Map<String, dynamic>,
      );
      await _userProfileBox.put('profile', profile);
    }

    // 3. Import Sessions
    if (data['sessions'] != null) {
      final List sessions = data['sessions'] as List;
      for (final s in sessions) {
        final session = SobrietySession.fromJson(s as Map<String, dynamic>);
        await _sessionsBox.put(session.id, session);
      }
    }

    // 4. Import Relapses
    if (data['relapses'] != null) {
      final List relapses = data['relapses'] as List;
      for (final r in relapses) {
        final relapse = RelapseEvent.fromJson(r as Map<String, dynamic>);
        await _relapseBox.put(relapse.id, relapse);
      }
    }

    // 5. Import Daily Logs
    if (data['daily_logs'] != null) {
      final List logs = data['daily_logs'] as List;
      for (final l in logs) {
        final log = DailyLog.fromJson(l as Map<String, dynamic>);
        await _dailyLogBox.put(log.dateKey, log);
      }
    }

    // 6. Ensure schema version is updated if importing from older/newer
    await _settingsBox.put('schema_version', currentSchemaVersion);

    // 7. Reschedule notifications if there's an active session
    final activeSession = getActiveSession();
    if (activeSession != null) {
      await NotificationService.instance.scheduleMilestoneNotifications(
        activeSession.startDate,
      );
    }
  }
}

// Provider
final sobrietyRepositoryProvider = Provider<SobrietyRepository>((ref) {
  return SobrietyRepository();
});
