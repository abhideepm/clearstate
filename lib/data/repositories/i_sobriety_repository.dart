import '../models/user_profile.dart';
import '../models/habit.dart';
import '../models/daily_log.dart';
import '../models/sobriety_session.dart';
import '../models/widget_config.dart';

/// Abstract interface for SobrietyRepository.
/// Enables proper mocking in tests and dependency inversion.
abstract class ISobrietyRepository {
  /// Returns true if the repository has been initialized.
  bool get isInitialized;

  /// Initialize the repository. Must be called before using any other methods.
  Future<void> init();

  // User Profile
  UserProfile? getUserProfile();
  Future<void> saveUserProfile({
    required List<String> selectedHabitIds,
    bool onboardingComplete = true,
  });
  Future<void> updateUserProfile(UserProfile profile);

  // Widget Configs
  WidgetConfig? getWidgetConfig(String key);
  Future<void> saveWidgetConfig(String key, WidgetConfig config);

  // Habits
  Habit? getHabit(String id);
  List<Habit> getAllHabits();
  Future<void> saveHabit(Habit habit);

  // Relapses
  Future<void> logRelapse(String habitId);
  Future<void> logSlip(String habitId);

  // Daily logs
  DailyLog? getDailyLog(String habitId, DateTime date);
  Future<void> logDay({
    required DateTime date,
    required String habitId,
    required bool isSober,
    int? drinks,
    int moodScore = 5,
    List<String> symptoms = const [],
  });

  // Session management
  SobrietySession? getActiveSession(String habitId);
  Future<SobrietySession> startNewSession(
    String habitId, {
    DateTime? startDate,
  });

  // Slip tracking
  int getTotalSlips(String habitId);
  int getSlipsThisWeek(String habitId);
  Future<void> convertSlipsToRelapse(String habitId);

  // Data management
  Future<void> nukeAllData();
  Future<void> factoryReset();

  // Backup & Restore
  String exportEncryptedData(String password);
  Map<String, dynamic> exportData();
  Future<void> importData(dynamic input, {String? password});
}
