import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/hive_boxes.dart';
import '../../core/services/notification_service.dart';
import '../../data/repositories/sobriety_repository.dart';

/// Notification settings persisted via Hive.
class NotificationSettings {
  final bool enabled;
  final bool initialized;
  final bool permissionDenied;

  const NotificationSettings({
    this.enabled = true,
    this.initialized = false,
    this.permissionDenied = false,
  });

  NotificationSettings copyWith({
    bool? enabled,
    bool? initialized,
    bool? permissionDenied,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      initialized: initialized ?? this.initialized,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }

  Map<String, dynamic> toMap() => {'enabled': enabled};

  factory NotificationSettings.fromMap(Map<dynamic, dynamic> map) {
    return NotificationSettings(
      enabled: map['enabled'] as bool? ?? true,
      initialized: true,
    );
  }
}

/// Manages notification settings state and persistence.
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  Box? _box;
  final Ref _ref;

  NotificationSettingsNotifier(this._ref)
    : super(const NotificationSettings()) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(HiveBoxes.notificationSettings);
    final stored = _box?.get(NotificationSettingsKeys.settings);
    if (stored != null) {
      state = NotificationSettings.fromMap(Map<dynamic, dynamic>.from(stored));
    } else {
      state = state.copyWith(initialized: true);
    }
  }

  /// Toggle notifications on/off.
  /// When enabled: requests permissions and schedules milestone notifications.
  /// When disabled: cancels all pending notifications.
  Future<void> toggle() async {
    // Don't allow toggle until initialized
    if (!state.initialized) return;

    final targetEnabled = !state.enabled;

    if (targetEnabled) {
      // Request permissions first
      final hasPermission = await NotificationService.instance
          .requestPermissions();
      if (!hasPermission) {
        // Keep disabled and mark permission denied
        state = state.copyWith(enabled: false, permissionDenied: true);
        await _box?.put(NotificationSettingsKeys.settings, state.toMap());
        return;
      }

      // Permission granted, enable notifications
      state = state.copyWith(enabled: true, permissionDenied: false);
      await _box?.put(NotificationSettingsKeys.settings, state.toMap());

      // Schedule notifications for active session
      final repo = _ref.read(sobrietyRepositoryProvider);
      final session = repo.getActiveSession();
      if (session != null) {
        await NotificationService.instance.scheduleMilestoneNotifications(
          session.startDate,
        );
      }
    } else {
      // Disable notifications
      state = state.copyWith(enabled: false);
      await _box?.put(NotificationSettingsKeys.settings, state.toMap());
      await NotificationService.instance.cancelAllMilestoneNotifications();
    }
  }

  /// Set enabled state directly (used during data wipe).
  Future<void> setEnabled(bool enabled) async {
    if (!state.initialized) return;
    state = state.copyWith(enabled: enabled);
    await _box?.put(NotificationSettingsKeys.settings, state.toMap());
  }

  /// Clear the permission denied flag (e.g., after user opens settings).
  void clearPermissionDenied() {
    state = state.copyWith(permissionDenied: false);
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
final hasNotificationPermissionProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  return await NotificationService.instance.hasPermissions();
});
