/// Centralized constants for all Hive box names and keys.
///
/// This file provides a single source of truth for Hive storage identifiers,
/// preventing typos and making refactoring easier.
abstract class HiveBoxes {
  /// Box storing the user's profile data.
  static const String userProfile = 'user_profile';

  /// Box storing sobriety session records.
  static const String sessions = 'sessions';

  /// Box storing relapse event records.
  static const String relapses = 'relapses';

  /// Box storing daily log entries.
  static const String dailyLogs = 'daily_logs';

  /// Box storing habit configurations.
  static const String habits = 'habits';

  /// Box storing app settings and configuration.
  static const String settings = 'settings';

  /// Box storing notification preferences.
  static const String notificationSettings = 'notification_settings';

  /// Box storing widget configurations.
  static const String widgetConfigs = 'widget_configs';
}

/// Keys used within the [HiveBoxes.userProfile] box.
abstract class UserProfileKeys {
  /// Key for the main user profile object.
  static const String profile = 'profile';
}

/// Keys used within the [HiveBoxes.settings] box.
abstract class SettingsKeys {
  /// Key for the database schema version.
  static const String schemaVersion = 'schema_version';

  /// Key for biometric authentication enabled state.
  static const String biometricEnabled = 'biometric_enabled';
}

/// Keys used within the [HiveBoxes.notificationSettings] box.
abstract class NotificationSettingsKeys {
  /// Key for the notification settings object.
  static const String settings = 'settings';
}
