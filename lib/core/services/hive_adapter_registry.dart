import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/habit.dart';
import '../../data/models/relapse_event.dart';
import '../../data/models/daily_log.dart';
import '../../data/models/widget_config.dart';
import '../../data/models/sobriety_session.dart';

/// Centralized Hive adapter registration to avoid scattered registration
/// and potential duplicate registration errors.
///
/// Type IDs are documented here for reference:
/// - 0: UserProfile
/// - 1: Habit
/// - 2: RelapseEvent
/// - 3: DailyLog
/// - 4: WidgetConfig
/// - 5: HabitType
/// - 6: SobrietySession
class HiveAdapterRegistry {
  static bool _isRegistered = false;

  /// Register all Hive adapters. Safe to call multiple times.
  static void registerAll() {
    if (_isRegistered) return;

    _registerAdapter<UserProfile>(0, UserProfileAdapter());
    _registerAdapter<Habit>(1, HabitAdapter());
    _registerAdapter<RelapseEvent>(2, RelapseEventAdapter());
    _registerAdapter<DailyLog>(3, DailyLogAdapter());
    _registerAdapter<WidgetConfig>(4, WidgetConfigAdapter());
    _registerAdapter<HabitType>(5, HabitTypeAdapter());
    _registerAdapter<SobrietySession>(6, SobrietySessionAdapter());

    _isRegistered = true;
  }

  static void _registerAdapter<T>(int typeId, TypeAdapter<T> adapter) {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
    }
  }

  /// Returns the type ID for a given model type name (for debugging).
  static int? getTypeId(String typeName) {
    const typeIds = {
      'UserProfile': 0,
      'Habit': 1,
      'RelapseEvent': 2,
      'DailyLog': 3,
      'WidgetConfig': 4,
      'HabitType': 5,
      'SobrietySession': 6,
    };
    return typeIds[typeName];
  }
}
