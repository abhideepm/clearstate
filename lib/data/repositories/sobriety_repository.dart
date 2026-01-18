import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_profile.dart';
import '../models/sobriety_session.dart';
import '../models/relapse_event.dart';
import '../models/daily_log.dart';
import '../../core/constants/drink_presets.dart';
import '../../core/constants/hive_boxes.dart';
import '../../core/services/encryption_service.dart';
import '../../core/services/id_generator.dart';
import '../../core/services/hive_adapter_registry.dart';

/// Pure persistence layer for sobriety data.
/// Side-effects (notifications, widgets) are handled by SobrietyOrchestrator.
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
    String currency = 'USD',
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
      currency: currency,
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

    // Repair multiple active sessions by ending all except most recent
    if (sessions.length > 1) {
      debugPrint(
        'Repairing: Found ${sessions.length} active sessions, keeping most recent',
      );
      sessions.sort((a, b) => b.startDate.compareTo(a.startDate));

      // End all but the first (most recent)
      for (int i = 1; i < sessions.length; i++) {
        sessions[i].endDate = sessions[i].startDate;
        sessions[i].save();
      }
    }

    _activeSessionCache = sessions.first;
    return _activeSessionCache;
  }

  /// Get all sessions for analytics/history.
  List<SobrietySession> getAllSessions() {
    _assertInitialized();
    return _sessionsBox.values.toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<void> startNewSession(DateTime startDate) async {
    _assertInitialized();

    final existingActive = getActiveSession();
    if (existingActive != null) {
      await endCurrentSession();
    }

    _activeSessionCache = null;

    final session = SobrietySession(
      id: IdGenerator.uuid(),
      startDate: startDate,
    );
    await _sessionsBox.put(session.id, session);
    _activeSessionCache = session;
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

  // Relapses (pure persistence - no side-effects)
  Future<void> logRelapse({
    required int drinksConsumed,
    required double costIncurred,
    required int caloriesConsumed,
    required String drinkType,
  }) async {
    _assertInitialized();
    final currentSession = getActiveSession();
    final streakDays = currentSession?.totalDays ?? 0;

    // End current session
    await endCurrentSession();

    // Log relapse event
    final relapse = RelapseEvent(
      id: IdGenerator.uuid(),
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
    _assertInitialized();
    final currentSession = getActiveSession();
    final streakDays = currentSession?.totalDays ?? 0;

    // Log slip event (does NOT end session or reset timer)
    final slip = RelapseEvent(
      id: IdGenerator.uuid(),
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
    return _relapseBox.values.where((r) => !r.isSlip).length;
  }

  int getTotalSlips() {
    _assertInitialized();
    return _relapseBox.values.where((r) => r.isSlip).length;
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
  }
}

/// Provider for SobrietyRepository.
/// Throws if accessed without proper initialization/override.
/// In production, override with initialized instance in main().
/// In tests, override with mock or call init() explicitly.
final sobrietyRepositoryProvider = Provider<SobrietyRepository>((ref) {
  throw StateError(
    'sobrietyRepositoryProvider must be overridden with an initialized '
    'SobrietyRepository instance. See main.dart for production usage.',
  );
});
