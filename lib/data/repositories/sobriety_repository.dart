import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/sobriety_session.dart';
import '../models/relapse_event.dart';
import '../models/daily_log.dart';
import '../../core/constants/drink_presets.dart';

// Re-export onboarding provider for app.dart
export '../../features/onboarding/onboarding_provider.dart';

class SobrietyRepository {
  static const String userProfileBoxName = 'user_profile';
  static const String sessionsBoxName = 'sessions';
  static const String relapseBoxName = 'relapses';
  static const String dailyLogBoxName = 'daily_logs';

  late Box<UserProfile> _userProfileBox;
  late Box<SobrietySession> _sessionsBox;
  late Box<RelapseEvent> _relapseBox;
  late Box<DailyLog> _dailyLogBox;

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

    _isInitialized = true;
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

  Future<void> startNewSession(DateTime startDate) async {
    final session = SobrietySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: startDate,
    );
    await _sessionsBox.put(session.id, session);
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

    // Start new session
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
    await _userProfileBox.clear();
    await _sessionsBox.clear();
    await _relapseBox.clear();
    await _dailyLogBox.clear();
  }
}

// Provider
final sobrietyRepositoryProvider = Provider<SobrietyRepository>((ref) {
  return SobrietyRepository();
});
