import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/sobriety_repository.dart';

/// Notification settings persisted via Hive.
class NotificationSettings {
  final bool enabled;

  const NotificationSettings({this.enabled = true});

  NotificationSettings copyWith({bool? enabled}) {
    return NotificationSettings(enabled: enabled ?? this.enabled);
  }

  Map<String, dynamic> toMap() => {'enabled': enabled};

  factory NotificationSettings.fromMap(Map<dynamic, dynamic> map) {
    return NotificationSettings(enabled: map['enabled'] as bool? ?? true);
  }
}

/// Manages notification settings state and persistence.
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  static const String _boxName = 'notification_settings';
  static const String _key = 'settings';

  Box? _box;
  final Ref _ref;

  NotificationSettingsNotifier(this._ref)
    : super(const NotificationSettings()) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);
    final stored = _box?.get(_key);
    if (stored != null) {
      state = NotificationSettings.fromMap(Map<dynamic, dynamic>.from(stored));
    }
  }

  /// Toggle notifications on/off.
  /// When enabled: requests permissions and schedules milestone notifications.
  /// When disabled: cancels all pending notifications.
  Future<void> toggle() async {
    final newEnabled = !state.enabled;
    state = state.copyWith(enabled: newEnabled);
    await _box?.put(_key, state.toMap());

    if (newEnabled) {
      // Request permissions and schedule notifications
      final hasPermission = await NotificationService.instance
          .requestPermissions();
      if (hasPermission) {
        final repo = _ref.read(sobrietyRepositoryProvider);
        final session = repo.getActiveSession();
        if (session != null) {
          await NotificationService.instance.scheduleMilestoneNotifications(
            session.startDate,
          );
        }
      }
    } else {
      // Cancel all pending notifications
      await NotificationService.instance.cancelAllMilestoneNotifications();
    }
  }

  /// Set enabled state directly (used during data wipe).
  Future<void> setEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _box?.put(_key, state.toMap());
  }

  /// Check if notifications are currently enabled.
  bool get isEnabled => state.enabled;
}

/// Provider for notification settings.
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      (ref) => NotificationSettingsNotifier(ref),
    );

/// Provider to check if device has notification permissions.
final hasNotificationPermissionProvider = FutureProvider<bool>((ref) async {
  return await NotificationService.instance.hasPermissions();
});
