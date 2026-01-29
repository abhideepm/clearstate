import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/habit.dart';
import '../models/relapse_event.dart';
import '../models/daily_log.dart';
import '../models/sobriety_session.dart';
import '../models/widget_config.dart';
import '../../core/constants/hive_boxes.dart';
import '../../core/services/encryption_service.dart';
import '../../core/services/id_generator.dart';
import '../../core/services/hive_adapter_registry.dart';
import 'i_sobriety_repository.dart';

/// Pure persistence layer for sobriety data.
/// Side-effects (notifications, widgets) are handled by SobrietyOrchestrator.
class SobrietyRepository implements ISobrietyRepository {
  static const int currentSchemaVersion = 1;

  late Box<UserProfile> _userProfileBox;
  late Box<Habit> _habitsBox;
  late Box<RelapseEvent> _relapseBox;
  late Box<DailyLog> _dailyLogBox;
  late Box<SobrietySession> _sessionsBox;
  late Box<WidgetConfig> _widgetConfigsBox;
  late Box _settingsBox;
  HiveAesCipher? _cipher;

  final Map<String, SobrietySession?> _activeSessionCache = {};

  bool _isInitialized = false;

  /// Returns true if the repository has been initialized.
  bool get isInitialized => _isInitialized;

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

    // Ensure all adapters are registered (safe to call multiple times)
    HiveAdapterRegistry.registerAll();

    // Open encrypted boxes for sensitive data
    _userProfileBox = await Hive.openBox<UserProfile>(
      HiveBoxes.userProfile,
      encryptionCipher: _cipher,
    );
    _habitsBox = await Hive.openBox<Habit>(
      HiveBoxes.habits,
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
    _sessionsBox = await Hive.openBox<SobrietySession>(
      HiveBoxes.sessions,
      encryptionCipher: _cipher,
    );

    // Widget configurations
    _widgetConfigsBox = await Hive.openBox<WidgetConfig>(
      HiveBoxes.widgetConfigs,
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

  // User Profile
  UserProfile? getUserProfile() {
    _assertInitialized();
    return _userProfileBox.get(UserProfileKeys.profile);
  }

  Future<void> saveUserProfile({
    required List<String> selectedHabitIds,
    bool onboardingComplete = true,
  }) async {
    _assertInitialized();
    final profile = UserProfile(
      selectedHabitIds: selectedHabitIds,
      onboardingComplete: onboardingComplete,
      trialStartDate: DateTime.now(), // Start 7-day trial on first profile creation
    );
    await updateUserProfile(profile);
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    _assertInitialized();
    await _userProfileBox.put(UserProfileKeys.profile, profile);
  }

  // Widget Configs
  WidgetConfig? getWidgetConfig(String key) {
    _assertInitialized();
    return _widgetConfigsBox.get(key);
  }

  Future<void> saveWidgetConfig(String key, WidgetConfig config) async {
    _assertInitialized();
    await _widgetConfigsBox.put(key, config);
  }

  // Habits
  Habit? getHabit(String id) {
    _assertInitialized();
    return _habitsBox.get(id);
  }

  List<Habit> getAllHabits() {
    _assertInitialized();
    return _habitsBox.values.toList();
  }

  Future<void> saveHabit(Habit habit) async {
    _assertInitialized();
    await _habitsBox.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    _assertInitialized();
    
    // Remove habit
    await _habitsBox.delete(id);
    
    // Remove associated sessions
    final sessionsToDelete = _sessionsBox.values
        .where((s) => s.habitId == id)
        .map((s) => s.id)
        .toList();
    for (final sessionId in sessionsToDelete) {
      await _sessionsBox.delete(sessionId);
    }
    
    // Remove associated relapses
    final relapsesToDelete = _relapseBox.values
        .where((r) => r.habitId == id)
        .map((r) => r.id)
        .toList();
    for (final relapseId in relapsesToDelete) {
      await _relapseBox.delete(relapseId);
    }
    
    // Remove associated daily logs
    final logsToDelete = _dailyLogBox.keys
        .where((k) => k.toString().startsWith('${id}_'))
        .toList();
    for (final logKey in logsToDelete) {
      await _dailyLogBox.delete(logKey);
    }
    
    // Clear session cache for this habit
    _activeSessionCache.remove(id);
  }

  // Relapses (habit-aware)
  Future<void> logRelapse(String habitId) async {
    _assertInitialized();
    final habit = getHabit(habitId);
    if (habit == null) return;

    // Update habit statistics before resetting
    final currentStreak = habit.totalDays;
    final newLongestStreak = currentStreak > habit.longestStreak
        ? currentStreak
        : habit.longestStreak;
    final newTotalSober = habit.totalSoberDays + currentStreak;
    final newRelapseCount = habit.relapseCount + 1;

    // Log relapse event
    final relapse = RelapseEvent(
      id: IdGenerator.uuid(),
      habitId: habitId,
      timestamp: DateTime.now(),
      streakDaysLost: currentStreak,
      isSlip: false,
    );
    await _relapseBox.put(relapse.id, relapse);

    // Update habit with new stats and reset start date
    final updatedHabit = habit.copyWith(
      startDate: DateTime.now(),
      longestStreak: newLongestStreak,
      totalSoberDays: newTotalSober,
      relapseCount: newRelapseCount,
    );
    await saveHabit(updatedHabit);

    // Log daily
    await logDay(
      date: DateTime.now(),
      habitId: habitId,
      isSober: false,
      moodScore: 3,
      symptoms: [],
    );
  }

  Future<void> logSlip(String habitId) async {
    _assertInitialized();

    final slip = RelapseEvent(
      id: IdGenerator.uuid(),
      habitId: habitId,
      timestamp: DateTime.now(),
      streakDaysLost: 0,
      isSlip: true,
    );
    await _relapseBox.put(slip.id, slip);

    await logDay(
      date: DateTime.now(),
      habitId: habitId,
      isSober: false,
      moodScore: 3,
      symptoms: [],
    );
  }

  double getSuccessRate(String habitId) {
    _assertInitialized();
    final habit = getHabit(habitId);
    if (habit == null) return 0.0;

    final duration = DateTime.now().difference(habit.startDate);
    final totalDays = duration.inDays + 1;

    final slips = _relapseBox.values
        .where((e) => e.habitId == habitId && e.isSlip)
        .length;

    return ((totalDays - slips) / totalDays).clamp(0.0, 1.0);
  }

  // Daily logs (habit-aware)
  DailyLog? getDailyLog(String habitId, DateTime date) {
    _assertInitialized();
    final dateKey = DateTime(date.year, date.month, date.day).toIso8601String().split('T')[0];
    return _dailyLogBox.get('${habitId}_$dateKey');
  }

  Future<void> logDay({
    required DateTime date,
    required String habitId,
    required bool isSober,
    int? drinks,
    int moodScore = 5,
    List<String> symptoms = const [],
  }) async {
    _assertInitialized();
    final log = DailyLog(
      date: DateTime(date.year, date.month, date.day),
      habitId: habitId,
      moodScore: moodScore,
      symptoms: symptoms,
      isSlip: !isSober,
      isRelapse: false,
    );
    await _dailyLogBox.put('${habitId}_${log.dateKey}', log);
  }

  int getTotalSoberDays(String habitId) {
    _assertInitialized();
    final habit = getHabit(habitId);
    if (habit == null) return 0;

    final duration = DateTime.now().difference(habit.startDate);
    final totalDays = duration.inDays;

    final nonSoberDays = _relapseBox.values
        .where((r) => r.habitId == habitId)
        .map(
          (r) => DateTime(r.timestamp.year, r.timestamp.month, r.timestamp.day),
        )
        .toSet()
        .length;

    return (totalDays - nonSoberDays).clamp(0, 100000);
  }

  // Session management
  SobrietySession? getActiveSession(String habitId) {
    _assertInitialized();

    if (_activeSessionCache.containsKey(habitId)) {
      return _activeSessionCache[habitId];
    }

    final active = _sessionsBox.values
        .where((s) => s.habitId == habitId && s.endDate == null)
        .cast<SobrietySession?>()
        .firstOrNull;

    _activeSessionCache[habitId] = active;
    return active;
  }

  Future<SobrietySession> startNewSession(
    String habitId, {
    DateTime? startDate,
  }) async {
    _assertInitialized();
    final now = startDate ?? DateTime.now();

    // End any existing active session for this habit
    final current = getActiveSession(habitId);
    if (current != null) {
      final ended = current.copyWith(endDate: now);
      await _sessionsBox.put(ended.id, ended);
    }

    final session = SobrietySession(
      id: IdGenerator.uuid(),
      habitId: habitId,
      startDate: now,
      endDate: null,
    );

    await _sessionsBox.put(session.id, session);
    _activeSessionCache[habitId] = session;

    // Keep Habit.startDate in sync with active sobriety period
    final habit = getHabit(habitId);
    if (habit != null) {
      await saveHabit(
        Habit(
          id: habit.id,
          name: habit.name,
          type: habit.type,
          themeColor: habit.themeColor,
          motivation: habit.motivation,
          startDate: now,
        ),
      );
    }

    return session;
  }

  int getTotalSlips(String habitId) {
    _assertInitialized();
    return _relapseBox.values
        .where((e) => e.habitId == habitId && e.isSlip)
        .length;
  }

  int getSlipsThisWeek(String habitId) {
    _assertInitialized();
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1)); // Monday
    return _relapseBox.values
        .where(
          (e) =>
              e.habitId == habitId &&
              e.isSlip &&
              !e.timestamp.isBefore(startOfWeek),
        )
        .length;
  }

  Future<void> convertSlipsToRelapse(String habitId) async {
    _assertInitialized();

    final now = DateTime.now();
    final habit = getHabit(habitId);

    final slips = _relapseBox.values
        .where((e) => e.habitId == habitId && e.isSlip)
        .toList();

    for (final slip in slips) {
      final updated = RelapseEvent(
        id: slip.id,
        timestamp: slip.timestamp,
        habitId: slip.habitId,
        streakDaysLost: habit == null
            ? 0
            : now.difference(habit.startDate).inDays,
        isSlip: false,
      );
      await _relapseBox.put(updated.id, updated);
    }

    // A "real relapse" resets the timer
    await startNewSession(habitId, startDate: now);
  }

  Future<void> nukeAllData() async {
    _assertInitialized();
    await _userProfileBox.clear();
    await _habitsBox.clear();
    await _relapseBox.clear();
    await _dailyLogBox.clear();
    await _sessionsBox.clear();
    _activeSessionCache.clear();
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
  String exportEncryptedData(String password) {
    _assertInitialized();
    final data = exportData();
    return EncryptionService.encryptPayload(jsonEncode(data), password);
  }

  Map<String, dynamic> exportData() {
    _assertInitialized();
    return {
      'version': currentSchemaVersion,
      'timestamp': DateTime.now().toIso8601String(),
      'profile': _userProfileBox.get(UserProfileKeys.profile)?.toJson(),
      'habits': _habitsBox.values.map((h) => h.toJson()).toList(),
      'sessions': _sessionsBox.values.map((s) => s.toJson()).toList(),
      'relapses': _relapseBox.values.map((r) => r.toJson()).toList(),
      'daily_logs': _dailyLogBox.values.map((l) => l.toJson()).toList(),
    };
  }

  Future<void> importData(dynamic input, {String? password}) async {
    _assertInitialized();

    Map<String, dynamic> data;

    if (input is String) {
      if (password == null) {
        throw Exception('Password required for encrypted backup');
      }
      final decrypted = EncryptionService.decryptPayload(input, password);
      data = jsonDecode(decrypted) as Map<String, dynamic>;
    } else if (input is Map<String, dynamic>) {
      data = input;
    } else {
      throw Exception('Invalid backup format');
    }

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
      _validateProfile(data['profile'] as Map<String, dynamic>);
    }

    if (data['sessions'] != null) {
      _validateSessions(data['sessions'] as List);
    }

    if (data['relapses'] != null) {
      _validateRelapses(data['relapses'] as List);
    }

    if (data['daily_logs'] != null) {
      _validateDailyLogs(data['daily_logs'] as List);
    }
  }

  void _validateProfile(Map<String, dynamic> profile) {
    if (!profile.containsKey('lastDrinkDate')) {
      throw Exception('Invalid profile: missing lastDrinkDate');
    }

    // Validate lastDrinkDate is parseable and reasonable
    final lastDrink = DateTime.tryParse(profile['lastDrinkDate'] as String);
    if (lastDrink == null) {
      throw Exception('Invalid profile: lastDrinkDate is not a valid date');
    }

    final now = DateTime.now();
    final minDate = DateTime(2000);
    if (lastDrink.isBefore(minDate) || lastDrink.isAfter(now)) {
      throw Exception(
        'Invalid profile: lastDrinkDate out of range (2000 to now)',
      );
    }

    // Validate numeric fields
    if (profile.containsKey('avgDrinksPerWeek')) {
      final drinks = profile['avgDrinksPerWeek'];
      if (drinks is! int || drinks < 0 || drinks > 500) {
        throw Exception('Invalid profile: avgDrinksPerWeek out of range');
      }
    }

    if (profile.containsKey('avgCostPerDrink')) {
      final cost = profile['avgCostPerDrink'];
      if ((cost is! double && cost is! int) || cost < 0 || cost > 1000) {
        throw Exception('Invalid profile: avgCostPerDrink out of range');
      }
    }
  }

  void _validateSessions(List sessions) {
    if (sessions.length > 10000) {
      throw Exception('Invalid backup: too many sessions (max 10000)');
    }

    for (final s in sessions) {
      if (s is! Map<String, dynamic>) {
        throw Exception('Invalid session: not a map');
      }
      if (!s.containsKey('id') || !s.containsKey('startDate')) {
        throw Exception('Invalid session: missing required fields');
      }

      final startDate = DateTime.tryParse(s['startDate'] as String);
      if (startDate == null) {
        throw Exception('Invalid session: startDate is not a valid date');
      }

      if (s['endDate'] != null) {
        final endDate = DateTime.tryParse(s['endDate'] as String);
        if (endDate == null) {
          throw Exception('Invalid session: endDate is not a valid date');
        }
        if (endDate.isBefore(startDate)) {
          throw Exception('Invalid session: endDate before startDate');
        }
      }
    }
  }

  void _validateRelapses(List relapses) {
    if (relapses.length > 10000) {
      throw Exception('Invalid backup: too many relapses (max 10000)');
    }

    for (final r in relapses) {
      if (r is! Map<String, dynamic>) {
        throw Exception('Invalid relapse: not a map');
      }
      if (!r.containsKey('id') || !r.containsKey('timestamp')) {
        throw Exception('Invalid relapse: missing required fields');
      }

      final timestamp = DateTime.tryParse(r['timestamp'] as String);
      if (timestamp == null) {
        throw Exception('Invalid relapse: timestamp is not a valid date');
      }

      // Validate numeric fields
      if (r.containsKey('drinksConsumed')) {
        final drinks = r['drinksConsumed'];
        if (drinks is! int || drinks < 0 || drinks > 1000) {
          throw Exception('Invalid relapse: drinksConsumed out of range');
        }
      }
    }
  }

  void _validateDailyLogs(List logs) {
    if (logs.length > 36500) {
      throw Exception('Invalid backup: too many daily logs (max 100 years)');
    }

    for (final l in logs) {
      if (l is! Map<String, dynamic>) {
        throw Exception('Invalid daily log: not a map');
      }
      if (!l.containsKey('date')) {
        throw Exception('Invalid daily log: missing date');
      }

      final date = DateTime.tryParse(l['date'] as String);
      if (date == null) {
        throw Exception('Invalid daily log: date is not a valid date');
      }
    }
  }

  Future<void> _importDataInternal(Map<String, dynamic> data) async {
    await nukeAllData();

    if (data['profile'] != null) {
      final profile = UserProfile.fromJson(
        data['profile'] as Map<String, dynamic>,
      );
      await _userProfileBox.put(UserProfileKeys.profile, profile);
    }

    if (data['habits'] != null) {
      final List habits = data['habits'] as List;
      for (final h in habits) {
        final habit = Habit.fromJson(h as Map<String, dynamic>);
        await _habitsBox.put(habit.id, habit);
      }
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
        // Use composite key to avoid data corruption and enable lookup
        await _dailyLogBox.put('${log.habitId}_${log.dateKey}', log);
      }
    }

    await _settingsBox.put(SettingsKeys.schemaVersion, currentSchemaVersion);
  }
}

/// Provider for SobrietyRepository.
/// Throws if accessed without proper initialization/override.
/// In production, override with initialized instance in main().
/// In tests, override with mock or call init() explicitly.
final sobrietyRepositoryProvider = Provider<ISobrietyRepository>((ref) {
  throw StateError(
    'sobrietyRepositoryProvider must be overridden with an initialized '
    'SobrietyRepository instance. See main.dart for production usage.',
  );
});
