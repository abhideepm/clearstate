import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'notification_constants.dart';
import 'notification_service_interface.dart';

/// Handles scheduling and cancellation of milestone notifications.
/// Notifications fire exactly when users hit sobriety milestones,
/// creating engagement even when the app is closed.
class NotificationService implements INotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize the notification plugin and timezone data.
  /// Call this once in main.dart before using any other methods.
  @override
  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  /// Handle notification taps (user opens notification)
  void _onNotificationTap(NotificationResponse response) {
    // Currently just opens the app. Could deep-link to timeline in future.
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions from the user.
  /// Returns true if permissions granted.
  @override
  Future<bool> requestPermissions() async {
    try {
      // Android 13+ requires explicit permission request
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        if (granted != true) return false;

        // Also request exact alarm permission for precise scheduling
        await androidPlugin.requestExactAlarmsPermission();
      }

      // iOS permission request
      final iosPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: false, // Silent with vibration
        );
        return granted ?? false;
      }

      return true;
    } catch (e) {
      debugPrint('NotificationService: Error requesting permissions: $e');
      return false;
    }
  }

  /// Check if notification permissions are granted.
  /// Note: iOS permission state can become stale if changed in Settings.
  @override
  Future<bool> hasPermissions() async {
    try {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        return await androidPlugin.areNotificationsEnabled() ?? false;
      }

      // iOS: assume granted if we got this far (checked during request)
      // Note: User can revoke in Settings; this may be stale.
      return true;
    } catch (e) {
      debugPrint('NotificationService: Error checking permissions: $e');
      return false;
    }
  }

  /// Schedule notifications for all future milestones based on session start.
  /// Only schedules milestones that haven't been reached yet.
  @override
  Future<void> scheduleMilestoneNotifications(DateTime sessionStartDate) async {
    if (!_isInitialized) {
      debugPrint('NotificationService: Not initialized, skipping schedule');
      return;
    }

    try {
      final now = DateTime.now();
      final daysSober = now.difference(sessionStartDate).inDays;

      for (final milestone in NotificationConstants.milestoneNotifications) {
        // Skip milestones already achieved
        if (daysSober >= milestone.dayThreshold) continue;

        final scheduledTime = _calculateMilestoneDateTime(
          sessionStartDate,
          milestone.dayThreshold,
        );

        // Don't schedule if somehow in the past
        if (scheduledTime.isBefore(now)) continue;

        await _scheduleNotification(
          id: milestone.notificationId,
          title: milestone.title,
          body: milestone.body,
          scheduledTime: scheduledTime,
        );

        debugPrint(
          'Scheduled: ${milestone.title} for $scheduledTime (ID: ${milestone.notificationId})',
        );
      }
    } catch (e) {
      debugPrint('NotificationService: Error scheduling notifications: $e');
    }
  }

  /// Calculate the exact DateTime when a milestone will be reached.
  /// Milestone triggers at the same time of day as the session started.
  DateTime _calculateMilestoneDateTime(DateTime startDate, int dayThreshold) {
    return startDate.add(Duration(days: dayThreshold));
  }

  /// Schedule a single notification.
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        NotificationConstants.channelId,
        NotificationConstants.channelName,
        channelDescription: NotificationConstants.channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: false, // Silent
        enableVibration: true, // With vibration
        vibrationPattern: Int64List.fromList([
          0,
          250,
          100,
          250,
        ]), // Subtle pattern
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility
            .private, // Keep content private on lock screen
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false, // Silent
      ),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'milestone_$id',
    );
  }

  /// Cancel all pending milestone notifications.
  /// Call this on relapse, data wipe, or when user disables notifications.
  @override
  Future<void> cancelAllMilestoneNotifications() async {
    try {
      for (final id in NotificationConstants.allNotificationIds) {
        await _plugin.cancel(id);
      }
      debugPrint('Cancelled all milestone notifications');
    } catch (e) {
      debugPrint('NotificationService: Error cancelling notifications: $e');
    }
  }

  /// Cancel a specific milestone notification by ID.
  @override
  Future<void> cancelNotificationById(int id) async {
    try {
      await _plugin.cancel(id);
    } catch (e) {
      debugPrint('NotificationService: Error cancelling notification $id: $e');
    }
  }

  /// Get list of pending notifications (for debugging).
  @override
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _plugin.pendingNotificationRequests();
    } catch (e) {
      debugPrint(
        'NotificationService: Error getting pending notifications: $e',
      );
      return [];
    }
  }
}
